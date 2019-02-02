/*
 * usb_ulpi.v Drive the ULPI interface of the Microchip USB3300
 *
 * Drives the USB2 physical interface
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
 * Registers
 * +===+=========================+=========================+
 * | # | Read                    | Write                   |
 * +===+=========================+=========================+
 * | 0 | Get Register Data       | Set Register Data       |
 * | 1 | Get Register ID         | Set Register ID         |
 * | 8 | Read Buffered Data      | Write Buffered Data     |
 * | C | Read RXD CMD            | Set PID for write       |
 * | F | Last operation status   | Module Control          |
 * |   |   B0 - ACK(1) / NAK(0)  |   B0 - Reg Write        |
 * |   |   B1 -                  |   B1 - Reg Read         |
 * |   |   B2 -                  |   B2 -                  |
 * |   |   B3 -                  |   B3 -                  |
 * |   |   B4 - Operation Done   |   B4 - Transmit         |
 * |   |   B5 -                  |   B5 -                  |
 * |   |   B6 -                  |   B6 -                  |
 * |   |   B7 - Data In Buffer   |   B7 - Clear Buffer     |
 * +===+=========================+=========================+
 *
 */
`timescale 1ns/1ns
`default_nettype none

module usb_ulpi (
		// Bus interface
		input wire clk_i,
		input wire reset_i,
		input wire [3:0] A,
		input wire [7:0] D_i,
		output reg [7:0] D_o,
		input wire wr_i,
		input wire rd_i,
		// Phy Interface
		input usb_clkin,
		input usb_dir,
		input usb_nxt,
		output reg usb_stp = 1'b1,
		output reg usb_reset = 1'b0,
		input [7:0] usb_data_i,
		output reg [7:0] usb_data_o = 8'd0,
		output wire usb_data_oe
	);

	parameter STATE_INIT = 4'd0, STATE_IDLE = 4'd1, STATE_WAITDIRL = 4'd2, STATE_SETD = 4'd3, STATE_WAITNXT = 4'd4,
				STATE_WAITDIRH = 4'd5, STATE_WAITREAD = 4'd6, STATE_SETSTP = 4'd7, STATE_RECEIVE = 4'd8;
	
	parameter OP_IDLE = 2'd0, OP_REGREAD = 2'd1, OP_REGWRITE = 2'd2, OP_XVR = 2'd3;
	
	// Wire definitions ===========================================================================
	wire regread_sig, regwrite_sig, transmit_sig;
	wire [7:0] status_register;
	wire [4:0] crc5_out;
	wire [15:0] crc16_out;
	wire crc_en;

	// Registers ==================================================================================

	// Bus Domain Registers
	reg [7:0] bus_reg_data, bus_reg_in;
	reg [5:0] bus_reg_id;
	reg bus_domain_regread = 1'b0;
	reg bus_domain_regwrite = 1'b0;
	reg bus_domain_transmit = 1'b0;
	reg [3:0] bus_pid = 1'b0;
	reg [5:0] tx_buffer_write_ptr = 6'd0;
	reg [1:0] track_crc = 2'd0;
	
	// Synchronisers for cross-domain signals
	reg [3:0] sync_reset = 4'd0;
	reg [2:0] phy_regread = 3'd0;
	reg [2:0] phy_regwrite = 3'd0;
	reg [2:0] phy_transmit = 3'd0;
	reg [2:0] bus_regread = 3'd0;
	reg [2:0] bus_regwrite = 3'd0;
	reg [2:0] bus_transmit = 3'd0;
	reg [2:0] sync_active = 3'd0;
	reg [7:0] rx_buffer[0:63];				// Cross domain data buffer
	reg [7:0] tx_buffer[0:63];				// Cross domain data buffer
	reg [2:0] data_in_buffer = 3'd0;
	
	// USB PHY Domain Registers
	reg [3:0] state = STATE_INIT;
	reg [5:0] state_cntr = 6'd1;
	reg phy_domain_regread = 1'b0;
	reg phy_domain_regwrite = 1'b0;
	reg phy_domain_transmit = 1'b0;
	reg [5:0] phy_reg_id = 6'd0;
	reg [7:0] phy_reg_data = 8'd0;
	reg delayed_oe = 1'b0;
	reg [1:0] phy_operation = 2'd0;
	reg [7:0] rxd_cmd = 8'd0;
	reg [5:0] rx_buffer_write_ptr = 6'd0;
	reg [5:0] tx_buffer_read_ptr = 6'd0;
	reg [3:0] phy_pid = 4'd0;
	
	// Assignments ================================================================================
	assign regread_sig = (bus_domain_regread != phy_domain_regread);
	assign regwrite_sig = (bus_domain_regwrite != phy_domain_regwrite);
	assign transmit_sig = (bus_domain_transmit != phy_domain_transmit);
	assign usb_data_oe = ~(delayed_oe | usb_dir);
	assign status_register = {data_in_buffer[2], 2'd0, ~sync_active[2], 4'd0};
	
	assign crc_en = (track_crc == 2'b01);
	
	// Module connections =========================================================================
	crc5 crc5_instance (D_i,crc_en,crc5_out,reset_i,clk_i);	
	crc16 crc16_instance (D_i,crc_en,crc16_out,reset_i,clk_i);	
	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================

	// Synchronizer chains PHY
	always @(posedge usb_clkin) sync_reset <= {sync_reset[2:0],reset_i};	// Bus Reset to PHY
	always @(posedge usb_clkin) phy_regread <= {phy_regread[1:0],regread_sig};
	always @(posedge usb_clkin) phy_regwrite <= {phy_regwrite[1:0],regwrite_sig};
	always @(posedge usb_clkin) phy_transmit <= {phy_transmit[1:0],transmit_sig};
	
	// Synchronizer chains BUS
	always @(posedge clk_i) bus_regread <= {bus_regread[1:0],regread_sig};
	always @(posedge clk_i) bus_regwrite <= {bus_regwrite[1:0],regwrite_sig};
	always @(posedge clk_i) bus_transmit <= {bus_transmit[1:0],transmit_sig};
	
	always @(posedge clk_i) sync_active <= {sync_active[1:0],(phy_operation[1] | phy_operation[0])};
	always @(posedge clk_i) data_in_buffer <= {data_in_buffer[1:0], rx_buffer_write_ptr != 6'd0 };		// TODO: This isn't sufficient synchronising
	
	// Track signal edges
	always @(posedge clk_i) track_crc <= {track_crc[0],wr_i};
	
	// Bus domain logic ===========================================================================
	always @(posedge clk_i or posedge reset_i)
	begin
		if( reset_i )
		begin
			bus_reg_data <= 8'd0;
			bus_reg_id <= 6'd0;
			bus_reg_in <= 8'd0;
			bus_domain_regread <= 1'b0;
			bus_domain_regwrite <= 1'b0;
			tx_buffer_write_ptr <= 6'b0;
		end
		else case(A)
			4'h0 : begin
				if( rd_i ) D_o <= phy_reg_data;
				else
				if( wr_i ) bus_reg_data <= D_i;
			end
			4'h1 : begin
				if( rd_i ) D_o <= {2'd0, bus_reg_id};
				else
				if( wr_i ) bus_reg_id <= D_i[5:0];
			end
			4'h8 : begin
				if( rd_i ) ;
				else
				if( wr_i ) begin
					tx_buffer[tx_buffer_write_ptr] <= D_i;
					tx_buffer_write_ptr <= tx_buffer_write_ptr + 1'b1;
				end
			end
			4'hc : begin
				// USB domain register rxd_cmd doesn't need synchronizer as status should be checked before reading
				if( rd_i ) D_o <= rxd_cmd;
				else if( wr_i ) bus_pid <= D_i[3:0];
			end
			// Control
			4'hf : begin
				if( rd_i ) D_o <= status_register;
				else
				if( wr_i ) begin
					if( D_i[1] )	// Reg read
					begin
						if( ~bus_regread[2] ) bus_domain_regread <= ~bus_domain_regread;
					end
					else
					if( D_i[0] )	// Reg write
					begin
						if( ~bus_regwrite[2] ) bus_domain_regwrite <= ~bus_domain_regwrite;
					end
					else
					if( D_i[7] )	// Clear buffer
					begin
						tx_buffer_write_ptr <= 6'd0;
					end
					else
					if( D_i[4] )	// Begin transmit
					begin
						if( ~bus_transmit[2] ) bus_domain_transmit <= ~bus_domain_transmit;
					end
				end
			end
			default: D_o <= 8'hff;
		endcase
	end
	
	// USB domain logic ===========================================================================
	// Set the OE
	always @(posedge usb_clkin) delayed_oe <= usb_dir;
	
	// USB State Machine	
	always @(posedge usb_clkin or posedge sync_reset[3])
	begin
		if( sync_reset[3] ) 
		begin
			state <= STATE_INIT;
			state_cntr <= 6'd1;
		end
		else
		begin
			case( state )
				STATE_INIT:
					begin
						usb_reset = 1'b1;
						usb_stp <= 1'b1;
						usb_data_o <= 8'd0;
						if( state_cntr != 6'd0 ) state_cntr <= state_cntr + 1'b1;
						else state <= STATE_IDLE;
					end
				STATE_IDLE:
					begin
						usb_reset <= 1'b0;
						usb_data_o <= 8'd0;
						usb_stp <= 1'b0;
						// Incoming read
						if( usb_dir ) begin
							phy_operation <= OP_XVR;
							rx_buffer_write_ptr <= 6'd0;
							state <= STATE_RECEIVE;
						end else
						// Read register
						if( phy_regread[2] ) begin
							phy_operation <= OP_REGREAD;
							// Capture command params
							phy_reg_id <= bus_reg_id;
							phy_domain_regread <= ~phy_domain_regread;
							if( usb_dir ) state <= STATE_WAITDIRL;
							else state <= STATE_SETD;
						end else	// Write register
						if( phy_regwrite[2] ) begin
							phy_operation <= OP_REGWRITE;
							// Capture command params
							phy_reg_id <= bus_reg_id;
							phy_reg_data <= bus_reg_data;
							phy_domain_regwrite <= ~phy_domain_regwrite;
							if( usb_dir ) state <= STATE_WAITDIRL;
							else state <= STATE_SETD;
						end else	// Transmit
						if( phy_transmit[2] ) begin
							phy_operation <= OP_XVR;
							// Capture command params
							phy_pid <= bus_pid;
							tx_buffer_read_ptr <= 6'd0;
							phy_domain_transmit <= ~phy_domain_transmit;
							if( usb_dir ) state <= STATE_WAITDIRL;
							else state <= STATE_SETD;
						end else phy_operation = OP_IDLE;
					end
				STATE_WAITDIRL:
					begin
						if( ~usb_dir ) state <= STATE_SETD;
					end
				STATE_SETD:
					begin
						case( phy_operation )
							OP_REGREAD:
								usb_data_o <= {2'b11, phy_reg_id};
							OP_REGWRITE:
								usb_data_o <= {2'b10, phy_reg_id};
							OP_XVR:
								usb_data_o <= {4'b0100, phy_pid};
						endcase
						state <= STATE_WAITNXT;
					end
				STATE_WAITNXT:
					begin
						if( usb_nxt ) begin
							usb_data_o <= 8'd0;		// Safety - set to NOP
							case( phy_operation )
								OP_REGREAD: state <= STATE_WAITDIRH;
								OP_REGWRITE: begin
									usb_data_o <= phy_reg_data;
									state <= STATE_SETSTP;
								end
								OP_XVR: begin
									usb_data_o <= tx_buffer[tx_buffer_read_ptr];
									tx_buffer_read_ptr <= tx_buffer_read_ptr + 1'b1;
									// Set STP if everything delivered
									if( tx_buffer_read_ptr + 1'b1 == tx_buffer_write_ptr )	state <= STATE_SETSTP;
								end
								default: state <= STATE_INIT;
							endcase
						end
					end
				STATE_WAITDIRH:
					if( usb_dir ) begin
						state <= STATE_WAITREAD;
					end
				STATE_WAITREAD:
					begin
						phy_reg_data <= usb_data_i;
						state <= STATE_IDLE;
					end
				STATE_SETSTP:
					begin
						usb_data_o <= 8'd0;
						usb_stp <= 1'b1;
						state <= STATE_IDLE;
					end
				STATE_RECEIVE:
					begin
						if( ~usb_dir ) begin		// TODO: Set signals
							state <= STATE_IDLE;
						end else begin
							if( ~usb_nxt ) 
								rxd_cmd <= usb_data_i;
							else begin
								rx_buffer[rx_buffer_write_ptr] <= usb_data_i;
								rx_buffer_write_ptr <= rx_buffer_write_ptr + 1'd1;
							end
						end
					end
				default:
					state <= STATE_INIT;
			endcase
		end
	end

endmodule
	
