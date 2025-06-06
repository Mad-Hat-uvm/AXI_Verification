//----------------------------------------------------------------
// AXI Read Sequence
// - Generates N read transactions using address in read range
// - Used with axi_read sequencer
//---------------------------------------------------------------

class axi_read_seq extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(axi_read_seq)

    rand int unsigned num_txns = 4;

    //Constructor
    function new(string name = "axi_read_seq");
        super.new(name);
    endfunction

    task body();
        axi_transaction tr;

        for(i = 0; i <= num_txns; i++) begin
            tr = axi_transaction::type_id::create("tr");

            tr.txn_type == AXI_READ;
            assert(tr.randomize() with {
                tr.txn_type = AXI_READ;
                addr inside {[32'h0000_0000 : 32'h0000_00FF]}; //restrict to write address range
            });

            `uvm_info("AXI_READ_SEQ", $sformatf("Sending READ[%0d]: %s", tr.convert2string()), UVM_MEDIUM)

            start_item(tr);
            finish_item(tr);
        end
    endtask
endclass