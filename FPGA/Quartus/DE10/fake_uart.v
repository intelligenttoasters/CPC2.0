/*
 * fake_uart.v
 *
 * Fake a uart with the DE10-Nano
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

module fake_uart ( 
	input clk_i,
	input reset_i,
	input [5:0] addr_i,	// 32-bit addresses, so only 6 bits needed to span 256 bytes of mem
	input write_i,
	input read_i,
	input [31:0] data_i,
	output [31:0] data_o,
	input uart_clk_i,
	output uart_tx_o,
	input uart_rx_i,
	output reset_o			// Used to reset the support CPU
	);

	// Wire definitions ===========================================================================
	
	// Registers ==================================================================================
	reg [5:0] A;
	reg [7:0] D;
	reg rd, wr;
	reg reset = 0;
	
	// Assignments ================================================================================
	assign reset_o = reset;
	
	// Module connections =========================================================================
	usart usart_con(
		// Uart signals
		.uclk_i(uart_clk_i),
		.tx_o(uart_tx_o),
		.rx_i(uart_rx_i),
		// Bus signals
		.n_reset_i(1),
		.busclk_i(clk_i),
		.A_i(A),
		.D_i(D),
		.D_o(data_o),
		.nWR_i(!(wr && (A[5:1] == 5'd0))),
		.nRD_i(!(rd && (A[5:1] == 5'd0))),
		// Interrupt signal
		.interrupt_o(),
		// DMA connection to memory for IPL
		.dma_en_i( ),
		.dma_adr_o( ),
		.dma_dat_o( ),
		.dma_wr_o( )
	);	

	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================
	// Switch logic to other clock edge
	always @(negedge clk_i)
	begin
		A <= addr_i[5:0];
		D <= data_i[7:0];
		wr <= write_i;
		// See the read waveforms for the fake_uart for the logic here (two clock cycles)
		rd <= (rd) ? 1'b0 : read_i;	// If Rd was active last, then deassert it
		
		// reset manager
		if( (addr_i == 6'd2) && write_i ) reset <= data_i[0];
	end
endmodule
	
