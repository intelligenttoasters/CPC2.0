	mmio_if u0 (
		.clk_i_clk            (<connected-to-clk_i_clk>),            //      clk_i.clk
		.hps_ddr3_mem_a       (<connected-to-hps_ddr3_mem_a>),       //   hps_ddr3.mem_a
		.hps_ddr3_mem_ba      (<connected-to-hps_ddr3_mem_ba>),      //           .mem_ba
		.hps_ddr3_mem_ck      (<connected-to-hps_ddr3_mem_ck>),      //           .mem_ck
		.hps_ddr3_mem_ck_n    (<connected-to-hps_ddr3_mem_ck_n>),    //           .mem_ck_n
		.hps_ddr3_mem_cke     (<connected-to-hps_ddr3_mem_cke>),     //           .mem_cke
		.hps_ddr3_mem_cs_n    (<connected-to-hps_ddr3_mem_cs_n>),    //           .mem_cs_n
		.hps_ddr3_mem_ras_n   (<connected-to-hps_ddr3_mem_ras_n>),   //           .mem_ras_n
		.hps_ddr3_mem_cas_n   (<connected-to-hps_ddr3_mem_cas_n>),   //           .mem_cas_n
		.hps_ddr3_mem_we_n    (<connected-to-hps_ddr3_mem_we_n>),    //           .mem_we_n
		.hps_ddr3_mem_reset_n (<connected-to-hps_ddr3_mem_reset_n>), //           .mem_reset_n
		.hps_ddr3_mem_dq      (<connected-to-hps_ddr3_mem_dq>),      //           .mem_dq
		.hps_ddr3_mem_dqs     (<connected-to-hps_ddr3_mem_dqs>),     //           .mem_dqs
		.hps_ddr3_mem_dqs_n   (<connected-to-hps_ddr3_mem_dqs_n>),   //           .mem_dqs_n
		.hps_ddr3_mem_odt     (<connected-to-hps_ddr3_mem_odt>),     //           .mem_odt
		.hps_ddr3_mem_dm      (<connected-to-hps_ddr3_mem_dm>),      //           .mem_dm
		.hps_ddr3_oct_rzqin   (<connected-to-hps_ddr3_oct_rzqin>),   //           .oct_rzqin
		.cpc_keys_keys        (<connected-to-cpc_keys_keys>),        //   cpc_keys.keys
		.uart_tx_o            (<connected-to-uart_tx_o>),            //       uart.tx_o
		.uart_rx_i            (<connected-to-uart_rx_i>),            //           .rx_i
		.uart_reset_o         (<connected-to-uart_reset_o>),         //           .reset_o
		.uart_clk_i_clk       (<connected-to-uart_clk_i_clk>)        // uart_clk_i.clk
	);

