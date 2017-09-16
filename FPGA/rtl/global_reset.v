/*
 * global_reset Holds the system in reset for the first few cycles
 *
 * Ensures reset functionality is completed at start up
 * Relies on FPGA setting default value for reset counter
 *
 * Part of the CPC2 project: http://intelligenttoasters.blog
 *
 * Copyright (C)2016  Intelligent.Toasters@gmail.com
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

module global_reset(
	input clock_i,
	input forced_reset_i,		// Data5 from supervisor, active high
	output n_reset_o,				// Global reset, active low
	output n_limited_reset_o	// Special limited reset, just for DMA program upload, not affected by forced_reset_i
	);

	// Wire definitions

	// Registers
	reg [7:0] reset_counter = 1;
	
	// Assignments
	assign n_reset_o 				= (reset_counter <= 1) & !forced_reset_i;	
	assign n_limited_reset_o 	= (reset_counter <= 1);	
	// Reset held high from first tick, then low until register roll over

	// Module connections
	
	// Simulation branches and control
	
	// Other logic
	always @(negedge clock_i)
		if( reset_counter != 0 )
			reset_counter <= reset_counter + 1'd1;
	
endmodule
