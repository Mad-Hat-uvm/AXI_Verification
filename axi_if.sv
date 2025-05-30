//---------------------------------------------------------
//AXI-Lite Interface Definition
//---------------------------------------------------------
interface axi_if #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32)
                  (input logic ACLK, input logic ARESETn);

//---------------------------------------------------------
//Write Address Channel
//---------------------------------------------------------
logic [ADDR_WIDTH-1 : 0] AWADDR;    //Write address
logic                    AWVALID;   //Write address valid
logic                    AWREADY;   //Write address ready (slave)

//---------------------------------------------------------
//Write Data Channel
//---------------------------------------------------------
logic [DATA_WIDTH-1 : 0] WDATA;     //Write Data
logic                    WVALID;    //Write Data Valid
logic                    WREADY;    //Write Data Ready (slave)

//---------------------------------------------------------
//Write Response Channel
//---------------------------------------------------------
logic [1:0]              BRESP;     //Write Response (OKAY, SLVERR, etc.)
logic                    BVALID;    //Write Response Valid
logic                    BREADY;    //Write Response Ready (master)

//---------------------------------------------------------
//Read Address Channel
//---------------------------------------------------------
logic [ADDR_WIDTH-1 : 0] ARDDR;     //Read Address
logic                    ARVALID;   //Read Address Valid
logic                    ARREADY;   //Read Address ready (slave)

//---------------------------------------------------------
//Read Data Channel
//---------------------------------------------------------
logic [DATA_WIDTH-1 : 0] RDATA;     //Read Data
logic [1:0]              RRESP;     //Read Response
logic                    RVALID;    //Read Data Valid
logic                    RREADY;    //Read Data Ready(master)

endinterface