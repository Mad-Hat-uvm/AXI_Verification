//----------------------------------------------------------------
// AXI Read Driver
// - Inherits from axi_driver
// - Enforces read-only transaction handling
// - Reuses drive_read() logic from base driver
//----------------------------------------------------------------

class axi_read_driver extends axi_driver;
    `uvm_component_utils(axi_read_driver)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //Overridden run_phase: read_only logic
    task run_phase(uvm_phase phase);
        axi_transaction tr;

        forever begin
            //Fetch transaction from sequencer
            seq_item_port.get_next_item(tr);

             //Enforce transaction type
             if(tr.txn_type != axi_transaction::AXI_READ)
               `uvm_fatal("AXI_READ_DRV", $sformatf("Recieved non_read transaction: %s", tr.convert2string()));

             //Drive_read transaction (inherited method)
             drive_read(tr);
               
            seq_item_port.item_done();
        end
    endtask
endclass

/* ✅ Summary
       Feature	                                       Purpose
Inherits drive_read()	                    Uses shared_read-driving logic
Enforces AXI_READ	                        Fails fast if misuse happens
Overrides run_phase()	                    Tailors to_read-only behavior */

