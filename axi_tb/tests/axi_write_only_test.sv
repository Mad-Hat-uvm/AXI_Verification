//----------------------------------------------------------------
// AXI Write Only Test
// - Verify that the write channel path (AW → W → B) works correctly
// - Check that data written to the DUT is captured by the monitor and validated by the scoreboard
// - No reads are performed
// - Sends multiple write transactions using axi_write_seq
// - Only the write agent is active
//----------------------------------------------------------------

class axi_write_only_test extends axi_base_test;
    `uvm_component_utils (axi_write_only_test)

    //Constructor
    function new(string name =  "axi_write_only_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //Build environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = axi_env::type_id::create("env", this);

        //Activate only the write agent
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.write_agent", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.read_agent", "is_active", UVM_PASSIVE);
    endfunction

    //Run the sequence
    task run_phase(uvm_phase phase);
        axi_write_seq write_seq;

        phase.raise_objection(this);
        //Create the write sequence
          seq = axi_write_seq::type_id::create("seq");
        
          //Start the write sequence
          seq.start(env.write_agent.seqr);

        phase.drop_objection(this);
    endtask
endclass