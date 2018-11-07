`timescale 1ns/100ps

module testbench_uart ();

  // Testbench uses 25 MHz clock
  // Want to interface to 115200 baud UART
  // 25000000 / 115200 = 217 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 40;
  parameter c_CLKS_PER_BIT    = 217;
  parameter c_BIT_PERIOD      = 8600;
  
  logic r_Clock;
  logic r_rst;
  logic i_RTS;
  logic empty;
  logic full;
  logic o_CTS;
  logic o_RX_Done;
  logic o_TX_Done; 
  logic w_TX_Active; 
  logic w_UART_Line;
  logic w_TX_Serial;
  logic [7:0] r_TX_Byte;
  logic [7:0] w_RX_Byte;


  uart_rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_Inst
    (r_Clock,
     r_rst,
     w_UART_Line, 
     full,
     o_CTS,
     o_RX_Done,
     w_RX_Byte
     );
  
  uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_Inst
    (r_Clock,
     r_rst,
     i_RTS,
     empty,
     r_TX_Byte,
     w_TX_Active,
     w_TX_Serial,
     o_TX_Done
     );

  assign w_UART_Line = w_TX_Active ? w_TX_Serial : 1'b1;
    
  always
  begin
    // #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
    r_Clock <= 1'b0;
    #20;
    r_Clock <= 1'b1;
    #20;
  end
  initial
    begin
      // #1 r_Clock <= 1'b1;
      full <=0;
      empty <=0;
      #5 r_rst <= 1'b1;
      #5 r_rst <= 1'b0;
      #5 r_rst <= 1'b1;
      @(posedge r_Clock);
      @(posedge r_Clock);
      i_RTS   <= 1'b1;
      r_TX_Byte <= 8'h3F;
      @(posedge r_Clock);
      i_RTS <= 1'b0;

      // Check that the correct command was receive
    end
  
  always @(posedge o_CTS)
  begin
    if (w_RX_Byte == 8'h3F)
      $display("Test Passed - Correct Byte Received");
    else
      $display("Test Failed - Incorrect Byte Received");
    #20
    $finish();
  end

endmodule
