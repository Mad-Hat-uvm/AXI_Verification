//--------------------------------------------------------------------
// AXI Virtual Interleave Sequence
// - Alternates between write and read transactions
// - Uses virtual sequencer to access both agents
//--------------------------------------------------------------------

class axi_virt_interleave_seq extends uvm_sequence;
    `uvm_object_utils(axi_virt_interleave_seq)

    //Virtual Sequencer type
    `uvm_declare_p_sequencer(axi_virtual_sequencer);

    //Constructor
    function new(string name = "axi_virt_interleave_seq");
        super.new(name);
    endfunction

    task body();
        axi_write_seq write_seq;
        axi_read_seq read_seq;

        for(i = 0; i < 4; i++) begin
            //Randomize a valid word-aligned address in 0x00 - 0xFF
            assert(std::randomize(addr) with {addr inside {[32'h00 : 32'hFF]}; addr[1:0] == 2'b00});

            //WRITE
            `uvm_info("VSEQ", $sformatf("Starting WRITE[%0d]", i), UVM_MEDIUM)
              write_seq = axi_write_seq::type_id::create("write_seq");
              write_seq.start(p_sequencer.write_sequencer);

            //READ
             `uvm_info("VSEQ", $sformatf("Starting READ[%0d]", i), UVM_MEDIUM)  
               read_seq  = axi_read_seq::type_id::create("read_seq");
               read_seq.start(p_sequencer.read_sequencer);
        end
    endtask
endclass