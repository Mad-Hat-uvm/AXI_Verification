//----------------------------------------------------------------
// AXI Virtual Test
// - Runs a co-ordinated read-write using virtual sequencer
//----------------------------------------------------------------

class axi_virtual_test extends uvm_test;
    `uvm_component_utils (axi_virtual_test)

    //Constructor
    function new(string name =  "axi_virtual_test", uvm_component parent = null);
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
        axi_virt_rw_seq vseq;

        phase.raise_objection(this);

         //Create and start virtual sequence
         vseq = axi_virt_rw_seq::type_id::create("vseq");
         vseq.start(env.virt_sequencer);
         
        phase.drop_objection(this);
    endtask
endclass