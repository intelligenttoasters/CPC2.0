
module HPS (
	memory_mem_a,
	memory_mem_ba,
	memory_mem_ck,
	memory_mem_ck_n,
	memory_mem_cke,
	memory_mem_cs_n,
	memory_mem_ras_n,
	memory_mem_cas_n,
	memory_mem_we_n,
	memory_mem_reset_n,
	memory_mem_dq,
	memory_mem_dqs,
	memory_mem_dqs_n,
	memory_mem_odt,
	memory_mem_dm,
	memory_oct_rzqin,
	hps_io_hps_io_gpio_inst_LOANIO01,
	hps_io_hps_io_gpio_inst_LOANIO02,
	hps_io_hps_io_gpio_inst_LOANIO03,
	hps_io_hps_io_gpio_inst_LOANIO04,
	hps_io_hps_io_gpio_inst_LOANIO05,
	hps_io_hps_io_gpio_inst_LOANIO06,
	hps_io_hps_io_gpio_inst_LOANIO07,
	hps_io_hps_io_gpio_inst_LOANIO08,
	hps_io_hps_io_gpio_inst_LOANIO10,
	hps_io_hps_io_gpio_inst_LOANIO11,
	hps_io_hps_io_gpio_inst_LOANIO12,
	hps_io_hps_io_gpio_inst_LOANIO13,
	hps_io_hps_io_gpio_inst_LOANIO42,
	hps_io_hps_io_gpio_inst_LOANIO49,
	hps_io_hps_io_gpio_inst_LOANIO50,
	loanio_in,
	loanio_out,
	loanio_oe,
	hps_gp_gp_in,
	hps_gp_gp_out);	

	output	[14:0]	memory_mem_a;
	output	[2:0]	memory_mem_ba;
	output		memory_mem_ck;
	output		memory_mem_ck_n;
	output		memory_mem_cke;
	output		memory_mem_cs_n;
	output		memory_mem_ras_n;
	output		memory_mem_cas_n;
	output		memory_mem_we_n;
	output		memory_mem_reset_n;
	inout	[31:0]	memory_mem_dq;
	inout	[3:0]	memory_mem_dqs;
	inout	[3:0]	memory_mem_dqs_n;
	output		memory_mem_odt;
	output	[3:0]	memory_mem_dm;
	input		memory_oct_rzqin;
	inout		hps_io_hps_io_gpio_inst_LOANIO01;
	inout		hps_io_hps_io_gpio_inst_LOANIO02;
	inout		hps_io_hps_io_gpio_inst_LOANIO03;
	inout		hps_io_hps_io_gpio_inst_LOANIO04;
	inout		hps_io_hps_io_gpio_inst_LOANIO05;
	inout		hps_io_hps_io_gpio_inst_LOANIO06;
	inout		hps_io_hps_io_gpio_inst_LOANIO07;
	inout		hps_io_hps_io_gpio_inst_LOANIO08;
	inout		hps_io_hps_io_gpio_inst_LOANIO10;
	inout		hps_io_hps_io_gpio_inst_LOANIO11;
	inout		hps_io_hps_io_gpio_inst_LOANIO12;
	inout		hps_io_hps_io_gpio_inst_LOANIO13;
	inout		hps_io_hps_io_gpio_inst_LOANIO42;
	inout		hps_io_hps_io_gpio_inst_LOANIO49;
	inout		hps_io_hps_io_gpio_inst_LOANIO50;
	output	[66:0]	loanio_in;
	input	[66:0]	loanio_out;
	input	[66:0]	loanio_oe;
	input	[31:0]	hps_gp_gp_in;
	output	[31:0]	hps_gp_gp_out;
endmodule
