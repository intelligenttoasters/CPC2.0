/*
 * hyperram_ctl.v - HyperRam Controller 
 *
 * This module provides a generic memory interface to a HyperRam module 
 *
 * Part of the CPC2 project: http://intelligenttoasters.blog
 *
 * Copyright (C)2018  Intelligent.Toasters@gmail.com
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
 
`timescale 1 ns/1 ns
`default_nettype none

module hyperram_ctl(
	// System core signals
	input wire 			clk_i,
	input wire			rst_i,
	output reg			ready_o, 
	
	// Memory  bus signals / asynchronous edge triggered bus
	input wire [23:0]	A_i,		// 24 bit address space, for 16 bit words (max 32MB)
	input wire [15:0]	D_i,
	output wire [15:0]	D_o,
	output wire			D_valid,	// Signal D_o contains a valid signal (busy can still be high when valid)
	// 000 - write single high, 001 - write single low, 
	// 010 - read mem, 011 - read mem - ** or if there's something in cache, read from cache **
	// 101 - write ctl, 111 - read ctl
	// 100 - cache flush to mem, 110 Write Cache
	input wire [2:0]	cmd_i,		
	input wire			go_i,		// Edge triggered action signal
	output wire			busy_o,		// Busy signal
	
	// HyperRAM hardware interface
	input wire [7:0]	dq_i,
	output reg [7:0]	dq_o,
	output reg			dq_oe,
	input wire			rwds_i,
	output reg			rwds_o,
	output reg			rwds_oe,
	output reg			csn_o,
	output reg			ck_o,
	output reg			resetn_o
    );

	`define MEMSIZE64
	//`define MEMSIZE128
	//`define MEMSIZE256
	
	// Constants ==================================================================================
	parameter INIT1 = 4'd0, INIT2 = 4'd1, IDLE = 4'd2, CMD1 = 4'd3, CMD2 = 4'd4, RD1 = 4'd5, RD2 = 4'd6,
				CSWAIT = 4'd7, WR1 = 4'd8, WR2 = 4'd9, LATENCY = 4'd10, LOOP = 4'd11;
	
	// Wire definitions ===========================================================================
	wire [47:0] cmd_bits;
	wire go_rising, cache_command_i, cache_command_b, read_command, ctl_command, cmd_rd, cmd_ctl;
	
	// Registers ==================================================================================
	
	// State machine registers
	reg [3:0]	state;			// FSM state
	reg [15:0]	large_counter;	// Large general counter
	reg [3:0]	small_counter;	// Small general counter
	reg [7:0]	cmd_bytes[0:5];	// 6 Command bytes
	reg			in_rwds_cycle;	// Signal in data stage
	
	// Read Data Cache
(* ramstyle = "mlab" *)	reg [15:0]	read_cache[0:7];	// 8 words, 16 bytes cache space
	reg [21:0]	cache_addr;			// 0-20 High order bits for caching address +1 bit to invalidate cache
	reg [2:0]	cache_line_ptr;		// Low order bits for caching
	reg			cache_valid;		// Read cache valid?
	reg [2:0]	cache_ptr;			// Points to active cache item to read
	// Write Data Cache
(* ramstyle = "mlab" *)	reg [15:0]	write_cache[0:7];	// 8 words, 16 bytes cache space
	reg [3:0]	write_ptr;			// Write pointer for the write cache
	reg [7:0]	cache_pop;			// Write-Cache population;
	
	// Buffered input signals that hold data stable
	reg [23:0]	A_b = 24'd0;
	reg [15:0]	D_b = 16'd0;
	reg [2:0]	cmd_b = 3'd0;

	// Signal level tracking
	reg [2:0]	track_go = 3'd0;
	
	// Assignments ================================================================================
	`ifdef MEMSIZE64	// second bit is only for control operations
	assign cmd_bits = {cmd_i[1], (cmd_i[2] & cmd_i[0]), 1'd0, 10'd0, A_i[21:3], 13'd0, A_i[2:0]};
	`endif	// TODO: Other memory sizes
	`ifdef MEMSIZE128
	assign cmd_bits = {~we_i, tga_i, 1'd0, 9'd0, adr_i[22:3], 13'd0, adr_i[2:0]};
	`endif
	`ifdef MEMSIZE256
	assign cmd_bits = {~we_i, tga_i, 1'd0, 8'd0, adr_i[23:3], 13'd0, adr_i[2:0]};
	`endif
	// Post trigger wire assignments - only valid after cmd is buffered
	assign cmd_rd = cmd_b[1];							// Signal READ operation
	assign cmd_ctl = ({cmd_b[2],cmd_b[0]} == 2'b11); 	// Signals a control command
	
	// Tracks the rising go trigger 
	assign go_rising = (track_go[2:1] == 2'b01);
	// Is the FSM busy?
	assign busy_o = (state != IDLE);
	// Signals the CMD_I is a cache command 
	assign cache_command_i = (cmd_i[2] & ~cmd_i[0]);
	assign cache_command_b = (cmd_b[2] & ~cmd_b[0]);
	// Signals the CMD_I is a read command
	assign read_command = (cmd_i[2:1] == 2'b01);
	// Signals a control command
	assign ctl_command = ({cmd_i[2],cmd_i[0]} == 2'b11);
	// Assign D_o asynchronously to be quickest
	assign D_o = read_cache[cache_line_ptr];
	// Assign valid output
	assign D_valid = cache_valid;
	
	// Module connections =========================================================================

	// Simulation branches and control ============================================================
	`ifdef SIM
wire [7:0] b0 = cmd_bytes[0];	
wire [7:0] b1 = cmd_bytes[1];	
wire [7:0] b2 = cmd_bytes[2];	
wire [7:0] b3 = cmd_bytes[3];	
wire [7:0] b4 = cmd_bytes[4];	
wire [7:0] b5 = cmd_bytes[5];	
wire [15:0] cache0 = read_cache[0];
wire [15:0] cache1 = read_cache[1];
wire [15:0] cache2 = read_cache[2];
wire [15:0] cache3 = read_cache[3];
wire [15:0] cache4 = read_cache[4];
wire [15:0] cache5 = read_cache[5];
wire [15:0] cache6 = read_cache[6];
wire [15:0] cache7 = read_cache[7];
wire [15:0] wcache0 = write_cache[0];
wire [15:0] wcache1 = write_cache[1];
wire [15:0] wcache2 = write_cache[2];
wire [15:0] wcache3 = write_cache[3];
wire [15:0] wcache4 = write_cache[4];
wire [15:0] wcache5 = write_cache[5];
wire [15:0] wcache6 = write_cache[6];
wire [15:0] wcache7 = write_cache[7];
`endif
	// Functions and tasks ========================================================================
	
	// Signal level tracking ======================================================================
	always @(posedge clk_i) track_go <= {track_go[1:0],go_i};
	
	// Core logic =================================================================================
		
	always @(posedge clk_i or posedge rst_i) 
	begin
		// Reset circuitry
		if( rst_i ) begin
			state <= INIT1;
			large_counter = 16'd30000;
		end else case(state)
			// Initialisation of signals and FSM
			// Two goes around, one for power up and one for reset release
			INIT1, INIT2: begin
				dq_o <= 8'd0;
				dq_oe <= 1'b0;
				rwds_o <= 1'b0;
				rwds_oe <= 1'b0;
				csn_o <= 1'b1;
				ck_o <= 1'b0;
				ready_o <= 1'b0;
				in_rwds_cycle <= 1'b0;
				resetn_o = ( state != INIT1 );
				cache_ptr <= 3'd0;
				cache_valid <= 1'b0;
				// Initial config - program config 1
				cmd_bytes[0] <= 8'h60;
				cmd_bytes[1] <= 8'h00;
				cmd_bytes[2] <= 8'h01;
				cmd_bytes[3] <= 8'h00;
				cmd_bytes[4] <= 8'h00;
				cmd_bytes[5] <= 8'h00;
				write_cache[0] <= 16'h8fee;	// Fixed latency. Variable latency is 16'h8fe6  
				cache_pop <= 8'b00000001;
				write_ptr <= 4'd0;
				cache_ptr <= 3'd0;
				cache_line_ptr <= 3'd0;
				// End initial config
				
				if( large_counter == 0 ) 
				begin
					large_counter <= 16'd20000;
					if( state == INIT1 ) state <= INIT2;
					//else state <= IDLE;
					else begin
						small_counter <= 4'd2;
						csn_o <= 1'b0;
						dq_oe <= 1'b1;
						cmd_b <= 3'b101;
						state <= CSWAIT;						
					end
				end
				else large_counter <= large_counter - 1'b1;
			end
			IDLE: begin
				// Signal core ready
				ready_o <= 1'b1;
				// Reset RWDS OE signal from previous write
				rwds_oe = 1'b0;
				// Reset RWDS flag
				in_rwds_cycle <= 1'b0;
				// Reset clk
				ck_o <= 1'b0;
				
				if( go_rising ) begin
					// Cache mainly used for streaming data, like the video module
					if( cache_command_i ) begin
						// If Cache flush then initiate write
						if( ~cmd_i[1] ) begin
							// Is there something to write home about?
							if( cache_pop[0] ) begin
								// Counter for CS latency
								small_counter <= 4'd2;
								csn_o <= 1'b0;
								dq_oe <= 1'b1;
								// Copy cmd bits to cmd bytes
								cmd_bytes[0] <= cmd_bits[47:40];		
								cmd_bytes[1] <= cmd_bits[39:32];		
								cmd_bytes[2] <= cmd_bits[31:24];		
								cmd_bytes[3] <= cmd_bits[23:16];		
								cmd_bytes[4] <= cmd_bits[15:08];		
								cmd_bytes[5] <= cmd_bits[07:00];
								// Start the process
								state <= CSWAIT;
							end
						end else begin	// Store data in cache registers
							if( write_ptr[0] ) write_cache[write_ptr[3:1]][15:8] <= D_i[15:8];
							else write_cache[write_ptr[3:1]][7:0] <= D_i[7:0];
							write_ptr <= write_ptr + 1'b1;
							cache_pop <= cache_pop | (1'b1<<write_ptr[3:1]); 
						end
					end else begin	// Single word action
						// Copy cmd bits to cmd bytes
						cmd_bytes[0] <= cmd_bits[47:40];
						cmd_bytes[1] <= cmd_bits[39:32];
						cmd_bytes[2] <= cmd_bits[31:24];
						cmd_bytes[3] <= cmd_bits[23:16];
						cmd_bytes[4] <= cmd_bits[15:08];
						cmd_bytes[5] <= cmd_bits[07:00];
						// For a write - populate the cache
						small_counter <= 4'd2;
						dq_oe <= 1'b1;
						// Data Read can be cached...so check if read
						if( read_command ) 
						begin
							// Point to correct cache line entry, or zero if control operation
							cache_line_ptr = A_i[2:0];
							// Check if we need a read cycle or cache is OK
							if( ( cache_addr == {1'b0,A_i[23:3]} ) & cache_valid )
							begin
								//state <= IDLE; 
							end else begin
								cache_addr <= {1'b0,A_i[23:3]};
								cache_ptr <= A_i[2:0];
								csn_o <= 1'b0;
								state <= CSWAIT;
							end
						end else begin
							// Must be a single write command or read/write control
							csn_o <= 1'b0;							
							// Store data in the cache
							write_cache[3'd0] <= D_i;
							// Reset the cache in the event that this is a write
							cache_ptr <= 3'd0;
							cache_pop <= 8'd0;
							write_ptr <= 4'd0;
							
							// Reset the cache_line_ptr for control read
							cache_line_ptr <= 3'd0;
							// Invalidate the cache 
							cache_addr <= {22{1'b1}};	// All 1-s
							
							// Set the state
							state <= CSWAIT;
						end
					end
					// Buffer the address, data and command for later use
					A_b <= A_i;
					D_b <= D_i;
					cmd_b <= cmd_i;
				end
				else begin
					csn_o <= 1'b1;	// By default, set the CS high to disable chip
				end
			end
			// Latency between CS and first command (2 cycles)
			CSWAIT: begin
				// If we're making a memory operation, invalidate the cache
				cache_valid <= 1'b0;
				// Count down from 2 to 0 before moving to next state
				if(small_counter == 4'd0) state <= CMD1;
				else small_counter <= small_counter - 1'b1;
			end
			// Output command bytes
			CMD1: begin
				dq_o <= cmd_bytes[small_counter];
				state <= CMD2;
			end
			CMD2: begin
				// Tick tock while the data is stable - mid transition
				ck_o <= ~ck_o;
				// Six clock edges
				if( small_counter == 4'd5 ) begin
					small_counter <= 4'd0;
					large_counter <= 1'b0;
					// No latency for control write
					if( cmd_ctl & ~cmd_rd ) state <= WR1; 
					// Start latency cycle
					else state <= LATENCY;
				end	// Still issuing command bytes, so go back for the next one
				else begin
					small_counter <= small_counter + 1'b1;
					state <= CMD1;
				end
			end
			// Read cycle - occurs after latency step
			RD1: begin
				if( in_rwds_cycle | rwds_i ) begin
					// Set signal
					in_rwds_cycle <= 1'b1;
					
					// If small_counter-b0 is set, then byte-pair received
					if( small_counter[0] ) cache_valid <= 1'b1;
					
					// Capture bytes either low or high based on low(0),high(1) - little endian for compatibility with PC
					if( small_counter[0] ) read_cache[cache_ptr][7:0] <= dq_i;
					else read_cache[cache_ptr][15:8] <= dq_i;
					
					// Cycle in 16 edges/bytes to the cache, wrapping as needed or 2 cycles for control
					if( small_counter == (cmd_ctl ? 4'd1 : 4'd15) ) state <= IDLE;
					// Count the clock edges
					else begin
						small_counter <= small_counter + 1'b1;
						// Increment cache pointer every other edge, i.e. only after 2 bytes received
						if( small_counter[0] ) cache_ptr <= cache_ptr + 1'b1;
					
						// Next state, toggle clock
						state <= RD2;
					end
				end else state <= RD2;
			end
			RD2: begin
				// Toggle the clock
				ck_o <= ~ck_o;
				// Cycle back for another byte
				state <= RD1;
			end
			// Latency happens before read/write and the timing of each is different
			LATENCY: begin	// Read/Write latency
				// Disable OE for read commands whether data or control
				if( cmd_rd ) dq_oe <= 1'b0;
				
				// Keep the clock pulse width consistent, even though there's only one step to this state 
				if( large_counter[0] ) ck_o <= ~ck_o;
				// Check for 22 or 20 clock edges before read/write starts
				if( large_counter == ((cmd_rd) ? 5'd21 : 5'd19)) state <= (cmd_rd) ? RD1 : WR1;
				else large_counter <= large_counter + 1'b1; // Otherwise, keep waiting
			end
			WR1: begin
				// If control reg write then don't mask data by disabling RWDS OE, otherwise required
				if( ~cmd_ctl ) rwds_oe <= 1'b1;
				// Send the data to the HyperRam BUS, counter goes from 0-15 to stream bytes out, high byte first
				dq_o <= ( small_counter[0] ) ? write_cache[small_counter[3:1]][7:0] : write_cache[small_counter[3:1]][15:8];
				// If we're dumping the cache to HyperRAM, no masking of data is required
				if( cache_command_b ) rwds_o <= 1'b0;
				// Otherwise for single writes, mask either high or low byte
				else rwds_o <= (small_counter[0] == cmd_b[0] ); 
				// Toggle the clock
				state <= WR2;
			end
			WR2: begin
				// Toggle clock
				ck_o <= ~ck_o;
				// If we only did one byte, or the cache population flag shows another byte-pair available
				if( cache_pop[small_counter[3:1]+1] | ~small_counter[0] )
				begin
					small_counter <= small_counter + 1'b1;
					state <= WR1;				
				end else begin
					// Reset the cache (whether used or not)
					cache_pop <= 8'd0;
					write_ptr <= 4'd0;
					state <= IDLE;
				end
			end
			// If we really get into trouble, reinitialize the engine 
			default: state <= INIT1;
		endcase
	end

endmodule


