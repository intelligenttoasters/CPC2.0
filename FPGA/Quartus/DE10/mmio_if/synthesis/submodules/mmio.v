/*
 * <file> <desc> 
 *
 * <fulldesc>
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

module mmio ( 
	input clk_i,
	input reset_i,
	input [5:0] addr_i,	// 32-bit addresses, so only 6 bits needed to span 256 bytes of mem
	input write_i,
	input read_i,
	input [31:0] data_i,
	output reg [31:0] data_o,
	output [79:0] keys
	);

	// Wire definitions ===========================================================================
	
	// Registers ==================================================================================
	reg [79:0] keys_r = 80'hffffffffffffffff;

	// Assignments ================================================================================
	assign keys = keys_r;
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================
	
	always @(negedge clk_i)
	if( !reset_i ) begin
		if( write_i ) begin
			case(addr_i)
				0:	keys_r[31:0] <= data_i;
				1:	keys_r[63:32] <= data_i;
				2:	keys_r[79:64] <= data_i[15:0];
			endcase
		end
		if( read_i ) begin
			case(addr_i)
				0:	data_o <= keys_r[31:0];
				1:	data_o <= keys_r[63:32];
				2:	data_o <= {16'hff,keys_r[79:64]};
			endcase
		end
	end
endmodule
	
