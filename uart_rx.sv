`timescale 1ns/100ps
// ============================================================================= //
// Designer:       Jose Iuri B. de Brito - jose.brito@embedded.ufcg.edu.br       //             //
//                                                                               //
// Design Name:    UART Reciever                                                 //
// Module Name:    uart_rx                                                       //
//                                                                               //
// ============================================================================= //

// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_CTS will be
// driven high for one clock cycle.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
  
module uart_rx 
  #(parameter CLKS_PER_BIT = 87)
  (
   input logic        i_Clock,
   input logic        rst,
   input logic        i_Rx_Serial,
   input logic        wr_ready,
   input logic        full,
   output logic       o_CTS,
   output logic       o_RX_Done,
   output logic [7:0] o_Rx_Byte
   );
    
  parameter IDLE         = 3'b000;
  parameter RX_START_BIT = 3'b001;
  parameter RX_DATA_BITS = 3'b010;
  parameter RX_STOP_BIT  = 3'b011;
  parameter CLEANUP      = 3'b100;
   
  logic           r_Rx_Data_R;
  logic           r_Rx_Data;
   
  logic [7:0]     r_Clock_Count;
  logic [2:0]     r_Bit_Index; //8 bits total
  logic [7:0]     r_Rx_Byte;
  logic           r_Rx_DV;
  logic [2:0]     r_SM_Main;
   
  // Purpose: Double-register the incoming data.
  // This allows it to be used in the UART RX Clock Domain.
  // (It removes problems caused by metastability)
  always_ff @(posedge i_Clock or negedge rst)
    begin
      if (!rst)
      begin
        r_Rx_Data_R <= 1'b1;
        r_Rx_Data   <= 1'b1;
      end
      else
      begin
        r_Rx_Data_R <= i_Rx_Serial;
        r_Rx_Data   <= r_Rx_Data_R;
      end
    end
   
   
  // Purpose: Control RX state machine
  always_ff @(posedge i_Clock)
    begin
      if (!rst)
      begin
        r_Clock_Count = 0;
        r_Bit_Index   = 0;
        r_Rx_Byte     = 0;
        r_Rx_DV       = 0;
        r_SM_Main     = 0;
      end
      else
      case (r_SM_Main)
        IDLE :
          begin
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (r_Rx_Data == 1'b0)          // Start bit detected
            begin
              o_RX_Done <= 1'b0;
              r_SM_Main <= RX_START_BIT;
              r_Rx_DV       <= 1'b0;
            end
            else
            begin
              r_SM_Main <= IDLE;
            end
          end
         
        // Check middle of start bit to make sure it's still low
        RX_START_BIT :
          begin
            if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
              begin
                if (r_Rx_Data == 1'b0)
                  begin
                    r_Clock_Count <= 0;  // reset counter, found the middle
                    r_SM_Main     <= RX_DATA_BITS;
                  end
                else
                  r_SM_Main <= IDLE;
              end
            else
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= RX_START_BIT;
              end
          end // case: s_RX_START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        RX_DATA_BITS :
          begin
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= RX_DATA_BITS;
              end
            else
              begin
                r_Clock_Count          <= 0;
                r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                 
                // Check if we have received all bits
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= RX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= RX_STOP_BIT;
                  end
              end
          end // case: s_RX_DATA_BITS
     
     
        // Receive Stop bit.  Stop bit = 1
        RX_STOP_BIT :
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= RX_STOP_BIT;
              end
            else
              begin
                r_Clock_Count <= 0;
                o_RX_Done <= 1'b1;
                r_SM_Main     <= CLEANUP;
              end
          end // case: s_RX_STOP_BIT
     
         
        // Stay here 1 clock
        CLEANUP :
          begin
            if(!full && wr_ready)
            begin
              r_SM_Main <= IDLE;
              r_Rx_DV   <= 1'b1;
            end
            else
            begin
              r_SM_Main <= CLEANUP;
            end
          end
         
         
        default :
          r_SM_Main <= IDLE;
         
      endcase
    end   
   
  assign o_CTS   = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;
   
endmodule // uart_rx