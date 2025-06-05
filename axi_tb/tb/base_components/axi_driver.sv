//----------------------------------------------------------------
// AXI Driver
// - Drives transaction from the sequencer onto the AXI Interface
// - Handles both write and read transfers (AXI-Lite behavior)
//----------------------------------------------------------------

class axi_driver extends uvm_driver #(axi_transaction);
    `uvm_component_utils(axi_driver)

    //Virtual interface handle
    virtual axi_if vif;

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //Build phase: get virtual interface
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
          `uvm_fatal("AXI_DRV", "Virtual interface not found for comfig DB")
    endfunction

    //Run phase: Drive Axi transactions
    task run_phase(uvm_phase phase);
        axi_transaction tr;

        forever begin
            //fetch next transaction from sequencer
            seq_item_port.get_next_item(tr);
             if(tr.txn_type == axi_transaction::AXI_WRITE)
              drive_write(tr);
             else
              drive_read(tr);

            seq_item_port.item_done(); //Notify sequencer
        end
    endtask

//---------------------------------------------------------
//Task: Drive AXI-Lite Write
//---------------------------------------------------------
    task drive_write(axi_transaction tr);
        //Drive write address
        vif.AWADDR  <= tr.addr;
        vif.AWVALID <= 1;
        wait (vif.AWREADY);
        vif.AWVALID <= 0;

        //Drive write data
        vif.WDATA   <= tr.data;
        vif.WVALID  <= 1;
        wait (vif.WREADY);
        vif.WVALID  <= 0;

        //Wait for write response
        vif.BREADY  <= 1;
        wait (vif.BVALID);
        tr.resp <= vif.BRESP;
        vif.BREADY  <= 0;

    `uvm_info("AXI_WRITE_DRV", $sformatf("Write: %s", tr.convert2string()), UVM_MEDIUM)
endtask

//---------------------------------------------------------
//Task: Drive AXI-Lite read
//---------------------------------------------------------
task drive_read(axi_transaction tr);
    //Drive read address
    vif.ARADDR  <= tr.addr;
    vif.ARVALID <= 1;
    wait (vif.ARREADY);
    vif.ARVALID <= 0;

    //Wait for read data
    vif.RREADY  <= 1;
    wait (vif.RVALID);
    tr.data <= vif.RDATA;
    tr.resp <= vif.RRESP;
    vif.RREADY  <= 0;

`uvm_info("AXI_READ_DRV", $sformatf("Read: %s", tr.convert2string()), UVM_MEDIUM)
endtask

endclass