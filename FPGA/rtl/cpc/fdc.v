/*
 * fdc.v Floppy disk emulator controller
 *
 * This emulates the uPD765 floppy controller used in the CPC
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

module fdc (
	// CPC CPU Interface
	input clk_i,
	input reset_i,
	input enable_i,
	input [7:0] data_i,
	output [7:0] data_o,
	input regsel_i,	// 0 = status, 1 = data
	input rd_i,
	input wr_i,
	output activity_o,
	input motor_i,
	// Support CPU interface
	input sup_clk_i,
	input [3:0] A,
	input [7:0] D_i,
	output [7:0] D_o,
	input sup_rd_i,
	input sup_wr_i,
	input sup_enable_i,
	output sup_int_o	// Interrupt
	);

	// States
	parameter IDLE = 6'd0, PARAM = 6'd1, READ_WRITE = 6'd2, EXEC = 6'd3, PRERESULT = 6'd4, RESULT = 6'd5, REPEAT = 6'd6;

	// Parameter table width
	parameter PT_WIDTH = 18;
	parameter P_WAIT_TO = 22;	// Wait time out - counter size bits 22 = approx 1s at 4MHz
	
	// Wire definitions ===========================================================================
	wire 			p_inval, p_rd, p_wr, p_rpt;
	wire [4:0]	p_cp;
	wire [3:0]	p_cr;
	wire [1:0]	p_rptn;	// Results pattern
	wire [2:0]	p_pptn;	// Parameter pattern
	wire [0:PT_WIDTH-1]	pt;
	wire [7:0] status_main;
	wire 			rd_rise, wr_rise;
	wire 			srd_rise, swr_rise;
	
	// Fifo management
	wire			rdbuf_empty, rdbuf_full;
	wire			wrbuf_empty, wrbuf_full;
	
	// Support status register
	wire [7:0]	support_status, D, s2c_dout, c2s_dout;
	wire 			data_reg = (A == 4'd0);

	// Work out if we're on track 0 for our selected drive
	wire track0;

	// Registers ==================================================================================
	reg [7:0] 	S0 = 0, S1 = 0, S2 = 0, S3 = 0;
	reg [4:0]	opcode;
	reg 			MT, SK;
	reg [5:0] 	state, pr_count;	// Parameter or result counter
	reg [0:PT_WIDTH-1] op_param;
	reg [9:0]	data_cntr = 0;
	reg [P_WAIT_TO-1:0] wait_timeout = 0;
	reg [4:0]	param_ptr;
	reg [1:0]	track_rd = 0, track_wr = 0;
	reg [1:0]	track_srd = 0, track_swr = 0;
	reg [3:0]	drive_active = 0, seek_end = 0;
	
	// Wait handlers
	reg 			support_wait_flag = 0;	// Signal from support CPU to wait
	reg			cpc_wait_flag = 0;		// Signal from CPC to follow support cpu
	wire			should_wait = (support_wait_flag != cpc_wait_flag);
	
	// Delay buffer empty flags
	reg [1:0]	rdbuf_empty_delay = 0;
	// Empty flag is set on falling edge of clock, so sample on rising
	// This suits Z80 CPU read too, which samples data on falling edge
	always @(posedge clk_i)	rdbuf_empty_delay <= {rdbuf_empty_delay[0],rdbuf_empty};
	
	// Control registers
	reg [7:0]	HU = 8'D0, TR = 8'd0, HD = 8'd0, NM = 8'd0, LS = 8'h0, TP = 8'h0, SC = 8'h0, FB = 8'he5, HRESULT = 0, READID = 0;
	reg [7:0]	result_register = 0;
	reg [7:0]	current_track0 = 0, current_track1 = 0, current_track2 = 0, current_track3 = 0;
	
	// Function definitions ===========================================================================
	// Command table attributes
	// INVAL 	= Invalid command code
	// C_P		= Count of parameters
	// RD			= Read command
	// WR			= Write command
	// C_R		= Count of result bytes (not data)
	// RPT		= Repeating instruction
	// PPTN		= Parameter byte sequence
	// RPTN		= Result byte sequence
	function [0:PT_WIDTH-1] param_table (
		input [4:0] cmd
		);
		case( cmd )
			// 	         			INVAL	C_P	RD		WR		C_R	RPT	PPTN	RPTN
			5'h02: param_table = {	1'b0,	5'd8,	1'b1,	1'b0,	4'd7,	1'b1,	3'd0,	2'd0 };	// doesn't really repeat, but used for status code
			5'h03: param_table = {	1'b0,	5'd2,	1'b0,	1'b0, 4'd0, 1'b0,	3'd1,	2'd0 };
			5'h04: param_table = {	1'b0,	5'd1,	1'b0,	1'b0, 4'd1, 1'b0,	3'd2,	2'd1 };
			5'h05: param_table = {	1'b0,	5'd8,	1'b0,	1'b1, 4'd7, 1'b1,	3'd3,	2'd2 };
			5'h06: param_table = {	1'b0,	5'd8,	1'b1,	1'b0, 4'd7, 1'b1,	3'd3,	2'd2 };
			5'h07: param_table = {	1'b0,	5'd1,	1'b0,	1'b0, 4'd0, 1'b0,	3'd2,	2'd0 };
			5'h08: param_table = {	1'b0,	5'd0,	1'b0,	1'b0, 4'd2, 1'b0,	3'd7,	2'd3 };
			5'h09: param_table = {	1'b0,	5'd8,	1'b0,	1'b1, 4'd7, 1'b1,	3'd3,	2'd2 };
			5'h0a: param_table = {	1'b0,	5'd1,	1'b0,	1'b0, 4'd7, 1'b0,	3'd2,	2'd2 };
			5'h0c: param_table = {	1'b0,	5'd8,	1'b1,	1'b0, 4'd7, 1'b1,	3'd3,	2'd2 };
			5'h0d: param_table = {	1'b0,	5'd5,	1'b0,	1'b1, 4'd7, 1'b0,	3'd4,	2'd2 };
			5'h0f: param_table = {	1'b0,	5'd2,	1'b0,	1'b0, 4'd0, 1'b0,	3'd5,	2'd0 };
			5'h11: param_table = {	1'b0,	5'd8,	1'b0,	1'b1, 4'd7, 1'b0,	3'd3,	2'd2 };
			5'h19: param_table = {	1'b0,	5'd8,	1'b0,	1'b1, 4'd7, 1'b0,	3'd3,	2'd2 };
			5'h1d: param_table = {	1'b0,	5'd8,	1'b0,	1'b1, 4'd7, 1'b0,	3'd3,	2'd2 };
			5'h1f: param_table = {	1'b1,	5'd0,	1'b0,	1'b0, 4'd1, 1'b0,	3'd7,	2'd0 };	// Invalid opcode structure
			default: param_table = ((2**PT_WIDTH)-1);	// Invalid
		endcase
	endfunction

	// Parameter pattern table
	function [0:31] param_ptn_table (
		input [2:0] ptn
	);
		case( ptn )
			3'd0	:	param_ptn_table = {4'd2, 4'd4, 4'd3, 4'hf, 4'hf, 4'd12, 4'hf, 4'hf};
			// 1 Not used, will default
			3'd2	:	param_ptn_table = {4'd2, 28'b_1111_1111_1111_1111_1111_1111_1111};
			3'd3	:	param_ptn_table = {4'd2, 4'd4, 4'd3, 4'd5, 4'hf, 4'd6, 4'hf, 4'hf};
			3'd4	:	param_ptn_table = {4'd2, 4'hf, 4'd12, 4'hf, 4'd7, 12'b_1111_1111_1111};
			3'd5	:	param_ptn_table = {4'd2, 4'd13, 24'b_1111_1111_1111_1111_1111_1111};
			// 7 Not used, will default
			default: param_ptn_table = 32'hffffffff;
		endcase
	endfunction
	
	// Results pattern table
	function [0:27] result_ptn_table (
		input [1:0] ptn
		);
		case( ptn )
			2'd0:	result_ptn_table = {4'd8, 4'd9, 4'd10, 4'd04, 4'd03, 4'd12, 4'd00};
			2'd1:	result_ptn_table = {4'd11, 4'd15, 4'd15, 4'd15, 4'd15, 4'd15, 4'd15};
			2'd2:	result_ptn_table = {4'd8, 4'd9, 4'd10, 4'd04, 4'd03, 4'd6, 4'd00};
			2'd3:	result_ptn_table = {4'd8, 4'd13, 4'd15, 4'd15, 4'd15, 4'd15, 4'd15};
		endcase
	endfunction

	// Write a register by reference should match below for clarity, not function
	task write_register(
		input [3:0] register,
		input [7:0] data
	);		
		case( register )
			// 00 is a fake register, fixed to 2
			// 01 if a fake register, dynamically set
			4'd02 : HU <= data;
			4'd03 : HD <= data;
			4'd04 : TR <= data;
			4'd05 : SC <= data;
			4'd06 : LS <= data;
			4'd07 : FB <= data;
			4'd08 : S0 <= data;
			4'd09 : S1 <= data;
			4'd10 : S2 <= data;
			4'd11 : S3 <= data;
			4'd12 : NM <= data;
			4'd13 : TP <= data;
			// 14 is HRESULT but not written using this routine
			// 15 is not used a NOP
		endcase
	endtask

	// Register access matrix should match list above for clarity
	function [7:0] read_register(
		input [3:0] register
		);
		case( register )
			4'd00 : read_register = 2'd2;					// Fake register SZ = 2
			4'd01	: read_register = support_status;
			4'd02 : read_register = HU;
			4'd03 : read_register = HD;
			4'd04 : read_register = TR;
			4'd05 : read_register = SC;
			4'd06 : read_register = LS;
			4'd07 : read_register = FB;
			4'd08 : read_register = S0;
			4'd09 : read_register = S1;
			4'd10 : read_register = S2;
			4'd11 : read_register = S3;
			4'd12 : read_register = NM;
			4'd13 : read_register = TP;
			4'd14 : read_register = HRESULT;
			default: read_register = 8'hff;
		endcase
	endfunction

	// Split param_pattern
	function [3:0] split(
		input [0:31] source,
		input [2:0] item
	);
		case( item )
			3'd0 :	split = source[0:3];
			3'd1 :	split = source[4:7];
			3'd2 :	split = source[8:11];
			3'd3 :	split = source[12:15];
			3'd4 :	split = source[16:19];
			3'd5 :	split = source[20:23];
			3'd6 :	split = source[24:27];
			3'd7 :	split = source[28:31];
		endcase
	endfunction
	
	// Assignments ================================================================================
	
	// Main CPC data output
	assign data_o = !regsel_i ? status_main :
						 (state == EXEC) ? ((rdbuf_empty_delay == 2'b11) ? 8'hff : s2c_dout) : 
						 (state == RESULT) ? result_register :
						 8'hff;	// Default when not in-cycle

	// Activity light indicator
	assign activity_o = (state == READ_WRITE) && should_wait; //enable_i & (rd_i | wr_i) & regsel_i;
	
	// Get operation codes
	assign pt = param_table( data_i[4:0] );
	// Decode operation codes, either with a live wire, or a register, depending upon the state
	assign {p_inval, p_cp, p_rd, p_wr, p_cr, p_rpt, p_pptn, p_rptn} = (state == IDLE) ? pt : op_param;
	
	// Maintain the support interface status register
	assign support_status = {motor_i, should_wait, SK, opcode};
	
	// Maintain the main status flag
	assign status_main = { 
								// Ready flag
								((state == IDLE) || (state == PARAM) || (state == EXEC) || (state == RESULT)),
								// Read/Write Flag
								(state == RESULT) || ((state == EXEC) & p_rd), 
								// In exec state
								(state == EXEC), 
								// Active controller
								(state != IDLE), 
								// Indicate drive activity 3-0
								drive_active};

	// Track RD+WR rise								
	assign rd_rise = (track_rd == 2'b01);
	assign wr_rise = (track_wr == 2'b01);
	assign srd_rise = (track_srd == 2'b01);
	assign swr_rise = (track_swr == 2'b01);
	
	// Support data connection
	assign D_o = (A == 4'd0) ? c2s_dout : read_register(A);
	
	// Work out if we're on track 0
	assign track0 = (HU[1:0] == 2'd0) ? (current_track0 == 8'd0) :
						(HU[1:0] == 2'd1) ? (current_track1 == 8'd0) :
						(HU[1:0] == 2'd2) ? (current_track2 == 8'd0) :
						(HU[1:0] == 2'd3) ? (current_track3 == 8'd0) : 1'b0;
						
	// Module connections =========================================================================
	// FIFO buffers
	// Read fifo
	fifo #(
		.log2_addr(9),	// 512 bytes
		.data_width(8)
	) s2c ( 
		.n_reset_i(~reset_i && (state > IDLE)),		// Reset at idle
		.wclk_i(sup_clk_i),	// Support connection
		.data_i(/*xxx*/D_i),
		.wr_i(swr_rise /*&& (state == READ_WRITE)*/),	// TODO: Does the state matter? Can write anytime when not in IDLE?
		.rclk_i(clk_i),		//CPC Connection
		.data_o(s2c_dout),
		.rd_i(rd_rise && (state == EXEC)),	// Note that data is delayed by 1 clock
		.fifo_empty_o(rdbuf_empty),
		.fifo_full_o(rdbuf_full)
	);
	// Write fifo
	fifo #(
		.log2_addr(9),	// 512 bytes
		.data_width(8)
	) c2s ( 
		.n_reset_i(~reset_i && (state > IDLE)),		// reset at idle
		.wclk_i(clk_i),		// CPC connection
		.data_i(data_i),	
		.wr_i(wr_rise && (state == EXEC)),
		.rclk_i(sup_clk_i),	// Support connection
		.data_o(c2s_dout),
		.rd_i(srd_rise),
		.fifo_empty_o(wrbuf_empty),
		.fifo_full_o(wrbuf_full)
	);
	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================

	// FSM output logic
	always @(posedge clk_i)
	begin
		if( reset_i )
		begin
			state <= IDLE;
			cpc_wait_flag <= 0;			
		end
		else case( state )
			IDLE: // Record the opcode if it's valid
				if ( wr_rise /*& enable_i*/ ) begin
					opcode <= data_i[4:0];	// Store the opcode
					MT <= data_i[7];			// And associated command bits
					SK <= data_i[5];
					op_param <= pt;			// Store the code structure
					param_ptr <= 1'b0;		// Pointer
					// Valid Opcode
					if ( ~p_inval )
					begin
						// Set next state
						if( p_cp > 0 ) 
						begin
							pr_count <= p_cp;		// Store the parameter count
							state <= PARAM;
						end
						else begin					// Only SenseInt has no parameters
							pr_count <= p_cr;		// Store the result count
							state <= READ_WRITE;	// Only sense.int without parameters
						end
						// Set data counter, for if it's needed
						data_cntr <= (p_rd|p_wr) ? 10'd512 : 1'b0;	// What about format?
						// Set wait timeout for if it's needed
						wait_timeout <= ((2**P_WAIT_TO)-1);
					end
					// Invalid Opcode
					else state <= PRERESULT;
				end
			PARAM: // Get the params
				begin
					if( wr_rise & enable_i & regsel_i) begin
						write_register( split( param_ptn_table( p_pptn ), param_ptr ), data_i );
						if( pr_count == 1 )	// i.e. Last parameter
						begin
							if( ~should_wait & ~p_wr ) cpc_wait_flag <= ~cpc_wait_flag;	// Toggle the wait flag if read op
