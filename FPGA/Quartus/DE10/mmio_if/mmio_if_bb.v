
module mmio_if (
	clk_i_clk,
	hps_ddr3_mem_a,
	hps_ddr3_mem_ba,
	hps_ddr3_mem_ck,
	hps_ddr3_mem_ck_n,
	hps_ddr3_mem_cke,
	hps_ddr3_mem_cs_n,
	hps_ddr3_mem_ras_n,
	hps_ddr3_mem_cas_n,
	hps_ddr3_mem_we_n,
	hps_ddr3_mem_reset_n,
	hps_ddr3_mem_dq,
	hps_ddr3_mem_dqs,
	hps_ddr3_mem_dqs_n,
	hps_ddr3_mem_odt,
	hps_ddr3_mem_dm,
	hps_ddr3_oct_rzqin,
	cpc_keys_keys,
	uart_tx_o,
	uart_rx_i,
	uart_reset_o,
	uart_clk_i_clk);	

	input		clk_i_clk;
	output	[14:0]	hps_ddr3_mem_a;
	output	[2:0]	hps_ddr3_mem_ba;
	output		hps_ddr3_mem_ck;
	output		hps_ddr3_mem_ck_n;
	output		hps_ddr3_mem_cke;
	output		hps_ddr3_mem_cs_n;
	output		hps_ddr3_mem_ras_n;
	output		hps_ddr3_mem_cas_n;
	output		hps_ddr3_mem_we_n;
	output		hps_ddr3_mem_reset_n;
	inout	[31:0]	hps_ddr3_mem_dq;
	inout	[3:0]	hps_ddr3_mem_dqs;
	inout	[3:0]	hps_ddr3_mem_dqs_n;
	output		hps_ddr3_mem_odt;
	output	[3:0]	hps_ddr3_mem_dm;
	input		hps_ddr3_oct_rzqin;
	output	[79:0]	cpc_keys_keys;
	output		uart_tx_o;
	input		uart_rx_i;
	output		uart_reset_o;
	input		uart_clk_i_clk;
endmodule
