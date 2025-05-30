//-------------------------------------------------------------
//AXI-Lite Slave DUT Module
//- Handles basic AXI read/write operations to internal memory
//- Compliant with AXI-Lite protocol (no burst, no ID, no QoS)
//-------------------------------------------------------------

module axi_lite_slave #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32, MEM_DEPTH = 256)
(
    input logic ACLK,
    input logic ARESETn,

    //Write Address Channel
    input  logic [ADDR_WIDTH-1 : 0] AWADDR,
    input  logic                    AWVALID,
    output logic                    AWREADY,

    //Write Data Channel
    input  logic [DATA_WIDTH-1 :0]  WDATA,
    input  logic                    WVALID,
    output logic                    WREADY,

    //Write Response Channel
    output logic [1:0]              BRESP,
    output logic                    BVALID,
    input  logic                    BREADY,

    //Read Address Channel
    input  logic  [ADDR_WIDTH-1 : 0] ARDDR,
    input  logic                     ARVALID,
    output logic                     ARREADY,

    //Read Data Channel
    output logic [DATA_WIDTH-1 : 0]  RDATA,
    output logic [1:0]               RRESP,
    output logic                     RVALID,
    input logic                      RREADY
);

//---------------------------------------------------------
//Internal Memory Array
//---------------------------------------------------------
logic [DATA_WIDTH-1 : 0] mem [0: MEM_DEPTH-1];

//---------------------------------------------------------
//Write Channel Logic
//---------------------------------------------------------
always_ff @(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) begin
        AWREADY <= 0;
        WREADY  <= 0;
        BRESP   <= 0;
    end else begin
        // Accept write address
        if(AWVALID && !AWREADY)
         AWREADY <= 1;
        else
         AWREADY <= 0;

        // Accept write data
        if(WVALID && !WREADY)
         WREADY  <= 1;
        else
         WREADY  <= 0;

        //Perform Write if both address and data are valid
        if(AWVALID && AWREADY && WVALID && WREADY) begin
            mem[AWADDR[7:0]] <= WDATA;  //Use LSB of address to index memory
            BVALID           <= 1;      //Signal write response
            BRESP            <= 2'b00;  //OKAY response

        end else if (BVALID && BREADY) begin
         BVALID <= 0;                   //Complete response
        end
    end
end

//---------------------------------------------------------
//Read Channel Logic
//---------------------------------------------------------
always_ff @(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn) begin
        ARREADY <= 0;
        RVALID  <= 0;
    end else begin
        // Accept read address
        if(ARVALID && !ARREADY)
         ARREADY <= 1;
        else
         ARREADY <= 0;


        //Drive Read Data when address is accepted
        if(ARVALID && ARREADY) begin
            RDATA <= mem[ARDDR[7:0]];  //Read Data from Memory
            RVALID           <= 1;     
            RRESP            <= 2'b00;  //OKAY response

        end else if (RVALID && RREADY) begin
         RVALID <= 0;                   //Complete read
        end
    end
end
endmodule