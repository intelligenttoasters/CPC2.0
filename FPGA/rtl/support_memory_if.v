/*
 * super_memory_if - interface between the memory and 
 * the data bus of the supervisor CPU
 *
 * Part of the CPC2 project: http://intelligenttoasters.blog
 *
 * Copyright (C)2017  Intelligent.Toasters@gmail.com
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, you can find a copy here:
 * https://www.gnu.org/licenses/gpl-3.0.en.html
 *
 */
`timescale 1ns/1ns

module support_memory_if(
	input clk,
	input [15:0] A,
	input [7:0] Din,
	output [7:0] Dout,
	input wr,
	output mem_wait
);
	assign mem_wait = 1'b0;
	
	// CPU Memory Interface
	`ifndef SIM
		ram	ram (
			.address ( A ),
			.clock ( clk ),
			.data ( Din),
			.wren ( wr ),
			.q ( Dout )
			);
	`else
		reg [7:0] ram[0:65535];
		// Permanently wire rom to DIN
		assign Dout = ram[A];
		// RAM Write
		always @(posedge wr)
			ram[A] = Din;
	`endif

endmodule
