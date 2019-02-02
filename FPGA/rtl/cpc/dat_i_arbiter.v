/*
 * dat_i_arbiter - arbitrate data coming into the CPU
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

module dat_i_arbiter(
		// Clock
		input wire clock_i,

		// Output
		output wire [7:0] D,
		
		// Lower Rom module
		input [7:0] l_rom,
		input l_rom_e,
		
		// Lower Rom module
		input [7:0] u_rom,
		input u_rom_e,

		// Ram module
		input [7:0] ram,
		input ram_e,

		// Extended Ram modules
		input [7:0] eram,
		input u_ram_e,
		
		// Standard 8255 PIO
		input [7:0] pio8255,
		input pio8255_e,
		
		// Printer IO
		input [7:0] io,
		input io_e,
		
		// FDC IO
		input [7:0] fdc,
		input fdc_e
	);

	// Wire definitions ===========================================================================

	// Registers ==================================================================================

	// Assignments ================================================================================
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================
	
	//always @(negedge clock_i)
	assign D =	(l_rom_e) ? l_rom :
					(u_rom_e) ? u_rom :
					(u_ram_e) ? eram :
					(ram_e) ? ram :
					(pio8255_e) ? pio8255 :
					(io_e) ? io :
					(fdc_e) ? fdc :
					8'd255;
endmodule
