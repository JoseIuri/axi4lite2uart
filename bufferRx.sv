`timescale 1ns/100ps
// ============================================================================= //
// Designer:       Jose Iuri B. de Brito -  jose.brito@embedded.ufcg.edu.br      //             //
//
// Design Name:    Buffer for Reception                                          //
// Module Name:    bebufferRx                                                    //
//                                                                               //
// ============================================================================= //

//
// This file contains the debuffer for Reception, used to convert 8 bits mensage 
// to 32 bits mensage.

module bufferRx (
	input logic clk,    // Clock
	input logic rst,

    output logic rxValid,
    input logic  empty,
    input logic  rxReady,
    output logic outReady,
    input logic outValid,

	output logic [31:0] data_out,
	input logic [7:0] data_in
	
);

typedef enum logic[2:0] {
	cleanup,
	first,
	second,
	third,
	fourth,
	send
} BUFFER_STATE;

BUFFER_STATE STATE_buffer;

logic [31:0] register;

always_ff @(posedge clk or negedge rst)
begin
	if (!rst)
	begin
		STATE_buffer <= cleanup;
		register <= 0;
		data_out <= 0;
		rxValid <= 1'b0;
	end
	else
	begin
		unique case (STATE_buffer)
		cleanup:
		begin
			rxValid <= 1'b0;
			outReady <= 1'b1;
			STATE_buffer <= first;
		end
		first:
		begin
			if(!empty && outValid)
			begin
				rxValid <= 1'b0;
				register[7:0] <= data_in;
				outReady <= 1'b1;
				STATE_buffer <= second;
			end
			else
			begin
				STATE_buffer <= first;
			end
		end
		second:
		begin
			if(!empty && outValid)
			begin
				rxValid <= 1'b0;
				register[15:8] <= data_in;
				outReady <= 1'b1;
				STATE_buffer <= third;
			end
			else
			begin
				STATE_buffer <= second;
			end			
		end
		third:
		begin
			if(!empty && outValid)
			begin
				rxValid <= 1'b0;
				register[23:16] <= data_in;
				outReady <= 1'b1;
				STATE_buffer <= fourth;
			end
			else
			begin
				STATE_buffer <= third;
			end
		end
		fourth:
		begin
			if(!empty && outValid)
			begin
				rxValid <= 1'b0;
				register[31:24] <= data_in;
				outReady <= 1'b0;
				STATE_buffer <= send;
			end
			else
			begin
				STATE_buffer <= fourth;
			end			
		end
		send:
		begin	
			if(rxReady)
			begin
				data_out <= register;
				rxValid <= 1'b1;
				outReady <= 1'b0;
				STATE_buffer <= cleanup;
			end
			else
			begin
				STATE_buffer <= send;
			end
		end
		endcase // STATE_buffer
	end
end
endmodule