/*
 * cache_byte.v - Byte oriented memory cache
 *
 * This cache sits between the SDRAM controller and the CPU to provide single bytes from the
 * SDRAM data blocks
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
`default_nettype none

module cache_byte (
	// Control
	input wire clock_i,
	input wire reset_i,
	output wire	busy_o,
	// Byte interface - ack now needed as this is exclusive
	input wire	 		benable_i,
	input wire			brd_i,
	input wire			bwr_i,
	output reg	 		bvalid_o,	// Signals bdat_o is valid for a read or write is complete
	input wire [23:0]	badr_i,		// 24 bits/16M byte range
	input wire [7:0]	bdat_i,
	output reg [7:0] 	bdat_o,
	// Word interface - ack used to transfer through an arbiter
	output reg	 		wenable_o,
	input wire			wack_i,
	output reg			wrd_o,
	output reg			wwr_o,
	input wire	 		wvalid_i,	// Is the SDRAM controller outputting a VALID signal (input or output in progress)
	output reg [22:0]	wadr_o,		// 23 bits/8M word range
	output wire	[15:0]	wdat_o,		// Data to SDRAM controller
	input wire [15:0]	wdat_i		// Data from SDRAM controller
	);

	// Parameters =================================================================================

	// Constants ==================================================================================
	parameter IDLE = 0, INIT1 = 1, INIT2 = 2, SEARCH = 3, READ1 = 4, READ2 = 5, READ3 = 6, OUTPUT1 = 7, 
				WRITE1 = 8, XXXXXX = 9, OUTPUT2 = 10, FLUSH1 = 11, FLUSH2 = 12, FLUSH3 = 13; 
		
	// Wire definitions ===========================================================================
	// Convenience wires
	wire 	[12:0] 	calc_tag;		// Tag (address) for current row, used to store in tags list	
	wire	[6:0]	calc_row;		// Cache row (either way)
	wire	[3:0]	calc_index;		// Cache byte index (byte/word location within row)
	wire	[1:0]	way0_flag;		// Direct pointer to row flag
	wire	[1:0]	way1_flag;		// Direct pointer to row flag
	wire	[12:0]	way0_tag;		// Direct pointer to row tag
	wire	[12:0]	way1_tag;		// Direct pointer to row tag
	wire	[7:0]	bdato_wire;		// Wire from cache memory
	wire	[15:0]	wdato_wire;		// Wire from cache memory
	// Simulation wires
	`ifdef SIM
		wire			calc_mru;		// Most recently used for current row
		wire [15:0]		fifo0, fifo1;	// Allows debug/GTKWave on fifo array
	`endif
	
	// Registers ==================================================================================
	reg [12:0] 	way0_tags 	[0:127];	// Way 0 tags (addresses) 14-bits
	reg [12:0] 	way1_tags 	[0:127]; 	// Way 1 tags (addresses) 14-bits
	reg [1:0] 	way0_flags 	[0:127];	// Way 0 Flags
	reg [1:0] 	way1_flags 	[0:127];	// Way 1 Flags
	reg 		mru			[0:127];	// Most recently used flags for victim selection
	reg			hit_way = 0;			// Which way achieved the hit?
	reg			write_ctl = 0;			// Cache write control signal for byte port (A)
	
	reg [3:0] 	state = INIT1;			// State machine state
	
	// Working registers, word port enable, word read, word write, byte port valid, word port write enable
	reg		wenable = 0, wrd = 0, wwr = 0, bvalid = 0, wwe = 0;
	// Word address (note it's 23 bits)
	reg 	[22:0] 	wadr;
	// Byte data output holding register
	reg		[7:0]	bdato;
	// Word (SDRAM) output fifo buffer
	reg		[15:0]	wdat_fifo[0:1];
	// Alternate edge SDRAM data capture (read data is on posedge SDRAM_CLK but NEGEDGE of memory logic clock)
	reg		[15:0]	mem_dat_alt;
	
	// Captured instruction
	reg		[23:0]	badr;			// Byte address is full 24-bit range (16MB)
	reg		[7:0]	bdati;			// Input data from the byte port to be stored 
	reg				brd, bwr;		// Which instruction? Rd/Wr?

	// Read/Write row index pointer, addresses each word in turn on the row
	reg		[2:0]	block_ptr;		// Cycles for read/write store, cycles through words on the row		
	
	// GP counter - used for timeouts, counting bytes/words etc
	reg		[7:0]	general_cntr;
	reg				advance_cntr = 0;	// Flag that signals if the general counter should advance
	
	// Assignments ================================================================================
	// Pre-calculate the tag for later, so we can refer to the tag rather than recalculate it
	assign calc_tag = badr[23:11];
	// Which row of the cache?
	assign calc_row = badr[10:4];
	// Note this cale index is 4 bits, indicating byte port operation
	assign calc_index = badr[3:0];
	// Quick handle to the flags
	assign way0_flag = way0_flags[calc_row];
	assign way1_flag = way1_flags[calc_row];
	// Quick handle to the tags
	assign way0_tag = way0_tags[calc_row];
	assign way1_tag = way1_tags[calc_row];
	// Output to the word interface is out of the bottom of the 3 word FIFO
	assign wdat_o = wdat_fifo[0];
	`ifdef SIM
	assign calc_mru = mru[calc_row];	// For GTKWave debugging
	assign fifo1 = wdat_fifo[1];		// Allows debug/GTKWave on fifo array 
	assign fifo0 = wdat_fifo[0];		// Allows debug/GTKWave on fifo array
	`endif

	// Busy Flag
	assign busy_o = (state != IDLE);
	
	// Module connections =========================================================================
	// This is an altera module to the block ram for the cache data. Port A is the byte port and
	// port B is the word port, so the address lines are one bit bigger on the A port
	cache_d	cache_inst (
			// The byte address is Way, then row, then index, and switch the LSB to give correct byte order
			.address_a ( {hit_way,calc_row,calc_index[3:1],~calc_index[0] } ),		
			// Way is MSB, then Row, then Index
			.address_b ( {hit_way,calc_row,block_ptr} ),
			// Both clocks are the same, but could be independent
			.clock_a ( clock_i ),
			.clock_b ( clock_i ),
			// Port A data comes from the byte port
			.data_a ( bdati ),
			// Port B data comes from the SDRAM port
			.data_b ( mem_dat_alt/*wdat_i TODO: Check */),
			// Port A is write then the byte port requests it
			.wren_a ( write_ctl ),
			// Port B is write when we're in a read mode (write enable signalled) and the SDRAM signals it's outputting data
			.wren_b ( wvalid_i & wwe ),
			// Output ports for A+B
			.q_a ( bdato_wire ),
			.q_b ( wdato_wire )
		);
	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================
	
	// Main finite state machine, positive clock edge logic 
	always @(posedge clock_i)
	if( reset_i ) state <= INIT1;
	else case( state )
		// Clear out key variables. Note the cache data is not cleared
		INIT1: begin
			wenable <= 1'b0; wrd <= 1'b0; wwr <= 1'b0; bvalid <= 1'b0;
			wadr <= 23'd0; bdato <= 8'd0;
			state <= INIT2;
		end
		// Clear out flags array and MRU - if these are clean, then the tags and cache don't need to be 0'd
		INIT2: begin
			way0_flags[general_cntr] <= 2'd0;
			way1_flags[general_cntr] <= 2'd0;
			mru[general_cntr] <= 1'b0;			
			if( ~general_cntr[6:0] == 7'd0 ) state <= IDLE;		// Last byte 7f
		end
		// Wait for a command, note that the byte port is the master port. No requests appear on the word port
		IDLE: begin
			// If we were advancing the counter, then it's no longer necessary here
			advance_cntr <= 1'b0;
			// Disable the write enable flag for the cache memory, to prevent overwriting if another port causes valid_i
			wwe <= 1'b0;
			if( benable_i & (brd_i | bwr_i))
			begin
				// Store instruction parameters for later as the command will cease after one clock cycle
				brd <= brd_i;
				bwr <= bwr_i;
				badr <= badr_i;
				bdati <= bdat_i;
				bvalid <= 1'b0;		// Reset valid from last operation
				// Point to next state
				state <= SEARCH;
			end
		end
		// Try to locate the correct cache row, if it's in the cache
		SEARCH : begin
			// Not empty way and tag hit (address matched) - cache hit!
			if( ( way0_flag != 2'd0 ) && (way0_tag == calc_tag) ) 
			begin
				// Indicate this was WAY0
				hit_way <= 1'b0;
				// Update the most recently used flag				
				mru[calc_row] <= 1'b0;
				$display("Cache HIT! Way 0");		// Debug messages
				// If we're reading from cache, go straight to output
				if( brd ) state <= OUTPUT1; 
				else
				// Otherwise store the data received on the byte port
				if( bwr ) state <= WRITE1;
				// Fail safe - if we somehow get here, then go back to idle
				else state <= IDLE;
			end
			else
			// Not empty way and tag hit (address matched) - cache hit!
			if( ( way1_flag != 2'd0 ) && (way1_tag == calc_tag) ) 
			begin
				// Indicate this was WAY1
				hit_way <= 1'b1;
				// Update the most recently used flag
				mru[calc_row] <= 1'b1;
				$display("Cache HIT! Way 1");		// Debug messages
				// If we're reading from cache, go straight to output
				if( brd ) state <= OUTPUT1;
				else
				// Otherwise store the data received on the byte port
				if( bwr ) state <= WRITE1;
				// Fail safe - if we somehow get here, then go back to idle
				else state <= IDLE;
			end
			// Otherwise it's a cache miss, so select a victim cache way/line
			else begin
				// If way 0 or way 1 is empty, just read/write to that way
				if( way0_flag == 2'd0 ) 
				begin
					hit_way <= 1'b0;
					state <= READ1;
				end
				else
				if ( way1_flag == 2'd0 )
				begin
					hit_way <= 1'b1;
					state <= READ1;
				end
				// Otherwise both ways full, so select a row for replacement 
				else begin 
					// Calculate victim way
					hit_way <= ~mru[calc_row];	// Select the way least recently used (not (~) most recent used)
					$display("At %08d Row replacement for %d, 0x%06x, victim way %d, victim tag: 0x%04x", $time, calc_row, badr, ~mru[calc_row], ~mru[calc_row] ? way1_tags[calc_row] : way0_tags[calc_row]);
					// If way is clean (no writes, so way is consistent with underlying SDRAM) then just discard way data
					if( ( way0_flag == 2'b01 ) && mru[calc_row] ) state <= READ1;
					else
					if( ( way1_flag == 2'b01 ) && ~mru[calc_row] ) state <= READ1;
					// Otherwise, if the way is dirty (has a write added to it since reading from SDRAM), flush it to memory first
					else begin
						$display("At %08d dirty flush for %d, 0x%06x, victim way %d", $time, calc_row, badr, ~mru[calc_row]);
						state = FLUSH1;
					end
				end
			end
		end
		// Reading from memory is a multi-state operation, first set the word (SDRAM) read signals
		// This work in conjunction with the 2-clock R-C delay in the SDRAM
		READ1 : begin
			if( ~wack_i )					// If ACK is high then still ACKing a previous cycle(such as a flush), so wait
			begin
				wenable <= 1'b1;			// Enable the word port
	//			wwe <= 1'b1;				// Write enable the cache data block ram
				wrd <= 1'b1;				// Signal a read from the word port 
				// Discard LSB because we're reading words not bytes, but start from the first address needed, 
				// so we can immediately output the required byte after the first word is read from the SDRAM
				wadr <= badr[23:1];
				state <= READ2;
			end
		end
		// Wait for the arbiter ack signal. If the SDRAM bus is in use, then we have to wait for the operation to complete
		// before we can assert our request. The ACK input from the arbiter gives us that signal
		READ2 : begin
			if( wack_i ) begin
				wwe <= 1'b1;			// Write enable the cache data block ram
				wenable <= 1'b0;		// Deassert the word enable signal
				wrd <= 1'b0;			// and the read signal - the SDRAM controller has recorded the operation already 
				advance_cntr <= 0;		// This signal ensures we don't advance the counter until ready				
				state <= READ3;
			end
		end
		// Wait for the valid signal from the SDRAM controller, indicating data is available on the word input port
		READ3 : if( wvalid_i ) begin
			$display("Read %04x in to cache word memory location %x", mem_dat_alt/*wdat_i*/, block_ptr);
			// Return the first byte immediately, for performance reasons
			if( general_cntr == 3'd7 ) begin
//				bdato <= badr[0] ? wdat_i[7:0] : wdat_i[15:8];	// Return the correct byte from the word
				bdato <= badr[0] ? mem_dat_alt[7:0] : mem_dat_alt[15:8];	// Return the correct byte from the word
				if( brd ) bvalid <= 1'b1;		// Signal to the byte port that the data on the output is valid
			end
			// Update the flags and tag with the read data upon completion
			if( general_cntr == 0 ) begin
				// Update the flags + tag
				if( hit_way == 1'b0 )
				begin
					way0_flags[calc_row] <= 2'b01;
					way0_tags[calc_row] <= calc_tag;
				end
				else 
				begin
					way1_flags[calc_row] <= 2'b01;
					way1_tags[calc_row] <= calc_tag;
				end

				// Mark the way recently used
				mru[calc_row] <= hit_way;
				
				// If read, then we're done
				if( ~bwr ) state <= IDLE;
				// Otherwise go write to the cache ram from the byte port
				else state <= WRITE1;
			end
			// Signal that we start to advance the counter every clock now (on the falling edge, next)
			else advance_cntr <= 1;
		end
		// The data requested from the byte port is in the cache, so simply return that 
		// Give the cache ram 1 cycle to retrieve the data, then output
		OUTPUT1 : state <= OUTPUT2;
		// The cache ram itself is clocked constantly, so it always presents data on its output port, one clock delayed
		OUTPUT2 : begin				
			// This data is transferred to the output ports on the falling edge of the clock, see the negedge block below
			bdato <= bdato_wire[7:0]; 
			bvalid <= 1;
			state <= IDLE;
		end
		// Cache holds the correct memory line, so now just write data into the cache data memory
		WRITE1 : begin
			// Indicate cached write is complete (early indicator)
			bvalid <= 1'b1;				
			// Update the flags with the dirty bit for either way 0 or 1
			if( hit_way == 1'b0 ) way0_flags[calc_row] <= 2'b11;
			else way1_flags[calc_row] <= 2'b11;
			// Finished write to cache data, so return idle
			state <= IDLE;
		end
		// This state flushes a dirty cache (written) back to the SDRAM
		FLUSH1 : begin
			// Stop the valid signal overwriting the cache, by disabling the write enable flag
			wwe <= 1'b0;
			// Enable the word port
			wenable <= 1'b1;
			// Indicate it's a write operation
			wwr <= 1'b1;
			// Output the address to the SDRAM port
			wadr <= {(hit_way) ? way1_tag : way0_tag, calc_row, block_ptr }; // 23 bits of word address
			// Move to the next step
			state <= FLUSH2;
		end
		// This state waits for the SDRAM controller to indicate it's accepted the command
		FLUSH2 : begin
			if( wack_i ) begin
				// Deassert the enable and write signals, but even while we're waiting, 
				// the data is being queued through the FIFO 
				wenable <= 1'b0;
				wwr <= 1'b0;
				advance_cntr <= 1'b0;
				state <= FLUSH3;
			end
		end
		// By now two bytes are queued in the FIFO, we wait for the valid signal before queuing any more
		FLUSH3 : begin
			advance_cntr <= wvalid_i;					// Advance the counter if the SDRAM is ready
			if( general_cntr == 7'd0 ) state <= READ1;	// Flushed finished, go to read process
		end
		// Default operation just in case of a corruption - default is to reinitialise controller
		default: state <= INIT1;		// Self reset on unknown
	endcase

	// Update output signals on falling edge
	always @(negedge clock_i)
	begin
		// Store memory line state for reading
		mem_dat_alt <= wdat_i;
	
		// Take action based on state
		case( state )
			// This state prepares to fill the arrays
			INIT1: general_cntr <= ~8'd0;			
			// This state points to the next array location
			INIT2: general_cntr <= general_cntr + 1'b1;
			// Idle / wait processing
			IDLE: begin
				// Stop the write to the byte cache ram
				write_ctl <= 1'b0;
			end
			// This state prepares to read 8 words
			READ1: begin
				general_cntr <= 3'd7;
				// Move data through the FIFO - just in case the last operation was a flush - takes an extra clock cycle to output
				wdat_fifo[0] <= wdat_fifo[1];			
			end
			// This state prepares the cache line pointer
			READ2: block_ptr <= wadr[2:0];
			// This state will advance the counter if the SDRAM has signalled it's ready
			READ3: begin
				if( advance_cntr ) begin
					// Adjust the address to the next location - this wraps if reading from a the middle of 16 byte block
					block_ptr <= block_ptr + 1'b1;
					general_cntr <= general_cntr - 1'b1;
				end
			end
			// Write signal for the byte cache memory, it's reset automatically on idle
			WRITE1 : write_ctl <= 1'b1;
			// Flush 8 words, 2 is pre-loaded in FLUSH2 state, so counter is 6 rather than 8
			FLUSH1 : begin
				general_cntr <= 3'd6;
				block_ptr <= 0;
			end
			// Fill top of cache, BUT only 2 bytes - if WACK takes a while we dont want to overflow the fifo! 
			FLUSH2 : if(block_ptr != 3'd2) begin
				{wdat_fifo[0],wdat_fifo[1]} <= {wdat_fifo[1], wdato_wire}; 
				block_ptr <= block_ptr + 1'b1;
			end
			// If the advance cntr flag is set, then we can continue to fill the FIFO
			FLUSH3 : if( advance_cntr ) begin
				// fill the fifo from the top
				{wdat_fifo[0],wdat_fifo[1]} <= {wdat_fifo[1], wdato_wire}; 
				// Adjust the address to the next location - this wraps if reading from a the middle of 8 word block
				block_ptr <= block_ptr + 1'b1;
				// Count down from 7 to 0
				general_cntr <= general_cntr - 1'b1;
			end
		endcase
		// Always update these output state signals for the word port
		wenable_o 	<= wenable;
		wrd_o 		<= wrd;
		wwr_o 		<= wwr;
		wadr_o		<= wadr;
		// Always update these output state signals for the byte port
		bvalid_o	<= bvalid;
		bdat_o		<= bdato;
	end
endmodule
	
