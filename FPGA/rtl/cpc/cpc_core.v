/*
 * cpc_core - the top level CPC rtl
 *
 * This is the actual CPC rtl
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

`define LO 1'b0
`define HI 1'b1

module cpc_core ( 
		input 			clk_16,
		input 			clk_4,
		input 			clk_1,
		input 			nreset_i,
		// UART Connection to Supervisor
		output uart_tx_o,
		input uart_rx_i,
		// Video signals
		input 			video_clk_i,
		input [15:0] 	video_A_o,
		output [7:0]	video_D_o,
		output [15:0]	video_offset_o,
		// Keyboard signals
		input	[79:0] keyboard_i,
		output [7:0] audio_o
	);

	// Wire definitions ===========================================================================
	wire [15:0] A;
	wire [7:0] DO, DI, l_rom_o, u_rom_o, u_rom0_o, ram_o, vram_o, Dpio, D8255_o;
	wire [7:0] ppia_o, ppia_i, ppic_o, u_rom5_o, u_rom6_o;
	wire nWR, nRD, nMREQ, nIORQ, nROMEN, nM1, cpu_int, l_rom_e, u_rom_e, ram_e;
	wire vsync_signal, hsync_signal;
	wire nIORD = (nIORQ | nRD);
	wire nIOWR = (nIORQ | nWR);
	wire nMEMRD = (nMREQ | nRD);
	wire nMEMWR = (nMREQ | nWR);
	wire [3:0] romsel_o;
	// CRTC / Video data
	wire [13:0]MA;
	wire [4:0]RA;
	wire [23:0] color_dat;
	wire video_border;
	wire [2:0] pixel_num;
	// PIO signals
	wire printer_port_e = (A[12] == `LO);
	wire [1:0] pio_selected_port;
	wire [7:0] portc_dat;	// Used to split port

	// Registers ==================================================================================
	
	// Assignments ================================================================================
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================

	tv80s cpu(
		// Clock and reset control
		.clk(clk_4),
		.reset_n( nreset_i ),
		// System lines
		.int_n(cpu_int),
		.nmi_n(1'b1),
		.busrq_n(1'b1),
		.wait_n(1'b1),
		// Data and address lines
		.di(DI),
		.dout(DO),
		.A(A),
		// control  lines
		.wr_n(nWR),
		.rd_n(nRD),
		.mreq_n(nMREQ),
		.iorq_n(nIORQ),
		.m1_n(nM1),
		.rfsh_n(),
		.halt_n(),
		.busak_n()
		);

	// Data bus arbiter
	dat_i_arbiter di_arbiter(
		.D( DI ),
		.l_rom(l_rom_o),
		.l_rom_e(l_rom_e),
		.u_rom(u_rom_o),
		.u_rom_e(u_rom_e),
		.ram(ram_o),
		.ram_e(ram_e),
		.pio8255(D8255_o),
		.pio8255_e( !A[11] && !nIORD ),
		.io(Dpio),
		.io_e(!nIORD && printer_port_e)
		);
		
	// Arbiter rules
	assign l_rom_e = (A[15:14] == 2'b00) && (nROMEN == 0);
	assign u_rom_e = (A[15:14] == 2'b11) && (nROMEN == 0);
	assign ram_e = !nMEMRD;

	// CPC Ram
	dpram cpc_ram(
		.address_a(A),
		.address_b(video_A_o),
		.data_a(DO),
		.data_b(8'b0),
		.clock_a(clk_16),
		.clock_b(video_clk_i),
		.wren_a(nMEMWR == `LO),
		.wren_b(1'b0),
		.q_a(ram_o),
		.q_b(video_D_o)
		);	
		
	rom #(
		.init_file("../../../roms/lower.mif"),
//		.init_file("../../../roms/OS464-edited.mif"),
		.ram_type("M10K")
		//.lpm_hint("ENABLE_RUNTIME_MOD = YES, INSTANCE_NAME = lrom")
		) 
	lower_rom(
		.address(A[13:0]),
		.clock(clk_16),
		.q(l_rom_o));	

	rom #(
		.init_file("../../../roms/upper.mif"),
 		.ram_type("M10K")
		//.lpm_hint("ENABLE_RUNTIME_MOD = YES, INSTANCE_NAME = ur00")
		) 
	upper_rom0(
		.address(A[13:0]),
		.clock(clk_16),
		.q(u_rom0_o));	

	small_rom #(
		.init_file("../../../roms/custom.mif"),
		.ram_type("M10K")
		//.lpm_hint("ENABLE_RUNTIME_MOD = YES, INSTANCE_NAME = max")
		)
	upper_rom5(
		.address(A[13:0]),
		.clock(clk_16),
		.q(u_rom5_o));	

	rom #(
		.init_file("../../../roms/maxam.mif"),
		.ram_type("MLAB")
		//.lpm_hint("ENABLE_RUNTIME_MOD = YES, INSTANCE_NAME = max")
		) 
	upper_rom6(
		.address(A[13:0]),
		.clock(clk_16),
		.q(u_rom6_o));	
		
	romsel romsel(
		.selector_i(romsel_o),
		.d_o( u_rom_o ),
		.d0_i( u_rom0_o ),
		.d5_i( u_rom5_o ),
		.d6_i( u_rom6_o )
		);

	// CRTC 6845
	reg crtc_e = 1'b1;
	always @(negedge clk_1) crtc_e <= (nIORD & nIOWR);
	crtc6845 crtc(
		.I_CLK(clk_1),
		.I_RSTn(nreset_i),
		.I_CSn(A[14]),
		.I_RWn(A[9]),
		.I_RS(A[8]),
		.I_E(!(nIORD & nIOWR)/*crtc_e*/),
		.I_DI(DO),
		.O_RA(RA), 
		.O_MA(MA), 
		// TODO: Fix this
		.O_H_SYNC(hsync_signal), 
		.O_V_SYNC(vsync_signal), 
		.O_DISPTMG(),
		.video_offset_o(video_offset_o)
		);

	// Amstrad gate array emulator	
	a40010 gate_array (
		.nreset_i(nreset_i),
		.clk_i(clk_16),
//		.slowclk_i(clk_1),
		.a_i(A),
		.d_i( DO ),
		.dv_i( video_D_o ),
		.nWR_i(nWR),
		.nRD_i(nRD),
		.nMREQ_i(nMREQ),
		.nIORQ_i(nIORQ),
		.nM1(nM1),			// TODO: Added to enable lower rom on int ack
		.nint_o(cpu_int),
		.nROMEN_o(nROMEN),
		.romsel_o(romsel_o),
		.video_pixel_i(pixel_num),
		.border_i(video_border),
		.color_dat_o(color_dat),
		.vsync_i(vsync_signal),
		.hsync_i(hsync_signal)
		);

