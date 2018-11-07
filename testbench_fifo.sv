`timescale 1ns/100ps

module testbench_fifo ();

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
  logic [7:0] data_in;
  logic [7:0] data_out;
  logic rd_en;
  logic wr_en;

  syn_fifo fifo (.clk(r_Clock), .rst(r_rst), .data_in(data_in), .rd_en(rd_en), .wr_en(wr_en),
                 .data_out(data_out), .empty(empty), .full(full));

    
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
      #5 r_rst <= 1'b1;
      #5 r_rst <= 1'b0;
      #5 r_rst <= 1'b1;
      

      @(posedge r_Clock);
      @(posedge r_Clock);
      data_in <= 8'h00;
      wr_en <= 1'b1;
      rd_en <= 1'b0;
      @(posedge r_Clock);
      wr_en <= 1'b0;
      @(posedge r_Clock);
      @(posedge r_Clock);
      data_in <= 8'h01;
      wr_en <= 1'b1;
      @(posedge r_Clock);
      wr_en <= 1'b0;
      @(posedge r_Clock);
      @(posedge r_Clock);
      data_in <= 8'h02;
      wr_en <= 1'b1;
      @(posedge r_Clock);
      wr_en <= 1'b0;
      @(posedge r_Clock);
      @(posedge r_Clock);
      data_in <= 8'h03;
      wr_en <= 1'b1;
      @(posedge r_Clock);
      wr_en <= 1'b0;
      @(posedge r_Clock);

      @(posedge r_Clock);
      rd_en <= 1'b1;
      @(posedge r_Clock);
      rd_en <= 1'b0;
      @(posedge r_Clock);
      if (data_out == 8'h00)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received"); 
      @(posedge r_Clock);
      rd_en <= 1'b1;
      @(posedge r_Clock);
      rd_en <= 1'b0;
      @(posedge r_Clock);
      if (data_out == 8'h01)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
      @(posedge r_Clock);
      rd_en <= 1'b1;
      @(posedge r_Clock);
      rd_en <= 1'b0;
      @(posedge r_Clock);
      if (data_out == 8'h02)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
      @(posedge r_Clock);
      rd_en <= 1'b1;
      @(posedge r_Clock);
      rd_en <= 1'b0;
      @(posedge r_Clock);
      if (data_out == 8'h03)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
      @(posedge r_Clock);
      @(posedge r_Clock);

      $finish;

    end

endmodule
