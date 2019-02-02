/*
 * sdram.v - SDRAM driver
 *
 * SDRAM driver written from scratch for 128M Alliance Memory (AS4C8M16SA)
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

`ifndef MODEL_TECH
`default_nettype none
`endif

`define SIZE128M
//`define LATENCY2

module sdram (
	// State machine clock
	input			memclk_i,
	input			reset_i,
	output reg	ready_o,
	// Logical Interface (8M words of 16 bits)
	input			enable_i,
	input 			rd_i,
	input 			wr_i,
	input [22:0] 	A_i,
	input [1:0]		Dm_i,
	output wire		D_valid,
	output reg		busy_o,
	// Physical SDRAM Interface
   output reg		Dq_oe,
   output reg [11:0] 	Addr, 
   output reg [1:0] 	Ba, 
   output 	     	Cke, 
   output reg     Cs_n, 
   output reg     Ras_n, 
   output reg     Cas_n, 
   output reg     We_n, 
   output [1 : 0] Dqm
);
	// States
	parameter INIT = 0, XXXXX = 1, IDLE = 2, PRECHARGE_ALL = 3, SET_MODE = 4, AUTO_REFRESH2 = 5,
				AUTO_REFRESH = 6, COUNT_DOWN = 7, FULL_COUNT_DOWN = 8, PRECHARGE_REFRESH = 9,
				CLOSE_ROW = 10, OPEN_ROW = 11, READ = 12, READOUT = 13, WRITE = 14, WRITEIN = 15, 
				WRITE_SETTLE = 16, STARTUP_REFRESH1 = 17, STARTUP_REFRESH2 = 18;
	
	// Wire definitions ===========================================================================
	wire refresh_pending;		// Waiting for opportunity to refresh
	wire [1:0] op_bank;
	wire [11:0] op_row;
	wire [8:0] op_col;
	
	// Registers ==================================================================================
	reg [4:0] state = INIT, next_state = IDLE;
	reg [15:0] counter;			// Used as single counter for start up, or split into 4 for bank cntr
	reg [9:0] refresh_ticker;
	reg refresh_due, refresh_done, D_valid1, D_valid_alt1, D_valid_alt2; 
	reg [11:0] lastrow[0:3];	// Last row accessed
	reg [3:0] bank_open;		// If the lastrow valid for this bank?
	reg [3:0] startup_cycles = 0;
	// Registered request interface
	reg if_rd, if_wr;
	reg [22:0] if_A;
	// Indicates that we're in a read/write process
	reg data_proc_cycle;
	// Valid indicator
	reg dvalid_falling, dvalid_rising;
	
	// Assignments ================================================================================
	assign Cke = 1'b1;			// Always enable clock
	// Refresh pending
	assign refresh_pending = refresh_due ^ refresh_done;	// XOR
	// Convenience/readability assignments
	assign op_bank = if_A[22:21];
	assign op_row = if_A[20:9];
	assign op_col = if_A[8:0];
	// Memory IF Assignments
	assign Dqm = Dm_i;
	
	// Module connections =========================================================================
	
	// Simulation branches and control ============================================================
	`ifdef SIM
		wire [11:0] debug_bankrow0=lastrow[0];	
		wire [11:0] debug_bankrow1=lastrow[1];	
		wire [11:0] debug_bankrow2=lastrow[2];	
		wire [11:0] debug_bankrow3=lastrow[3];	
	`endif
	
	// Other logic ================================================================================

	// Function definitions ===========================================================================
	// Command table attributes (Wait = delay after executing command, A-Banks is a op affecting all)
	function [0:5] param_table (
		input [3:0] cmd
		);
		case( cmd )
			//                     A10         CS    RAS   CAS   WE    R0/C1
			4'd00: param_table = { 1'b1,       1'b0, 1'b1, 1'b1, 1'b1, 1'b0}; // Nop
			4'd01: param_table = { 1'b1,       1'b0, 1'b0, 1'b1, 1'b0, 1'b0}; // Precharge all
			4'd02: param_table = { 1'b0,       1'b0, 1'b0, 1'b0, 1'b0, 1'b0}; // Set mode
			4'd03: param_table = { 1'b0,       1'b0, 1'b0, 1'b0, 1'b1, 1'b0}; // Auto refresh
			4'd04: param_table = { 1'b0,       1'b0, 1'b0, 1'b1, 1'b0, 1'b0}; // Precharge Bank
			4'd05: param_table = { op_row[10], 1'b0, 1'b0, 1'b1, 1'b1, 1'b0}; // Bank Activate
			4'd06: param_table = { 1'b0,       1'b0, 1'b1, 1'b0, 1'b1, 1'b1}; // READ
			4'd07: param_table = { 1'b0,       1'b0, 1'b1, 1'b0, 1'b0, 1'b1}; // WRITE
			default: param_table = -6'd1;	// Invalid
		endcase
	endfunction

	// Set the registered signals for the SDRAM
	task set_signals ( input [0:5] data );
		{Cs_n, Ras_n, Cas_n, We_n, Ba, Addr[11:0]} <= 
			{data[1:4], op_bank, (~data[5]) ? op_row[11] : 1'b0, data[0], (data[5]) ? {1'b0, op_col} : op_row[9:0]};		
		
	endtask	

	// Set timeout for the specific bank
	task set_bank_timeout ( input [1:0] bank, input [3:0] data );
		case(bank)
			2'd0: counter[3:0] <= data;
			2'd1: counter[7:4] <= data;
			2'd2: counter[11:8] <= data;
			2'd3: counter[15:12] <= data;
		endcase
	endtask	
	
	// Timer expired for bank?
	function bank_timeout( input [1:0] bank );
		case(bank)
			2'd0: bank_timeout = (counter[3:0] == 4'd0); 
			2'd1: bank_timeout = (counter[7:4] == 4'd0); 
			2'd2: bank_timeout = (counter[11:8] == 4'd0); 
			2'd3: bank_timeout = (counter[15:12] == 4'd0);
		endcase
	endfunction
	
	// Manage state machine - set next states
	always @(posedge memclk_i or posedge reset_i)
	begin
		if( reset_i ) begin
			refresh_done <= 0;
			lastrow[0] <= 0;
			lastrow[1] <= 0;
			lastrow[2] <= 0;
			lastrow[3] <= 0;
			// No banks open
			bank_open <= 0;
			state <= INIT;
			// Ready flag
			ready_o <= 1'b0;
			// Reset tickers
			refresh_ticker <= 0;
			refresh_due <= 0;
			// Reset registered interface signals
			if_A <= 22'd0;
			if_rd <= 1'b0;
			if_wr <= 1'b0;
			dvalid_rising <= 1'b0;
		end
		else begin
			// FSM Machine
			case( state )
				// Count downs - used by pretty much every command
				COUNT_DOWN: begin
					set_signals(param_table(0));
					// Transition to next state
					if( bank_timeout(op_bank) ) state <= next_state;
					// Updated counters					
					if( ~bank_timeout(2'd0) ) counter[3:0] <= counter[3:0] - 1'b1;
					if( ~bank_timeout(2'd1) ) counter[7:4] <= counter[7:4] - 1'b1;
					if( ~bank_timeout(2'd2) ) counter[11:8] <= counter[11:8] - 1'b1;
					if( ~bank_timeout(2'd3) ) counter[15:12] <= counter[15:12] - 1'b1;
				end
				
				// Full range count down for start up
				FULL_COUNT_DOWN: begin
					set_signals(param_table(0));
					if( counter == 0 )
						state <= next_state;
					else
						counter <= counter - 1'b1;
				end
								
				// Power on initialize
				INIT: begin
					set_signals(param_table(0));
					data_proc_cycle <= 0;
					counter <= -16'd1; 				// Wait for stable clock > 200uS (410uS)
					state <= FULL_COUNT_DOWN;
					next_state <= PRECHARGE_ALL;
				end

				// Precharge all banks
				PRECHARGE_ALL: begin
					set_signals(param_table(1));
					counter <= 16'h1111;	// Countdown all banks
					bank_open <= 0;			// No banks open
					state <= COUNT_DOWN;
					startup_cycles <= 7;	// Startup counter - 8 refreshes
					next_state <= STARTUP_REFRESH1; 
				end
				
				// Initial refresh start up required before mode set in some devices 
				STARTUP_REFRESH1: begin
					set_signals(param_table(3));
					state <= STARTUP_REFRESH2;
				end
				STARTUP_REFRESH2: begin
					set_signals(param_table(0));
					counter <= 16'h7777;
					state <= COUNT_DOWN;
					if( startup_cycles == 0 ) next_state <= SET_MODE;
					else begin
						startup_cycles <= startup_cycles - 1'b1;
						next_state <= STARTUP_REFRESH1;
					end
				end

				// Precharge all banks then refresh
				PRECHARGE_REFRESH: begin
					set_signals(param_table(1));
					// Only process precharge if an operation is not in progress
					if( counter == 0 ) begin
						bank_open <= 0;			// No banks open
						counter <= 16'h1111;	// Countdown all banks
						state <= COUNT_DOWN;
						next_state <= AUTO_REFRESH;
					end
				end

				// Set mode command
				SET_MODE: begin
					set_signals(param_table(2));
					`ifdef LATENCY2
					Addr <= 12'h23;	// 8-word bursts with 2.latency
					`else
					Addr <= 12'h33;	// 8-word bursts with 3.latency
					`endif
					
					counter <= 4'd0;
					state <= COUNT_DOWN;
					next_state <= AUTO_REFRESH2;
					ready_o <= 1'b1;
				end
				
				// Auto Refresh 2 - start up double auto refresh
				AUTO_REFRESH2: begin
					set_signals(param_table(3));
					counter <= 16'h8888;
					state <= COUNT_DOWN;
					next_state <= AUTO_REFRESH;
				end

				// Auto Refresh
				AUTO_REFRESH: begin
					set_signals(param_table(3));
					counter <= 16'h8888;
					state <= COUNT_DOWN;
					next_state <= IDLE;
					// Clear the refresh pending flag
					if( refresh_pending ) refresh_done <= ~refresh_done;
				end
					
				// Set mode command
				IDLE: begin
					// Set the signals
					set_signals(param_table(0));
				
					// Ensure the OE is disabled
					Dq_oe <= 1'b0;

					// Process refresh ticker @ 60MHz
					`ifdef SIZE128M
					// Refresh ticker - cycle at 937 for 64mS cycle - 4096 Rows
					if(refresh_ticker == 10'd937)
					`else
					// Refresh ticker - cycle at 468 for 64mS cycle - 8192 Rows
					if(refresh_ticker == 10'd468)
					`endif
					begin
						refresh_ticker <= 10'd0;
						// Cause refresh to be due
						state <= PRECHARGE_REFRESH;
					end
					else 
					if (enable_i ) begin
					
						// Reset registered interface signals
						if_A <= A_i;
						if_rd <= rd_i;
						if_wr <= wr_i;
					
						// Increment refresh ticker
						refresh_ticker <= (refresh_ticker + 1'b1);

						// Manage OE signal for DQ signals
						if( wr_i ) Dq_oe <= 1'b1;
													
						// Check row in bank, if not same then close
						if( bank_open[op_bank] )
						begin
							// Is bank correct?
							if( lastrow[op_bank] != op_row ) begin
								state <= CLOSE_ROW;
							end
							// Bank open and ready!
							else state <= (rd_i) ? READ : (wr_i) ? WRITE : IDLE; //(Failsafe)
							
						end
						else state <= OPEN_ROW;			// Otherwise open the bank
					end
					// Otherwise stay in idle
					else begin
						// Increment refresh ticker
						refresh_ticker <= (refresh_ticker + 1'b1);

						state <= IDLE;
					end
					// Can't be in retrieval if idle 
					data_proc_cycle <= 0;
				end
				
				// Close row command
				CLOSE_ROW: begin
					set_signals(param_table(4));
					set_bank_timeout(op_bank, 1);
					bank_open[op_bank] <= 0;			// Close this bank
					state <= COUNT_DOWN;
					next_state <= OPEN_ROW;
				end
				
				// Open row command
				OPEN_ROW: begin
					set_signals(param_table(5));
					set_bank_timeout(op_bank, 1);
					state <= COUNT_DOWN;
					next_state <= (if_rd) ? READ : (if_wr) ? WRITE : IDLE; //(Failsafe)				
					bank_open[op_bank] <= 1;			// Indicate bank open
					lastrow[op_bank] <= op_row;			// Store the row for later comparison
				end
				
				// Read command
				READ: begin
					set_signals(param_table(6));
					`ifdef LATENCY2
						set_bank_timeout(op_bank, 0);
					`else	// Latency 3 clocks
						set_bank_timeout(op_bank, 1);
					`endif
					state <= COUNT_DOWN;
					next_state <= READOUT;
				end
				
				// OUT processing
				READOUT: begin
					set_signals(param_table(0));
					data_proc_cycle <= 1'b1;
					set_bank_timeout(op_bank, 6);
					state <= COUNT_DOWN;
					next_state <= IDLE;
				end
				
				// Write command
				WRITE: begin
					set_signals(param_table(7));
					state <= WRITEIN;
					data_proc_cycle <= 1'b1;
				end

				// IN processing (-2)
				WRITEIN: begin
					set_signals(param_table(0));
					set_bank_timeout(op_bank, 5);
					state <= COUNT_DOWN;
					next_state <= WRITE_SETTLE;
				end
				
				WRITE_SETTLE: begin
					set_signals(param_table(0));
					`ifdef LATENCY2
						set_bank_timeout(op_bank, 0);
					`else	// Latency 3 clocks
						set_bank_timeout(op_bank, 1);
					`endif
					data_proc_cycle <= 0;
					state <= COUNT_DOWN;
					next_state <= IDLE;
				end
				
				// If we lose the state, then self-reset
				default: state <= INIT;		
			endcase		
		end
	end

	// Set the busy and valid flags on the falling edge
	always @(negedge memclk_i or posedge reset_i)
	if( reset_i ) begin
		D_valid1 <= 1'b0;
		busy_o <= 1'b0;
	end
	else case( state )
		IDLE, WRITE_SETTLE: begin
			D_valid1 <= 1'b0;
			D_valid_alt1 <= 1'b0;
			busy_o <= 1'b0;
		end
		OPEN_ROW, CLOSE_ROW: busy_o <= 1'b1;
		READ: begin
			busy_o <= 1'b1;
		end
		READOUT: begin
			D_valid_alt1 <= 1'b1;		// Need to delay
		end
		WRITE: begin
			D_valid1 <= 1'b1;
			busy_o <= 1'b1;
		end
		default: ;
	endcase
	
	// Delay read valid signal by half a clock
	always @(posedge memclk_i) D_valid_alt2 <= D_valid_alt1;
	assign D_valid = (D_valid_alt2 | D_valid1);
	
endmodule
