//----------------------------------------------------------------
// AXI Monitor
// - Passively samples DUT signals via virtual interface
// - Captures both read and write transactions
// - Publishes transactions via analysis port
//----------------------------------------------------------------

class axi_monitor extends uvm_monitor;
 `uvm_component_utils(axi_monitor)
    //Virtual interface handle
    virtual axi_if vif;

    //Analysis port to broadcast observed transactions
    uvm_analysis_port #(axi_transaction) mon_ap;

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
        @(posedge vif.ACLK iff (vif.AWVALID && vif.AWREADY));
        tr = axi_transaction::type_id::create("tr", this);
        tr.txn_type = axi_transaction::AXI_WRITE;
        tr.addr = vif.AWADDR;

        //Wait for Write Data handshake
        @(posedge vif.ACLK iff (vif.WVALID && vif.WREADY));
        tr.data = vif.WDATA;

        //Wait for response
        @(posedge vif.ACLK iff (vif.BVALID && vif.BREADY));
        tr.resp = vif.BRESP;

        `uvm_info("AXI_MON_WRITE", $sformatf("Sample write: %s",tr.convert2string()), UVM_MEDIUM)

        //Send transaction to scoreboard
        mon_ap.write(tr);
        
    end
endtask

//----------------------------------------------------------------
// Monitor AXI Read channel
//----------------------------------------------------------------
task monitor_read_channel();
    axi_transaction tr;

    forever begin
        //Wait for read address handshake
        @(posedge vif.ACLK iff (vif.ARVALID && vif.ARREADY));
        tr = axi_transaction::type_id::create("tr", this);
        tr.txn_type = axi_transaction::AXI_READ;
        tr.addr = vif.ArADDR;

        //Wait for Read Data handshake
        @(posedge vif.ACLK iff (vif.RVALID && vif.RREADY));
        tr.data = vif.RDATA;
        tr.resp = vif.RRESP;


        `uvm_info("AXI_MON_READ", $sformatf("Sample read: %s",tr.convert2string()), UVM_MEDIUM)

        //Send transaction to scoreboard
        mon_ap.write(tr);
        
    end
endtask

endclass