//							wait_timeout <= (2**P_WAIT_TO)-1;
							// If read operation, go to read, otherwise goto exec to get data, idle is fail safe
							state <= p_wr ? EXEC : READ_WRITE;
//							if( p_wr ) data_cntr <= 10'd512;
						end
						else begin
							pr_count <= pr_count - 1'b1;
							param_ptr <= param_ptr + 1'b1;
						end
					end
				end
			READ_WRITE:	
			begin // Wait until the master has processed params or filled the buffer
				if( ( wait_timeout == 0 ) || ~should_wait )
				begin
					if( p_rd ) 
					begin
//						data_cntr <= (p_rd) ? 10'd512 : 1'b0;	// What about format?
						state <= EXEC;
					end
					else // Write operation, so straight to result
					state <= PRERESULT;
				end
				else wait_timeout <= wait_timeout - 1'b1;
			end
			EXEC:	// CPC reads in/out data_cntr bytes
				begin
					if( data_cntr == 0 ) begin
						state <= p_wr ? READ_WRITE : PRERESULT; // Set next status
						if( ~should_wait & p_wr ) cpc_wait_flag <= ~cpc_wait_flag;	// Toggle the wait flag if write op
					end
					else if( rd_rise | wr_rise ) data_cntr <= data_cntr - 1'b1;
				end
			PRERESULT:
			begin // Here we set up all the response codes
			
				// Set the next state
				if( p_cr > 0 )
					state <= RESULT;
				else
					state <= IDLE;
	
				// Result count setup
				pr_count <= (~p_inval) ? p_cr : 1'd1;		// How many results, only S0 for error
				param_ptr <= 1'b0;								// Pointer

				// Set seek/recalib
				if( ( opcode == 5'h0f ) /*seek*/ || ( opcode == 5'h07 ) /* recalib */ )
				begin
					// First set TR - TR and TP must be the same - no special formats!
					TR <= ( opcode[3] ) ? TP : 8'd0;
					seek_end <= 1'b1;
					// Then set track 0 signal
					case( HU[1:0] )
						2'd00: begin
							drive_active[0] <= 1;
							if( opcode[3] ) // If seek
								current_track0 <= TP;
							else
								current_track0 <= 8'd0;
						end
						2'd01: begin
							drive_active[1] <= 1;
							if( opcode[3] ) // If seek
								current_track1 <= TP;
							else
								current_track1 <= 8'd0;
						end
						2'd02: begin
							drive_active[2] <= 1;
							if( opcode[3] ) // If seek
								current_track2 <= TP;
							else
								current_track2 <= 8'd0;
						end
						2'd03: begin
							drive_active[3] <= 1;
							if( opcode[3] ) // If seek
								current_track3 <= TP;
							else
								current_track3 <= 8'd0;
						end
					endcase
				end
				
				// If sense.int, then clear busy flags
				if( opcode == 5'h08 ) drive_active <= 4'd0;
				
				// If read ID, then populate LS with ID
				if( opcode == 5'h0a )
				begin
					LS <= READID;
					TR <= 8'd0;
					HD <= 8'd0;
				end

				// Set status regs ===========================================
				S0 <= {
							// Set error codes for bit 6+7
							p_inval ? 2'b10 :			// Invalid opcode
							HRESULT[0] ? 2'b11 :		// Drive not ready
							p_rpt ? 2'd01 : 			// Aborted/read fail because operation repeat not terminated (normal for a CPC)
							2'd0, 						// All OK
							// Bit 5 - seek end
							(seek_end) ? 1'b1 : ((opcode == 5'h08)||(opcode == 5'h0a)) ? 1'b0 : S0[5], 
							// Bit 4 Equip / recal fail,
							HRESULT[1], 
							// 3 not ready
							HRESULT[0],
							// 2-hd, 1:0 Unit
							HU[2:0]
						};
				// 	End-of-track, ----, Write prot, sector id not found
				S1 <= {(p_rd|p_wr), 4'd0, HRESULT[2], HRESULT[3], HRESULT[2]};
				S2 <= 8'd0;	//{3'd0,HRESULT[2],1'b0,HRESULT[2],HRESULT[2],HRESULT[2]};
				S3 <= {1'b0, HRESULT[3], 1'b1, track0, 1'b0, HU[2:0]};
			end
			RESULT:
			begin
				// Reset seek_end flag - no results stage for seek/recal commands, so OK to reset here
				seek_end <= 0;
				// Read out the results, only progress if RD is active and data reg accessed
				if( rd_rise ) begin	
					result_register <= read_register( split( {result_ptn_table( p_rptn ),4'd0}, param_ptr ) );
					if( pr_count != 0 ) begin
						// Shift result register
						pr_count <= pr_count - 1'b1;
						param_ptr <= param_ptr + 1'b1;
					end
				end
				else
				if( pr_count == 0 ) begin
					state <= IDLE;	// TODO: repeat
				end
			end
			default: state <= IDLE;
		endcase
	end

	// Toggle Support Flag if needed
	always @(posedge sup_clk_i)
	begin
		if( reset_i )
			support_wait_flag <= 0;
		else
		if( (A == 4'd1) && D_i[0] && sup_wr_i && sup_enable_i && should_wait )
			support_wait_flag <= ~support_wait_flag;
	end
	
	// Track the CPC read/write cycle so that we don't accidentally empty the FIFOs
	always @(negedge clk_i)
	begin
		track_rd <= {track_rd[0], enable_i & regsel_i & rd_i};
		track_wr <= {track_wr[0], enable_i & regsel_i & wr_i};
	end

	// Track the RD/WR signal for support connection to FIFO 
	always @(negedge sup_clk_i)
	begin
		track_srd <= {track_srd[0], sup_enable_i & data_reg & sup_rd_i};
		track_swr <= {track_swr[0], sup_enable_i & data_reg & sup_wr_i};
	end

	// Handle Host Status Reg Write
	always @(posedge sup_clk_i)
	begin
		if( (A == 4'd14) && sup_wr_i && sup_enable_i) HRESULT <= D_i;
	end

	// Handle Read ID Write
	always @(posedge sup_clk_i)
	begin
		if( (A == 4'd15) && sup_wr_i && sup_enable_i) READID <= D_i;
	end
endmodule
	
