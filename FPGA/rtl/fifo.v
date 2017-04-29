/*
 * fifo.v flexible fifo
 *
 * Flexible fifo
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

module fifo #(
	parameter log2_addr = 3, data_width = 8
	) ( 
	input n_reset_i,
	input clk_i,
	input [data_width-1:0] data_i,
	input wr_i,
	output [data_width-1:0] data_o,
	input rd_i,
	output fifo_empty_o,
	output fifo_full_o
	);
	
	// Wire definitions
	wire [log2_addr-1:0] gray_head; 
	wire [log2_addr-1:0] gray_tail; 

	wire fifo_full;
	wire fifo_empty;
	
	// Registers
	reg [data_width-1:0] out = 0;						// Output register
	reg [data_width-1:0] fifo_buffer [0:2**log2_addr-1] /* synthesis ramstyle = "M10K" */;
	reg [log2_addr:0] 	fifo_head = 0;				// Counters have one more bit to indicate full/empty
	reg [log2_addr:0] 	fifo_tail = 0;				// If lowest bits are the same then the high bit inicates full (high bits different)
																// Or empty (high bits same)
	
	// Assignments
	assign gray_head = fifo_head[log2_addr-1:0] ^ {1'b0, fifo_head[log2_addr-1:1]};
	assign gray_tail = fifo_tail[log2_addr-1:0] ^ {1'b0, fifo_tail[log2_addr-1:1]};
	assign data_o = out; //fifo_buffer[fifo_tail];
	assign fifo_full = (gray_head == gray_tail) & (fifo_head[log2_addr] != fifo_tail[log2_addr]);
	assign fifo_empty = (gray_head == gray_tail) & (fifo_head[log2_addr] == fifo_tail[log2_addr]);
	assign fifo_empty_o = fifo_empty;
	assign fifo_full_o = fifo_full;
	
	// Module connections
	
	// Simulation branches and control
	
	// Move Write Pointers
	always @(negedge n_reset_i or negedge wr_i)
	begin
		if( n_reset_i == 0 ) fifo_head <= 0;	
		else 
		if( !fifo_full ) fifo_head = fifo_head + 1'b1;
	end
	
	// Store data
	always @(posedge wr_i)
		if( !fifo_full ) fifo_buffer[fifo_head] = data_i;	
	
	// Move Read Pointers
	always @(negedge n_reset_i or negedge rd_i)
	begin
		if( n_reset_i == 0 ) 
			fifo_tail <= 0;
		else 
			if( !fifo_empty )
				fifo_tail <= fifo_tail + 1'b1;
	end
	
	// Retrieve data on posedge read signal
	always @(posedge rd_i)
		out <= fifo_buffer[fifo_tail];
		
endmodule
