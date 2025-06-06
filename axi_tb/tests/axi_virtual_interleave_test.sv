//----------------------------------------------------------------
// AXI Virtual Interleave Test
// - Runs interleaved write/read transactions using a virtual sequence
// - Validates sequencer co-ordination and scoreboard behavior
//----------------------------------------------------------------

class axi_virtual_interleave_test extends axi_base_test;
    `uvm_component_utils (axi_virtual_interleave_test)

    //Constructor
    function new(string name =  "axi_virtual_interleave_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //Build environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //Create environment
        env = axi_env::type_id::create("env", this);

        //Activate both agents
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.write_agent", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.read_agent", "is_active", UVM_ACTIVE);
    endfunction

    //Run the sequence
    task run_phase(uvm_phase phase);
        axi_virt_interleave_seq vseq;

        phase.raise_objection(this);

         //Create and start virtual sequence
         vseq = axi_virt_interleave_seq::type_id::create("vseq");
         vseq.start(env.virt_sequencer);
         
        phase.drop_objection(this);
    endtask
endclass