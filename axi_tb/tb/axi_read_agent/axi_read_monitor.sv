//----------------------------------------------------------------
// AXI Read Monitor
// - Inherits from axi_monitor
// - Samples only AR and R channel
// - Publishes observed read transactions via mon_ap
//----------------------------------------------------------------

class axi_read_monitor extends axi_monitor;
    `uvm_component_utils(axi_read_monitor)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //Overriden run_phase to monitor only read channels
    task run_phase(uvm_phase phase);
        fork
            monitor_read_channel(); //Inherited from axi_monitor
        join
    endtask

endclass

/* ✅ Summary
Feature	                                   Description
Inherits from axi_monitor	   Reuses config, virtual interface, analysis port
run_phase() override	       Disables write logic — monitors only read
monitor_read_channel()	       Sampled from base — no reread needed */