/* | Feature                                        | Status |
| ---------------------------------------------- | ------ |
| `reset_if` via `uvm_config_db`                 | ✅ Yes  |
| Skip sampling during reset                     | ✅ Yes  |
| Functional coverage guarded by reset           | ✅ Yes  |
| Analysis port `write()` only called post-reset | ✅ Yes  | */

// Update: Addition of functional coverage
//----------------------------------------------------------------
// AXI Monitor
// - Passively samples DUT signals via virtual interface
// - Captures both read and write transactions
// - Publishes transactions via analysis port
//----------------------------------------------------------------

class axi_monitor extends uvm_monitor;
 `uvm_component_utils(axi_monitor)
    //Virtual interface handle
    virtual axi_if   vif;
    virtual reset_if rst_if;

    //Analysis port to broadcast observed transactions
    uvm_analysis_port #(axi_transaction) mon_ap;

    //Latest sampled transaction(used by covergroup)
    axi_transaction tr_cov;

    //Covergroup declaration
    covergroup cg_axi_transaction @(posedge vif.ACLK);
        coverpoint tr_cov.txn_type {
            bins write = {AXI_WRITE};
            bins read  = {AXI_READ};
        }

        coverpoint tr_cov.addr {
            bins low_range = {[32'h0000_0000 : 32'h0000_001F]}; //[0 : 31]
            bins mid_range = {[32'h0000_0020 : 32'h0000_00BF]}; //[32 : 191]
            bins mid_range = {[32'h0000_00C0 : 32'h0000_00FF]}; //[192 : 255]
        }

        coverpoint tr_cov.rep{
            bins okay    = {2'b00};
            bins slverr  = {2'b10};
            bins decerr  = {2'b11};
        }

        cross txn_type, addr;
        cross txn_type, resp;
    endgroup

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction

    //Build phase: get virtual interface from config_db
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
        `uvm_fatal("AXI_MONITOR", "Virtual interface not found")

        if(!uvm_config_db#(virtual reset_if)::get(this, "", "rst_if", rst_if))
        `uvm_fatal("AXI_MONITOR", "Reset interface not found")

        cg_axi_transaction = new();
        
    endfunction

    //Run phase: Launch forked monitors
    task run_phase(uvm_phase phase);
        fork
            monitor_write_channel();
            monitor_read_channel();
        join
    endtask

//----------------------------------------------------------------
// Monitor AXI Write channel
//----------------------------------------------------------------
task monitor_write_channel();
    axi_transaction tr;

    forever begin
        //Wait for write address handshake
        @(posedge vif.ACLK);
        if(!rst_if.rst_n) continue;  //If we are in reset, skip this cycle

        if (vif.AWVALID && vif.AWREADY) begin
        tr = axi_transaction::type_id::create("tr", this);
        tr.txn_type = axi_transaction::AXI_WRITE;
        tr.addr = vif.AWADDR;
        end else continue;

        //Wait for Write Data handshake
        @(posedge vif.ACLK); 
         if(!rst_if.rst_n) continue;

        if (vif.WVALID && vif.WREADY)
        tr.data = vif.WDATA;

        //Wait for response
        @(posedge vif.ACLK);
        if(!rst_if.rst_n) continue;

         if (vif.BVALID && vif.BREADY);
        tr.resp = vif.BRESP;

        `uvm_info("AXI_MON_WRITE", $sformatf("Sample write: %s",tr.convert2string()), UVM_MEDIUM)

        //Send transaction to scoreboard
        mon_ap.write(tr);
        
        tr_cov = tr;         //assign to covergroup-sampled variable
        cg_axi_transaction.sample();
    end
endtask

//----------------------------------------------------------------
// Monitor AXI Read channel
//----------------------------------------------------------------
task monitor_read_channel();
    axi_transaction tr;

    forever begin
        //Wait for read address handshake
        @(posedge vif.ACLK);
        if(!rst_if.rst_n) continue;

         (vif.ARVALID && vif.ARREADY) begin
        tr = axi_transaction::type_id::create("tr", this);
        tr.txn_type = axi_transaction::AXI_READ;
        tr.addr = vif.ARADDR;
         end else continue;

        //Wait for Read Data handshake
        @(posedge vif.ACLK)
        if(!rst_if.rst_n) continue;
         if (vif.RVALID && vif.RREADY) begin
        tr.data = vif.RDATA;
        tr.resp = vif.RRESP;


        `uvm_info("AXI_MON_READ", $sformatf("Sample read: %s",tr.convert2string()), UVM_MEDIUM)

        //Send transaction to scoreboard
        mon_ap.write(tr);

        tr_cov = tr;         //assign to covergroup-sampled variable
        cg_axi_transaction.sample();
        end
        
    end
endtask

endclass

/* In production-grade environments (Qualcomm, Intel, Apple, ARM, etc.), the preferred approach is:

✔️ Modify the axi_monitor to ignore or filter out transactions during reset
✅ Why This Is Preferred in Industry
Reason	Why It Matters
✅ Prevents false scoreboard mismatches	If the monitor reports a transaction during reset, but DUT doesn’t act on it,
 scoreboard sees a mismatch.
✅ Keeps coverage accurate	You don’t want coverage bins falsely triggered during reset conditions.
✅ Makes the testbench reset-aware	If your driver pauses during reset, your monitor must align — or else you get 
inconsistent behavior.
✅ Supports clean reset recovery tests	Lets you verify that post-reset behavior is correct, without polluting logs 
or coverage from junk transactions. */