//--------------------------------------------------------------------
// AXI Virtual Read-Write Sequence
// - Co-ordinates read and write sequences through virtual sequencer
//--------------------------------------------------------------------

class axi_virt_rw_seq extends uvm_sequence;
    `uvm_object_utils(axi_write_seq)

    //Virtual Sequencer type
    `uvm_declare_p_sequencer(axi_virtual_sequencer);

    //Constructor
    function new(string name = "axi_write_seq");
        super.new(name);
    endfunction

    task body();
        axi_write_seq write_seq;
        axi_read_seq read_seq;

        write_seq = axi_write_seq::type_id::create("write_seq");
        read_seq  = axi_read_seq::type_id::create("read_seq");

        `uvm_info("VSEQ", "Starting WRITE seq", UVM_MEDIUM)
         write_seq.start(p_sequencer.write_sequencer);

        `uvm_info("VSEQ", "Starting READ seq", UVM_MEDIUM)
         read_seq.start(p_sequencer.read_sequencer);
    endtask
endclass