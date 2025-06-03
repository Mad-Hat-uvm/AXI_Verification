//----------------------------------------------------------------
// AXI Write Sequence
// - Generates N write transactions with random addr/data
// - Used with axi_write sequencer
//---------------------------------------------------------------

class axi_write_seq extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(axi_write_seq)

    rand int unsigned num_txns = 4;

    //Constructor
    function new(string name = "axi_write_seq");
        super.new(name);
    endfunction

    task body();
        axi_transaction tr;

        for(i = 0; i <= num_txns; i++) begin
            tr = axi_transaction::type_id::create("tr");

            tr.txn_type == AXI_WRITE;
            assert(tr.randomize() with {
                tr.txn_type = AXI_WRITE;
                addr inside {[32'h0000_0000 : 32'h0000_00FF]}; //restrict to small memory range
            });

            `uvm_info("AXI_WRITE_SEQ", $sformatf("Sending WRITE[%0d]: %s", tr.convert2string()), UVM_MEDIUM)

            start_item(tr);
            finish_item(tr);
        end
    endtask
endclass