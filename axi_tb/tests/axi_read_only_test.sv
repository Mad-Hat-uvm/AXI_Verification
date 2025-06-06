//----------------------------------------------------------------
// AXI Read Only Test
// - Verify that the read channel path (AR -> R) works correctly
// - Read from locations that are expected to be pre initialized
// - Scoreboard validates expected v/s RDATA
// - No writes are performed
// - Reads from a fixed address space using axi_read_seq
// - Only the read agent is active
//----------------------------------------------------------------

class axi_read_only_test extends axi_base_test;
    `uvm_component_utils (axi_read_only_test)

    //Constructor
    function new(string name =  "axi_read_only_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //Build environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //Activate only the write agent
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.write_agent", "is_active", UVM_PASSIVE);
        uvm_config_db#(uvm_active_passive_enum)::set(this, "env.read_agent", "is_active", UVM_ACTIVE);
    endfunction

    //Run the sequence
    task run_phase(uvm_phase phase);
        axi_read_seq seq;

        phase.raise_objection(this);
        //Create the write sequence
          seq = axi_read_seq::type_id::create("seq");
        
          //Start the write sequence
          seq.start(env.read_agent.seqr);

        phase.drop_objection(this);
    endtask
endclass