// Fake Keyboard Handler
assign ppia_i = (ppic_o[3:0] == 4'd0) ? keyboard_i[7:0] :
					 (ppic_o[3:0] == 4'd1) ? keyboard_i[15:8] :
					 (ppic_o[3:0] == 4'd2) ? keyboard_i[23:16]:
					 (ppic_o[3:0] == 4'd3) ? keyboard_i[31:24] :
					 (ppic_o[3:0] == 4'd4) ? keyboard_i[39:32] :
					 (ppic_o[3:0] == 4'd5) ? keyboard_i[47:40] :
					 (ppic_o[3:0] == 4'd6) ? keyboard_i[55:48] :
					 (ppic_o[3:0] == 4'd7) ? keyboard_i[63:56] :
					 (ppic_o[3:0] == 4'd8) ? keyboard_i[71:64] :
					 (ppic_o[3:0] == 4'd9) ? keyboard_i[79:72] :
						8'd255;

	// Fake PPIO - fixed directional ports
	ppi_fake ppi8255(
		.nreset_i(nreset_i),
		.clk_i(clk_16),
		.nCS_i(A[11]),
		.a0(A[8]),
		.a1(A[9]),
		.nIORD_i(nIORD),
		.nIOWR_i(nIOWR),
		.d_i(DO),
		.d_o(D8255_o),
		.a_i(ppia_i),
		.a_o(ppia_o),
		.b_i({7'd127,vsync_signal}),	// Tape in, printer busy, ~EXP pin, 4xManufacturer, syncin
		.c_o(ppic_o)	
		);

// HDMI Module driver
/*
hdmi_video video(
	.CLOCK_50_i(CLOCK_50_B6A),
	.reset_i( !nreset_i ),
	.hdmi_clk_o(HDMI_TX_CLK),
	.hdmi_de_o(HDMI_TX_DE),
	.hdmi_vs_o(HDMI_TX_VS),
	.hdmi_hs_o(HDMI_TX_HS),
	.hdmi_d_o(HDMI_TX_D),
	.a_o(Av),
	.vram_clk_o(vram_clk),
	.color_dat_i(color_dat),
	.video_pixel_o(pixel_num),
	.border_o(video_border),
	.video_offset_i(video_offset)
	);

*/	
`ifndef SIM
// Sound / keyboard module	
YM2149 sounddev(
  // data bus
  .I_DA(ppia_o),			// Output only, keyboard doesn't go through the sound module
  .O_DA(),
  .O_DA_OE_L(),
  // control
  .I_A9_L(`LO),			// Not used
  .I_A8(`HI),				// Not used
  .I_BDIR(ppic_o[7]),
  .I_BC2(`HI),
  .I_BC1(ppic_o[6]),
  .I_SEL_L(`HI),			// Default - clock divisor select - none

  .O_AUDIO(audio_o),
  // port a
  .I_IOA(8'hff),
  .O_IOA(),
  .O_IOA_OE_L(),
  // port b
  .I_IOB(8'hff),
  .O_IOB(),
  .O_IOB_OE_L(),
  //
  .ENA(`HI),          // Check this clock enable for higher speed operation
  .RESET_L(nreset_i),
  .CLK(clk_1)
  );
`endif
endmodule

