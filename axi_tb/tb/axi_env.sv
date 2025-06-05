//----------------------------------------------------------------
// AXI Environment (Enhanced)
// - Adds virtual sequencer to co-ordinate write and read agents
//----------------------------------------------------------------
class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)

    //Agents
    axi_write_agent write_agent;
    axi_read_agent  read_agent;

    //Scoreboard
    axi_scoreboard  scoreboard;

    //Virtual Sequencer
    axi_virtual_sequencer virt_sequencer;

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    //Build: create both agents
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        write_agent    = axi_write_agent::type_id::create("write_agent", this);
        read_agent     = axi_read_agent::type_id::create("read_agent", this);
        scoreboard     = axi_scoreboard::type_id::create("scoreboard", this);
        virt_sequencer = axi_virtual_sequencer::type_id::create("virt_sequencer", this);

    //You can set ACTIVE/PASSIVE externally or in the test
    endfunction

    //Connect phase: connect analysis ports if needed
    function void connect_phase(uvm_phase phase);
        super.connect(phase);

        write_agent.mon.mon_ap.connect(scoreboard.write_export);
        read_agent.mon.mon_ap.connect(scoreboard.read_export);

        //Virtual Sequencer hookup
        virt_sequencer.write_sequencer = write_agent.seqr;
        virt_sequencer.read_sequencer  = read_agent.seqr;
    endfunction
endclass