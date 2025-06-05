//----------------------------------------------------------------
// AXI Read Agent
// - Wraps sequencer, driver and monitor for AXI read channel
// - Supports active/passive agent behavior
//----------------------------------------------------------------

class axi_read_agent extends uvm_agent;
    `uvm_component_utils(axi_read_agent)

    axi_read_sequencer seqr;
    axi_read_driver    drv;
    axi_read_monitor   mon;

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //Build Phase: Create components based on agent's is_active setting
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(is_active == UVM_ACTIVE) begin
            seqr = axi_read_sequencer::type_id::create("seqr", this);
            drv  = axi_read_driver::type_id::create("drv", this);
        end

           mon   = axi_read_monitor::type_id::create("mon", this);
    endfunction

    //Connect Phase: Connect sequencer to driver
    function connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if(is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction
    
endclass