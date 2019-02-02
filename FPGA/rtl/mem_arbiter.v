/*
 * mem_arbiter.v - switches between each memory conduit 
 *
 * This module decides on which request is satisfied next, based on
 * order of priority and an 8 clock cycle. 
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

module mem_arbiter (
	// Control
	input			clock_i,
	input			reset_i,
	// Output port
	output reg [22:0]	adr_o,
	output [15:0]	dat_o,
	output [1:0]	dm_o,
	output reg		rd_o,
	output reg		wr_o,
	output reg		enable_o,
	input				busy_i,
	input			valid_i,
	// Port 1
	input 		 	req1_i,
	output reg	 	ack1_o,
	input [22:0]	adr1_i,
	input [15:0]	dat1_i,
	input [1:0]		dm1_i,
	input			rd1_i,
	input			wr1_i,
	// Port 2
	input 		 	req2_i,
	output reg	 	ack2_o,
	input [22:0]	adr2_i,
	input [15:0]	dat2_i,
	input [1:0]		dm2_i,
	input			rd2_i,
	input			wr2_i,
	// Port 3
	input 		 	req3_i,
	output reg	 	ack3_o,
	input [22:0]	adr3_i,
	input [15:0]	dat3_i,
	input [1:0]		dm3_i,
	input			rd3_i,
	input			wr3_i,
	// Port 4
	input 		 	req4_i,
	output reg	 	ack4_o,
	input [22:0]	adr4_i,
	input [15:0]	dat4_i,
	input [1:0]		dm4_i,
	input			rd4_i,
	input			wr4_i
	);

	// Parameters / constants
	parameter IDLE = 0, ACTIVE = 1, INCYCLE = 2; 
		
	// Wire definitions ===========================================================================

	// Registers ==================================================================================
	reg [2:0] 	state = IDLE, last_state = IDLE;
	reg [2:0]	cntr = 0;
	reg rd = 0, wr = 0;
	reg ack1 = 0, ack2 = 0, ack3 = 0, ack4 = 0;
	
	// Assignments ================================================================================
	assign dat_o = (ack1_o) ? dat1_i : (ack2_o) ? dat2_i : (ack3_o) ? dat3_i : (ack4_o) ? dat4_i : 16'd0; 
	assign dm_o = (ack1_o) ? dm1_i : (ack2_o) ? dm2_i : (ack3_o) ? dm3_i : (ack4_o) ? dm4_i : 2'd0; 
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================
	always @(posedge clock_i)
	if( reset_i ) state <= IDLE;
	else case( state )
		// Cant process if still waiting for old cycle to finish
		IDLE : if( ~valid_i ) begin
			if( req1_i & (rd1_i | wr1_i) ) begin
				state <= ACTIVE;
				ack1 <= 1'b1;
				adr_o <= adr1_i;
				// Sanitise read/write signals - can't be both!
				if( rd1_i ) begin
					rd <= 1'b1;
					wr <= 1'b0;
				end
				else begin
					rd <= 1'b0;
					if( wr1_i ) wr <= 1'b1;
					else wr <= 1'b0;
				end
			end
			else
			if( req2_i & (rd2_i | wr2_i) ) begin
				state <= ACTIVE;
				adr_o <= adr2_i;
				ack2 <= 1'b1;
				// Sanitise read/write signals - can't be both!
				if( rd2_i ) begin
					rd <= 1'b1;
					wr <= 1'b0;
				end
				else begin
					rd <= 1'b0;
					if( wr2_i ) wr <= 1'b1;
					else wr <= 1'b0;
				end
			end
			else
			if( req3_i & (rd3_i | wr3_i) ) begin
				state <= ACTIVE;
				adr_o <= adr3_i;
				ack3 <= 1'b1;
				// Sanitise read/write signals - can't be both!
				if( rd3_i ) begin
					rd <= 1'b1;
					wr <= 1'b0;
				end
				else begin
					rd <= 1'b0;
					if( wr3_i ) wr <= 1'b1;
					else wr <= 1'b0;
				end
			end
			else
			if( req4_i & (rd4_i | wr4_i) ) begin
				state <= ACTIVE;
				adr_o <= adr4_i;
				ack4 <= 1'b1;
				// Sanitise read/write signals - can't be both!
				if( rd4_i ) begin
					rd <= 1'b1;
					wr <= 1'b0;
				end
				else begin
					rd <= 1'b0;
					if( wr4_i ) wr <= 1'b1;
					else wr <= 1'b0;
				end
			end 
		end
		ACTIVE : if( valid_i ) begin
 			state <= INCYCLE;
 			cntr <= 3'd7;	// Ensures all 8 words are visible for the duration of the tSU+tH
		end
		INCYCLE : begin
			ack1 <= 0;
			ack2 <= 0;
			ack3 <= 0;
			ack4 <= 0;			
			if( cntr == 0 ) state <= IDLE;
			else cntr <= cntr - 1'b1;
		end
		default: state <= IDLE; 
	endcase
	
	reg pending_acknowledgement = 0;
	
	// Change RAM signals
	always @(negedge clock_i)
	begin
		case( state )
			IDLE: begin
				ack1_o <= 0;
				ack2_o <= 0;
				ack3_o <= 0;
				ack4_o <= 0;
				rd_o <= 0;
				wr_o <= 0;
				enable_o <= 0;
				last_state <= IDLE;
				pending_acknowledgement <= 1'b1;
			end
			ACTIVE: begin	// It remains in this state until the valid_i signal goes active indicating an active in/out
				if( pending_acknowledgement ) begin
					ack1_o <= ack1;
					ack2_o <= ack2;
					ack3_o <= ack3;
					ack4_o <= ack4;
					rd_o <= rd;
					wr_o <= wr;
					enable_o <= 1;
					// If the SDRAM controller accepted our command, then reset the control lines
					if( busy_i ) pending_acknowledgement <= 1'b0;
				end
				else
				begin
					enable_o <= 0;
					rd_o <= 0;
					wr_o <= 0;
				end
			end
			INCYCLE : begin
				enable_o <= 0;
				rd_o <= 0;
				wr_o <= 0;
			end
		endcase
	end
endmodule
	
