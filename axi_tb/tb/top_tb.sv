//-----------------------------------------------------------------
// Top-Level Testbench wrapper
// - Instantiates DUT and AXI Interface
// - Generates Clock and Reset
//----------------------------------------------------------------
`timescale 1ns/1ps

module tb_top;

    //Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter MEM_DEPTH  = 256;

//-----------------------------------------------------------------
//Clock and Reset Signals
//-----------------------------------------------------------------
logic clk;
logic rst_n;

//-----------------------------------------------------------------
//Clock Generation: 10ns period
//-----------------------------------------------------------------
initial clk = 0;
always #5 clk = ~clk;

//-----------------------------------------------------------------
//Reset Generation
//-----------------------------------------------------------------
initial begin
    rst_n = 0;
    #50;
    rst_n = 1;
end

//-----------------------------------------------------------------
//AXI Interface Instance
//-----------------------------------------------------------------
axi_if #(ADDR_WIDTH, DATA_WIDTH) axi_if_inst (.ACLK(clk), .ARESETn(rst_n));

//-----------------------------------------------------------------
//DUT Instance (AXI-Lite Slave)
//-----------------------------------------------------------------
axi_lite_slave #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .MEM_DEPTH(MEM_DEPTH)
) dut (
    .ACLK    (clk),
    .ARESETn (rst_n),

    //Write Address Channel
    .AWADDR(axi_if_inst.AWADDR),
    .AWVALID(axi_if_inst.AWVALID),
    .AWREADY(axi_if_inst.AWREADY),

    //Write Data Channel
    .WDATA(axi_if_inst.WDATA),
    .WVALID(axi_if_inst.WVALID),
    .WREADY(axi_if_inst.WREADY),

    //Write Response Channel
    .BRESP(axi_if_inst.BRESP),
    .BVALID(axi_if_inst.BVALID),
    .BREADY(axi_if_inst.BREADY),

    //Read Address Channel
    .ARADDR(axi_if_inst.ARADDR),
    .ARVALID(axi_if_inst.ARVALID),
    .ARREADY(axi_if_inst.ARREADY),

    //Read Data Channel
    .RDATA(axi_if_inst.RDATA),
    .RVALID(axi_if_inst.RVALID),
    .RREADY(axi_if_inst.RREADY),
    .RRESP(axi_if_inst.RRESP)
);

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