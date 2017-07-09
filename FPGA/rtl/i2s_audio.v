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

module i2s_audio ( 
	input clk_i,
	input [15:0] left_i,
	input [15:0] right_i,
	output reg [3:0] i2s_o,
	output reg lrclk_o,
	output sclk_o
	);

	// Wire definitions ===========================================================================
	wire squelch_l, squelch_r;
	
	// Registers ==================================================================================
  reg [5:0] bit_cntr = 0;
  reg [3:0] i2s = 0;
  reg [63:0] shift_reg = 64'd0;
  reg delayed_out = 0;
  // Synchronizer chain
  reg [15:0] left_buffer[0:2];
  reg [15:0] right_buffer[0:2];
  // Audio squelch
	reg [15:0] last_l = 0, last_r = 0;
	reg [8:0] squelch_timeout_l;	// 46.875Hz cut-off
	reg [8:0] squelch_timeout_r;	// 46.875Hz cut-off
	
	// Assignments ================================================================================
  assign sclk_o = clk_i;
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	
  // Update output lines on negative edge because HDMI chip reads on posedge
  always @(negedge clk_i)
	begin
  	lrclk_o <= bit_cntr[5];
  	i2s_o[0] <= i2s[0];
  	i2s_o[1] <= i2s[1];
  	i2s_o[2] <= i2s[2];
  	i2s_o[3] <= i2s[3];
	end
 
  // Repeatedly counts 0-63 bits out
  always @(posedge clk_i)
      bit_cntr <= bit_cntr + 1'b1;
//  always @(negedge clk_i)
//	bit_cntr_delayed <= bit_cntr;
 
  // Shift the bits out
  always @(negedge clk_i)
  begin
	if( bit_cntr == 6'd63 )
	{delayed_out, shift_reg} <= {shift_reg[63],left_buffer[0],16'd0,right_buffer[0],16'd0};
	else
	{delayed_out,shift_reg} <= {shift_reg,1'b0};
  end
 
  // Send MSB to output, note this delays the data by one clock as required for the LRCLK
  always @(posedge clk_i)
  begin
	i2s[0] <= delayed_out;
	i2s[1] <= delayed_out;
	i2s[2] <= delayed_out;
	i2s[3] <= delayed_out;
  end
 
	// Synchronizer for input
	always @(posedge clk_i)
	begin
		{left_buffer[0],left_buffer[1],left_buffer[2]} <= {left_buffer[1],left_buffer[2],(!squelch_l) ? left_i : 0};
		{right_buffer[0],right_buffer[1],right_buffer[2]} <= {right_buffer[1],right_buffer[2],(!squelch_r) ? right_i : 0};
	end

	// Other logic ================================================================================
	// Audio squelch
	assign squelch_l = (squelch_timeout_l == 0);
	always @(negedge clk_i)
	begin
		if( last_l == left_i )
		begin
			if( !squelch_l )
				squelch_timeout_l <= (squelch_timeout_l != 0) ? squelch_timeout_l - 1'b1 : 0;
		end
		else
		begin
			last_l <= left_i;
			squelch_timeout_l <= 9'h1ff;
		end	
	end
	
	assign squelch_r = (squelch_timeout_r == 0);
	always @(negedge clk_i)
	begin
		if( last_r == left_i )
		begin
			if( !squelch_r )
				squelch_timeout_r <= (squelch_timeout_r != 0) ? squelch_timeout_r - 1'b1 : 0;
		end
		else
		begin
			last_r <= left_i;
			squelch_timeout_r <= 9'h1ff;
		end	
	end
endmodule
	
