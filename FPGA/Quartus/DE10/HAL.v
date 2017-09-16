/*
 * HAL - Harware abstraction layer
 *
 * Runs on the DE10 to provide a shim between the DE10 and the custom hardware interface
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

module HAL(

	//////////// CLOCK //////////
	input 		          		FPGA_CLK1_50,
	input 		          		FPGA_CLK2_50,
	input 		          		FPGA_CLK3_50,

	//////////// HDMI //////////
	inout 		          		HDMI_I2C_SCL,
	inout 		          		HDMI_I2C_SDA,
	inout 		          		HDMI_I2S,
	inout 		          		HDMI_LRCLK,
	inout 		          		HDMI_MCLK,
	inout 		          		HDMI_SCLK,
	output		          		HDMI_TX_CLK,
	output		          		HDMI_TX_DE,
	output		    [23:0]		HDMI_TX_D,
	output		          		HDMI_TX_HS,
	input 		          		HDMI_TX_INT,
	output		          		HDMI_TX_VS,

	// SDRAM
    output   [14: 0]    HPS_DDR3_ADDR,
    output   [ 2: 0]    HPS_DDR3_BA,
    output              HPS_DDR3_CAS_N,
    output              HPS_DDR3_CK_N,
    output              HPS_DDR3_CK_P,
    output              HPS_DDR3_CKE,
    output              HPS_DDR3_CS_N,
    output   [ 3: 0]    HPS_DDR3_DM,
    inout    [31: 0]    HPS_DDR3_DQ,
    inout    [ 3: 0]    HPS_DDR3_DQS_N,
    inout    [ 3: 0]    HPS_DDR3_DQS_P,
    output              HPS_DDR3_ODT,
    output              HPS_DDR3_RAS_N,
    output              HPS_DDR3_RESET_N,
    input               HPS_DDR3_RZQ,
    output              HPS_DDR3_WE_N,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [7:0]		LED,

	//////////// SW //////////
	input 		     [3:0]		SW
);

	// Wire definitions ===========================================================================
	wire oneled;
	wire [7:0] LEDS;
	wire [7:0] R,G,B;
	wire [79:0] keyboard;
	wire uart_rx, uart_tx, uart_reset;
	// Registers ==================================================================================
	
	// Assignments ================================================================================

	assign LED = {7'd0,oneled};
	assign HDMI_TX_D = {R,G,B};
	
	// Module connections =========================================================================
CPC2 cpc(
		.CLK_50(FPGA_CLK1_50),
		// SPI Ports
		.SPI_MOSI(), 
		.SPI_MISO(), 
		.SPI_SCK(), 
		.SPI_CS(),
		.DATA7(),				// SPI client ready
		.DATA6(),				// SPI master ready
		// Hard coded de-assert data lines, a high on this line prevents data 6+7 from being asserted
		// Avoids potential conflicts on the lines during power up switch over from FPGA FPP
		.DATA5(uart_reset),
		.I2C_SCL(HDMI_I2C_SCL),
		.I2C_SDA(HDMI_I2C_SDA),
		// Disk/activity LED
		.LED(oneled),
		// Video port
		.VSYNC(HDMI_TX_VS),
		.HSYNC(HDMI_TX_HS),
		.VDE(HDMI_TX_DE),
		.VCLK(HDMI_TX_CLK),
		.R(R),
		.G(G),
		.B(B),
		.uart_rx_i(uart_tx),	// Cross over
		.uart_tx_o(uart_rx),	// Cross over
		.keyboard_i(keyboard)
		);	
	// Simulation branches and control ============================================================
	
	// Other logic ================================================================================
	mmio_if u0 (
		.clk_i_clk            (FPGA_CLK1_50),            //    clk_i.clk
		.hps_ddr3_mem_a       (HPS_DDR3_ADDR),       // hps_ddr3.mem_a
		.hps_ddr3_mem_ba      (HPS_DDR3_BA),      //         .mem_ba
		.hps_ddr3_mem_ck      (HPS_DDR3_CK_P),      //         .mem_ck
		.hps_ddr3_mem_ck_n    (HPS_DDR3_CK_N),    //         .mem_ck_n
		.hps_ddr3_mem_cke     (HPS_DDR3_CKE),     //         .mem_cke
		.hps_ddr3_mem_cs_n    (HPS_DDR3_CS_N),    //         .mem_cs_n
		.hps_ddr3_mem_ras_n   (HPS_DDR3_RAS_N),   //         .mem_ras_n
		.hps_ddr3_mem_cas_n   (HPS_DDR3_CAS_N),   //         .mem_cas_n
		.hps_ddr3_mem_we_n    (HPS_DDR3_WE_N),    //         .mem_we_n
		.hps_ddr3_mem_reset_n (HPS_DDR3_RESET_N), //         .mem_reset_n
		.hps_ddr3_mem_dq      (HPS_DDR3_DQ),      //         .mem_dq
		.hps_ddr3_mem_dqs     (HPS_DDR3_DQS_P),     //         .mem_dqs
		.hps_ddr3_mem_dqs_n   (HPS_DDR3_DQS_N),   //         .mem_dqs_n
		.hps_ddr3_mem_odt     (HPS_DDR3_ODT),     //         .mem_odt
		.hps_ddr3_mem_dm      (HPS_DDR3_DM),      //         .mem_dm
		.hps_ddr3_oct_rzqin   (HPS_DDR3_RZQ),    //         .oct_rzqin
		.uart_rx_i			 (uart_rx),         	//     uart.uart_rx
		.uart_tx_o			 (uart_tx),         	//     uart.uart_tx
		.uart_clk_i_clk		(FPGA_CLK1_50),
		.uart_reset_o			(uart_reset),
		.cpc_keys_keys        (keyboard)         // cpc_keys.keys
	);

endmodule
	
