//-------------------------------------------------------------
// AXI Transaction Class
// - Unified class for both read and write transactions
// - Supports future extensions like burst, protection, etc.
//-------------------------------------------------------------

class axi_transaction extends uvm_sequence_item;

//-------------------------------------------------------------
// Enum: Transaction type (Read/Write)
//-------------------------------------------------------------
typedef enum { AXI_READ, AXI_WRITE } axi_txn_type_e;
rand axi_txn_type_e txn_type;

//-------------------------------------------------------------
// Address and Data
//-------------------------------------------------------------
rand bit [31:0] addr;
rand bit [31:0] data;

//-------------------------------------------------------------
// Transaction Metadata
//-------------------------------------------------------------
rand bit [3:0] id;     //Transaction ID
rand bit [1:0] burst;  //Burst type (FIXED, INCR, WRAP)
rand bit [3:0] length; //Burst length
rand bit [1:0] resp;   //Response (Filled in by monitor)

//-------------------------------------------------------------
// Constraints
//-------------------------------------------------------------
constraint default_burst {
    burst inside {2'b00, 2'b01}; //FIXED OR INCR
}

constraint addr_alignment {
    addr[1:0] == 2'b00;          //Word-aligned address
}

//-------------------------------------------------------------
//Factory Registration
//-------------------------------------------------------------
`uvm_object_utils_begin
  `uvm_field_enum(axi_txn_type_e, txn_type, UVM_ALL_ON)
  `uvm_field_int(addr,      UVM_ALL_ON)
  `uvm_field_int(data,      UVM_ALL_ON)
  `uvm_field_int(id,        UVM_ALL_ON)
  `uvm_field_int(burst,     UVM_ALL_ON)
  `uvm_field_int(length,    UVM_ALL_ON)
  `uvm_field_int(resp,      UVM_ALL_ON)
`uvm_object_util_end

//-------------------------------------------------------------
//Constructor
//-------------------------------------------------------------
function new(string name = "axi_transaction");
 super.new(name);
endfunction

//-------------------------------------------------------------
//Convert to String (Debug)
//-------------------------------------------------------------
function string convert2string();
    return $sformatf("TYPE=%s ADDR=0x%08x DATA=0x%08x LEN=%0d BURST=%0d",
                    (txn_type == AXI_READ) ? "READ" : "WRITE",
                    addr, data, length, burst);
endfunction: convert2string


endclass