// mmio_if_hps_0.v

// This file was auto-generated from altera_hps_hw.tcl.  If you edit it your changes
// will probably be lost.
// 
// Generated using ACDS version 14.0 200 at 2017.05.28.12:10:00

`timescale 1 ps / 1 ps
module mmio_if_hps_0 #(
		parameter F2S_Width = 0,
		parameter S2F_Width = 0
	) (
		output wire        h2f_rst_n,      //         h2f_reset.reset_n
		input  wire        h2f_lw_axi_clk, //  h2f_lw_axi_clock.clk
		output wire [11:0] h2f_lw_AWID,    // h2f_lw_axi_master.awid
		output wire [20:0] h2f_lw_AWADDR,  //                  .awaddr
		output wire [3:0]  h2f_lw_AWLEN,   //                  .awlen
		output wire [2:0]  h2f_lw_AWSIZE,  //                  .awsize
		output wire [1:0]  h2f_lw_AWBURST, //                  .awburst
		output wire [1:0]  h2f_lw_AWLOCK,  //                  .awlock
		output wire [3:0]  h2f_lw_AWCACHE, //                  .awcache
		output wire [2:0]  h2f_lw_AWPROT,  //                  .awprot
		output wire        h2f_lw_AWVALID, //                  .awvalid
		input  wire        h2f_lw_AWREADY, //                  .awready
		output wire [11:0] h2f_lw_WID,     //                  .wid
		output wire [31:0] h2f_lw_WDATA,   //                  .wdata
		output wire [3:0]  h2f_lw_WSTRB,   //                  .wstrb
		output wire        h2f_lw_WLAST,   //                  .wlast
		output wire        h2f_lw_WVALID,  //                  .wvalid
		input  wire        h2f_lw_WREADY,  //                  .wready
		input  wire [11:0] h2f_lw_BID,     //                  .bid
		input  wire [1:0]  h2f_lw_BRESP,   //                  .bresp
		input  wire        h2f_lw_BVALID,  //                  .bvalid
		output wire        h2f_lw_BREADY,  //                  .bready
		output wire [11:0] h2f_lw_ARID,    //                  .arid
		output wire [20:0] h2f_lw_ARADDR,  //                  .araddr
		output wire [3:0]  h2f_lw_ARLEN,   //                  .arlen
		output wire [2:0]  h2f_lw_ARSIZE,  //                  .arsize
		output wire [1:0]  h2f_lw_ARBURST, //                  .arburst
		output wire [1:0]  h2f_lw_ARLOCK,  //                  .arlock
		output wire [3:0]  h2f_lw_ARCACHE, //                  .arcache
		output wire [2:0]  h2f_lw_ARPROT,  //                  .arprot
		output wire        h2f_lw_ARVALID, //                  .arvalid
		input  wire        h2f_lw_ARREADY, //                  .arready
		input  wire [11:0] h2f_lw_RID,     //                  .rid
		input  wire [31:0] h2f_lw_RDATA,   //                  .rdata
		input  wire [1:0]  h2f_lw_RRESP,   //                  .rresp
		input  wire        h2f_lw_RLAST,   //                  .rlast
		input  wire        h2f_lw_RVALID,  //                  .rvalid
		output wire        h2f_lw_RREADY,  //                  .rready
		output wire [14:0] mem_a,          //            memory.mem_a
		output wire [2:0]  mem_ba,         //                  .mem_ba
		output wire        mem_ck,         //                  .mem_ck
		output wire        mem_ck_n,       //                  .mem_ck_n
		output wire        mem_cke,        //                  .mem_cke
		output wire        mem_cs_n,       //                  .mem_cs_n
		output wire        mem_ras_n,      //                  .mem_ras_n
		output wire        mem_cas_n,      //                  .mem_cas_n
		output wire        mem_we_n,       //                  .mem_we_n
		output wire        mem_reset_n,    //                  .mem_reset_n
		inout  wire [31:0] mem_dq,         //                  .mem_dq
		inout  wire [3:0]  mem_dqs,        //                  .mem_dqs
		inout  wire [3:0]  mem_dqs_n,      //                  .mem_dqs_n
		output wire        mem_odt,        //                  .mem_odt
		output wire [3:0]  mem_dm,         //                  .mem_dm
		input  wire        oct_rzqin       //                  .oct_rzqin
	);

	generate
		// If any of the display statements (or deliberately broken
		// instantiations) within this generate block triggers then this module
		// has been instantiated this module with a set of parameters different
		// from those it was generated for.  This will usually result in a
		// non-functioning system.
		if (F2S_Width != 0)
		begin
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
			instantiated_with_wrong_parameters_error_see_comment_above
					f2s_width_check ( .error(1'b1) );
		end
		if (S2F_Width != 0)
		begin
			initial begin
				$display("Generated module instantiated with wrong parameters");
				$stop;
			end
			instantiated_with_wrong_parameters_error_see_comment_above
					s2f_width_check ( .error(1'b1) );
		end
	endgenerate

	mmio_if_hps_0_fpga_interfaces fpga_interfaces (
		.h2f_rst_n      (h2f_rst_n),      //         h2f_reset.reset_n
		.h2f_lw_axi_clk (h2f_lw_axi_clk), //  h2f_lw_axi_clock.clk
		.h2f_lw_AWID    (h2f_lw_AWID),    // h2f_lw_axi_master.awid
		.h2f_lw_AWADDR  (h2f_lw_AWADDR),  //                  .awaddr
		.h2f_lw_AWLEN   (h2f_lw_AWLEN),   //                  .awlen
		.h2f_lw_AWSIZE  (h2f_lw_AWSIZE),  //                  .awsize
		.h2f_lw_AWBURST (h2f_lw_AWBURST), //                  .awburst
		.h2f_lw_AWLOCK  (h2f_lw_AWLOCK),  //                  .awlock
		.h2f_lw_AWCACHE (h2f_lw_AWCACHE), //                  .awcache
		.h2f_lw_AWPROT  (h2f_lw_AWPROT),  //                  .awprot
		.h2f_lw_AWVALID (h2f_lw_AWVALID), //                  .awvalid
		.h2f_lw_AWREADY (h2f_lw_AWREADY), //                  .awready
		.h2f_lw_WID     (h2f_lw_WID),     //                  .wid
		.h2f_lw_WDATA   (h2f_lw_WDATA),   //                  .wdata
		.h2f_lw_WSTRB   (h2f_lw_WSTRB),   //                  .wstrb
		.h2f_lw_WLAST   (h2f_lw_WLAST),   //                  .wlast
		.h2f_lw_WVALID  (h2f_lw_WVALID),  //                  .wvalid
		.h2f_lw_WREADY  (h2f_lw_WREADY),  //                  .wready
		.h2f_lw_BID     (h2f_lw_BID),     //                  .bid
		.h2f_lw_BRESP   (h2f_lw_BRESP),   //                  .bresp
		.h2f_lw_BVALID  (h2f_lw_BVALID),  //                  .bvalid
		.h2f_lw_BREADY  (h2f_lw_BREADY),  //                  .bready
		.h2f_lw_ARID    (h2f_lw_ARID),    //                  .arid
		.h2f_lw_ARADDR  (h2f_lw_ARADDR),  //                  .araddr
		.h2f_lw_ARLEN   (h2f_lw_ARLEN),   //                  .arlen
		.h2f_lw_ARSIZE  (h2f_lw_ARSIZE),  //                  .arsize
		.h2f_lw_ARBURST (h2f_lw_ARBURST), //                  .arburst
		.h2f_lw_ARLOCK  (h2f_lw_ARLOCK),  //                  .arlock
		.h2f_lw_ARCACHE (h2f_lw_ARCACHE), //                  .arcache
		.h2f_lw_ARPROT  (h2f_lw_ARPROT),  //                  .arprot
		.h2f_lw_ARVALID (h2f_lw_ARVALID), //                  .arvalid
		.h2f_lw_ARREADY (h2f_lw_ARREADY), //                  .arready
		.h2f_lw_RID     (h2f_lw_RID),     //                  .rid
		.h2f_lw_RDATA   (h2f_lw_RDATA),   //                  .rdata
		.h2f_lw_RRESP   (h2f_lw_RRESP),   //                  .rresp
		.h2f_lw_RLAST   (h2f_lw_RLAST),   //                  .rlast
		.h2f_lw_RVALID  (h2f_lw_RVALID),  //                  .rvalid
		.h2f_lw_RREADY  (h2f_lw_RREADY)   //                  .rready
	);

	mmio_if_hps_0_hps_io hps_io (
		.mem_a       (mem_a),       // memory.mem_a
		.mem_ba      (mem_ba),      //       .mem_ba
		.mem_ck      (mem_ck),      //       .mem_ck
		.mem_ck_n    (mem_ck_n),    //       .mem_ck_n
		.mem_cke     (mem_cke),     //       .mem_cke
		.mem_cs_n    (mem_cs_n),    //       .mem_cs_n
		.mem_ras_n   (mem_ras_n),   //       .mem_ras_n
		.mem_cas_n   (mem_cas_n),   //       .mem_cas_n
		.mem_we_n    (mem_we_n),    //       .mem_we_n
		.mem_reset_n (mem_reset_n), //       .mem_reset_n
		.mem_dq      (mem_dq),      //       .mem_dq
		.mem_dqs     (mem_dqs),     //       .mem_dqs
		.mem_dqs_n   (mem_dqs_n),   //       .mem_dqs_n
		.mem_odt     (mem_odt),     //       .mem_odt
		.mem_dm      (mem_dm),      //       .mem_dm
		.oct_rzqin   (oct_rzqin)    //       .oct_rzqin
	);

endmodule
