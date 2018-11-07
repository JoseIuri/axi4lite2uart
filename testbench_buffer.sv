`timescale 1ns/100ps

module testbench_buffer ();

  // Testbench uses 25 MHz clock
  // Want to interface to 115200 baud UART
  // 25000000 / 115200 = 217 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 40;
  parameter c_CLKS_PER_BIT    = 217;
  parameter c_BIT_PERIOD      = 8600;
  
  logic r_Clock;
  logic r_rst;
  logic empty;
  logic full;
  logic [31:0] data_inTx;
  logic [31:0] data_outRx;
  logic [7:0]  data_tr;
  logic rd_en;
  logic wr_en;

  logic rxValid;
  logic txValid;
  logic rxReady;
  logic txReady;
  logic outReady;
  logic outValid;

  bufferRx bufferRx (.clk(r_Clock), .rst(r_rst), .rxValid(rxValid), .empty(empty),
                     .rxReady(rxReady), .outReady(outReady), .outValid(outValid), .data_out(data_outRx), .data_in(data_tr));

  bufferTx bufferTx (.clk(r_Clock), .rst(r_rst), .txValid(txValid), .full(full), .outReady(outReady),
                     .txReady(txReady), .outValid(outValid), .data_out(data_tr), 
                     .data_in(data_inTx));


  always
  begin
    // #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
    r_Clock <= 1'b0;
    #(c_CLOCK_PERIOD_NS/2);
    r_Clock <= 1'b1;
    #(c_CLOCK_PERIOD_NS/2);
  end

  initial
    begin
      // #1 r_Clock <= 1'b1;
      full <= 0;
      empty <= 0;
      #5 r_rst <= 1'b1;
      #5 r_rst <= 1'b0;
      #5 r_rst <= 1'b1;  
      @(posedge r_Clock);
      @(posedge r_Clock);
      data_inTx <= 32'h0000f0f0;
      txValid <= 1'b1;
      rxReady <= 1'b1;
      @(posedge r_Clock);
      @(posedge r_Clock);
      @(posedge r_Clock);
      @(posedge r_Clock);
      @(posedge r_Clock);
      @(posedge r_Clock);
      @(posedge r_Clock);
      @(posedge r_Clock);
      if (data_outRx == 32'hf0f0)
        $display("Test Passed - Correct Word Received");
      else
        $display("Test Failed - Incorrect Word Received");
      $finish;
    end

endmodule
