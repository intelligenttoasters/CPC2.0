/*
 * usart.v - Serial interface to supervisor chip
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

`define BAUD 115200
`define CLOCK 48000000
//(`CLOCK/`BAUD)
//`define SPAN 103 
`define SPAN (`CLOCK/`BAUD)

module usart #(
	parameter fifo_log2 = 9,
	parameter divisor = `SPAN
	) ( 
	// Uart signals
	output tx_o,
	input rx_i,
	// Bus signals
	input n_reset_i,
	input busclk_i,	// Clock for bus signals
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

	// Wire definitions ===========================================================================
	wire			dma_rd, dma_reset_n;
	wire [7:0]	outbound_data, inbound_data, status_reg;
	wire			inbound_empty, outbound_empty, outbound_full, inbound_full;
	wire			rx_fall, rx;
	wire			inb_read_data;
	
	// Registers ==================================================================================
	reg			clear_buffers;				// Buffer reset flag
	reg			interrupt;					// Interrupt flag
	reg			rd = 0, wr = 0;			// Read and write flags
	reg [15:0]	inbound_timer = 0, outbound_timer = 0;
	reg [3:0]	inbound_counter = 0, outbound_counter = 0;
	
	// Edge tracking and synchronizer chain
	reg [3:0]	track_rx = 4'b1111;
	
	// Inbound Registers
	reg [7:0] 	rdr = 0;		// Receive data register, dont record stop bit
	
	// Outbound Registers
	reg [9:0]	sdr = 10'b1111111111;		// Send data register
	
	// Assignments ================================================================================
	assign D_o = (A_i[0] == 0) ? inbound_data : status_reg;	// Data register or status register based on LSB
	assign status_reg = {4'b1111,outbound_full,outbound_empty,inbound_full,inbound_empty};
	assign interrupt_o = interrupt;
	assign rx_fall = (track_rx[3:2] == 2'b10);
	assign rx = track_rx[2];
	assign inb_read_data = !nRD_i && (A_i[0] == 0);
	
	// Module connections =========================================================================
	
	// Normalise the CPU signals, RD only active for one cycle, starting on negedge
	// Delay the read signal by 2 clocks, then current state AND delayed state will overlap on only one clock
	reg [1:0] track_rd = 2'b00;
	reg inb_rd = 0;
	always @(posedge busclk_i) track_rd <= {track_rd[0],inb_read_data};
	always @(negedge busclk_i) inb_rd <= (inb_rd) ? 1'b0 : (track_rd[1] & inb_read_data);
	
	// Inbound FIFO
	fifo #(
		.log2_addr(fifo_log2),
		.data_width(8)
	) inbound ( 
		.n_reset_i(!clear_buffers & dma_reset_n),	// Reset on request or DMA start
		.rclk_i(busclk_i),
		.data_i(rdr),
		.wclk_i(busclk_i),
		.wr_i(wr),
		.data_o(inbound_data),
		.rd_i(inb_rd | dma_rd),	// Read - when RD goes low
		.fifo_empty_o(inbound_empty),
		.fifo_full_o(inbound_full)
	);

	// Outbound FIFO
	fifo #(
		.log2_addr(fifo_log2),
		.data_width(8)
	) outbound ( 
		.n_reset_i(!clear_buffers),
		.wclk_i(busclk_i),
		.data_i(D_i),
		.wr_i(!nWR_i & (A_i[0] == 0)),	// Only write when addressing the outbound reg
		.rclk_i(busclk_i),
		.data_o(outbound_data),
		.rd_i(rd),
		.fifo_empty_o(outbound_empty),
		.fifo_full_o(outbound_full)
	);

	// =============================================================
	// Support memory DMA in from SPI - allows in-system programming
	// =============================================================
	support_dma support_dma(
		.clk_i(busclk_i),
		.n_reset_o( dma_reset_n ),
		.enable_i(dma_en_i),
		.d_avail_i(!inbound_empty),
		.data_i( inbound_data ),
		.adr_o( dma_adr_o ),
		.data_o( dma_dat_o ),
		.wr_o(dma_wr_o),
		.rd_o(dma_rd)
	);
	
	// Control ============================================================	
	// Delay the reset signal for the outbound logic as read has to happen before engine starts
//	reg [1:0] delayed_reset = 0;
//	always @(negedge busclk_i) delayed_reset <= {delayed_reset[0],n_reset_i};
//	wire delayed_reset_sig = delayed_reset[1];
	
	// Delay the outbound_empty signal for the outbound logic as read has to happen before engine starts transmitting
	reg delayed_read = 0;
	always @(posedge busclk_i) delayed_read <= rd;
	reg delayed_read2 = 0;
	always @(negedge busclk_i) delayed_read2 <= delayed_read;
	
	// Outbound logic =================================================
	always @(posedge busclk_i)
	begin
		if( n_reset_i & dma_reset_n)
		begin
			// Outbound timer
			if( outbound_timer != 0 ) 
				outbound_timer <= outbound_timer - 1'b1;
			else begin
				// Outbound counter
				if( outbound_counter != 0 ) 
				begin
					outbound_counter <= outbound_counter - 1'b1;
					outbound_timer <= divisor;
					sdr <= {1'd1,sdr[9:1]};						// Move to the next bit, fill with 1's
				end
				else
				begin
					if( delayed_read2 )
					begin
						outbound_counter <= 4'd9;				// Send 10 bits, including framing
						outbound_timer <= divisor;				// Sample every bit width
						sdr <= {1'b1,outbound_data,1'b0};	// Send outbound framed by start and stop bits
					end			
				end
			end
		end
		else begin	// Abort any transmission
			outbound_timer <= 0;
			outbound_counter <= 0;
		end
	end
	
	// Outbound memory read - if RD is high then make it low, then cycle starting will prevent RD signal from rising again
	always @(negedge busclk_i)
		rd <= ( rd ) ? 1'b0 : ((outbound_timer == 16'd0) && (outbound_counter == 4'd0) && n_reset_i && !outbound_empty);	

	// Outbound transmit line
	assign tx_o = sdr[0];
	
	// Inbound logic ============================================
	// Synchronize and track the received signal
	always @(posedge busclk_i) track_rx <= {track_rx[2:0], rx_i};
	
	always @(negedge busclk_i)
	begin
		if( n_reset_i & dma_reset_n)
		begin
			// inbound timer
			if( inbound_timer != 0 ) 
				inbound_timer <= inbound_timer - 1'b1;
			else begin
				// inbound counter
				if( inbound_counter != 0 ) 
				begin
					inbound_counter <= inbound_counter - 1'b1;
					inbound_timer <= divisor;
					rdr <= {rx,rdr[7:1]};						// Sample to the next bit
				end
				else
				begin
					if( rx_fall )									// Start the process on the first fall
					begin
						inbound_counter <= 4'd9;				// Receive 10 bits, including framing
						inbound_timer <= (divisor>>1);		// Sample every bit width, starting at half bit width
					end					
				end
			end
		end
		else begin	// Abort any reception
			inbound_timer <= 0;
			inbound_counter <= 0;
		end
	end

	// Inbound memory write logic
	reg [1:0] track_finish = 2'b11;
	always @(posedge busclk_i) track_finish <= {track_finish[0],((inbound_timer == 16'd0) && (inbound_counter==0))};
	always @(negedge busclk_i) wr <= (track_finish == 2'b01);
	
	// Other logic ================================================================================

	// Clear the buffers
	reg [1:0] track_clear;
	wire rs = !nWR_i & (A_i[0] == 1'b1) & D_i[7];
	always @(posedge busclk_i)	track_clear <= {track_clear[0],rs};
	always @(negedge busclk_i) clear_buffers <= (track_clear == 2'b01);

	// ================================================================================	
	// Interrupt line - registered
	// ================================================================================	
	reg [15:0] old_reg = 0;
	always @(negedge busclk_i) old_reg <= {old_reg[7:0],status_reg};	// Shift down 8 bits
	always @(posedge busclk_i) interrupt = (old_reg[15:8] != status_reg);

	
endmodule
	
