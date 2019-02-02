/*
 * up2wb - 8-bit microprocessor to wishbone master interface 
 *
 * This module converts 8-bit IO signals of the Z80 uP to 32-bit wishbone signals
 * Uses 4-bit addressing, 8 bit data, read and write signals
 * Registers:
 * 	B3 	- Control/Status Signal (4'h8-4'hf)
 *    B2 	- Address or Data (0 - data, 1 - address)
 *		B1:0 	- Byte index 0-low byte, 3-high byte
 *
 * Control Signal Data:
 *		B7		- Begin Operation
 *		B6 	- Write Operation
 *		B5:2	- Byte Select
 *		1:0	- Not used
 * Status Signals:
 *		B0		- Busy
 *
 * Part of the CPC2 project: http://intelligenttoasters.blog
 *
 * Copyright (C)2018  Intelligent.Toasters@gmail.com
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
`default_nettype none

module up2wb ( 
	// Master signals
	input wire			clk_i,
	input wire			reset_i,
	// uP Interface
	input wire 	[3:0] A_i,
	input wire 	[7:0] D_i,
	output reg 	[7:0] D_o,
	input wire 			rd_i,
	input wire 			wr_i,
	// WB Master Interface
	output reg [31:0]	adr_o,
	output reg [31:0] dat_o,
	output reg			we_o,
	output reg [3:0]	sel_o,
	output reg 			stb_o,
	output reg			cyc_o,
	input wire [31:0]	dat_i,
	input wire			ack_i
	);

	// Wire definitions ===========================================================================
	wire rd_rise, wr_rise;
	
	// Registers ==================================================================================
	reg [1:0] track_rd, track_wr;
	reg [31:0] dat_store;
	reg busy;
	
	// Assignments ================================================================================
	assign rd_rise = (track_rd == 2'b01);
	assign wr_rise = (track_wr == 2'b01);
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	
	// Synchronizers ==============================================================================
	always @(posedge clk_i) track_rd <= {track_rd[0],rd_i};
	always @(posedge clk_i) track_wr <= {track_wr[0],wr_i};

	// Other logic ================================================================================
	always @(posedge clk_i or posedge reset_i)
	if( reset_i )
	begin
		adr_o <= 32'd0;
		dat_o <= 32'd0;
		we_o <= 1'b0;
		sel_o <= 4'd0;
		stb_o <= 1'b0;
		cyc_o <= 1'b0;
	end else begin
		if( wr_rise )
		begin
			case( A_i[3:2] )
				2'b00: 	// Update dat_o
					begin
						case( A_i[1:0] )
							2'b00: dat_o[7:0] <= D_i;
							2'b01: dat_o[15:8] <= D_i;
							2'b10: dat_o[23:16] <= D_i;
							2'b11: dat_o[31:24] <= D_i;
						endcase
					end
				2'b01:	// Update adr_o
					begin
						case( A_i[1:0] )
							2'b00: adr_o[7:0] <= D_i;
							2'b01: adr_o[15:8] <= D_i;
							2'b10: adr_o[23:16] <= D_i;
							2'b11: adr_o[31:24] <= D_i;
						endcase
					end
				2'b10,2'b11:	// Control operation
					if( D_i[7] ) begin	// Trigger on B7 of data
						sel_o <= D_i[5:2];
						we_o <= D_i[6];
						stb_o <= 1'b1;
						cyc_o <= 1'b1;
					end
			endcase
		end 
		else begin
			if( rd_rise ) 
			begin
				case( A_i[3:2] )
					2'b00: 	// Read dat_store
						begin
							case( A_i[1:0] )
								2'b00: D_o <= dat_store[7:0];
								2'b01: D_o <= dat_store[15:8];
								2'b10: D_o <= dat_store[23:16];
								2'b11: D_o <= dat_store[31:24];
							endcase
						end
					2'b01:	// Read adr_o
						begin
							case( A_i[1:0] )
								2'b00: D_o <= adr_o[7:0];
								2'b01: D_o <= adr_o[15:8];
								2'b10: D_o <= adr_o[23:16];
								2'b11: D_o <= adr_o[31:24];
							endcase
						end
					2'b10,2'b11:	// Status operation
						D_o <= {1'b0, we_o, sel_o, 1'b0, busy};
				endcase
			end
			else if( ack_i ) begin
				stb_o <= 1'b0;
				cyc_o <= 1'b0;
			end
		end
	end

	always @(posedge clk_i or posedge reset_i)
	if( reset_i ) begin
		dat_store <= 32'd0;
		busy <= 1'b0;
	end
	else begin
		if( ack_i ) begin
			dat_store <= dat_i;
			busy <= 1'b0;
		end
		else	// Set busy on process start
		if( wr_rise & A_i[3] & D_i[7] ) busy <= 1'b1;
	end

endmodule
	
