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
		// Fast clock input
		input fast_clock_i,
		// These are the individual interrupt lines
		input [7:0] interrupt_lines_i,
		// Read interrupt state
		input rd_i,		
		// Interrupt line
		output n_int_o,
		// Interrupt register
		output [7:0] dat_o
	);

	// Wire definitions ===========================================================================
	wire [7:0] 	lines;
	wire			rd;
	
	// Registers ==================================================================================
	reg [2:0] track_rd;
	
	// Assignments ================================================================================
	assign n_int_o = (lines == 0);	// Cause an interrupt if one line is active
	assign dat_o = lines;
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	always @(posedge fast_clock_i) track_rd <= {track_rd[1:0],rd_i};
	assign rd = (track_rd[2:1] == 2'b10);
	
	// Note that when RD cycle finishes then it resets all latches
	SR sr1( .clock_i(fast_clock_i), .S( interrupt_lines_i[0]), .R(rd), .Q(lines[0]) );
	SR sr2( .clock_i(fast_clock_i), .S( interrupt_lines_i[1]), .R(rd), .Q(lines[1]) );
	SR sr3( .clock_i(fast_clock_i), .S( interrupt_lines_i[2]), .R(rd), .Q(lines[2]) );
	SR sr4( .clock_i(fast_clock_i), .S( interrupt_lines_i[3]), .R(rd), .Q(lines[3]) );
	SR sr5( .clock_i(fast_clock_i), .S( interrupt_lines_i[4]), .R(rd), .Q(lines[4]) );
	SR sr6( .clock_i(fast_clock_i), .S( interrupt_lines_i[5]), .R(rd), .Q(lines[5]) );
	SR sr7( .clock_i(fast_clock_i), .S( interrupt_lines_i[6]), .R(rd), .Q(lines[6]) );
	SR sr8( .clock_i(fast_clock_i), .S( interrupt_lines_i[7]), .R(rd), .Q(lines[7]) );
	
	// Other logic ================================================================================
	
endmodule
	
module SR(
	input clock_i,
	input S,
	input R,
	output Q
);
	reg out;	// Need to reset before use, default is powerup high
	
	assign Q = out;
	
	always @(negedge clock_i)
	begin
		if( S ) 
			out <= 1'b1;
		else
		if( R )
			out <= 1'b0;
	end
endmodule
