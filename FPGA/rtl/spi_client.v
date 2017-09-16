/*
 * SPI_client.v client module 
 *
 * SPI module with 16 byte buffer
 *		Addresses: 0 - data, 1 - control(write)/status(read)
 *						Control reg; bit 0 - ready to process, bit 7 - clear in/out buffers
 *						Status reg; CSn,0,0,master_rdy_i,outbound_full,outbound_empty,inbound_full,inbound_empty 
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

module spi_client #(
	parameter fifo_log2 = 9
	) ( 
	// SPI client connection
	input fast_clock_i,		// At least 4 times faster than SPI clock of 40MHz
	input mosi_i,
	output miso_o,
	input sck_i,
	input cs_i,
	// External SPI status signals
	output slave_rdy_o,
	input master_rdy_i,
	// Bus signals
	input n_reset_i,
	input busclk_i,
	input [3:0] A_i,	// Only 2 registers, buffer(0) and status(1)
	input [7:0] D_i,
	output [7:0] D_o,
	input nWR_i,
	input nRD_i,
	// Host interrupt, cleared by a read to the status register
	output interrupt_o,
	// DMA interface for Initial Program Load
	input 			dma_en_i,	// DMA enable
	output [15:0] 	dma_adr_o,	// DMA address
	output [7:0]	dma_dat_o,
	output 			dma_wr_o		// To memory
	);

	// Wire definitions
	wire 			sck_rise, sck_fall, cs_rise, cs_fall, cs_active;
	wire [7:0]	outbound_data, inbound_data, status_reg;
	wire			inbound_empty, outbound_empty, outbound_full, inbound_full;
	wire			dma_rd, dma_reset_n;
	
	// Inbound Registers
	reg [7:0] 	rdr = 0;
	
	// System vars
	reg [2:0]	track_sck = 3'd0, track_cs = 3'd0, track_mosi = 3'd0;
	reg [2:0] 	cntr = 0;
	reg			slave_rdy = 0;				// Slave ready register, active high
	reg			outbound_empty_reg = 1;	// Register outbound because it obscures the last byte
	reg			rd = 0, wr = 0;			// Read and write flags
	reg 			first_write = 0;			// Prevent a write happening when CS first goes low
	reg			clear_buffers;				// Buffer reset flag
	reg			interrupt;					// Interrupt flag
	
	// Assignments ======================================================
	// Track rise fall of two main signals
	assign sck_rise = (track_sck[2:1] == 2'b01);
	assign sck_fall = (track_sck[2:1] == 2'b10);
	assign cs_rise = (track_cs[2:1] == 2'b01);
	assign cs_fall = (track_cs[2:1] == 2'b10);
	assign cs_active = !track_cs[1];
	// Output assignments
	assign slave_rdy_o = slave_rdy;
	assign status_reg = {cs_i,2'b11,master_rdy_i,outbound_full,outbound_empty,inbound_full,inbound_empty};
	assign interrupt_o = interrupt;
	
	// Data output assignment
	assign D_o = (A_i[0] == 0) ? inbound_data : status_reg;	// Data register or status register based on LSB
					
	
	// Module connections	
	// Inbound FIFO
	fifo #(
		.log2_addr(fifo_log2),
		.data_width(8)
	) inbound ( 
		.n_reset_i(!clear_buffers & dma_reset_n),	// Reset on request or DMA start
		.clk_i(busclk_i),
		.data_i(rdr),
		.wr_i(wr),
		.data_o(inbound_data),
		.rd_i((!nRD_i & (A_i[0] == 0)) | dma_rd),	// Read - when RD goes low
		.fifo_empty_o(inbound_empty),
		.fifo_full_o(inbound_full)
	);

	// Outbound FIFO
	fifo #(
		.log2_addr(fifo_log2),
		.data_width(8)
	) outbound ( 
		.n_reset_i(!clear_buffers),
		.clk_i(busclk_i),
		.data_i(D_i),
		.wr_i(!nWR_i & (A_i[0] == 0)),	// Only write when addressing the outbound reg
		.data_o(outbound_data),
		.rd_i(rd),
		.fifo_empty_o(outbound_empty),
		.fifo_full_o(outbound_full)
	);

	// Track SCK
	always @(posedge fast_clock_i)
		track_sck <= {track_sck[1:0], sck_i};

	// Track CS
	always @(posedge fast_clock_i)
		track_cs <= {track_cs[1:0], cs_i};

	// Track MOSI into this clock domain
	always @(posedge fast_clock_i)
		track_mosi <= {track_mosi[1:0], mosi_i};
	
	// Inbound shift registers
	always @(posedge fast_clock_i)
	begin
		if( !cs_active )
			cntr <= 3'd0;
		else begin
			if( sck_rise ) rdr <= {rdr[6:0],track_mosi[1]};
			if( sck_fall ) cntr <= cntr + 3'd1;
		end
	end

	// Detect a mid-cycle so the first_write flag can be reset
	always @(negedge fast_clock_i)
	begin
		if( !cs_active ) first_write <= 1;
		else
		if( cntr == 3'd4 ) first_write <= 0;
	end

	// Write buffer handling
	always @(negedge fast_clock_i) wr <= cs_active & (cntr==3'd7) & sck_fall & !first_write;

	// Read buffer handling
	always @(negedge fast_clock_i) rd <= (cs_active & (cntr==3'd7) & sck_fall) | cs_fall;
	
	// Set the outbound data
	assign miso_o = (!outbound_empty_reg) ? outbound_data[~cntr]: 1'b1;
	
	// Need to register the empty flag because the read is at the start and sets the empty flag
	// obscuring the last byte from transmission
	always @(posedge rd) outbound_empty_reg = outbound_empty;
	
	// ================================================================================	
	// Status/Data registers
	// ================================================================================	
	
	reg [2:0] slow_cs;
	always @(negedge busclk_i) slow_cs = {slow_cs[1:0],cs_i};
	wire slow_rise = (slow_cs == 2'b01);
	
	// Writing 0bxxxxxxx1 to address 1 will flag the device as ready
	always @( posedge busclk_i )
	begin
		if( slow_rise )
			slave_rdy <= 0;
		else begin
			if( !nWR_i & ( A_i[0] == 1'b1 ) )
				slave_rdy <= D_i[0];
		end
	end
	
	// Clear the buffers
	reg [1:0] track_clear;
	wire rs = !nWR_i & (A_i[0] == 1'b1) & D_i[7];
	always @(negedge busclk_i)	track_clear <= {track_clear[0],rs};
	always @(posedge busclk_i) clear_buffers <= (track_clear == 2'b01);

	// ================================================================================	
	// Interrupt line - registered
	// ================================================================================	
	reg [7:0] old_reg = 0;
	always @(negedge fast_clock_i) old_reg <= status_reg;
	always @(posedge fast_clock_i) interrupt = (old_reg != status_reg);
	
	// =============================================================
	// Support memory DMA in from SPI - allows in-system programming
	// =============================================================
	support_dma support_dma(
		.clk_i(/*fast_clock_i*/busclk_i),
		.n_reset_o( dma_reset_n ),
		.enable_i(dma_en_i),
		.d_avail_i(!inbound_empty),
		.data_i( inbound_data ),
		.adr_o( dma_adr_o ),
		.data_o( dma_dat_o ),
		.wr_o(dma_wr_o),
		.rd_o(dma_rd)
	);
	
	// =============================================================
	
endmodule
