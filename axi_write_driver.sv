//----------------------------------------------------------------
// AXI Write Driver
// - Inherits from axi_driver
// - Enforces write-only transaction handling
// - Reuses drive_write() logic from base driver
//----------------------------------------------------------------

class axi_write_driver extends axi_driver;
    `uvm_component_utils(axi_write_driver)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //Overridden run_phase: write_only logic
    task run_phase(uvm_phase phase);
        axi_transaction tr;

        forever begin
            //Fetch transaction from sequencer
            seq_item_port.get_next_item(tr);

             //Enforce transaction type
             if(tr.txn_type != axi_transaction::AXI_WRITE)
               `uvm_fatal("AXI_WRITE_DRV", $sformatf("Recieved non-write transaction: %s", tr.convert2string()));

             //Drive write transaction (inherited method)
             drive_write(tr);
               
            seq_item_port.item_done();
        end
    endtask
endclass