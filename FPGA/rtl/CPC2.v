/*
 * CPC2 - Top level entity
 *
 * Top level entity for the CPC2 project
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
`default_nettype none

module CPC2(
		input CLK_50,
		// Control Ports
		output DATA7,				// Heartbeat
		input DATA6,				// Unassigned
		// Hard coded de-assert data lines, a high on this line prevents data 6+7 from being asserted
		// Avoids potential conflicts on the lines during power up switch over from FPGA FPP
		input DATA5,				// Soft reset
		inout I2C_SCL,
		inout I2C_SDA,
		// Disk/activity LED
		output LED,
		// Video port
		output VSYNC,
		output HSYNC,
		output VDE,
		output VCLK,
		output [7:0] R,
		output [7:0] G,
		output [7:0] B,
		output [3:0] I2S,
		output ASCLK,
		output LRCLK,
		output MCLK,
		// Uart port
		input uart_rx_i,
		output uart_tx_o,
		// USB port
		output usb_mode,
		output usb_suspend,
		input usb_vm,
		input usb_vp,
		input usb_rcv,
		output usb_vpo,
		output usb_vmo,
		output usb_speed,
		output usb_oen,
		// SDRAM interface
		inout [15:0] 	sdram_Dq, 
		output [11:0] 	sdram_Addr, 
		output [1:0] 	sdram_Ba, 
		output     		sdram_Clk, 
		output 	     	sdram_Cke, 
		output 			sdram_Cs_n, 
		output 			sdram_Ras_n, 
		output 			sdram_Cas_n, 
		output 			sdram_We_n, 
		output [1 : 0] sdram_Dqm
		);
 
	// Wire definitions ===========================================================================
	wire			global_reset_n, limited_reset_n, heartbeat;
	wire			clock_160, clock_120, clock_48, clock_40, clock_16, clock_4, clock_1, clock_audio;
	
	// support cpu wiring
	wire [15:0]	support_address, sys_address;
	wire [7:0]	support_dout, support_din, support_mem, support_io, io_data, fdc_dout;
	wire [7:0]	sys_data;
	wire			support_mreq, support_m1, support_iorq, support_rd, support_wr;
	wire			sys_rd, sys_wr, dma_rd;
	wire [7:0]	write_protect_high;

	// Support IO Wires
	wire [15:0] io_nwr, io_nrd, wb_we, wb_stb;
	wire [7:0]	wb_adr, wb_dat;
	wire [7:0]	uart_dout, intmgr_dout, i2c_dout, kbd_dout, usb_dout, memctl_dout;
	wire [3:0]	io_a;
	wire			io_clk;
	wire			i2c_ack, usb_ack;
	wire			uart_interrupt, cpu_interrupt, i2c_interrupt, fdc_interrupt;
	
	// Video wiring
	wire [15:0]	vram_A;
	wire [7:0] vram_D;
	wire [15:0] video_offset;
	wire [7:0] audio_signal;
	
	// CPC Wiring
	wire [79:0] keyboard_data;

	// Shared ROM lines
	wire [14:0] shared_rom_addr;
	wire [7:0] shared_rom_data;
	
	// FDC
	wire fdc_motor, fdc_activity;
	
	// Registers
reg [7:0] usb_rdout = 0; 

	// Assignments	
	assign usb_suspend = 0;
	assign usb_mode = 1;
	
	// Prevent assertion when deassert active - note it only happens AFTER the FPGA is configured
	assign DATA7 = (!DATA5) ? heartbeat : 1'bz;
	
	// Simulation branches and control ===========================================================
	`ifndef SIM
	master_clock master_clk (
		.refclk(CLK_50),   		//  refclk.clk
		.rst(!limited_reset_n),	//  reset.reset
		.outclk_0(clock_160),
		.outclk_1(clock_120),
		.outclk_2(clock_48),
		.outclk_3(clock_40),
		.outclk_4(clock_16),
		.outclk_5(clock_4),
		.outclk_6(clock_1),
		.outclk_7(clock_audio)
	);
	/*
	audio_clock audio_clk (
		.refclk(cascade_clock),   		//  refclk.clk
		.rst(!limited_reset_n),	//  reset.reset
		.outclk_0(clock_audio)
	);
	*/
	`else
		reg clk48 = 0;
		assign clock_48 = clk48;
		always begin
			#10 clk48 = ~clk48;
			#11 clk48 = ~clk48;
			#10 clk48 = ~clk48;
			#11 clk48 = ~clk48;
			#10 clk48 = ~clk48;
			#11 clk48 = ~clk48;
			#10 clk48 = ~clk48;
			#11 clk48 = ~clk48;
			#10 clk48 = ~clk48;
			#11 clk48 = ~clk48;
			#10 clk48 = ~clk48;
			#10 clk48 = ~clk48;
		end
		reg clk40 = 0;
		assign clock_40 = clk40;
		always begin
			#12 clk40 = ~clk40;
			#13 clk40 = ~clk40;
		end
		reg clk16 = 0;
		assign clock_16 = clk16;
		always begin
			#31 clk16 = ~clk16;
			#32 clk16 = ~clk16;
			#31 clk16 = ~clk16;
			#31 clk16 = ~clk16;
		end
		reg [3:0] xcntr = 0;
		always @(posedge clock_16) xcntr <= xcntr + 1'b1;
		assign clock_4 = xcntr[1];
		assign clock_1 = xcntr[3];
	`endif
	// Module connections ========================================================================
	
	led_driver led( clock_48, fdc_motor, fdc_activity, LED );
	// Dummy LED driver
