/*
 * video.v Fake video driver
 *
 * This is a temporary display engine that simply renders the content of the 
 * screen buffer, ignoring the CRTC. This will be replaced by a proper render
 * when memory is available.
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
	output [7:0] b,
	output [15:0] A_o,
	input [7:0] D_i,
	input [15:0] video_offset_i
	);

	parameter offset_x = 80;
	parameter offset_y = 100;
	
	// Wire definitions ===========================================================================

	// Registers ==================================================================================
	reg [10:0] hor = 0;
	reg [9:0] ver = 0;
	reg [10:0] pixel_x;
	reg [9:0] pixel_y;
	reg [15:0] video_offset;
	reg [15:0] video_offset_delay;
	
	reg [15:0] A = 0;
	reg [7:0] rs = 0;
	reg [7:0] gs = 0;
	reg [7:0] bs = 0;
	// Assignments ================================================================================

	assign A_o = A;
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================

	// Synchronizer chain for offset
	always @(negedge clk_i) video_offset_delay <= video_offset_i;
	
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
				video_offset = video_offset_delay;
			end
		end
	end

	// Valid during screen on
	assign de = (hor >= 216) && (hor < 1016) && (ver >= 27) && (ver < 627);
	
	// Syncs
	assign hsync = (hor < 128);	// Pos sync
	assign vsync = (ver < 4);		// Pos sync
	
	// Clock
	assign clk_o = clk_i;
	
	// Generate picture here =========================
	always @(posedge clk_i)
	begin
		// Display (DE) starts at pixel 216, so give us the timespan of 8 pixels
		// To gather the data for the display, then pipeline the output
		pixel_x <= hor - 11'd208;	// Not 216
		pixel_y <= ver - 10'd27 - offset_y;
	end
	
	// Convert X/Y to Address
	wire [8:0] row = pixel_y[9:1];	// Duplicate rows
	// Weird CPC offsets, every row is 2048 bytes offset
	wire [10:0] Ay = (row[7:3] * 80);
	wire [10:0] Axy = Ay + pixel_x[9:3];	// Div pixels by 8
	wire [10:0] Atotal = Axy + video_offset[10:0];
	// Set the address on negative clock because memory is strobed on positive clock
	always @(negedge clk_i) A <= {video_offset[15:14], row[2:0], Atotal};
	
	// Calculate the pixel (assume mode 1, so pixels 1+2,3+4,5+6,7+8 are duplicated)
	// Don't care which color, so OR the bits, if not pen 0 then display
	reg [0:7] pixels;
	always @(negedge clk_i)
		if ( pixel_x[2:0] == 3'd0 )
			pixels <= 
				{
					D_i[7] | D_i[3], D_i[7] | D_i[3],
					D_i[6] | D_i[2], D_i[6] | D_i[2],
					D_i[5] | D_i[1], D_i[5] | D_i[1],
					D_i[4] | D_i[0], D_i[4] | D_i[0]
				};
		else
			pixels <= {pixels[1:7],1'b0};	// Shift
	
	// Use 648 as the last pixel location because pipeline needs 8 bits to read the memory
	// So the end of the display is 8 pixels after the last pixel set has been obtained
	wire en = de && (pixel_x < 10'd648) && (pixel_y < 10'd400);

	assign r = (en) ? ((pixels[0]) ? 8'hf8 : 8'h0) : 8'd0;
	assign g = (en) ? ((pixels[0]) ? 8'hf8 : 8'h0) : 8'd0;
	assign b = (en) ? ((pixels[0]) ? 8'h00 : 8'h7d) : 8'd0;
/*
	assign r = (en) ? ((pixels[0]) ? 8'h00 : 8'hff) : 8'd0;
	assign g = (en) ? ((pixels[0]) ? 8'h00 : 8'hff) : 8'd0;
	assign b = (en) ? ((pixels[0]) ? 8'h00 : 8'hff) : 8'd0;
*/	
endmodule
