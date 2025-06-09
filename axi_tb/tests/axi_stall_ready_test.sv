/* ✅ Purpose of axi_stall_ready_test
Runs a virtual sequence (axi_stall_ready_seq)

The sequence simulates delayed READY signals for AW, W, or AR channels

Confirms AXI protocol handshake robustness under stall conditions */
//---------------------------------------------------------------------------
// AXI Stall ready Test
// - Runs a sequence that stalls AWREADY/WREADY/RREADY
// - Verifies protocol behavior under backpressure
//---------------------------------------------------------------------------

class axi_stall_ready_test extends axi_base_test;
    `uvm_component_utils (axi_stall_ready_test)

    //Constructor
    function new(string name =  "axi_stall_ready_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //Build environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);


        //Activate both agents
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.write_agent", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.read_agent", "is_active", UVM_ACTIVE);
    endfunction

    //Run the sequence
    task run_phase(uvm_phase phase);
        axi_stall_ready_seq vseq;

        phase.raise_objection(this);

         //Create and start virtual sequence
         vseq = axi_stall_ready_seq::type_id::create("vseq");
         vseq.start(env.virt_sequencer);
         
        phase.drop_objection(this);
    endtask
endclass