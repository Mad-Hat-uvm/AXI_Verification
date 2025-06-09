/* | Goal               | Description                                     |
| ------------------ | ----------------------------------------------- |
| 🧠 Simulate delay  | Emulate a slow bus or pipelined memory          |
| 📦 Scoreboard test | Ensure delayed read still returns correct data  |
| 🔁 Repeatable      | Can loop for multiple delayed read/write cycles | */

//--------------------------------------------------------------------
// AXI Virtual Stress Sequence
// - Writes a value, waits N cycles, then reads it back
//--------------------------------------------------------------------

class axi_virt_rw_latency_seq extends uvm_sequence;
    `uvm_object_utils(axi_virt_rw_latency_seq)

    //Virtual Sequencer type
    `uvm_declare_p_sequencer(axi_virtual_sequencer);

    rand bit unsigned latency = 5;

    //Constructor
    function new(string name = "axi_virt_rw_latency_seq");
        super.new(name);
    endfunction

    task body();
        axi_transaction tr_w, tr_r;
        bit [31:0] addr;


        //Optionally randomize latency between write and read
        assert(this.randomize() with {latency inside {[3 : 10]}; });

        for(i = 0; i < 3; i++) begin

            //Randomize transaction address generation
            assert(std::randomize(addr) with {
                addr inside {[32'h0000_0000 : 32'h0000_00FF]};
                addr[1:0] == 2'b00; //Word alignes
            });

            tr_w = axi_transaction::type_id::create($sformatf("write_tr_%0d", i));
            tr_w.txn_type = AXI_WRITE;
            tr_w.addr     = addr;
            tr_w.data     = $urandom();
            
                `uvm_info("AXI_LATENCY_SEQ", $sformatf("WRITE 0x%0h to addr 0x%0h", tr_w.data, tr_w.addr), UVM_MEDIUM)

                //Send transaction to sequencer
                tr_w.start(p_sequencer.write_sequencer);

                //Insert latency/delay before issuing read
                repeat(latency)@(posedge p_sequencer.write_sequencer.vif.ACLK);

                //READ transaction
                tr_r = axi_transaction::type_id::create($sformatf("read_tr_%0d", i));
               `uvm_info("AXI_LATENCY_SEQ", $sformatf("READ from addr 0x%0h after delay=%0d", tr_r.addr, latency), UVM_MEDIUM)

                //Send transaction to sequencer
                tr.start(p_sequencer.read_sequencer);  
            

            //Optional randomized inter-transactional delay
            #(1 + $urandomrange(0, 3));
        end
    endtask
endclass

/* ✅ Do You Need to Change the Scoreboard for axi_virt_rw_latency_seq?
No changes are required if your scoreboard already:

Tracks all write transactions in a reference model (e.g., associative array)

On read, looks up the address and compares read.data == ref_mem[addr]

That is enough — regardless of how many cycles separate the write and read.

✅ UVM scoreboards are transaction-level, not cycle-accurate by default — so a delay between write and read is perfectly valid. */