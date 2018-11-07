`timescale 1ns/100ps
// ============================================================================= //
// Designer:       Jose Iuri B. de Brito -  jose.brito@embedded.ufcg.edu.br      //
//                 Rubbens Fernandes Roux - rubens.abrantes@embedded.ufcg.edu.br //
//                                                                               //
// Design Name:    Sybnchronous FIFO                                             //
// Module Name:    syn_fifo                                                      //
//                                                                               //
// ============================================================================= //

//
// This file contains the FIFO for comunnication between UART modules and AXI4Lite 
// modules

module syn_fifo (
clk      , // Clock input
rst      , // Active low reset
data_in  , // Data input
rd_en    , // Read enable
rd_valid , // Read Valid
wr_en    , // Write Enable
wr_ready , // Write ready
data_out , // Data Output
empty    , // FIFO empty
full       // FIFO full
);    
 
// FIFO constants
parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 8;
parameter RAM_DEPTH = (1 << ADDR_WIDTH);
// Port Declarations
input logic clk ;
input logic rst ;
input logic rd_en ;
input logic wr_en ;
output logic rd_valid;
output logic wr_ready;
input logic [DATA_WIDTH-1:0] data_in ;
output logic full ;
output logic empty ;
output logic [DATA_WIDTH-1:0] data_out ;

logic [DATA_WIDTH-1:0] fila [RAM_DEPTH];

//-----------Internal variables-------------------
logic [ADDR_WIDTH-1:0] wr_pointer;
logic [ADDR_WIDTH-1:0] rd_pointer;
logic [ADDR_WIDTH :0] status_cnt;

//-----------Variable assignments---------------
assign full = (status_cnt == (RAM_DEPTH-1));
assign empty = (status_cnt == 0);
assign wr_ready = 1'b1;

//-----------Code Start---------------------------
always_ff @(posedge clk or negedge rst)
begin : WRITE_POINTER
  if (!rst) begin
    wr_pointer <= 0;
  end else if (wr_en) begin
    wr_pointer <= wr_pointer + 1;
    fila[wr_pointer] <= data_in;
  end
end

always_ff @(posedge clk or negedge rst)
begin : READ_POINTER
  if (!rst) begin
    rd_pointer <= 0;
    rd_valid <= 0;
  end else if (rd_en) begin
    rd_valid <= 1;
    rd_pointer <= rd_pointer + 1;
  endmodule
end

always_ff  @(posedge clk or negedge rst)
begin : READ_DATA
  if (!rst) begin
    data_out <= 0;
  end else if (rd_en) begin
    
    data_out <= fila[rd_pointer];
  end
end

always_ff @(posedge clk or negedge rst)
begin : STATUS_COUNTER
  if (!rst) begin
    status_cnt <= 0;

  // Read but no write.
  end else if ((rd_en) && !(wr_en) && (status_cnt != 0)) begin
    status_cnt <= status_cnt - 1;
  // Write but no read.
  end else if ((wr_en) && !(rd_en) && (status_cnt != RAM_DEPTH)) begin
    status_cnt <= status_cnt + 1;
  end
end 


endmodule