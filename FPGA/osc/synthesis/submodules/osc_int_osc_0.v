//altint_osc CBX_AUTO_BLACKBOX="ALL" CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="Cyclone V" clkout oscena
//VERSION_BEGIN 14.0 cbx_altint_osc 2014:06:05:09:45:41:SJ cbx_arriav 2014:06:05:09:45:41:SJ cbx_cycloneii 2014:06:05:09:45:41:SJ cbx_lpm_add_sub 2014:06:05:09:45:41:SJ cbx_lpm_compare 2014:06:05:09:45:41:SJ cbx_lpm_counter 2014:06:05:09:45:41:SJ cbx_lpm_decode 2014:06:05:09:45:41:SJ cbx_mgl 2014:06:05:10:17:12:SJ cbx_nightfury 2014:06:05:09:45:41:SJ cbx_stratix 2014:06:05:09:45:41:SJ cbx_stratixii 2014:06:05:09:45:41:SJ cbx_stratixiii 2014:06:05:09:45:41:SJ cbx_stratixv 2014:06:05:09:45:41:SJ cbx_tgx 2014:06:05:09:45:41:SJ cbx_zippleback 2014:06:17:19:05:45:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, the Altera Quartus II License Agreement,
//  the Altera MegaCore Function License Agreement, or other 
//  applicable license agreement, including, without limitation, 
//  that your use is for the sole purpose of programming logic 
//  devices manufactured by Altera and sold by Altera or its 
//  authorized distributors.  Please refer to the applicable 
//  agreement for further details.



//synthesis_resources = cyclonev_oscillator 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  osc_int_osc_0
	( 
	clkout,
	oscena) /* synthesis synthesis_clearbox=1 */;
	output   clkout;
	input   oscena;

	wire  wire_sd1_clkout;

	cyclonev_oscillator   sd1
	( 
	.clkout(wire_sd1_clkout),
	.clkout1(),
	.oscena(oscena));
	assign
		clkout = wire_sd1_clkout;
endmodule //osc_int_osc_0
//VALID FILE
