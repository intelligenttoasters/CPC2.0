/*
 * sram_ctl - Push and pull data to/from the SRAM 
 *
 * This allows the supervisor to put data in the SRAM memory and read it out again.
 * Note that this operation halts the CPC clock and so affects CPC timing
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
 * 	0000 (0x0) Data In/Out
 *		1000 (0x8) Set address low byte (0-7)
 *		1001 (0x9) Set address middle byte (8-15)
 *		1010 (0xa) Set address high byte (16-23)
 *		1111 (0xF) Control signals
 *						b7 - Assert supervisor bus control (halts CPC clock)
 *						b6 - Use control signals, not memory addresses
 */
`timescale 1ns/1ns
`default_nettype none

module sram_ctl ( 
	// Control signals
	input wire 			clk_i,
	input wire			reset_i,
	// Support Bus signals
	input wire [3:0]	A_i,
	input wire [7:0]	D_i,
	output wire [7:0]	D_o,
	input wire 			rd_i,
	input wire 			wr_i,
	output reg			wait_o,
	// Memory arbiter signals
	output reg			cpc_pause_o,
	input					cpc_pause_ack_i,
	// CPC Signals/RAMROM signals
	input wire [23:0]	cpc_A_i,
	input wire [7:0]	cpc_D_i,
	output wire [7:0]	cpc_D_o,
	input wire	 		cpc_en_i,
	input wire	 		cpc_rd_i,
	input wire	 		cpc_wr_i,
	output wire [63:0] cpc_romflags_o,
	// Memory signals
	output wire [23:0]	mem_A_o,
	input wire [15:0]		mem_D_i,
	output wire [15:0]	mem_D_o,
	output wire	 			mem_go_o,
	output wire	[2:0]		mem_cmd_o,
	input wire				mem_busy_i,
	input wire				mem_valid_i
	);

	// Wire definitions ===========================================================================
	wire rd_rise, wr_rise, crd_rise, cwr_rise, busy_rise;
	wire [7:0] support_data_snip;
	
	// Registers ==================================================================================
	reg [7:0]		A[0:3], DOUT = 8'd0;
	reg [1:0]		track_rd = 2'd0, track_wr = 2'd0, track_crd = 2'd0, track_cwr = 2'd0;
	reg 				control_ops = 1'd0;
	reg 				old_lsb = 1'b0, incr_address = 1'b0;
	reg [63:0]		romflags = 64'd0;
	
	// Assignments ================================================================================
	assign mem_A_o = (cpc_pause_o & cpc_pause_ack_i) ? {1'b0, A[2], A[1], A[0][7:1]} : {1'b0,cpc_A_i[23:1]};		// A multiplexor
	assign mem_D_o = (cpc_pause_o & cpc_pause_ack_i) ? {D_i,D_i} : {cpc_D_i,cpc_D_i};	// D multiplexor
	assign mem_go_o = (cpc_pause_o & cpc_pause_ack_i) ? 											// en multiplexor
									((rd_rise | wr_rise) & (A_i==4'd0)) : 
									((crd_rise | cwr_rise) & cpc_en_i);
	assign mem_cmd_o = (cpc_pause_o & cpc_pause_ack_i) ? {control_ops, rd_i, control_ops ? 1'b1 : A[0][0]} : {1'b0, cpc_rd_i, cpc_A_i[0]};
	
	// CPC Output
	assign cpc_D_o = cpc_A_i[0] ? mem_D_i[15:8] : mem_D_i[7:0];

	// Snip the correct byte from the word returned from memory
	assign support_data_snip = (old_lsb ? mem_D_i[15:8] : mem_D_i[7:0]);
	// Switch between internal code and memory data	
	assign D_o = (A_i == 4'd0) ? support_data_snip : DOUT;

	// Output the ROMFLAGS
	assign cpc_romflags_o = romflags;
	
	// Track rise
	assign rd_rise = (track_rd == 2'b01);
	assign wr_rise = (track_wr == 2'b01);
	assign crd_rise = (track_crd == 2'b01);
	assign cwr_rise = (track_cwr == 2'b01);
	
	// Wait signal when processing a txn, and data not yet valid
	//assign wait_o = incr_address & ~mem_valid_i;
	
	// Module connections =========================================================================
			
	// Simulation branches and control ============================================================
	
	// Core logic ================================================================================
	
	// Track rises
	always @(posedge clk_i) track_rd <= {track_rd[0],rd_i};
	always @(posedge clk_i) track_wr <= {track_wr[0],wr_i};
	always @(posedge clk_i) track_crd <= {track_rd[0],cpc_rd_i};
	always @(posedge clk_i) track_cwr <= {track_wr[0],cpc_wr_i};
	
	// Handle the IO bus signals
	always @(posedge clk_i or posedge reset_i)
	if( reset_i ) begin
		{A[3],A[2],A[1],A[0]} <= 32'd0;
		DOUT <= 8'd0;
		cpc_pause_o <= 1'b0;
		incr_address <= 1'b0;
		romflags <= 64'd0;
	end else begin
		// When controller accepted address, then increment address
		if( (mem_valid_i | mem_busy_i) & incr_address ) begin	
			old_lsb <= A[0][0];
			{A[3],A[2],A[1],A[0]} <= {A[3],A[2],A[1],A[0]} + 1'b1;
			incr_address <= 1'b0;
		end
		else
		case( A_i )
			4'b0000 : begin
				// Trigger an update to the address is requested
				if( rd_rise | wr_rise ) incr_address <= 1'b1;
			end
			// Read/write the starting address
			4'b1000, 4'b1001, 4'b1010, 4'b1011 : begin
				if( rd_i ) DOUT <= A[A_i[1:0]];
				else
				if( wr_i ) A[A_i[1:0]] <= D_i;
			end
			// Not really an SRAM function, but manages the rom flags
			4'b1100 : begin	
				if( wr_i ) case( D_i[7:6] )
					2'b01 : romflags[D_i[5:0]] <= 1'b0;		// Clear
					2'b10 : romflags[D_i[5:0]] <= 1'b1;		// Set
					2'b11 : romflags <= 64'd0;					// Flush ROMS
				endcase
			end
			// Control signals
			4'b1111 : begin
				if( wr_i ) begin
					cpc_pause_o <= D_i[7];
					control_ops <= D_i[6];
				end
				else
				if( rd_i ) DOUT <= {cpc_pause_ack_i,control_ops,6'd0};
			end
			default: ;
		endcase
	end
	
	// Manage WAIT signal
	always @(posedge clk_i or posedge reset_i)
	if( reset_i ) wait_o <= 1'b0;
	else begin
		if( ( A_i == 4'd0 ) && (rd_rise/*|wr_rise*/) ) wait_o <= 1'b1;
		else if( mem_valid_i | ~mem_busy_i ) wait_o <= 1'b0;
	end
		
endmodule
	
