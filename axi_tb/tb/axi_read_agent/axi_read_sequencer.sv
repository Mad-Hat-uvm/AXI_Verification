//--------------------------------------------------------------------------
// AXI Read Sequencer
// - Inherits from axi_sequencer
// - Used exclusively in axi_read_agent for read transaction co-ordination
//--------------------------------------------------------------------------

class axi_read_sequencer extends axi_sequencer;
    `uvm_component_utils(axi_read_sequencer)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
endclass