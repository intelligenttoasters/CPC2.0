// (C) 2001-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module HPS_hps_0_hps_io_border(
// gpio_loanio
  output wire [29 - 1 : 0 ] gpio_loanio_loanio0_i
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio0_oe
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio0_o
 ,output wire [29 - 1 : 0 ] gpio_loanio_loanio1_i
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio1_oe
 ,input wire [29 - 1 : 0 ] gpio_loanio_loanio1_o
 ,output wire [9 - 1 : 0 ] gpio_loanio_loanio2_i
 ,input wire [9 - 1 : 0 ] gpio_loanio_loanio2_oe
 ,input wire [9 - 1 : 0 ] gpio_loanio_loanio2_o
// memory
 ,output wire [15 - 1 : 0 ] mem_a
 ,output wire [3 - 1 : 0 ] mem_ba
 ,output wire [1 - 1 : 0 ] mem_ck
 ,output wire [1 - 1 : 0 ] mem_ck_n
 ,output wire [1 - 1 : 0 ] mem_cke
 ,output wire [1 - 1 : 0 ] mem_cs_n
 ,output wire [1 - 1 : 0 ] mem_ras_n
 ,output wire [1 - 1 : 0 ] mem_cas_n
 ,output wire [1 - 1 : 0 ] mem_we_n
 ,output wire [1 - 1 : 0 ] mem_reset_n
 ,inout wire [32 - 1 : 0 ] mem_dq
 ,inout wire [4 - 1 : 0 ] mem_dqs
 ,inout wire [4 - 1 : 0 ] mem_dqs_n
 ,output wire [1 - 1 : 0 ] mem_odt
 ,output wire [4 - 1 : 0 ] mem_dm
 ,input wire [1 - 1 : 0 ] oct_rzqin
// hps_io
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO01
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO02
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO03
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO04
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO05
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO06
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO07
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO08
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO10
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO11
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO12
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO13
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO42
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO49
 ,inout wire [1 - 1 : 0 ] hps_io_gpio_inst_LOANIO50
);

assign hps_io_gpio_inst_LOANIO01 = intermediate[1] ? intermediate[0] : 'z;
assign hps_io_gpio_inst_LOANIO02 = intermediate[3] ? intermediate[2] : 'z;
assign hps_io_gpio_inst_LOANIO03 = intermediate[5] ? intermediate[4] : 'z;
assign hps_io_gpio_inst_LOANIO04 = intermediate[7] ? intermediate[6] : 'z;
assign hps_io_gpio_inst_LOANIO05 = intermediate[9] ? intermediate[8] : 'z;
assign hps_io_gpio_inst_LOANIO06 = intermediate[11] ? intermediate[10] : 'z;
assign hps_io_gpio_inst_LOANIO07 = intermediate[13] ? intermediate[12] : 'z;
assign hps_io_gpio_inst_LOANIO08 = intermediate[15] ? intermediate[14] : 'z;
assign hps_io_gpio_inst_LOANIO10 = intermediate[17] ? intermediate[16] : 'z;
assign hps_io_gpio_inst_LOANIO11 = intermediate[19] ? intermediate[18] : 'z;
assign hps_io_gpio_inst_LOANIO12 = intermediate[21] ? intermediate[20] : 'z;
assign hps_io_gpio_inst_LOANIO13 = intermediate[23] ? intermediate[22] : 'z;
assign hps_io_gpio_inst_LOANIO42 = intermediate[25] ? intermediate[24] : 'z;
assign hps_io_gpio_inst_LOANIO49 = intermediate[27] ? intermediate[26] : 'z;
assign hps_io_gpio_inst_LOANIO50 = intermediate[29] ? intermediate[28] : 'z;

wire [30 - 1 : 0] intermediate;

wire [63 - 1 : 0] floating;

