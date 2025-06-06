//----------------------------------------------------------------
// AXI Read-Write Test
// - Writes to an address using the write sequencer
// - Immediately reads back from the address using the read sequencer
// - Both agents are active
// - Validates data integrity through scoreboard
// - Scoreboard validates the functional correctness of read data
//----------------------------------------------------------------

class axi_read_write_test extends axi_base_test;
    `uvm_component_utils (axi_read_write_test)

    //Constructor
    function new(string name =  "axi_read_write_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //Build environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //Optionally set agent active/passive here
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.write_agent", "is_active", UVM_ACTIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.read_agent", "is_active", UVM_ACTIVE);
    endfunction

    //Run the sequence
    task run_phase(uvm_phase phase);
        axi_write_seq write_seq;
        axi_read_seq  read_seq;

        phase.raise_objection(this);
          
         //First perform write
          write_seq = axi_write_seq::type_id::create("write_seq", this);
          write_seq.start(env.write_agent.seqr);

          //Then read back the same address
          read_seq  = axi_read_seq::type_id::create("read_seq", this);
           read_seq.start(env.read_agent.seqr);
          
        phase.drop_objection(this);
    endtask
endclass