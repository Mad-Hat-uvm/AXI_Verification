//--------------------------------------------------------------------
// AXI Virtual Stress Sequence
// - Runs high-volume randomized interleaved write/read traffic
//--------------------------------------------------------------------

class axi_virt_stress_seq extends uvm_sequence;
    `uvm_object_utils(axi_virt_stress_seq)

    //Virtual Sequencer type
    `uvm_declare_p_sequencer(axi_virtual_sequencer);

    rand bit unsigned num_ops = 20;

    //Constructor
    function new(string name = "axi_virt_stress_seq");
        super.new(name);
    endfunction

    task body();
        axi_transaction tr;
        bit [31:0] addr;
        bit do_write;

        //Optionally randomize count of ops
        assert(this.randomize());

        for(i = 0; i < num_ops; i++) begin

            //Randomize transaction type and address
            assert(std::randomize(do_write));
            assert(std::randomize(addr) with {
                addr inside {[32'h0000_0000 : 32'h0000_00FF]};
                addr[1:0] == 2'b00; //Word alignes
            });

            tr = axi_transaction::type_id::create($sformatf("tr: %0d", i));
            tr.addr = addr;
            tr.txn_type = do_write ? AXI_WRITE : AXI_READ;

            if(do_write) begin
                data = $urandom();
                `uvm_info("AXI_STRESS", $sformatf("WRITE 0x%0h to addr 0x%0h", tr.data, tr.addr), UVM_MEDIUM)

                //Send transaction to sequencer
                tr.start(p_sequencer.write_sequencer);
            end
            else begin
               `uvm_info("AXI_STRESS", $sformatf("READ from addr 0x%0h", tr.addr), UVM_MEDIUM)

                //Send transaction to sequencer
                tr.start(p_sequencer.read_sequencer);  
            end

            //Optional randomized inter-transactional delay
            #(1 + $urandomrange(0, 3));
        end
    endtask
endclass