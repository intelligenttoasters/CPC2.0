/*
 * keyboard.v - Keyboard interface for CPC
 *
 * Connects to the support CPU to set the appropriate keys.
 * Note this is POSITIVE logic, rather than negative logic of the CPC keyboard
 * Set a key bit to 1 to indictate 'down' or 0 for 'up'
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

module keyboard ( 
	output reg [79:0] keyboard_o,
	// Bus signals
	input busclk_i,	// Clock for bus signals
	input nreset_i,
	input [3:0] A_i,	// 10x8-bit registers, representing the 80 keys
	input [7:0] D_i,
	output reg [7:0] D_o,
	input nWR_i,
	input nRD_i	
	);

	// Wire definitions ===========================================================================

	// Registers ==================================================================================
	reg [79:0] keyboard;
	
	// Assignments ================================================================================
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================
	always @(posedge busclk_i)
	begin
		if( !nreset_i ) begin
			keyboard <= 80'd0;
			keyboard_o <= ~(80'd0);
		end
		else begin
			if( !nRD_i ) begin
				D_o <= 	(A_i == 4'd0) ? keyboard[7:0] :
							(A_i == 4'd1) ? keyboard[15:8] :
							(A_i == 4'd2) ? keyboard[23:16] :
							(A_i == 4'd3) ? keyboard[31:24] :
							(A_i == 4'd4) ? keyboard[39:32] :
							(A_i == 4'd5) ? keyboard[47:40] :
							(A_i == 4'd6) ? keyboard[55:48] :
							(A_i == 4'd7) ? keyboard[63:56] :
							(A_i == 4'd8) ? keyboard[71:64] :
							(A_i == 4'd9) ? keyboard[79:72] : 
							8'd0;
			end
			if( !nWR_i ) begin
				if( A_i > 4'd9 ) begin		// Writing to other ports is the control reg
					if( D_i[7] ) begin
						keyboard <= 80'd0;
						keyboard_o = ~(80'd0);
					end
					else
						if( D_i[0] )
							keyboard_o <= ~keyboard;
				end
				else
				keyboard <= {
							(A_i != 4'd9) ? keyboard[79:72] : D_i,
							(A_i != 4'd8) ? keyboard[71:64] : D_i,
							(A_i != 4'd7) ? keyboard[63:56] : D_i,
							(A_i != 4'd6) ? keyboard[55:48] : D_i,
							(A_i != 4'd5) ? keyboard[47:40] : D_i,
							(A_i != 4'd4) ? keyboard[39:32] : D_i,
							(A_i != 4'd3) ? keyboard[31:24] : D_i,
							(A_i != 4'd2) ? keyboard[23:16] : D_i,
							(A_i != 4'd1) ? keyboard[15:8] : D_i,
							(A_i != 4'd0) ? keyboard[7:0] : D_i
									};
			end
		end
	end
endmodule
	
