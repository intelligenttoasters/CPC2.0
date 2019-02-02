/*
 * tfr_mem.v - Memory transfer function
 *
 * Allows the support CPU to store stuff in the SDRAM memory
 *
 * Part of the CPC2 project: http://intelligenttoasters.blog
 *
 * Copyright (C)2018 Intelligent.Toasters@gmail.com
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
 * Registers are: 
 * 		0,1,2 Address of SDRAM memory (24 bits)
 * 		4 - WRITEONLY - Mark rom 1-31 as populated or un populated (Bit 7 = state, 4-0 = rom #)
 *			4 - READONLY - Get ROM status flags ROMs 0-7
 *			5 - READONLY - Get ROM status flags ROMs 8-15
 *			6 - READONLY - Get ROM status flags ROMs 16-23
 *			7 - READONLY - Get ROM status flags ROMs 24-31
 *			F - Write only - Data out
 */
`timescale 1ns/1ns

module tfr_mem ( 
	// Signals
	input wire memclk_i,
	output reg [23:0]	bus_A_o,
	output reg [7:0] bus_D_o,
	output reg [31:0] romflags_o,
	// Bus signals
	input busclk_i,	// Clock for bus signals
	input nreset_i,
	input [3:0] A_i,	// 10x8-bit registers, representing the 80 keys
	input [7:0] D_i,
	output reg [7:0] D_o,
	input nWR_i,
	input nRD_i	
	);

	// Wire definitions ===========================================================================

	// Registers ==================================================================================
	reg [23:0] addr_io;
	
	// Assignments ================================================================================
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================
	
	function [7:0] lookup_register( input [3:0] a );
		case( a )
			4'h0: lookup_register = addr_io[7:0];
			4'h1: lookup_register = addr_io[15:8];
			4'h2: lookup_register = addr_io[23:16];
			4'h4: lookup_register = romflags_o[7:0];
			4'h5: lookup_register = romflags_o[15:8];
			4'h6: lookup_register = romflags_o[23:16];
			4'h7: lookup_register = romflags_o[31:24];
			default: lookup_register = 8'hff;
		endcase
	endfunction
	
	// Write a register by reference should match below for clarity, not function
	task write_register(
		input [3:0] a,
		input [7:0] d
	);		
		case( a )
			4'h0: addr_io[7:0] <= d;
			4'h1: addr_io[15:8] <= d;
			4'h2: addr_io[23:16] <= d;
			4'h4: romflags_o[d[4:0]] <= d[7];
			4'hf: bus_D_o <= d;
			default: ;
		endcase
	endtask
	
	// IO Domain clock
	always @(posedge busclk_i)
	begin
		if( !nreset_i ) begin
			addr_io <= 24'd0;
			bus_D_o <= 8'd0;
			romflags_o <= 32'd0;
		end
		else begin
			if( !nRD_i ) D_o <= lookup_register(A_i);
			if( !nWR_i ) begin
				write_register(A_i,D_i);
				if( A_i == 4'hf ) addr_io <= addr_io + 1'b1;
			end
		end
	end
	
	// Memory Domain Clock
	always @(posedge memclk_i)
	begin
		bus_A_o <= (addr_io -1'b1);	// Correction for early increment
	end
	
endmodule
	
