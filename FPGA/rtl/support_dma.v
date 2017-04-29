/*
 * support_dma - processes DMA on the support memory 
 *
 * Used for uploading code to the suport CPU
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

module support_dma ( 
		input 			clk_i,
		input 			enable_i,	// When this goes high, it resets the state machine to first state
		input 			d_avail_i,	// Goes high when data is available
		input [7:0]		data_i,
		output [15:0] 	adr_o,		// DMA address
		output [7:0]	data_o,
		output 			wr_o,			// To memory
		output			rd_o,			// To SPI
		output			n_reset_o	// To clear the SPI before starting
	);

	// Wire definitions ===========================================================================

	// Registers ==================================================================================
	reg [2:0] 	state = 3'd0;
	reg [15:0] 	address = 0;
	reg 			mem_wr = 0;
	reg			spi_rd = 0;
	reg			n_reset = 1;
	
	// Assignments ================================================================================
	assign adr_o = address;
	assign wr_o = mem_wr;
	assign rd_o = spi_rd;
	assign data_o = data_i;
	assign n_reset_o = n_reset;
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	
	always @(posedge clk_i)
	begin
		case (state)
			0 :begin
				address <= 16'd0;
				mem_wr <= 0;
				spi_rd <= 0;
				if( enable_i ) state <= 3'd1;
			end
			1 :begin
				n_reset <= 0;
				state <= 3'd2;
				end
			2 :begin
				n_reset <= 1;
				if( !enable_i ) 
					state <= 3'd0;
				else
					if( d_avail_i )
						state <= 3'd3;
			end
			3 :begin
				spi_rd <= 1'b1;
				state <= 3'd4;
			end
			4 :begin
				spi_rd <= 1'b0;
				mem_wr <= 1'b1;
				state <= 3'd5;
			end
			5 :begin
				mem_wr <= 1'd0;
				address <= address + 1'b1;
				state <= 3'd2;
			end
			default:
				state <= 3'd0;
		endcase
	end
	// Other logic ================================================================================
	
endmodule
	
