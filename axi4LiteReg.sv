// ============================================================================= //
// Designer:       Jose Iuri B. de Brito -  jose.brito@embedded.ufcg.edu.br                     //             //
//                 Rubbens Fernandes Roux - rubens.abrantes@embedded.ufcg.edu.br                                                              //
//
// Design Name:    AXI4LIte Registers Bank                                       //
// Module Name:    axi4LiteReg                                                   //
//                                                                               //
// ============================================================================= //

//
// This file contains the AXI4Lite Registers, used to comunnicate with the FIFO for
// bridge btween peripheals.
//

module axi4LiteReg
(
    input logic clk,
    input logic rst,
    //interface start
    input logic        wr_amba,
    input logic [31:0] addr_rc,
    input logic [31:0] addr_wc,
    output logic [31:0] data_out, // 2Interface
    input logic [3:0]  strb,

    input logic  [31:0] data_in, // 4Interface
    //interface end

    input logic [31:0] rx_data,
    output logic [31:0] tx_data,

    output logic rxReady,
    input logic  rxValid,
    output logic txValid,
    input logic  txReady
);

logic [31:0] regs [2];

assign data_out = regs[addr_rc[2]];
assign rxReady = 1'b1; // always ready.
assign tx_data = regs[0];


always_ff @ (posedge clk our negedge rst)
begin
    if(!rst)
    begin
        regs[0] <= 0;
        regs[1] <= 0;
        txValid <= 0;
    end
    else
    begin
        if(wr_amba)
        begin
            regs[addr_wc[2]] <= (strb == 0) ? data_in : {(strb[3]) ? data_in[31:24] : regs[addr_wc[2]][31:24],
                                                         (strb[2]) ? data_in[23:16] : regs[addr_wc[2]][23:16],
                                                         (strb[1]) ? data_in[15: 8] : regs[addr_wc[2]][15: 8],
                                                         (strb[0]) ? data_in[ 7: 0] : regs[addr_wc[2]][ 7: 0]};
            txValid <= 1'b1;
        end
        if(txReady && txValid)
        begin
            txValid <= 1'b0;
        end
        if(rxValid)
        begin
            regs[1] <= rx_data;
        end
    end
end

endmodule // axi4LiteReg