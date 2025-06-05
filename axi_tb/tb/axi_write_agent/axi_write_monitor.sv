//----------------------------------------------------------------
// AXI Write Monitor
// - Inherits from axi_monitor
// - Samples only AW, W and B channel
// - Publishes observed write transactions via mon_ap
//----------------------------------------------------------------

class axi_write_monitor extends axi_monitor;
    `uvm_component_utils(axi_write_monitor)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //Overriden run_phase to monitor only write channels
    task run_phase(uvm_phase phase);
        fork
            monitor_write_channel(); //Inherited from axi_monitor
        join
    endtask

endclass

/* ✅ Summary
Feature	                                   Description
Inherits from axi_monitor	   Reuses config, virtual interface, analysis port
run_phase() override	       Disables read logic — monitors only write
monitor_write_channel()	       Sampled from base — no rewrite needed */