`timescale 1ns / 1ps
`define WDSel_FromALU 3'b000  
`define WDSel_FromMEM 3'b001
`define WDSel_FromPC 3'b010
module ThreeWayMux(
    input [2:0] WDSel,
    input [31:0] alu_data,
    input [31:0] dm_data,
    input [31:0] pc_data,
    output [31:0]   mux_out
);
assign mux_out = (WDSel==`WDSel_FromALU) ? alu_data :
                 ((WDSel==`WDSel_FromMEM) ? dm_data :
                 pc_data+4);
endmodule