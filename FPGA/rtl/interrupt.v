/*
 * interrupt.v - Interrupt handler 
 *
 * Manages the interrupt lines, requires a read to 
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

module interrupt_manager ( 
		// These are the individual interrupt lines
		input [7:0] interrupt_lines_i,
		// Read interrupt state
		input n_rd_i,		
		// Interrupt line
		output n_int_o,
		// Interrupt register
		output [7:0] dat_o
	);

	// Wire definitions ===========================================================================
	wire [7:0] lines;

	// Registers ==================================================================================
	
	// Assignments ================================================================================
	assign n_int_o = (lines == 0);	// Cause an interrupt if one line is active
	assign dat_o = lines;
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	// Note that when RD cycle finishes then it resets all latches
	SR sr1( .S( interrupt_lines_i[0]), .R(n_rd_i), .Q(lines[0]) );
	SR sr2( .S( interrupt_lines_i[1]), .R(n_rd_i), .Q(lines[1]) );
	SR sr3( .S( interrupt_lines_i[2]), .R(n_rd_i), .Q(lines[2]) );
	SR sr4( .S( interrupt_lines_i[3]), .R(n_rd_i), .Q(lines[3]) );
	SR sr5( .S( interrupt_lines_i[4]), .R(n_rd_i), .Q(lines[4]) );
	SR sr6( .S( interrupt_lines_i[5]), .R(n_rd_i), .Q(lines[5]) );
	SR sr7( .S( interrupt_lines_i[6]), .R(n_rd_i), .Q(lines[6]) );
	SR sr8( .S( interrupt_lines_i[7]), .R(n_rd_i), .Q(lines[7]) );
	
	// Other logic ================================================================================
	
endmodule
	
module SR(
	input S,
	input R,
	output Q
);
	reg out;	// Need to reset before use, default is powerup high
	
	assign Q = out;
	
	always @(posedge S or posedge R)
	begin
		if( S ) 
			out <= 1'b1;
		else
		if( R )
			out <= 1'b0;
	end
endmodule
