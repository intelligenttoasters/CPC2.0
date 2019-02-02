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
		input CLK2_50,
		input CLK_12,
		// Soft reset
		input reset_i,
		// I2C Control Ports
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
		// SDCard Port
		output mmcclk_o,
		input mmccmd_i,
		output mmccmd_o,
		output mmccmd_oe,
		input [3:0] mmcdata_i,
		output [3:0] mmcdata_o,
		output mmcdata_oe,
		// HyperRAM1 hardware interface
		inout wire [7:0]	hyper_dq,
		inout wire			hyper_rwds,
		output wire			hyper_csn_o,
		output wire			hyper_ck_o,
		output wire			hyper_resetn_o,
		// HyperRAM2 hardware interface
		inout wire [7:0]	hyper2_dq,
		inout wire			hyper2_rwds,
		output wire			hyper2_csn_o,
		output wire			hyper2_ck_o,
		output wire			hyper2_resetn_o,
		// USB port
		input usb_clkin,
		input usb_dir,
		input usb_nxt,
		output usb_stp,
		output usb_reset,
		input [7:0] usb_data_i,
		output [7:0] usb_data_o,
		output usb_data_oe
		);

	// Register definitions
	reg [3:0] romram_sync;
	
	// ASMI Registers
	reg [31:0] asmi_A;
	reg asmi_read = 1'b0;
		
	// Wire definitions ===========================================================================
	wire			global_reset_n, limited_reset_n, heartbeat;
	wire			clock_74_25, clock_48, clock_40, clock_16, clock_4, clock_1, clock_audio;
	`ifndef SIM
	wire clock_mem;
	`endif
	
	// support cpu wiring
	wire [15:0]	support_address, ipl_address;
	wire [7:0]	support_dout, support_din, support_mem, support_io, io_data, fdc_dout;
	wire [7:0]	ipl_data;
	wire			support_mreq, support_m1, support_iorq, support_rd, support_wr, support_wait, support_wait2;
	wire			sys_rd, ipl_wr;
	wire [7:0]	write_protect_high;

	// Support IO Wires
	wire [15:0] io_nwr, io_nrd, wb_we, wb_stb;
	wire [7:0]	wb_adr, wb_dat;
	wire [7:0]	uart_dout, intmgr_dout, i2c_dout, kbd_dout, memctl_dout, sram_dout, sram2_dout, usb_dout, cpcctl_dout, sdc_dout, brs_dout;
	wire [3:0]	io_a;
	wire			io_clk;
	wire			i2c_ack;
	wire			uart_interrupt, cpu_interrupt, i2c_interrupt, fdc_interrupt;
	
	// Video wiring
	wire [15:0]	vram_A;
	wire [7:0] vram_D;
	wire [15:0] video_offset;
	wire [7:0] audio_signal;
	
	// CPC Wiring
	wire [79:0] keyboard_data;

	// Shared ROM lines
	wire [23:0] romram_addr;
	wire [7:0] romram_data2cpc;
	wire [7:0] romram_data2mem;
	wire romram_rd, romram_wr, romram_enable, romram_enable_rise;
	wire [63:0] rom_flags;
	
	// ASMI Interface
	wire [7:0] asmi_data, asmi_dout;
	wire asmi_busy, asmi_ready;
	
	// FDC
	wire fdc_motor, fdc_activity;
	
	wire [23:0] tfr_A;
	wire [7:0] tfr_D;
	
	// Registers
	reg support_enable = 0;
	
	// Assignments
	assign romram_enable_rise = (romram_sync[3:2] == 2'b01);
	
	// Simulation branches and control ===========================================================
	`ifndef SIM
	master_clock master_clk (
		.refclk(CLK_50),   		//  refclk.clk
		.rst(!limited_reset_n),	//  reset.reset
		.outclk_0(clock_mem),
		.outclk_1(clock_40)
	);

	// HDMI Audio clock
	audio_clock audio_clk (
		.refclk(CLK_12),   		//  refclk.clk
		.rst(!limited_reset_n),	//  reset.reset
		.outclk_0(clock_audio)
	);
	// Slow clocks
	cpc_clks cpc_clocks (
		.refclk(CLK2_50),   		//  refclk.clk
		.rst(!limited_reset_n),	//  reset.reset
		.outclk_0(clock_48),
		.outclk_1(clock_16),
		.outclk_2(clock_4),
		.outclk_3(clock_1)
	);	
	`else
		reg clock_mem = 0;
		always begin
		#4 clock_mem <= ~clock_mem;
		end
		
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
			#31 clk16 = ~clk16;
			#31 clk16 = ~clk16;
			#32 clk16 = ~clk16;
		end
		reg clk4 = 0;
		assign clock_4 = clk4;
		always begin
			#125 clk4 = ~clk4;
		end
		reg clk1 = 0;
		assign clock_1 = clk1;
		always begin
			#500 clk1 = ~clk1;
		end
	`endif
	// Module connections ========================================================================

	// Disk Drive LED
	led_driver led( clock_48, fdc_motor, fdc_activity, LED );

	// Global reset
	global_reset global_reset( 
		.clock_i( CLK_50 ), 
		.forced_reset_i( reset_i ),
		.n_reset_o(global_reset_n),
		.n_limited_reset_o(limited_reset_n)
	);

	// Support CPU
	tv80n supportcpu (
		.reset_n(global_reset_n), 
		.clk(clock_48), 
		.wait_n(~(support_wait|support_wait2)),
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
		.dma_en_i( reset_i ),
		.dma_adr_o( ipl_address ),
		.dma_dat_o( ipl_data ),
		.dma_wr_o( ipl_wr )
	);
	// End UART Module ====================================================

	// HyperRam Memory Module =============================================
	wire [7:0] hyper_dq_i, hyper_dq_o;
	wire [15:0] hyper2sram, sram2hyper;
	wire hyper_dq_oe, hyper_rwds_o, hyper_rwds_i, hyper_rwds_oe, hyper_go, hyper_valid, hyper_busy, hyper_ready;
	wire [23:0] hyper_A;
	wire [2:0] hyper_cmd;
	
	// Bidirectional buffers
	assign hyper_dq = (hyper_dq_oe) ? hyper_dq_o : 8'bzzzzzzzz;
	assign hyper_dq_i = hyper_dq;
	assign hyper_rwds = (hyper_rwds_oe) ? hyper_rwds_o : 1'bz;
	assign hyper_rwds_i = hyper_rwds;

	hyperram_ctl hyperram (
		// System core signals
		.clk_i(clock_mem),
		.rst_i(~global_reset_n),
		.ready_o(hyper_ready),
		// Memory  bus signals / asynchronous edge triggered bus
		.A_i(hyper_A),		// 24 bit address space, for 16 bit words (max 32MB)
		.D_i(sram2hyper),
		.D_o(hyper2sram),
		.D_valid(hyper_valid),
		.cmd_i(hyper_cmd),
		.go_i(hyper_go),		// Edge triggered action signal
		.busy_o(hyper_busy),		// Busy signal
		// HyperRAM hardware interface
		.dq_i(hyper_dq_i),
		.dq_o(hyper_dq_o),
		.dq_oe(hyper_dq_oe),
		.rwds_i(hyper_rwds_i),
		.rwds_o(hyper_rwds_o),
		.rwds_oe(hyper_rwds_oe),
		.csn_o(hyper_csn_o),
		.ck_o(hyper_ck_o),
		.resetn_o(hyper_resetn_o)
    );	
	
	// End HyperRam Memory Module =========================================
	
	// HyperRam multiplexor support CPU and CPC ===========================
	wire sram_loopback;
	sram_ctl sram ( 
	// Control signals
	.clk_i(clock_48),
	.reset_i(~global_reset_n),
	// Support Bus signals
	.A_i(io_a),
	.D_i(io_data),
	.D_o(sram_dout),
	.rd_i(~io_nrd[7]),
	.wr_i(~io_nwr[7]),
	.wait_o(support_wait),
	// CPC Signals/RAMROM signals
	.cpc_pause_o(sram_loopback),
	.cpc_pause_ack_i(sram_loopback),
	.cpc_A_i(romram_addr),
	.cpc_D_i(romram_data2mem),
	.cpc_D_o(romram_data2cpc),
	.cpc_en_i(romram_enable_rise),
	.cpc_rd_i(romram_rd),
	.cpc_wr_i(romram_wr),
	.cpc_romflags_o(rom_flags),
	// Memory signals
	.mem_A_o(hyper_A),
	.mem_D_i(hyper2sram),
	.mem_D_o(sram2hyper),
	.mem_cmd_o(hyper_cmd),
	.mem_go_o(hyper_go),
	.mem_busy_i(hyper_busy),
	.mem_valid_i(hyper_valid)
	);
	// HyperRam multiplexor support CPU and CPC ===========================

	// HyperRam 2 Memory Module =============================================
	wire [7:0] hyper2_dq_i, hyper2_dq_o;
	wire [15:0] hyper2sram2, sram2hyper2;
	wire hyper2_dq_oe, hyper2_rwds_o, hyper2_rwds_i, hyper2_rwds_oe, hyper2_go, hyper2_valid, hyper2_busy, hyper2_ready;
	wire [23:0] hyper2_A;
	wire [2:0] hyper2_cmd;
	
	// Bidirectional buffers
	assign hyper2_dq = (hyper2_dq_oe) ? hyper2_dq_o : 8'bzzzzzzzz;
	assign hyper2_dq_i = hyper2_dq;
	assign hyper2_rwds = (hyper2_rwds_oe) ? hyper2_rwds_o : 1'bz;
	assign hyper2_rwds_i = hyper2_rwds;

	hyperram_ctl hyperram2 (
		// System core signals
		.clk_i(clock_mem),
		.rst_i(~global_reset_n),
		.ready_o(hyper2_ready),
		// Memory  bus signals / asynchronous edge triggered bus
		.A_i(hyper2_A),		// 24 bit address space, for 16 bit words (max 32MB)
		.D_i(sram2hyper2),
		.D_o(hyper2sram2),
		.D_valid(hyper2_valid),
		.cmd_i(hyper2_cmd),
		.go_i(hyper2_go),		// Edge triggered action signal
		.busy_o(hyper2_busy),		// Busy signal
		// HyperRAM hardware interface
		.dq_i(hyper2_dq_i),
		.dq_o(hyper2_dq_o),
		.dq_oe(hyper2_dq_oe),
		.rwds_i(hyper2_rwds_i),
		.rwds_o(hyper2_rwds_o),
		.rwds_oe(hyper2_rwds_oe),
		.csn_o(hyper2_csn_o),
		.ck_o(hyper2_ck_o),
		.resetn_o(hyper2_resetn_o)
    );
	// End HyperRam 2 Memory Module =========================================

	// HyperRam2 multiplexor support Controller CPU and Video ===========================
	wire sram2_loopback;
	sram_ctl sram2 ( 
	// Control signals
	.clk_i(clock_48),
	.reset_i(~global_reset_n),
	// Support Bus signals
	.A_i(io_a),
	.D_i(io_data),
	.D_o(sram2_dout),
	.rd_i(~io_nrd[8]),
	.wr_i(~io_nwr[8]),
	.wait_o(support_wait2),
	// Video Signals
	.cpc_pause_o(sram2_loopback),			// Support CPU bus access RQ
	.cpc_pause_ack_i(sram2_loopback),	// Video logic bus ack
	// Video Addr/Dat/Ctl
	.cpc_A_i(),
	.cpc_D_i(),
	.cpc_D_o(),
	.cpc_en_i(),
	.cpc_rd_i(),
	.cpc_wr_i(),
	.cpc_romflags_o(),						// Not required
	// Memory signals
	.mem_A_o(hyper2_A),
	.mem_D_i(hyper2sram2),
	.mem_D_o(sram2hyper2),
	.mem_cmd_o(hyper2_cmd),
	.mem_go_o(hyper2_go),
	.mem_busy_i(hyper2_busy),
	.mem_valid_i(hyper2_valid)
	);
	// HyperRam2 multiplexor support CPU and CPC ===========================
	
	// Synchronizer on romram_enable (clk4 domain -> mem domain)
	always @(posedge clock_mem) romram_sync <= {romram_sync[2:0],romram_enable};

//	assign support_wait = ~support_enable;
	
	// ASMI Interface for ROM Images (0 data/read trigger 8:11 address, 15 read status/trigger read
	`ifndef SIM
	asmi asmi0 (
		.clkin      (clock_48),      				//      clkin.clk
		.read       (asmi_read),      			//       read.read
		.rden       (asmi_read), 					//       rden.rden
		.addr       (asmi_A[23:0]),  				//       addr.addr[24]
		.reset      (~global_reset_n),      	//      reset.reset
		.dataout    (asmi_data),    				//    dataout.dataout[8]
		.busy       (asmi_busy),       			//       busy.busy
		.data_valid (asmi_ready)  					// data_valid.data_valid
	);	
	`endif
	// Store ASMI Address
	always @(posedge clock_48 or negedge global_reset_n)
	if( ~global_reset_n)
	begin
		asmi_A <= 32'd0;
	end else begin
		//if(asmi_track_busy == 2'b10) asmi_A <= asmi_A + 1'b1;		// Falling edge of busy increment address
		if( asmi_ready ) asmi_A <= asmi_A + 1'b1;
		else
		if( ~io_nwr[9] ) begin
			// Write to registers requires bit 3 of address set
			if( io_a[3:2] == 2'b10 ) case(io_a[1:0])
				2'd0 : asmi_A[7:0] <= io_data;
				2'd1 : asmi_A[15:8] <= io_data;
				2'd2 : asmi_A[23:16] <= io_data;
				2'd3 : asmi_A[31:24] <= io_data;
			endcase
			else
			if(io_a == 4'd15 ) asmi_read <= 1'b1;
		end
		else asmi_read <= 1'b0;
	end
	assign asmi_dout = (io_a == 4'd0) ? asmi_data : 
							 (io_a == 4'd8) ? asmi_A[7:0] :
							 (io_a == 4'd9) ? asmi_A[15:8] :
							 (io_a == 4'd10) ? asmi_A[23:16] :
							 (io_a == 4'd11) ? asmi_A[31:24] :
							 {asmi_ready,6'd0,asmi_busy};
	// End ASMI Interface
	
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
	support_memory_if memif (
		.clk(clock_48),
		.wp_address(write_protect_high),
		// Support memory interface
		.support_A(support_address),
		.support_Din(support_dout),
		.support_Dout(support_mem),
		.support_wr(!support_wr && !support_mreq),
		// System memory interface
		.sys_en(reset_i),		// If the soft reset is active, then enable the system memory interface
		.sys_A(ipl_address),
		.sys_data(ipl_data),
		.sys_wr(ipl_wr)
	);
	
	// Support Memory Write Control
	memctl memory_control(
		.clk_i(io_clk),
		.reset_i(~global_reset_n),
		.wr_i( ~io_nwr[5] ),
		.rd_i( ~io_nrd[5] ),
		.D_i(io_data),
		.D_o(memctl_dout),
		.wp_o(write_protect_high)
	);
	
	cpcctl cpc_control(
		.clk_i(io_clk),
		.reset_i(~global_reset_n),
		.wr_i( ~io_nwr[15] ),
		.D_i(io_data),
		.D_o(cpcctl_dout)
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
				memctl_dout,	// Port 0x50 - 0x5f	Memory protect control space
				usb_dout,		// Port 0x60 - 0x6f	USB2 Controller space
				sram_dout,		// Port 0x70 - 0x7f	SRAM interface1 - CPC
				sram2_dout,		// Port 0x80 - 0x8f	SRAM interface2 - Video
				asmi_dout,		// Port 0x90 - 0x9f	ASMI Flash memory
				sdc_dout,		// Port 0xa0 - 0xaf	SDC Controller, through uP to WB
				brs_dout,		// Port 0xb0 - 0xbf	Block RAM Spooler for SD Card
				8'd0,
				8'd0,
				8'd0,
				{hyper_ready,hyper2_ready,cpcctl_dout[5:0]}		// Port 0xf0 - 0xff	CPC Control signals, bit7-sram rdy, bit6-sram2 rdy, bit0-reset
				}),				// Merged data path - 16 streams
		.ack_i(i2c_ack /*| usb_ack*/),		// WB Ack in wire-or'ed
		.we_o(wb_we),			// WB Write out
		.stb_o(wb_stb),		// WB Strobe out
		.adr_o(wb_adr),		// WB Registered addr
		.dat_o(wb_dat)			// WB Registered data
	);
	
	// Interrupt manager, address 0x10-0x1f
	interrupt_manager intmgr (
		.fast_clock_i(clock_48),
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
	reg [7:0] audio_sync[0:4];
	always @(negedge clock_audio)
	begin
		audio_sync[4] <= audio_sync[3];
		audio_sync[3] <= audio_sync[2];
		audio_sync[2] <= audio_sync[1];
		audio_sync[1] <= audio_sync[0];
		audio_sync[0] <= audio_signal;
	end
	
	i2s_audio audio(
		.clk_i(clock_audio),
		.left_i({audio_sync[4],8'd0}),
		.right_i({audio_sync[4],8'd0}),
		.i2s_o(I2S),
		.lrclk_o(LRCLK),
		.sclk_o(ASCLK)
	);

	// uP to WB Master I/F for SDCard controller
	wire [31:0] sdc_adr, sdc_dati, sdc_dato;
	wire [3:0] sdc_sel;
	wire sdc_we, sdc_stb, sdc_cyc, sdc_ack;
	up2wb sdc_if (
		// Master Signals
		.clk_i(clock_48),
		.reset_i(~global_reset_n),
		// uP Interface
		.A_i(io_a),
		.D_i(io_data),
		.D_o(sdc_dout),
		.wr_i(~io_nwr[4'ha]),
		.rd_i(~io_nrd[4'ha]),
		// WB Interface
		.adr_o(sdc_adr),
		.dat_o(sdc_dato),
		.dat_i(sdc_dati),
		.we_o(sdc_we),
		.sel_o(sdc_sel),
		.stb_o(sdc_stb),
		.cyc_o(sdc_cyc),
		.ack_i(sdc_ack)
	);
	
	wire [31:0] sd_ma, sd_mdi,sd_mdo;
	wire sd_sel, sd_we, sd_cyc, sd_stb, sd_ack;
	
	// SDCard Controller
	sdc_controller sdmmc (
           // WISHBONE common
           .wb_clk_i(clock_48), 
           .wb_rst_i(~global_reset_n), 
           // WISHBONE slave
           .wb_dat_i(sdc_dato), 
           .wb_dat_o(sdc_dati),
           .wb_adr_i(sdc_adr[7:0]), 
           .wb_sel_i(sdc_sel), 
           .wb_we_i(sdc_we), 
           .wb_cyc_i(sdc_cyc), 
           .wb_stb_i(sdc_stb), 
           .wb_ack_o(sdc_ack),
           // WISHBONE master
           .m_wb_dat_o(sd_mdo),
           .m_wb_dat_i(sd_mdi),
           .m_wb_adr_o(sd_ma), 
           .m_wb_sel_o(sd_sel), 
           .m_wb_we_o(sd_we),
           .m_wb_cyc_o(sd_cyc),
           .m_wb_stb_o(sd_stb), 
           .m_wb_ack_i(sd_ack),
           .m_wb_cti_o(), 
           .m_wb_bte_o(),
           //SD BUS
           .sd_cmd_dat_i(mmccmd_i), 
           .sd_cmd_out_o(mmccmd_o), 
           .sd_cmd_oe_o(mmccmd_oe), 
           .sd_dat_dat_i(mmcdata_i), 
           .sd_dat_out_o(mmcdata_o), 
           .sd_dat_oe_o(mmcdata_oe), 
           .sd_clk_o_pad(mmcclk_o),
           .sd_clk_i_pad(clock_48),
			  // Interrupts
           .int_cmd(), 
           .int_data()
       );	
		 
	reg sd_last_stb = 1'b0;
	always @(posedge clock_48) sd_last_stb <= sd_stb;
	wire stb_rise = ({sd_last_stb, sd_stb} == 2'b01);
	
	reg [1:0] ack_counter;	
	always @(posedge clock_48)
	begin
		if( ~sd_stb ) ack_counter = 2'd0;
		else ack_counter = (ack_counter == 2'd2) ? 2'd0 : ack_counter + 1'b1;
	end	
	
	// Ack only every third cycle for read to allow data through the blockram registers
	assign sd_ack = (sd_we) ? sd_stb : (ack_counter == 2'd2);		
	
	wire [15:0] SD_A;
	wire [7:0] SD_D, SD_Q;
	wire SD_WE;
	
	// Buffers data to/from SD card
	sdcard_buffer sd_buffer (
		.aclr_a(~global_reset_n),
		.aclr_b(~global_reset_n),
		.address_a(sd_ma[9:2]),		// Word aligned
		.address_b(SD_A[9:0]),
		.clock_a(clock_48),
		.clock_b(clock_48),
		.data_a({sd_mdo[7:0], sd_mdo[15:8], sd_mdo[23:16],sd_mdo[31:24]}),	// Quartus mangles byte order 32-8 conversion
		.data_b(SD_D),				
		.wren_a(sd_we & stb_rise),	// One write cycle
		.wren_b(SD_WE),
		.q_a({sd_mdi[7:0],sd_mdi[15:8],sd_mdi[23:16],sd_mdi[31:24]}),			// Quartus mangles byte order 32-8 conversion
		.q_b(SD_Q)
	);
	// Buffer In/Out Data for SD Card
	blockram_spool brs (
		// System signals
		.clk_i(clock_48),
		.areset_i(~global_reset_n),
		// Blockram Interface
		.address_o(SD_A[9:0]),		// Only 1024 bytes in buffer
		.data_o(SD_D),
		.q_i(SD_Q),
		.wren_o(SD_WE),
		// CPC Interface
		.A_i(io_a),
		.D_i(io_data),
		.D_o(brs_dout),
		.rd_i(~io_nrd[4'hb]),
		.wr_i(~io_nwr[4'hb])
		);	
	// End of SDCard controller
	
	// USB ULPI
	usb_ulpi usb (
		// Bus Interface
		.clk_i(io_clk),
		.reset_i(~global_reset_n),
		.A(io_a),
		.D_i(io_data),
		.D_o(usb_dout),
		.wr_i( ~io_nwr[6] ),
		.rd_i( ~io_nrd[6] ),	
		// Phy Interface
		.usb_clkin(usb_clkin),
		.usb_dir(usb_dir),
		.usb_nxt(usb_nxt),
		.usb_stp(usb_stp),
		.usb_reset(usb_reset),
		.usb_data_i(usb_data_i),
		.usb_data_o(usb_data_o),
		.usb_data_oe(usb_data_oe)
	);
	
	// ===============================================================================
	// ======== This is the real CPC Core ============================================
	// ===============================================================================
	cpc_core core ( 
		.clk_16(clock_16),
		.clk_4(clock_4),
		.clk_1(clock_1),
		.nreset_i(~cpcctl_dout[0]),
		// Video memory access here
		.video_clk_i(clock_40),
		.video_A_o(vram_A),
		.video_D_o(vram_D),
		.video_offset_o(video_offset),
		.keyboard_i(keyboard_data),
		.audio_o(audio_signal),
		// Shared ROM
		.romram_addr_o(romram_addr),
		.romram_data_i(romram_data2cpc),
		.romram_data_o(romram_data2mem),
		.romram_enable_o(romram_enable),
		.romram_rd_o(romram_rd),
		.romram_wr_o(romram_wr),
		.romram_valid_i(hyper_valid),
		.romflags_i(rom_flags),
		// FDC Interface
		.fdc_motor(fdc_motor),
		.fdc_activity(fdc_activity),
		.S_clk_i(clock_48),
		.S_A_i(io_a),
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
	
	// 25% duty cycle when motor is on, or full intensity when reading
	assign led_o = (cntr > 0) | (fdc_motor_i && (cycle == 2'd0));
	
endmodule

// Sets and stores the write protect address
module memctl(
	input clk_i,
	input reset_i,
	input rd_i,
	input wr_i,
	input [7:0] D_i,
	output reg [7:0] D_o,
	output reg [7:0] wp_o = 7'h00
);
	always @(posedge clk_i or posedge reset_i)
	if( reset_i ) wp_o <= 8'd0;
	else begin 
		if( wr_i ) wp_o <= D_i[7:0];
		if( rd_i ) D_o <= wp_o;
	end
endmodule

// Sets and stores the write protect address
// Bit 0 - Reset CPC
// Bit 1 - Inhibit Clock
module cpcctl(
	input clk_i,
	input reset_i,
	input wr_i,
	input [7:0] D_i,
	output reg [7:0] D_o
);
	always @(posedge clk_i or posedge reset_i)
	if( reset_i ) D_o <= 8'd1;				// Hold in reset when in system reset
	else if( wr_i ) D_o <= D_i[7:0];
endmodule
