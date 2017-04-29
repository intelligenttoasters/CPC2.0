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

module video(
	input clk_i,
	output hsync,
	output vsync,
	output de,
	output clk_o,
	output [7:0] r,
	output [7:0] g,
	output [7:0] b
	);

	// Wire definitions ===========================================================================

	// Registers ==================================================================================
	reg [10:0] hor = 0;
	reg [9:0] ver = 0;
	reg HSYNC,VSYNC,DE;
	
	reg [7:0] rs = 0;
	reg [7:0] gs = 0;
	reg [7:0] bs = 0;
	// Assignments ================================================================================

	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================

	// Move the counters
	always @(negedge clk_i)
	begin
		if( hor < 11'd1056 )
			hor <= hor + 1'b1;
		else begin
			hor <= 11'd0;
			//ver <= (ver < 628) ? ver + 1'b1 : 1'b0;
			if( ver < 628 )
			begin
				ver <= ver + 1'b1;
				bs <= bs - 1'b1;
			end else begin
				ver <= 0;
				bs <= 0;
			end;
		end
	end

	// Valid during screen on
	assign de = (hor >= 216) && (hor < 1016) && (ver >= 27) && (ver < 627);
	
	// Syncs
	assign hsync = (hor < 128);	// Pos sync
	assign vsync = (ver < 4);		// Pos sync
	
	// Clock
	assign clk_o = clk_i;

	// Generate colour bars
	always @(posedge clk_i)
	begin
		if( !de )
		begin
			rs <= 0;
			gs <= 0;
		end else begin
			rs <= rs + 1'b1;
			gs <= gs - 1'b1;
		end
	end

wire [7:0] rs1 = {rs[7:3],3'd0};
wire [7:0] gs1 = {gs[7:3],3'd0};
wire [7:0] bs1 = {bs[7:3],3'd0};

	assign r = (de) ? rs1 : 0;
	assign g = (de) ? gs1 : 0;
	assign b = (de) ? bs1 : 0;
endmodule
	
