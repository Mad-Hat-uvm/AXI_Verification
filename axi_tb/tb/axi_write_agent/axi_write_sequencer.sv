//----------------------------------------------------------------
// AXI Write Sequencer
// - Inherits from axi_sequencer
// - Used exclusively in axi_write_agent
//----------------------------------------------------------------

class axi_write_sequencer extends axi_sequencer;
    `uvm_component_utils(axi_write_sequencer)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
endclass