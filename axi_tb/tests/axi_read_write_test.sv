//----------------------------------------------------------------
// AXI Read-Write Test
// - Performs write sequence, then read sequence
// - Scoreboard checks functional correctness
//----------------------------------------------------------------

class axi_read_write_test extends uvm_test;
    `uvm_component_utils (axi_read_write_test)

    //Constructor
    function new(string name =  "axi_read_write_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    //Build environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = axi_env::type_id::create("env", this);

        //Optionally set agent active/passive here
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.write_agent", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.read_agent", "is_active", UVM_ACTIVE);
    endfunction

    //Run the sequence
    task run_phase(uvm_phase phase);
        axi_write_seq write_seq;
        axi_read_seq  read_seq;

        phase.raise_objection(this);

          write_seq = axi_write_seq::type_id::create("write_seq", this);
          read_seq  = axi_read_seq::type_id::create("read_seq", this);

          //Start write first, then read
          write_seq.start(env.write_agent.seqr);
          read_seq.start(env.read_agent.seqr);

        phase.drop_objection(this);
    endtask
endclass