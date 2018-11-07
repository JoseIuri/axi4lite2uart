// ============================================================================= //
// Designer:       Jose Iuri B. de Brito - jose.brito@embedded.ufcg.edu.br       //             //
//                                                                               //
// Design Name:    AXI4Lite to UART bridge                                       //
// Module Name:    axi2uart                                                      //
//                                                                               //
// ============================================================================= //

// This file contains the top module of AXI4 LITE to UART bridge 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87

module axi2uart 
(
	
	axi4_lite_hierarchical	amba_intf,
	input logic				i_RTS,
	input logic				i_Rx_Serial,
	output logic			o_CTS,
	output logic     	    o_TX_Serial,
	output logic			o_TX_Done
);


	parameter CLKS_PER_BIT = 217;

	logic wr_amba;
	logic addr_rc;
	logic addr_wc;
	logic [3:0] strb;
	logic [31:0] if2reg;
	logic [31:0] reg2if;

	logic [31:0] rx_data;
	logic [31:0] tx_data;
	logic rxReady;
	logic rxValid;
	logic txValid;
	logic txReady;

	logic fullTx;
	logic emptyTx;
	logic fullRx;
	logic emptyRx
	logic outEnable;

	logic [7:0] data_in_fifo_TX;
	logic [7:0] o_RX_Byte;
	logic [7:0] data_out_fifo_RX
	logic [7:0] i_TX_Byte;
	logic rd_en_rx;
	logic outReady;
	logic outValid;
	logic outValid_rx;
	logic wr_ready
	logic o_RX_Done;
	logic rd_valid;



	amba_if amba_if (.amba_if(amba_intf), .wr_amba(wr_amba), .data_in(reg2if), .addr_rc(addr_rc),
					 .addr_wc(addr_wc), .data_out(if2reg), .strb(strb));

	ax4LiteReg registerFile(.clk(amba_intf.ACLK), .rst(amba_intf.ACLK), .wr_amba(wr_amba),
	    					.addr_rc(addr_rc), .addr_wc(addr_rc), .data_out(reg2if), .strb(strb),
	   						.data_in(if2reg), .rx_data(.rx_data), .tx_data(.tx_data),
	   						.rxReady(rxReady), .rxValid(rxValid), .txValid(.txValid), .txReady(txReady));

	bufferTx bufferTx( .clk(amba_intf.ACLK), .rst(amba_intf.ACLK), .txValid(txValid), .full(fullTx), .outReady(outReady),
	    			   .txReady(txReady), .outValid(outValid), .data_in(tx_data), .data_out(data_in_fifo_TX));

	bufferRx bufferRx( .clk(amba_intf.ACLK), .rst(amba_intf.ACLK), .rxValid(rxValid), .empty(emptyRx),
	    			   .rxReady(rxReady), .outReady(rd_en_rx), .outValid(outValid_rx), .data_out(rx_data), .data_in(data_out_fifo_RX));

	syn_fifo fifoTx (.clk(amba_intf.ACLK), .rst(amba_intf.ACLK), .data_in(data_in_fifo_TX),
					 .rd_en(i_RTS), .wr_en(outValid), .wr_ready(outReady), .rd_valid(rd_valid), .data_out(i_TX_Byte), .empty(emptyTx),
					 .full(fullTx));

	syn_fifo fifoRx (.clk(amba_intf.ACLK), .rst(amba_intf.ACLK), .data_in(o_RX_Byte),
					 .rd_en(rd_en_rx), .wr_en(o_RX_Done), .wr_ready(wr_ready), .rd_valid(outValid_rx), .data_out(data_out_fifo_RX), .empty(emptyRx),
					 .full(fullRx));

	uart_tx   #(CLKS_PER_BIT) uart_tx ( .i_Clock(amba_intf.ACLK), .rst(amba_intf.ACLK), .i_RTS(i_RTS), .empty(emptyTX),
										.rd_valid(rd_valid), .i_TX_Byte(i_TX_Byte), .o_TX_Active(), .o_TX_Serial(o_TX_Serial),
										.o_TX_Done(o_TX_Done));	

	uart_rx   #(CLKS_PER_BIT) uart_rx ( .i_Clock(amba_intf.ACLK), .rst(amba_intf.ACLK) .i_Rx_Serial(i_Rx_Serial), .wr_ready(wr_ready), .full(fullRx),
										.o_CTS(o_CTS), .o_RX_Done(o_RX_Done), .o_Rx_Byte(o_Rx_Byte));


endmodule