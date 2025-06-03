//----------------------------------------------------------------
// AXI Base Test
// - Instantiates the axi_env
// - Runs a basic write sequence through the write agent
//----------------------------------------------------------------

class axi_base_test extends uvm_test;
    `uvm_component_utils(axi_base_test)

    //Constructor
    function new(string name = "axi_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    //Build environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = axi_env::type_id::create("env", this);

        //Optionally set agent active/passive here
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.write_agent", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.read_agent", "is_active", UVM_PASSIVE);
    endfunction

    //Run the sequence
    task run_phase(uvm_phase phase);
        axi_write_seq seq;

        phase.raise_objection(this);

         //Create and start the sequence on write agents's sequencer
          seq = axi_write_seq::type_id::create("seq", this);
          seq.start(env.write_agent.seqr);
        phase.drop_objection(this);
    endtask
endclass