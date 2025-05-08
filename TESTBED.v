/**************************************************************************/
// Copyright (c) 2024, OASIS Lab
// MODULE: TESTBED
// FILE NAME: TESTBED.v
// VERSRION: 1.0
// DATE: July 26, 2024
// AUTHOR: Yu-Hsuan Hsu, NYCU IEE
// DESCRIPTION: ICLAB2024FALL / LAB3 / TESTBED
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/
`timescale 1ns/10ps

`include "PATTERN.v"
`ifdef RTL
    `include "SRAM_Controller.v"
`endif
`ifdef GATE
    `include "SRAM_Controller_SYN.v"
`endif

module TESTBED;

wire clk;
wire rst_n;
wire in_valid;
wire addr_valid;
wire [7:0] in_data;
wire [5:0] addr;
wire out_valid;
wire [31:0] out_data;


initial begin
    `ifdef RTL
        $fsdbDumpfile("SRAM_Controller.fsdb");
        $fsdbDumpvars(0,"+mda");
    `endif
    `ifdef GATE
        $sdf_annotate("SRAM_Controller_SYN.sdf", u_SRAM_Controller);
        $fsdbDumpfile("SRAM_Controller_SYN.fsdb");
        $fsdbDumpvars(0,"+mda"); 
    `endif
end

SRAM_Controller u_SRAM_Controller(
	.clk		(clk),
	.rst_n		(rst_n),
	.in_valid	(in_valid),
	.in_data	(in_data),
	.addr_valid	(addr_valid),
	.addr		(addr),
	.out_valid	(out_valid),
	.out_data	(out_data)
);
    
PATTERN u_PATTERN(
	.clk		(clk),
	.rst_n		(rst_n),
	.in_valid	(in_valid),
	.in_data	(in_data),
	.addr_valid	(addr_valid),
	.addr		(addr),
	.out_valid	(out_valid),
	.out_data	(out_data)
);

endmodule
