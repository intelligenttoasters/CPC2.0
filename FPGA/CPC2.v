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

module CPC2(
		input CLK_50,
		// SPI Ports
		input SPI_MOSI, 
		output SPI_MISO, 
		input SPI_SCK, 
		input SPI_CS,
		output DATA7,				// SPI client ready
		input DATA6,				// SPI master ready
		// Hard coded de-assert data lines, a high on this line prevents data 6+7 from being asserted
		// Avoids potential conflicts on the lines during power up switch over from FPGA FPP
		input DATA5,
		// Disk/activity LED
		output LED
		);
 
	// Wire definitions ===========================================================================
	wire			global_reset_n, global_clock, support_clock;
	// support cpu wiring
	wire [15:0]	support_address;
	wire [7:0]	support_dout, support_din, support_mem, support_io, io_data;
	wire			support_mreq, support_m1, support_iorq, support_rd, support_wr, support_wait;
	
	// IO Wires
	wire [15:0] io_nwr, io_nrd;
	wire [7:0]	spi_dout;
	wire [7:0]	intmgr_dout;
	wire [3:0]	io_a;
	wire			io_clk;
	wire			spi_interrupt, cpu_interrupt;
	
	// SPI wires
	wire slave_ready, master_ready;
	
	// Registers

	// Assignments	
	//assign support_dout = support_bus;
	// Prevent assertion when deassert active - note it only happens AFTER the FPGA is configured
	assign DATA7 = (DATA5) ? 1'bz : slave_ready;
	assign master_ready = DATA6;
	
	// Simulation branches and control ===========================================================
	`ifndef SIM
		osc o (
			.oscena(1'b1), 
			.clkout(global_clock)
			);
		reg [2:0] sc_divider = 0;
		always @(posedge global_clock) sc_divider <= sc_divider + 1'b1;
		assign support_clock = sc_divider[2];
	`else
		assign global_clock = CLK_50;	// Temporary until the 50MHz clock is fixed		
		reg [1:0] sc_divider = 0;
		always @(posedge global_clock) sc_divider <= sc_divider + 1'b1;
		assign support_clock = sc_divider[1];
	`endif

	// Module connections ========================================================================

	// Global reset
	global_reset global_reset( 
		.clock_i( global_clock ), 
		.forced_reset_i( DATA5 ),
		.n_reset_o(global_reset_n) 
	);

	// CPU
	tv80n supportcpu (
		.reset_n(global_reset_n), 
		.clk(support_clock), 
		.wait_n(!support_wait), 
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
	// SPI Module ========================================================
	wire ungated_miso;
	spi_client spi(
		// Controls
		.slave_rdy_o( slave_ready ),
		.master_rdy_i ( master_ready ),
		// SPI client connection
		.mosi_i(SPI_MOSI),
		.miso_o(ungated_miso),
		.sck_i(SPI_SCK),
		.cs_i(SPI_CS),
		// Bus signals
		.n_reset_i(global_reset_n),
		.busclk_i(io_clk),
		.A_i(io_a),
		.D_i(io_data),
		.D_o(spi_dout),
		.nWR_i(io_nwr[0]),
		.nRD_i(io_nrd[0]),
		.interrupt_o(spi_interrupt)
	);
	// Gate the MISO based on CS (active low)
	assign SPI_MISO = (SPI_CS) ? 1'bz : ungated_miso; 
	// End SPI Module ====================================================

	// Switch between IO and memory interfaces
	data_multiplexer m (
		.Din1(support_mem),
		.Din2(support_io),
		.Dout(support_din),
		.selector({!support_iorq,!support_mreq})
	);

	// Interface to memory
	support_memory_if memif(
		.clk(support_clock),
		.A(support_address),
		.Din(support_dout),
		.Dout(support_mem),
		.wr(!support_wr && !support_mreq),
		.mem_wait(support_wait)
	);
	
	// Switching IO interface
	support_io_if io (
		// CPU Interface
		.clk_i(support_clock),
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
				spi_dout,		// Port 0x00 - 0x0f	SPI
				intmgr_dout,	// Port 0x10 - 0x1f	Interrupt manager
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				8'd0,
				8'd0
				})		// Merged data path - 16 streams
	);
	
	// Interrupt manager, address 0x10-0x1f
	interrupt_manager intmgr (
		.interrupt_lines_i({7'd0,spi_interrupt}),
		.n_rd_i(io_nrd[1]),
		.n_int_o(cpu_interrupt),
		.dat_o(intmgr_dout)
	);
	
	// Dummy LED driver
	LED led( global_clock, LED );
/*
// SignalProbe
reg [31:0] xxx; wire [31:0] yyy;
always @(negedge global_clock)
	xxx <= {support_clock,support_m1,support_address,support_bus,support_rd,support_wr,support_mreq,support_iorq};
XXXX x(xxx,yyy);	

	
endmodule

module XXXX(
	input [31:0] a,
	output [31:0] b
	);
	assign b = a;
*/
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

module LED(
	input clk_i,
	output led_o
);
	/* Replace this LED driver */	
	reg [25:0] cntr = 16;	
	assign led_o = ((cntr[25:22] == 0 ) || (cntr[25:22] == 1) || (cntr[25:22] == 6)) & (cntr[4:0] <= 5'b11110);
	always @(posedge clk_i) cntr <= cntr + 1'b1;
	/* End LED driver */

endmodule