cyclonev_hps_peripheral_gpio gpio_inst(
 .GPIO1_PORTA_I({
    hps_io_gpio_inst_LOANIO50[0:0] // 21:21
   ,hps_io_gpio_inst_LOANIO49[0:0] // 20:20
   ,floating[5:0] // 19:14
   ,hps_io_gpio_inst_LOANIO42[0:0] // 13:13
   ,floating[18:6] // 12:0
  })
,.LOANIO1_O({
    gpio_loanio_loanio1_o[28:0] // 28:0
  })
,.LOANIO0_OE({
    gpio_loanio_loanio0_oe[28:0] // 28:0
  })
,.LOANIO0_I({
    gpio_loanio_loanio0_i[28:0] // 28:0
  })
,.GPIO1_PORTA_OE({
    intermediate[29:29] // 21:21
   ,intermediate[27:27] // 20:20
   ,floating[24:19] // 19:14
   ,intermediate[25:25] // 13:13
   ,floating[37:25] // 12:0
  })
,.LOANIO2_O({
    gpio_loanio_loanio2_o[8:0] // 8:0
  })
,.LOANIO1_I({
    gpio_loanio_loanio1_i[28:0] // 28:0
  })
,.GPIO0_PORTA_O({
    intermediate[22:22] // 13:13
   ,intermediate[20:20] // 12:12
   ,intermediate[18:18] // 11:11
   ,intermediate[16:16] // 10:10
   ,floating[38:38] // 9:9
   ,intermediate[14:14] // 8:8
   ,intermediate[12:12] // 7:7
   ,intermediate[10:10] // 6:6
   ,intermediate[8:8] // 5:5
   ,intermediate[6:6] // 4:4
   ,intermediate[4:4] // 3:3
   ,intermediate[2:2] // 2:2
   ,intermediate[0:0] // 1:1
   ,floating[39:39] // 0:0
  })
,.LOANIO2_I({
    gpio_loanio_loanio2_i[8:0] // 8:0
  })
,.LOANIO2_OE({
    gpio_loanio_loanio2_oe[8:0] // 8:0
  })
,.GPIO0_PORTA_I({
    hps_io_gpio_inst_LOANIO13[0:0] // 13:13
   ,hps_io_gpio_inst_LOANIO12[0:0] // 12:12
   ,hps_io_gpio_inst_LOANIO11[0:0] // 11:11
   ,hps_io_gpio_inst_LOANIO10[0:0] // 10:10
   ,floating[40:40] // 9:9
   ,hps_io_gpio_inst_LOANIO08[0:0] // 8:8
   ,hps_io_gpio_inst_LOANIO07[0:0] // 7:7
   ,hps_io_gpio_inst_LOANIO06[0:0] // 6:6
   ,hps_io_gpio_inst_LOANIO05[0:0] // 5:5
   ,hps_io_gpio_inst_LOANIO04[0:0] // 4:4
   ,hps_io_gpio_inst_LOANIO03[0:0] // 3:3
   ,hps_io_gpio_inst_LOANIO02[0:0] // 2:2
   ,hps_io_gpio_inst_LOANIO01[0:0] // 1:1
   ,floating[41:41] // 0:0
  })
,.GPIO0_PORTA_OE({
    intermediate[23:23] // 13:13
   ,intermediate[21:21] // 12:12
   ,intermediate[19:19] // 11:11
   ,intermediate[17:17] // 10:10
   ,floating[42:42] // 9:9
   ,intermediate[15:15] // 8:8
   ,intermediate[13:13] // 7:7
   ,intermediate[11:11] // 6:6
   ,intermediate[9:9] // 5:5
   ,intermediate[7:7] // 4:4
   ,intermediate[5:5] // 3:3
   ,intermediate[3:3] // 2:2
   ,intermediate[1:1] // 1:1
   ,floating[43:43] // 0:0
  })
,.GPIO1_PORTA_O({
    intermediate[28:28] // 21:21
   ,intermediate[26:26] // 20:20
   ,floating[49:44] // 19:14
   ,intermediate[24:24] // 13:13
   ,floating[62:50] // 12:0
  })
,.LOANIO1_OE({
    gpio_loanio_loanio1_oe[28:0] // 28:0
  })
,.LOANIO0_O({
    gpio_loanio_loanio0_o[28:0] // 28:0
  })
);


hps_sdram hps_sdram_inst(
 .mem_dq({
    mem_dq[31:0] // 31:0
  })
,.mem_odt({
    mem_odt[0:0] // 0:0
  })
,.mem_ras_n({
    mem_ras_n[0:0] // 0:0
  })
,.mem_dqs_n({
    mem_dqs_n[3:0] // 3:0
  })
,.mem_dqs({
    mem_dqs[3:0] // 3:0
  })
,.mem_dm({
    mem_dm[3:0] // 3:0
  })
,.mem_we_n({
    mem_we_n[0:0] // 0:0
  })
,.mem_cas_n({
    mem_cas_n[0:0] // 0:0
  })
,.mem_ba({
    mem_ba[2:0] // 2:0
  })
,.mem_a({
    mem_a[14:0] // 14:0
  })
,.mem_cs_n({
    mem_cs_n[0:0] // 0:0
  })
,.mem_ck({
    mem_ck[0:0] // 0:0
  })
,.mem_cke({
    mem_cke[0:0] // 0:0
  })
,.oct_rzqin({
    oct_rzqin[0:0] // 0:0
  })
,.mem_reset_n({
    mem_reset_n[0:0] // 0:0
  })
,.mem_ck_n({
    mem_ck_n[0:0] // 0:0
  })
);

endmodule

