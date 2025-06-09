//------------------------------------------------------------------------
// Reset Interface: Clocked, Active-Low Reset with Assertions + Coverage
// -----------------------------------------------------------------------

interface reset_if(input logic clk);
    logic rst_n;

    //Internal tracker for how long reset has been held low
    int reset_cycles = 0;

    //Task to set/reset active-low reset
    task set_reset(bit active_low);
        rst_n = active_low;
    endtask

    //-----------------------------------
    // Reset Coverage group
    //-----------------------------------
    covergroup cg_reset @(posedge clk);
        coverpoint reset_cycles {
            bins held_1         = {1};
            bins held_2         = {2};
            bins held_3         = {3};
            bins held_4_or_more = {4 : $};
        }
    endgroup

    cg_reset reset_cg = new();

    //Track and sample reset duration
    always @(posedge clk) begin
        if(!rst_n) begin
            reset_cycles++;
        end else if(reset_cycles > 0) begin
            reset_cg.sample();
            $display("Reset held for %0d cycles at time %0t", reset_cycles, $time);
            reset_cycles = 0;
        end
    end

    //-----------------------------------
    // Assertions
    // ----------------------------------

    //1. Reset must be held for atleast 2 cycles
    property reset_min_hold;
        @(posedge clk) disable iff(rst_n)
        $rose(!rst_n) |-> ##[1:2] !rst_n;
    endproperty
    assert property (reset_min_hold)
    else $error("Reset must be held for atleast 2 clock cycles");

    //2. Reset deasserted cleanly on clock edge
    property reset_deasserted_on_clk;
        @(posedge clk)
        $fell(!rst_n) |-> $stable(rst_n);
    endproperty
    assert property (reset_deasserted_on_clk)
    else $error("Reset deasserted asynchronously or glitchy");
    
endinterface