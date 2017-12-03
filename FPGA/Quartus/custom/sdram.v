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
`define LATENCY2

module sdram (
	// State machine clock
	input			memclk_i,
	input			reset_i,
	// Logical Interface (8M words of 16 bits)
	input			enable_i,
	input 			rd_i,
	input 			wr_i,
	input [22:0] 	A_i,
	input [15:0] 	D_i,
	input [1:0]		Dm_i,
	output [15:0] 	D_o,
	output reg		D_valid,
	// Physical SDRAM Interface
   input 	  [15:0] 	Dq_in,	// From Ram
   output     [15:0]	Dq_out,	// To Ram
   output				Dq_oe,
   output reg [11:0] 	Addr, 
   output reg [1:0] 	Ba, 
   output      			Clk, 
   output 	     		Cke, 
   output reg     		Cs_n, 
   output reg     		Ras_n, 
   output reg     		Cas_n, 
   output reg     		We_n, 
   output [1 : 0] 		Dqm
);
	// States
	parameter INIT = 0, XXXXX = 1, IDLE = 2, PRECHARGE_ALL = 3, SET_MODE = 4, AUTO_REFRESH2 = 5,
				AUTO_REFRESH = 6, COUNT_DOWN = 7, FULL_COUNT_DOWN = 8, PRECHARGE_REFRESH = 9,
				CLOSE_ROW = 10, OPEN_ROW = 11, READ = 12, READOUT = 13, WRITE = 14, WRITEIN = 15, 
				WRITE_SETTLE = 16, STARTUP_REFRESH1 = 17, STARTUP_REFRESH2 = 18;
	
	// Wire definitions ===========================================================================
	wire [3:0] wait_timeout;	// Waiting for a bank timeout
	wire refresh_pending;		// Waiting for opportunity to refresh
	wire op_pending;			// Interface operation pending
	wire [1:0] op_bank;
	wire [11:0] op_row;
	wire [8:0] op_col;
	
	// Registers ==================================================================================
	reg [4:0] state = INIT, next_state = IDLE;
	reg [15:0] counter;			// Used as single counter for start up, or split into 4 for bank cntr
	reg [11:0] refresh_ticker;
	reg refresh_due, refresh_done; 
	reg [11:0] lastrow[0:3];	// Last row accessed
	reg [3:0] bank_open;		// If the lastrow valid for this bank?
	reg [3:0] startup_cycles = 0;
	// Registered request interface
	reg if_rd, if_wr;
	reg [22:0] if_A;
	// Alternate edge request
	reg if_rd_alt, if_wr_alt, op_pending_alt;
	reg [22:0] if_A_alt;
	// Operation pending
	reg op_due, op_done;
	// Indicates that we're in a read/write process
	reg data_proc_cycle;
	// Indicates that the state machine is busy with something OTHER than refresh and should ignore requests
	reg fsm_busy;
	
	// Assignments ================================================================================
	assign Clk = memclk_i;
	assign Cke = 1'b1;			// Always enable clock
	// Timeout signals
	assign wait_timeout[0] = (counter[3:0] == 0);		// Set if a timer is ticking for bank 0 
	assign wait_timeout[1] = (counter[7:4] == 0);		// Set if a timer is ticking for bank 1 
	assign wait_timeout[2] = (counter[11:8] == 0); 		// Set if a timer is ticking for bank 2
	assign wait_timeout[3] = (counter[15:12] == 0); 	// Set if a timer is ticking for bank 3
	assign refresh_pending = refresh_due ^ refresh_done;	// XOR
	assign op_pending = op_due ^ op_done;				// XOR
	// Convenience/readability assignments
	assign op_bank = if_A_alt[22:21];
	assign op_row = if_A_alt[20:9];
	assign op_col = if_A_alt[8:0];
	// Memory IF Assignments
	assign D_o = Dq_in;
	assign Dq_out = D_i;
	assign Dq_oe = (D_valid & if_wr_alt);	// Output enable for DQ
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
			4'd00: param_table = { 1'b1,       1'b1, 1'b1, 1'b1, 1'b1, 1'b0}; // Nop
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
			default: bank_timeout = 0;
		endcase
	endfunction
	
	// Track the memory request interface signals, rising edge
	always @(posedge memclk_i)
	if( reset_i ) begin
		op_due <= 0;
		if_rd <= 0;
		if_wr <= 0;
		if_A <= 0;
	end
	else
	if( enable_i && ~fsm_busy ) begin	// Ignore any requests during processing
		if_rd <= rd_i;
		if_wr <= wr_i;
		if_A <= A_i;
		if( ~op_pending ) op_due <= ~op_due;
	end
	// Capture on alt-edge
	always @(negedge memclk_i)
	begin
		if_rd_alt <= if_rd;
		if_wr_alt <= if_wr;
		if_A_alt <= if_A;
		op_pending_alt <= op_pending;
	end
	
	// Manage state machine - set next states
	always @(posedge memclk_i)
	begin
		if( reset_i ) begin
			refresh_done <= 0;
			op_done <= 0;
			lastrow[0] <= 0;
			lastrow[1] <= 0;
			lastrow[2] <= 0;
			lastrow[3] <= 0;
			// No banks open
			bank_open <= 0;
			state <= INIT;
			// Not busy
			fsm_busy <= 0;
		end
		else begin
			// FSM Machine
			case( state )
				// Count downs - used by pretty much every command
				COUNT_DOWN: begin
					// Transition to next state
					if( bank_timeout(op_bank) ) state <= next_state;
					// Updated counters
					if( ~wait_timeout[0] ) counter[3:0] <= counter[3:0] - 1'b1;
					if( ~wait_timeout[1] ) counter[7:4] <= counter[7:4] - 1'b1;
					if( ~wait_timeout[2] ) counter[11:8] <= counter[11:8] - 1'b1;
					if( ~wait_timeout[3] ) counter[15:12] <= counter[15:12] - 1'b1;
				end
				
				// Full range count down for start up
				FULL_COUNT_DOWN: begin
					if( counter == 0 )
						state <= next_state;
					else
						counter <= counter - 1'b1;
				end
								
				// Power on initialize
				INIT: begin
					data_proc_cycle <= 0;
					counter <= -16'd1; 				// Wait for stable clock > 200uS (410uS)
					state <= FULL_COUNT_DOWN;
					next_state <= PRECHARGE_ALL;
				end

				// Precharge all banks
				PRECHARGE_ALL: begin
					counter <= 16'h1111;	// Countdown all banks
					bank_open <= 0;			// No banks open
					state <= COUNT_DOWN;
					startup_cycles <= 7;	// Startup counter - 8 refreshes
					next_state <= STARTUP_REFRESH1; 
				end
				
				// Initial refresh start up required before mode set in some devices 
				STARTUP_REFRESH1: begin
					state <= STARTUP_REFRESH2;
				end
				STARTUP_REFRESH2: begin
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
					counter <= 4'd0;
					state <= COUNT_DOWN;
					next_state <= AUTO_REFRESH2;
				end
				
				// Auto Refresh 2 - start up double auto refresh
				AUTO_REFRESH2: begin
					counter <= 16'h8888;
					state <= COUNT_DOWN;
					next_state <= AUTO_REFRESH;
				end

				
				// Auto Refresh
				AUTO_REFRESH: begin
					counter <= 16'h8888;
					state <= COUNT_DOWN;
					next_state <= IDLE;
					// Clear the refresh pending flag
					if( refresh_pending ) refresh_done <= ~refresh_done;
				end
					
				// Set mode command
				IDLE: begin
					if( refresh_pending ) begin
						state <= PRECHARGE_REFRESH;
						fsm_busy <= 0;
					end
					else if( op_pending_alt ) begin
						// Reset the pending flag, always half a cycle behind _alt, so will be set
						if( op_pending ) op_done <= ~op_done;
						
						// Doing something, so set busy flag
						fsm_busy <= 1'b1;
						
						// Check row in bank, if not same then close
						if( bank_open[op_bank] )
						begin
							// Is bank correct?
							if( lastrow[op_bank] != op_row ) begin
								state <= CLOSE_ROW;
							end
							// Bank open and ready!
							else state <= (if_rd_alt) ? READ : (if_wr_alt) ? WRITE : IDLE; //(Failsafe)
						end
						else state <= OPEN_ROW;			// Otherwise open the bank
					end
					// Otherwise stay in idle
					else begin
						state <= IDLE;
						// Not busy
						fsm_busy <= 0;
					end
					// Can't be in retrieval if idle 
					data_proc_cycle <= 0;
				end
				
				// Close row command
				CLOSE_ROW: begin
					set_bank_timeout(op_bank, 1);
					bank_open[op_bank] <= 0;			// Close this bank
					state <= COUNT_DOWN;
					next_state <= OPEN_ROW;
				end
				
				// Open row command
				OPEN_ROW: begin
					set_bank_timeout(op_bank, 1);
					state <= COUNT_DOWN;
					next_state <= (if_rd_alt) ? READ : (if_wr_alt) ? WRITE : IDLE; //(Failsafe)
					bank_open[op_bank] <= 1;			// Indicate bank open
					lastrow[op_bank] <= op_row;			// Store the row for later comparison
				end
				
				// Read command
				READ: begin
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
					data_proc_cycle <= 1'b1;
					set_bank_timeout(op_bank, 6);
					state <= COUNT_DOWN;
					next_state <= IDLE;
				end
				
				// Write command
				WRITE: begin
					state <= WRITEIN;
					data_proc_cycle <= 1'b1;
				end

				// IN processing (-2)
				WRITEIN: begin
					set_bank_timeout(op_bank, 5);
					state <= COUNT_DOWN;
					next_state <= WRITE_SETTLE;
				end
				
				WRITE_SETTLE: begin
					`ifdef LATENCY2
						set_bank_timeout(op_bank, 0);
					`else	// Latency 3 clocks
						set_bank_timeout(op_bank, 1);
					`endif
					data_proc_cycle <= 0;
					state <= COUNT_DOWN;
					next_state <= IDLE;
					fsm_busy <= 0;
				end
				
				// If we lose the state, then self-reset
				default: state <= INIT;		
			endcase		
		end
	end
	
	// Update signals (memory reads in on rising edge)
	always @(negedge memclk_i)
	begin
		if( reset_i ) begin
			refresh_ticker <= 0;
			refresh_due <= 0;
		end
		else begin
			`ifdef SIZE128M
			// Refresh ticker - cycle at 2432, 62.2848ms full cycle (15.20625uS repeats) 4096 Rows
			if(refresh_ticker[11:7] == 5'b10011)
			`else
			// Refresh ticker - cycle at 768, 62.91456ms full cycle (8192 Rows)
			if(refresh_ticker[9:8] == 2'b11)
			`endif
			begin
				refresh_ticker <= 12'd0;
				// Cause refresh to be due
				if( ~refresh_pending ) refresh_due <= ~refresh_due;
			end
			else refresh_ticker <= (refresh_ticker + 1'b1);

			// Set the valid indicator
			D_valid <= (data_proc_cycle || (state == READOUT) || (state == WRITE)) && (state != IDLE) && (state != WRITE_SETTLE);
			
			// Set the output state
			case( state )
				IDLE: 				set_signals(param_table(0));
				INIT: 				set_signals(param_table(0));
				COUNT_DOWN:			set_signals(param_table(0));
				FULL_COUNT_DOWN:	set_signals(param_table(0));
				STARTUP_REFRESH2:	set_signals(param_table(0));
				PRECHARGE_ALL: 		set_signals(param_table(1));
				PRECHARGE_REFRESH:	set_signals(param_table(1));
				AUTO_REFRESH2:		set_signals(param_table(3));
				AUTO_REFRESH:		set_signals(param_table(3));
				STARTUP_REFRESH1:	set_signals(param_table(3));
				CLOSE_ROW:			set_signals(param_table(4));
				OPEN_ROW:			set_signals(param_table(5));
				READ:				set_signals(param_table(6));
				READOUT:			set_signals(param_table(0));
				WRITE:				set_signals(param_table(7));
				WRITEIN:			set_signals(param_table(0));
				WRITE_SETTLE:		set_signals(param_table(0));
				SET_MODE: begin
					set_signals(param_table(2));
					Addr <= 12'h23;	// 8-word bursts with 2.latency
				end
				default:			set_signals(param_table(0));	// NOP
			endcase
		end
	end

endmodule
