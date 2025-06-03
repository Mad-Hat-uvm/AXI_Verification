//----------------------------------------------------------------
// AXI Scoreboard
// - Implements a reference model for AXI read/write behavior
// - Compares read data signal against reference model
//----------------------------------------------------------------

class axi_scoreboard extends uvm_component;
    `uvm_component_utils(axi_scoreboard)

    uvm_analysis_imp #(axi_transaction, axi_scoreboard) write_export;
    uvm_analysis_imp #(axi_transaction, axi_scoreboard) read_export;

    //Reference model
    bit [31:0] ref_mem [int];  //associative array indexed by address

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);

        write_export = new("write_export", this);
        read_export  = new("read_export", this);
    endfunction

    //Called when write monitor sends a transaction
    function void write(input axi_transaction tr);
        if(tr.txn_type == axi_transaction::AXI_WRITE) begin
            ref_mem[tr.addr] = tr.data;
            `uvm_info("AXI_SB_WRITE", $sformatf("Logged WRITE addr=0x%0h data=0x%0h", tr.addr, tr.data), UVM_MEDIUM)
        end 
        else begin
            `uvm_error("AXI_SB_WRITE", "Received non_write transaction on write export");
            
        end
    endfunction

     //Called when read monitor sends a transaction
    function void read(input axi_transaction tr);
        bit [31:0] expected;

        if(tr.txn_type == axi_transaction::AXI_READ) begin
          if(ref_mem.exists(tr.addr)) begin
            expected = ref_mem[tr.addr];
            if(expected != tr.data)
            `uvm_error("AXI_SB_READ", $sformatf("Read MISMATCH at 0x0%h: expected: 0x0%h actual=0x0%h", tr.addr, expected, tr.data))
            else
            `uvm_info("AXI_SB_READ", $sformatf("Read MATCH at 0x%0h: data=0x%0h", tr.addr, tr.data), UVM_MEDIUM)
          end 
          else begin
            `uvm_warning("AXI_SB_READ", $sformatf("Read from UNWRITTEN addr=0x%0h", tr.addr));
          end
        end
        else begin
            `uvm_error("AXI_SB_READ", "Received non_write transaction on write export");
        end
    endfunction


endclass