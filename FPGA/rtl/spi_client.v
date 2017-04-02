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
	output interrupt_o
	);

	// Wire definitions
	wire			sck_gated;
	wire [7:0]	outbound_data, inbound_data;
	wire			inbound_empty, outbound_empty, outbound_full, inbound_full;
	wire			cycle_commit;
	wire			clear_buffers;	// Buffer reset flag
	
	// Inbound Registers
	reg [7:0] 	rdr = 0;
	
	// System vars
	reg [2:0] 	shift_count = 7;
	reg [2:0] 	delayed_shift_count = 7;
	reg			in_cycle, old_cycle;	// Indicates the SPI is in a cycle
	reg [7:0]	data_reg;	// Holding register for the data bus
	reg			slave_rdy = 0;	// Slave ready register
//	reg			interrupt = 0;
//	reg			cycle_commit = 0;		// Commit for write/read in/out buffers
	
	// Assignments
	assign sck_gated = sck_i & !cs_i & n_reset_i & slave_rdy; // Not reset, and slave ready then pass SCK
	assign D_o = data_reg;
	assign slave_rdy_o = slave_rdy;
	//assign interrupt_o = interrupt;
	
	// Module connections	
	// Inbound FIFO
	fifo #(
		.log2_addr(fifo_log2),
		.data_width(8)
	) inbound ( 
		.n_reset_i(n_reset_i & !clear_buffers),
		.data_i(rdr),
		.wr_i(cycle_commit),
		.data_o(inbound_data),
		.rd_i(!nRD_i & (A_i[0] == 0)),	// Read confirm - when RD goes high again at end of read cycle
		.fifo_empty_o(inbound_empty),
		.fifo_full_o(inbound_full)
	);

	// Outbound FIFO
	fifo #(
		.log2_addr(fifo_log2),
		.data_width(8)
	) outbound ( 
		.n_reset_i(n_reset_i & !clear_buffers),
		.data_i(D_i),
		.wr_i(!nWR_i & (A_i[0] == 0)),	// Only write when addressing the outbound reg
		.data_o(outbound_data),
		.rd_i(cycle_commit),
		.fifo_empty_o(outbound_empty),
		.fifo_full_o(outbound_full)
	);

	// Bit counters
	always @(posedge sck_gated or posedge cs_i)
			shift_count <= (cs_i == 1'b1) ? 3'd7 : shift_count - 1'b1;
	always @(negedge sck_gated or posedge cs_i)
			delayed_shift_count <= (cs_i == 1'b1) ? 3'd7 : shift_count;
			
	// This is a cycle indicator flag - are we in the middle of an SPI cycle
	always @(sck_gated or cs_i)
	begin
		if( cs_i )
			in_cycle <= 0;
		else begin
			if( sck_gated && delayed_shift_count == 7 )
				in_cycle <= 1;
			else
			if( !sck_gated && shift_count == 7 )
				in_cycle <= 0;
		end
	end
	
	// Manage the read/write commit signal at the end of each cycle
	// Sample the in_cycle signal and store the last state for comparison
	always @( negedge sck_i ) old_cycle <= in_cycle;
	assign cycle_commit = (old_cycle == 1) & (in_cycle == 0);	// Self resets when old=new

	// Inbound shift registers
	always @(posedge sck_gated)	rdr <= {rdr[6:0],mosi_i};

	// Outbound portion
	// Only allow the MISO to be driven if something to send
	assign miso_o = (slave_rdy & !outbound_empty) ? outbound_data[delayed_shift_count]: 1'b1;
	
	// ================================================================================	
	// Status/Data registers
	// ================================================================================	
	always @(negedge nRD_i)
		data_reg <= (A_i[0] == 0) ? inbound_data : 
					{cs_i,2'b0,master_rdy_i,outbound_full,outbound_empty,inbound_full,inbound_empty};
	
	// Writing anything to address 1 will flag the device as ready
	always @(negedge nWR_i or posedge cs_i)
		if( !nWR_i )
		begin
			if ( A_i[0] == 1'b1 )
				slave_rdy <= D_i[0];
		end
		else
		if( cs_i )
			slave_rdy <= 0;

	// Clear the buffers
	assign clear_buffers = (rs == 1'b1) && (last_state == 1'b0);
	wire rs = !nWR_i & (A_i[0] == 1'b1) & D_i[7];
	reg last_state = 0;
	always @(posedge busclk_i)
		last_state <= rs;
	// ================================================================================	
	// Interrupt line
	// ================================================================================	
	reg [5:0] old_triggers = 0;
	wire [5:0] interrupt_triggers = {cs_i, outbound_full, inbound_full, outbound_empty, inbound_empty, master_rdy_i };
	always @(posedge busclk_i) old_triggers <= interrupt_triggers;
	assign interrupt_o = (old_triggers != interrupt_triggers);
	/*
	always @(posedge (old_triggers != interrupt_triggers) or negedge nRD_i)
	begin
		if( !nRD_i )
			interrupt <= 0;
		else
			interrupt <= 1;
	end
	*/
endmodule
