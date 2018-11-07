`timescale 1ns/100ps
// ============================================================================= //
// Designer:       Jose Iuri B. de Brito -  jose.brito@embedded.ufcg.edu.br      //
//                 Rubbens Fernandes Roux - rubens.abrantes@embedded.ufcg.edu.br //
//																				 //
// Design Name:    Buffer for Transmission                                       //
// Module Name:    bufferTx                                                      //
//                                                                               //
// ============================================================================= //

//
// This file contains the Buffer for Transmission, used to convert 32 bits mensage 
// to 8 bits mensage.


module bufferTx (
	input logic clk,    // Clock
	input logic rst,

    input logic  txValid,
    input logic  full,
    input logic  outReady,
    output logic txReady,
    output logic outValid,

	input logic [31:0] data_in,
	output logic [7:0] data_out
	
);

typedef enum logic[2:0] {
	preset,
	first,
	second,
	third,
	fourth,
	cleanup
} BUFFER_STATE;

BUFFER_STATE STATE_buffer;

logic [31:0] register;

always_ff @(posedge clk or negedge rst)
begin
	if (!rst)
	begin
		STATE_buffer <= preset;
		register <= 0;
		data_out <= 0;
		outValid <= 0;
		txReady <= 1'b1;
	end
	else
	begin
		unique case (STATE_buffer)
		preset:
		begin
			if(txValid)
			begin
				register <= data_in;
				STATE_buffer <= first;
				txReady <= 1'b0;
			end
			else
			begin
				STATE_buffer <= preset;
			end
		end
		first:
		begin
			if(!full && outReady)
			begin
				txReady <= 1'b0;
				outValid <= 1'b1;
				data_out <= register[7:0];
				STATE_buffer <= second;
			end
			else
			begin
				STATE_buffer <= first;
			end
		end
		second:
		begin
			if(!full && outReady)
			begin
				txReady <= 1'b0;
				outValid <= 1'b1;
				data_out <= register[15:8];
				STATE_buffer <= third;
			end
			else
			begin
				STATE_buffer <= second;
			end
		end
		third:
		begin
			if(!full && outReady)
			begin
				txReady <= 1'b0;
				outValid <= 1'b1;
				data_out <= register[23:16];
				STATE_buffer <= fourth;
			end
			else
			begin
				STATE_buffer <= third;
			end
		end
		fourth:
		begin
			if(!full && outReady)
			begin
				txReady <= 1'b0;
				outValid <= 1'b1;
				data_out <= register[31:24];
				STATE_buffer <= cleanup;
			end
			else
			begin
				STATE_buffer <= fourth;
			end
		end
		cleanup:
		begin
			register <= 32'bz;
			outValid <= 1'b0;
			txReady <= 1'b1;
			STATE_buffer <= preset;
		end
		endcase // STATE_buffer
	end
end
endmodule