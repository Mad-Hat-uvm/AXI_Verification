//-----------------------------------------------------------------
// Top-Level Testbench : Supports full AXI UVM test suite
// - Instantiates DUT and AXI Interface
// - Generates Clock and Reset
// - UVM config_db setup
//----------------------------------------------------------------
`timescale 1ns/1ps

module tb_top;

    //Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter MEM_DEPTH  = 256;

//-----------------------------------------------------------------
//Clock Generation: 10ns period
//-----------------------------------------------------------------
logic ACLK;
initial ACLK = 0;
always #5 ACLK = ~ACLK;   //100Mhz clock

//-----------------------------------------------------------------
//Reset Interface
//-----------------------------------------------------------------
reset_if rst_if(ACLK);       //Reset interface with assertions and coverage
logic ARESETn = rst_if.rst_n; //Alias from reset interface

//-----------------------------------------------------------------
//AXI Interface Instance
//-----------------------------------------------------------------
axi_if #(ADDR_WIDTH, DATA_WIDTH) axi_vif (ACLK, ARESETn);

//-----------------------------------------------------------------
//DUT Instance (AXI-Lite Slave)
//-----------------------------------------------------------------
axi_lite_slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .MEM_DEPTH(MEM_DEPTH)
) dut (
    .AACLK    (ACLK),
    .ARESETn (ARESETn),

    //Write Address Channel
    .AWADDR(axi_vif.AWADDR),
    .AWVALID(axi_vif.AWVALID),
    .AWREADY(axi_vif.AWREADY),

    //Write Data Channel
    .WDATA(axi_vif.WDATA),
    .WVALID(axi_vif.WVALID),
    .WREADY(axi_vif.WREADY),

    //Write Response Channel
    .BRESP(axi_vif.BRESP),
    .BVALID(axi_vif.BVALID),
    .BREADY(axi_vif.BREADY),

    //Read Address Channel
    .ARADDR(axi_vif.ARADDR),
    .ARVALID(axi_vif.ARVALID),
    .ARREADY(axi_vif.ARREADY),

    //Read Data Channel
    .RDATA(axi_vif.RDATA),
    .RVALID(axi_vif.RVALID),
    .RREADY(axi_vif.RREADY),
    .RRESP(axi_vif.RRESP)
);

//-------------------------------------------------------------------
// UVM Hookup and Simulation control
//-------------------------------------------------------------------
initial begin
    //Pass interfaces into UVM via config_db
    uvm_config_db#(virtual axi_if)::set(null, "uvm_test_top.env", "vif", axi_vif);
    uvm_config_db#(virtual reset_if)::set(null, "uvm_test_top.env", "rst_if", rst_if);
end
//-------------------------------------------------------------------
// UVM Test Start hook
//-------------------------------------------------------------------
initial begin
    //Dump simulation waveform (optional)
    $dumpfile("dump.vcd");
    $dumpvars(0, top_tb);

    //Start UVM
    run_test();
end
endmodule