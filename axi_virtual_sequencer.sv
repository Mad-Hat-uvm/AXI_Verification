//-------------------------------------------------------------
// AXI Virtual Sequencer
// - Contains handles to read and write sequencers
// - Used by virtual sequences to co-ordinate both the agents
//-------------------------------------------------------------

class axi_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(axi_virtual_sequencer)

    //Handle to underlying agent sequencers
    axi_write_sequencer write_sequencer;
    axi_read_sequencer  read_sequencer;
   
     //Constructor
    function new(string name, uvm_component parent);
     super.new(name, parent);
    endfunction
   
   endclass