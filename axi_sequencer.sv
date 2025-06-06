//-------------------------------------------------------------
// AXI Sequencer
// - Cordinates transaction flow between sequence and driver
//-------------------------------------------------------------

class axi_sequencer extends uvm_sequencer #(axi_transaction);
 `uvm_component_utils(axi_sequencer)

  //Constructor
 function new(string name, uvm_component parent);
  super.new(name, parent);
 endfunction

endclass