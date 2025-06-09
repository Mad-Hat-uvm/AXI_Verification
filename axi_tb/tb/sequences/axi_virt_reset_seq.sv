//--------------------------------------------------------------------
// AXI Virtual Reset Sequence
// - Issues transactions before and after reset
// - Applies reset using reset_if from config_db
//--------------------------------------------------------------------

class axi_virt_reset_seq extends uvm_sequence;
    `uvm_object_utils(axi_virt_reset_seq)

    //Virtual Sequencer type
    `uvm_declare_p_sequencer(axi_virtual_sequencer);

    virtual reset_if rst_if;

    //Constructor
    function new(string name = "axi_virt_reset_seq");
        super.new(name);
    endfunction

    task body();
        axi_transaction tr;
        bit [31:0] addr;
        bit do_write;

        //Get reset interface from config_db
        if(!uvm_config_db#(virtual rst_if)::get(null, "uvm_test_top.env", "rst_if", rst_if))
        `uvm_fatal("VSEQ_RESET", "reset_if not found in config_db")
        
       //Part 1: 3 randomized transactions BEFORE reset
        `uvm_info("VSEQ_RESET", ">>> Starting pre-reset traffic <<<", UVM_MEDIUM)
        
        for(i = 0; i < 3; i++) begin

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
                //Send transaction to sequencer
                tr.start(p_sequencer.write_sequencer);
            end
            else begin
                //Send transaction to sequencer
                tr.start(p_sequencer.read_sequencer);  
            end

            //Optional randomized inter-transactional delay
            #(1 + $urandomrange(0, 3));
        end

        //part 2: apply RESET
         `uvm_info("VSEQ_RESET", ">>> APPLY RESET <<<", UVM_MEDIUM)

          rst_if.set_reset(1'b0);     // Active low reset
          #20;                        // hold reset for 20 ns
          rst_if.set_reset(1'b1);     // deassert reset

         `uvm_info("VSEQ_RESET", ">>> RESET RELEASED <<<", UVM_MEDIUM)
          #10;                        //allow DUT to recover

          //Part 3: 3 randomized transactions AFTER reset
        `uvm_info("VSEQ_RESET", ">>> Starting post-reset traffic <<<", UVM_MEDIUM)
        
        for(i = 0; i < 3; i++) begin

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
                //Send transaction to sequencer
                tr.start(p_sequencer.write_sequencer);
            end
            else begin
                //Send transaction to sequencer
                tr.start(p_sequencer.read_sequencer);  
            end

            //Optional randomized inter-transactional delay
            #(1 + $urandomrange(0, 3));
        end
    endtask
endclass