//	led_driver led( clock_48, !uart_rx_i, LED );
//	led_driver2 led( clock_16, LED );
//	led_driver3 led( clock_audio, LED );


	// Global reset
	global_reset global_reset( 
		.clock_i( CLK_50 ), 
		.forced_reset_i( DATA5 ),
		.n_reset_o(global_reset_n),
		.n_limited_reset_o(limited_reset_n)
	);

	// Support CPU
	tv80n supportcpu (
		.reset_n(global_reset_n), 
		.clk(clock_48), 
		.wait_n(1'b1),
		.m1_n(), 
		.mreq_n(support_mreq), 
		.iorq_n(support_iorq), 
		.rd_n(support_rd), 
		.wr_n(support_wr), 
		.rfsh_n(), 
		.halt_n(), 
		.busak_n(), 
		.int_n(cpu_interrupt),
		.nmi_n(1'b1), 
		.busrq_n(1'b1), 
		.A(support_address),
		.di(support_din),
		.dout(support_dout)
	);
	// UART Module ========================================================
	usart usart_con(
		// Uart signals
		.tx_o(uart_tx_o),
		.rx_i(uart_rx_i),
		// Bus signals
		.n_reset_i(limited_reset_n),
		.busclk_i(io_clk),
		.A_i(io_a),
		.D_i(io_data),
		.D_o(uart_dout),
		.nWR_i(io_nwr[0]),
		.nRD_i(io_nrd[0]),
		// Interrupt signal
		.interrupt_o(uart_interrupt),
		// DMA connection to memory for IPL
		.dma_en_i( DATA5 ),
		.dma_adr_o( sys_address ),
		.dma_dat_o( sys_data ),
		.dma_wr_o( sys_wr )
	);
	// End UART Module ====================================================

	// Keyboard Data Module================================================
	keyboard kbd_if ( 
				.keyboard_o(keyboard_data),
				// Bus signals
				.busclk_i(io_clk),	// Clock for bus signals
				.nreset_i( global_reset_n ),
				.A_i(io_a),	// 10x8-bit registers, representing the 80 keys
				.D_i(io_data),
				.D_o(kbd_dout),
				.nWR_i(io_nwr[3]),
				.nRD_i(io_nrd[3]));
	// End Keyboard Module ================================================

	// Switch between IO and memory interfaces
	data_multiplexer m (
		.Din1(support_mem),
		.Din2(support_io),
		.Dout(support_din),
		.selector({!support_iorq,!support_mreq})
	);
	
	// Interface to support memory, write protect except for data area
//	support_memory_if #( .wp_address(16'hc000) ) memif (
	support_memory_if memif (
		.clk(clock_48),
		.wp_address(write_protect_high),
		// Support memory interface
		.support_A(support_address),
		.support_Din(support_dout),
		.support_Dout(support_mem),
		.support_wr(!support_wr && !support_mreq),
		// System memory interface
		.sys_en(DATA5),		// If the soft reset is active, then enable the system memory interface
		.sys_A(sys_address),
		.sys_data(sys_data),
		.sys_wr(sys_wr),
		// Shared ROM data
		.rom_A(shared_rom_addr),
		.rom_D(shared_rom_data)
	);
	
	memctl memory_control(
		.clk_i(io_clk),
		.reset_i(~global_reset_n),
		.wr_i( ~io_nwr[5] ),
		.rd_i( ~io_nrd[5] ),
		.A_i(io_a),
		.D_i(io_data),
		.D_o(memctl_dout),
		.wp_o(write_protect_high)
	);
	
	// Switching IO interface
	support_io_if io (
		// CPU Interface
		.clk_i(clock_48),
		.A_i(support_address[7:0]),
		.D_i(support_dout),
		.D_o(support_io),
		.nrd_i(support_rd),
		.nwr_i(support_wr),
		.niorq_i(support_iorq),
		// IO Interface
		.clk_o(io_clk),
		.A_o(io_a),
		.nrd_o(io_nrd),		// One read bit per device
		.nwr_o(io_nwr),		// One write bit per device
		.io_o(io_data),		// Shared data out
		.io_i({					// Demux the input here
				uart_dout,		// Port 0x00 - 0x0f	Uart
				intmgr_dout,	// Port 0x10 - 0x1f	Interrupt manager
				i2c_dout,		// Port 0x20 - 0x2f	I2C interface
				kbd_dout,		// Port 0x30 - 0x3f	Keyboard interface
				fdc_dout,		// Port 0x40 - 0x4f	FDC Interface
				memctl_dout,	// Port 0x50 - 0x5f	Memory control space
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				usb_dout,		// Port 0xB0 - 0xBF USB control
				usb_dout,		// Port 0xC0 - 0xCF USB control
				usb_dout,		// Port 0xD0 - 0xDF USB control
				usb_dout,		// Port 0xE0 - 0xEF USB control
				8'd0				// Port 0xF0 - 0xFF Unused
				}),				// Merged data path - 16 streams
		.ack_i(i2c_ack | usb_ack),		// WB Ack in wire-or'ed
		.we_o(wb_we),			// WB Write out
		.stb_o(wb_stb),		// WB Strobe out
		.adr_o(wb_adr),		// WB Registered addr
		.dat_o(wb_dat)			// WB Registered data
	);
	
	// Interrupt manager, address 0x10-0x1f
	interrupt_manager intmgr (
		.fast_clock_i(clock_40),
		.interrupt_lines_i({5'd0,fdc_interrupt,i2c_interrupt,uart_interrupt}),
		.rd_i(!io_nrd[1]),
		.n_int_o(cpu_interrupt),
		.dat_o(intmgr_dout)
	);
	
	// =======================================================================================
	// Wire and REG here for readability
	wire sdaoen, sdao, scloen, sclo;
	assign I2C_SDA = (sdaoen) ? 1'bz : sdao;
	assign I2C_SCL = (scloen) ? 1'bz : sclo;

	// i2c Interface module
	i2c_master_top #( .ARST_LVL(1'b0) ) i2c (
		.wb_clk_i(clock_48), 
		.wb_rst_i(1'b0), 
		.arst_i(global_reset_n), 
		.wb_adr_i(wb_adr[2:0]), 
		.wb_dat_i(wb_dat), 
		.wb_dat_o(i2c_dout),
		.wb_we_i(wb_we[2]),
		.wb_stb_i(wb_stb[2]),
		.wb_cyc_i(wb_stb[2]),
		.wb_ack_o(i2c_ack), 
		.wb_inta_o(i2c_interrupt),
		.scl_pad_i(I2C_SCL),
		.scl_pad_o(sclo), 
		.scl_padoen_o(scloen), 
		.sda_pad_i(I2C_SDA), 
		.sda_pad_o(sdao), 
		.sda_padoen_o(sdaoen) 
	);

	// USB Interface
	wire usb_oe_p;
	assign usb_oen = !usb_oe_p;

	// Strobe - limit to 1 clock cycle
	wire usb_stb = wb_stb[11] | wb_stb[12] | wb_stb[13] | wb_stb[14];
	reg [1:0] track_stb = 2'd0;
	reg altedge_stb = 0;
	
	always @(posedge io_clk) track_stb <= {track_stb[0],usb_stb};
//	always @(posedge io_clk) if( {track_stb[0],usb_stb} == 2'b01) usb_rdout <= usb_dout;	// Register data out
	always @(negedge io_clk) altedge_stb <= ({track_stb,usb_stb} == 3'b001);

	wire usb_we = wb_we[11] | wb_we[12] | wb_we[13] | wb_we[14];
	reg track_we = 1'd0;
	reg altedge_we = 0;
	always @(posedge io_clk) track_we <= usb_we;
	always @(negedge io_clk) altedge_we <= ({track_we,usb_we} == 2'b01);	

	usbHost usb(
		.clk_i(io_clk),         	//Wishbone bus clock. Maximum 5*usbClk=240MHz
		.rst_i(!global_reset_n), 	//Wishbone bus sync reset. Synchronous to 'clk_i'. Resets all logic
		.address_i({
						(wb_adr[7:4] == 4'd14) ? 4'hE :
						(wb_adr[7:4] == 4'd13) ? 4'h3 :
						(wb_adr[7:4] == 4'd12) ? 4'h2 :
						(wb_adr[7:4] == 4'd11) ? 4'h0 :
						4'hF, wb_adr[3:0]}),   //Wishbone bus address in
		.data_i(wb_dat),           //Wishbone bus data in
		.data_o(usb_dout),  	      //Wishbone bus data out
		.we_i(altedge_we),                //Wishbone bus write enable in
		.strobe_i(altedge_stb),            //Wishbone bus strobe in
		.ack_o(usb_ack),          //Wishbone bus acknowledge out
		.usbClk(clock_48),        //usb clock. 48Mhz +/-0.25%
		.hostSOFSentIntOut(), 
		.hostConnEventIntOut(), 
		.hostResumeIntOut(), 
		.hostTransDoneIntOut(),
		.USBWireDataIn({usb_vp, usb_vm}),
		.USBWireDataOut({usb_vpo, usb_vmo}),
		.USBWireCtrlOut(usb_oe_p),
		.USBFullSpeed(usb_speed)
	);

	// Dummy SYNC general
	video fake_video( 
		// Clocking in
		.clk_i(clock_40),
		// Video out
		.hsync(HSYNC),
		.vsync(VSYNC),
		.de(VDE),
		.clk_o(VCLK),
		.r(R),
		.g(G),
		.b(B),
		// Video ram access
		.A_o(vram_A),
		.D_i(vram_D),
		// Offset for scrolling
		.video_offset_i(video_offset)
	);

	// Dummy I2S audio driver
	i2s_audio audio(
		.clk_i(clock_audio),
		.left_i({audio_signal,8'd0}),
		.right_i({audio_signal,8'd0}),
		.i2s_o(I2S),
		.lrclk_o(LRCLK),
		.sclk_o(ASCLK)
	);

	// SDRAM BIG Memory ==============================================================
	wire [15:0] 	sdram_Dq_sw;
	wire 				sdram_oe;
	
	sdram ram (
		// Control Signals
		.memclk_i(clock_160), .reset_i(~global_reset_n),
		// Logical Interface (8M words of 16 bits)
		.enable_i(1'b1), .rd_i(), .wr_i(), .A_i(), .D_i(),
		.Dm_i(2'b00), .D_o(), .D_valid(),
		// Physical SDRAM Interface
		.Dq_in(sdram_Dq),
		.Dq_out(sdram_Dq_sw),
		.Dq_oe(sdram_oe),
		.Addr(sdram_Addr), 
		.Ba(sdram_Ba), 
		.Clk(sdram_Clk), 
		.Cke(sdram_Cke), 
		.Cs_n(sdram_Cs_n), 
		.Ras_n(sdram_Ras_n), 
		.Cas_n(sdram_Cas_n), 
		.We_n(sdram_We_n), 
		.Dqm(sdram_Dqm)
		);
	// Switchable data bus
	assign sdram_Dq = (sdram_oe) ? sdram_Dq_sw : 16'bz;
	
	// END SDRAM BIG Memory ==========================================================
	
	// ===============================================================================
	// ======== This is the real CPC Core ============================================
	// ===============================================================================
	cpc_core core ( 
		.clk_16(clock_16),
		.clk_4(clock_4),
		.clk_1(clock_1),
		.nreset_i(global_reset_n),
		// Video memory access here
		.video_clk_i(clock_40),
		.video_A_o(vram_A),
		.video_D_o(vram_D),
		.video_offset_o(video_offset),
		.keyboard_i(keyboard_data),
		.audio_o(audio_signal),
		// Shared ROM
		.shared_rom_addr_o(shared_rom_addr),
		.shared_rom_data_i(shared_rom_data),
		// FDC Interface
		.fdc_motor(fdc_motor),
		.fdc_activity(fdc_activity),
		.S_clk_i(clock_48),
		.S_A_i(io_a[3:0]),
		.S_D_i(support_dout),
		.S_D_o(fdc_dout),
		.S_rd_i(~io_nrd[4]),
		.S_wr_i(~io_nwr[4]),
		.S_enable_i(~(io_nrd[4] & io_nwr[4])),
		.S_fdc_int_o(fdc_interrupt)
		);
	// ===============================================================================
endmodule

// One-off multiplexer
module data_multiplexer(
	input [1:0] selector,
	input [7:0] Din1,
	input [7:0] Din2,
	output [7:0] Dout
);
	assign Dout = 	(selector == 2'd01) ? Din1 : 
						(selector == 2'd02) ? Din2 :
						8'b1;
endmodule

module led_driver(
	input clk_i,
	input fdc_motor_i,
	input fdc_activity_i,
	output led_o
);
	reg [20:0] cntr = 0;
	reg [1:0] cycle = 0;
	
	always @(posedge clk_i)
	begin
		if( fdc_activity_i == 1 ) 
			cntr = 1;
		else
			if( cntr > 0 ) cntr = cntr + 1'b1;
	end

	// Duty cycle for motor
	always @(posedge clk_i)	cycle <= cycle + 1'b1;
	
	// 50% duty cycle when motor is on, or full intensity when reading
	assign led_o = (cntr > 0) | (fdc_motor_i && (cycle[0] == 2'd0));
	
endmodule

module memctl(
	input clk_i,
	input reset_i,
	input rd_i,
	input wr_i,
	input [3:0] A_i,
	input [7:0] D_i,
	output reg [7:0] D_o,
	output reg [7:0] wp_o = 8'h00
);
	always @(posedge clk_i)
	if( reset_i )
	begin
		wp_o <= 8'd0;
	end
	else
	begin 
		case( A_i )
			0: begin
				if( wr_i ) wp_o <= D_i;
				if( rd_i ) D_o <= wp_o;
			end
			default: ;
		endcase
	end
endmodule
