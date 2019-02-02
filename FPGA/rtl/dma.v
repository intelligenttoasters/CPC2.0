/*
 * dma.v - DMA module for support CPU
 *
 * Copies memory from the support CPU memory space to the SDRAM or the other way around
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
 * Registers:
 * 	0-3 : SDRAM Address (byte addressing, aligned on 8 word boundaries)
 *		4-5 : Support Memory Address (byte addressing, aligned on 2 byte boundaries)
 *		8-9 : Copy length (truncated to multiples of 16 bytes/8 words)
 *		F-F : 	Control(W)		Status(R)
 *			Bit 0	Start	S->M		Error
 *			Bit 1	Start M->S		Operation In Progress
 *			Bit 2	Abort				Operation Complete
 * 		Bit 3						SDRAM Ready
 */
`timescale 1ns/1ns
`default_nettype none

module dma ( 
	// Control Interface
	input wire 			clock_i,			// Support CPU clock
	input wire			reset_i,
	input wire			sdram_ready_i,
	input wire [3:0] 	A_i,
	input wire [7:0]	D_i,
	output reg [7:0]	D_o,
	input wire			rd_i,
	input wire			wr_i,
	output wire			interrupt_o,
	input wire 			mem_clock_i,	// SDRAM clock
	// SDRAM Interface
	output reg 		 	req_o,
	input	wire		 	ack_i,
	output reg [31:0]	adr_o,
	output reg [15:0]	dat_o,
	input wire [15:0]	dat_i,
	output wire			rd_o,
	output wire			wr_o,
	// Combined with falling edge of clock valid_i indicates that the data should transition to next state
	input wire			valid_i,
	// Memory Interface
	output reg [14:0] dma_A,
	output reg [7:0] dma_Dout,
	input wire [7:0]	dma_Din,
	output reg			dma_wr,
	input wire [6:0]	dma_wp
	);

	parameter IDLE = 3'd0, ERROR = 3'd1, 	
				// ^^ Inactive states ^^
				// vv Inactive states vv
				M2S1 = 3'd2, S2M1 = 3'd3,	// Read from source
				M2S2 = 3'd4, S2M2 = 3'd5;	// Write to destination
	
	// Wire definitions ===========================================================================
	wire [7:0] status;
	wire m2s_state, s2m_state, abort_state;
	
	// Registers ==================================================================================
	reg [2:0] state;
	reg [31:0] sd_addr, sd_addr_work;
	reg [15:0] tfr_counter, tfr_counter_work;
	reg [14:0] mem_addr, mem_addr_work;
	(* ramstyle = "mlab" *) reg [15:0] holding, holding_alt;
	(* ramstyle = "mlab" *) reg [7:0] data_buffer_h [0:7], data_buffer_l [0:7];
	reg [5:0] burst_cntr;
	reg [3:0] buffer_ptr;
	
	// Clock crossing domiain registers
	reg cpu_m2s_state, mem_m2s_state;
	reg cpu_s2m_state, mem_s2m_state;
	reg cpu_abort_state, mem_abort_state;
	reg [2:0] cpu_m2s_synchroniser, cpu_s2m_synchroniser, cpu_abort_synchroniser; 

	// Assignments ================================================================================
	assign status = {4'd0, sdram_ready_i, (state==IDLE),
							~((state==IDLE)||(state==ERROR)), state == ERROR};
	assign m2s_state = (cpu_m2s_synchroniser[2] != mem_m2s_state);
	assign s2m_state = (cpu_s2m_synchroniser[2] != mem_s2m_state);
	assign abort_state = (cpu_abort_synchroniser[2] != mem_abort_state);
	
	// Set up control signals for SDRAM
	assign wr_o = (state == M2S2);
	assign rd_o = (state == S2M1);
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	`ifdef SIM
		wire [15:0] buf0 = { data_buffer_h[0], data_buffer_l[0] };
		wire [15:0] buf1 = { data_buffer_h[1], data_buffer_l[1] };
		wire [15:0] buf2 = { data_buffer_h[2], data_buffer_l[2] };
		wire [15:0] buf3 = { data_buffer_h[3], data_buffer_l[3] };
		wire [15:0] buf4 = { data_buffer_h[4], data_buffer_l[4] };
		wire [15:0] buf5 = { data_buffer_h[5], data_buffer_l[5] };
		wire [15:0] buf6 = { data_buffer_h[6], data_buffer_l[6] };
		wire [15:0] buf7 = { data_buffer_h[7], data_buffer_l[7] };
	`endif
	// Support clock logic
	always @(posedge clock_i or posedge reset_i)
	begin
		if( reset_i ) begin
			sd_addr <= 32'd0;
			mem_addr <= 15'd0;
			tfr_counter <= 15'd0;
			cpu_m2s_state <= 1'b0;
			cpu_s2m_state <= 1'b0;
			cpu_abort_state <= 1'b0;
		end
		else begin
			if( wr_i ) begin
				case( A_i )
					// Store the registers
					4'd0: sd_addr[7:0] <= {D_i[7:4],4'd0};
					4'd1: sd_addr[15:8] <= D_i;
					4'd2: sd_addr[23:16] <= D_i;
					4'd3: sd_addr[31:24] <= D_i;
					4'd4: mem_addr[7:0] <= D_i;
					4'd5: mem_addr[14:8] <= D_i[6:0];
					4'd8: tfr_counter[7:0] <= {D_i[7:4],4'd0};
					4'd9: tfr_counter[15:8] <= D_i;
					// Control handler
					4'd15: begin
						// If M->SD
						if( D_i[1] ) begin
							if( ~m2s_state ) cpu_m2s_state <= ~cpu_m2s_state;
						end 
						else
						// If SD->M
						if( D_i[0] ) begin
							if( ~s2m_state ) cpu_s2m_state <= ~cpu_s2m_state;
						end 
						else
						// If Abort
						if( D_i[2] ) begin
							if( ~abort_state ) cpu_abort_state <= ~cpu_abort_state;
						end 						
					end
					default: ;
				endcase
			end
			else
			if( rd_i ) begin
				// Return stored registers
				case( A_i )
					4'd0: D_o <= sd_addr[7:0];
					4'd1: D_o <= sd_addr[15:8];
					4'd2: D_o <= sd_addr[23:16];
					4'd3: D_o <= sd_addr[31:24];
					4'd4: D_o <= mem_addr[7:0];
					4'd5: D_o <= mem_addr[14:8];
					4'd8: D_o <= tfr_counter[7:0];
					4'd9: D_o <= tfr_counter[15:8];
					4'd15: D_o <= status;
				endcase
			end				
		end
	end

	// Synchronisers CPU->MEM domain
	always @(negedge mem_clock_i) 
	begin
		cpu_m2s_synchroniser <= {cpu_m2s_synchroniser[1:0],cpu_m2s_state};
		cpu_s2m_synchroniser <= {cpu_s2m_synchroniser[1:0],cpu_s2m_state};
		cpu_abort_synchroniser <= {cpu_abort_synchroniser[1:0],cpu_abort_state};
	end

	always @(posedge mem_clock_i or posedge reset_i)
	begin
		if( reset_i ) begin
			state <= IDLE;
			mem_m2s_state <= 1'b0;
			mem_s2m_state <= 1'b0;
			mem_abort_state <= 1'b0;
			dma_wr <= 1'b0;
			req_o <= 1'b0;
		end
		else begin
			case( state )
				// Trigger DMA start operations
				IDLE, ERROR : begin
					dma_wr <= 1'b0;
					// Memory to SDRAM
					if( m2s_state ) begin
						state <= M2S1;
						mem_m2s_state <= ~mem_m2s_state;
						burst_cntr <= 5'd0;
					end
					else
					// SDRAM to Memory
					if( s2m_state ) begin
						state <= S2M1;
						req_o <= 1'b1;
						adr_o <= sd_addr_work;
						mem_s2m_state <= ~mem_s2m_state;
					end
					// Transfer counter is num bytes / 16 (burst)
					tfr_counter_work <= {4'b0,tfr_counter[15:4]};
					sd_addr_work <= {1'b0,sd_addr[31:1]};
					mem_addr_work <= mem_addr;
					burst_cntr <= 5'd0;
					buffer_ptr <= 4'd0;
				end
				// Read block ram
				M2S1 : begin
					// Move the dma address forward 16 bytes
					if( burst_cntr < 5'd16 )
					begin
						dma_A <= mem_addr_work;
						mem_addr_work <= mem_addr_work + 1'b1;					
					end

					// Wait until the data gets through the pipeline before storing
					if ( burst_cntr > 5'd1 ) 
					begin
						// High-low pairs
						case( buffer_ptr[0] )
							0: data_buffer_l[buffer_ptr[3:1]] <= dma_Din;
							1: data_buffer_h[buffer_ptr[3:1]] <= dma_Din;
						endcase
						buffer_ptr <= buffer_ptr + 1'b1;
					end
					if( burst_cntr == 5'd17 )
					begin
						adr_o <= sd_addr_work;
						burst_cntr <= 5'd0;
						buffer_ptr <= 4'd0;
						// Check for abort
						if( abort_state )
						begin
							state <= ERROR;
							mem_abort_state <= ~mem_abort_state;
						end
						else
						begin
							state <= M2S2;
							req_o <= 1'b1;
						end
					end else burst_cntr <= burst_cntr + 1'b1;
				end

				// Write SDRAM
				M2S2 : begin
					if( ack_i ) req_o <= 1'b0;
					if( ( buffer_ptr == 0 ) || valid_i )
					begin
						holding <= {data_buffer_h[buffer_ptr],data_buffer_l[buffer_ptr]};
						dat_o <= holding;
						buffer_ptr <= buffer_ptr + 1'b1;
					end

					// If the SDRAM controller indicates that it's ready to accept written data
					if( valid_i ) 
					begin
						if ( burst_cntr != 5'd7 )
							burst_cntr <= burst_cntr + 1'b1;
						else begin

							// SDRAM address only needs an update each time the next burst starts
							sd_addr_work <= sd_addr_work + 4'd8;
							
							// If the transfer is finished, then return to idle
							if( tfr_counter_work <= 4'd1 ) state <= IDLE;
							else begin
								// Otherwise reduce the transfer count by 1 (8 words) and go back for next set of data
								tfr_counter_work <= tfr_counter_work - 1'd1;
								buffer_ptr <= 4'd0;
								burst_cntr <= 5'd0;
								sd_addr_work <= sd_addr_work + 4'd8;
								state <= M2S1;
							end
						end
					end
				end
				
				// Read SDRAM
				S2M1 : begin
					if( ack_i ) req_o <= 1'b0;
				
					if( valid_i || (burst_cntr != 0))
					begin
						{data_buffer_h[buffer_ptr],data_buffer_l[buffer_ptr]} <= holding_alt;
						if( burst_cntr == 5'd7 ) 
						begin
							state <= S2M2;
							burst_cntr <= 5'd0;
							buffer_ptr <= 3'd0;
							sd_addr_work <= sd_addr_work + 4'd8;
						end else begin
							burst_cntr <= burst_cntr + 1'b1;
							buffer_ptr <= buffer_ptr + 1'b1;
						end
					end
				end
				
				// Write MEM
				S2M2 : begin
					// Set up the DMA write address
					dma_A <= mem_addr_work;
					dma_wr <= 1'b1;
					dma_Dout <= (buffer_ptr[0]) ? data_buffer_h[buffer_ptr[3:1]] : data_buffer_l[buffer_ptr[3:1]];
					buffer_ptr <= buffer_ptr + 1'b1;
					if( burst_cntr < 16 )
					begin
						burst_cntr <= burst_cntr + 1'b1;
						mem_addr_work <= mem_addr_work + 1'b1;
					end else begin
						dma_wr <= 1'b0;
						if( tfr_counter_work == 1'd1 ) state <= IDLE;
						else begin
							tfr_counter_work <= tfr_counter_work - 1'b1;
							burst_cntr <= 1'b0;
							buffer_ptr <= 1'b0;
							req_o <= 1'b1;
							adr_o <= sd_addr_work;
							state <= S2M1;
						end
					end
				end
				
				default: ;
			endcase
		end
	end
	
	// Data is available before rising SDRAM clock, so read it on negedge of mem_clock as it's offset
	always @(negedge mem_clock_i) holding_alt <= dat_i;

endmodule
	
