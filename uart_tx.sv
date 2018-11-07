`timescale 1ns/100ps
// ============================================================================= //
// Designer:       Jose Iuri B. de Brito - jose.brito@embedded.ufcg.edu.br       //             //
//                                                                               //
// Design Name:    UART Transmitter                                              //
// Module Name:    uart_tx                                                       //
//                                                                               //
// ============================================================================= //

// This file contains the UART Transmitter.  This transmitter is able
// to transmit 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When transmit is complete o_Tx_done will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 25 MHz Clock, 115200 baud UART
// (25000000)/(115200) = 217
 
module uart_tx 
  #(parameter CLKS_PER_BIT = 217)
  (
   input logic       i_Clock,
   input logic       rst,
   input logic       i_RTS,
   input logic       empty,
   input logic       rd_valid,
   input logic [7:0] i_TX_Byte, 
   output logic      o_TX_Active,
   output logic      o_TX_Serial,
   output logic      o_TX_Done
   );
 
  parameter IDLE         = 3'b000;
  parameter TX_START_BIT = 3'b001;
  parameter TX_DATA_BITS = 3'b010;
  parameter TX_STOP_BIT  = 3'b011;
  parameter CLEANUP      = 3'b100;
  
  logic [2:0] r_SM_Main;
  logic [7:0] r_Clock_Count;
  logic [2:0] r_Bit_Index;
  logic [7:0] r_TX_Data;
  logic       r_TX_Done;
  logic       r_TX_Active;
    
  always_ff @(posedge i_Clock or negedge rst)
  begin
    if (!rst)
    begin
      r_SM_Main     <= 0;
      r_Clock_Count <= 0;
      r_Bit_Index   <= 0;
      r_TX_Data     <= 0;
      r_TX_Done     <= 0;
      r_TX_Active   <= 0;
    end
    else
    begin
      case (r_SM_Main)
        IDLE :
          begin
            o_TX_Serial   <= 1'b1;         // Drive Line High for Idle
            r_TX_Done     <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
            
            if(!empty)
            begin
              if (i_RTS == 1'b1 && rd_valid)
              begin
                r_TX_Active <= 1'b1;
                r_TX_Data   <= i_TX_Byte;
                r_SM_Main   <= TX_START_BIT;
              end
              else
                r_SM_Main <= IDLE;
            end
            else
            begin
              r_SM_Main <= IDLE;
            end
          end // case: IDLE
        
        
        // Send out Start Bit. Start bit = 0
        TX_START_BIT :
          begin
            o_TX_Serial <= 1'b0;
            
            // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
            begin
              r_Clock_Count <= r_Clock_Count + 1;
              r_SM_Main     <= TX_START_BIT;
            end
            else
            begin
              r_Clock_Count <= 0;
              r_SM_Main     <= TX_DATA_BITS;
            end
          end // case: TX_START_BIT
        
        
        // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
        TX_DATA_BITS :
          begin
            o_TX_Serial <= r_TX_Data[r_Bit_Index];
            
            if (r_Clock_Count < CLKS_PER_BIT-1)
            begin
              r_Clock_Count <= r_Clock_Count + 1;
              r_SM_Main     <= TX_DATA_BITS;
            end
            else
            begin
              r_Clock_Count <= 0;
              
              // Check if we have sent out all bits
              if (r_Bit_Index < 7)
              begin
                r_Bit_Index <= r_Bit_Index + 1;
                r_SM_Main   <= TX_DATA_BITS;
              end
              else
              begin
                r_Bit_Index <= 0;
                r_SM_Main   <= TX_STOP_BIT;
              end
            end 
          end // case: TX_DATA_BITS
        
        
        // Send out Stop bit.  Stop bit = 1
        TX_STOP_BIT :
          begin
            o_TX_Serial <= 1'b1;
            
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
            begin
              r_Clock_Count <= r_Clock_Count + 1;
              r_SM_Main     <= TX_STOP_BIT;
            end
            else
            begin
              r_TX_Done     <= 1'b1;
              r_Clock_Count <= 0;
              r_SM_Main     <= CLEANUP;
              r_TX_Active   <= 1'b0;
            end 
          end // case: TX_STOP_BIT
        
        
        // Stay here 1 clock
        CLEANUP :
          begin
            r_TX_Done <= 1'b1;
            r_SM_Main <= IDLE;
          end
        
        
        default :
          r_SM_Main <= IDLE;
        
      endcase
    end
  end
  
  assign o_TX_Active = r_TX_Active;
  assign o_TX_Done   = r_TX_Done;
  
endmodule
