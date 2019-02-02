
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module CPC2_DE10(

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

	//////////// HPS //////////
	inout 		          		HPS_CONV_USB_N,
	output		    [14:0]		HPS_DDR3_ADDR,
	output		     [2:0]		HPS_DDR3_BA,
	output		          		HPS_DDR3_CAS_N,
	output		          		HPS_DDR3_CKE,
	output		          		HPS_DDR3_CK_N,
	output		          		HPS_DDR3_CK_P,
	output		          		HPS_DDR3_CS_N,
	output		     [3:0]		HPS_DDR3_DM,
	inout 		    [31:0]		HPS_DDR3_DQ,
	inout 		     [3:0]		HPS_DDR3_DQS_N,
	inout 		     [3:0]		HPS_DDR3_DQS_P,
	output		          		HPS_DDR3_ODT,
	output		          		HPS_DDR3_RAS_N,
	output		          		HPS_DDR3_RESET_N,
	input 		          		HPS_DDR3_RZQ,
	output		          		HPS_DDR3_WE_N,
	output		          		HPS_ENET_GTX_CLK,
	inout 		          		HPS_ENET_INT_N,
	output		          		HPS_ENET_MDC,
	inout 		          		HPS_ENET_MDIO,
	input 		          		HPS_ENET_RX_CLK,
	input 		     [3:0]		HPS_ENET_RX_DATA,
	input 		          		HPS_ENET_RX_DV,
	output		     [3:0]		HPS_ENET_TX_DATA,
	output		          		HPS_ENET_TX_EN,
	inout 		          		HPS_GSENSOR_INT,
	inout 		          		HPS_I2C0_SCLK,
	inout 		          		HPS_I2C0_SDAT,
	inout 		          		HPS_I2C1_SCLK,
	inout 		          		HPS_I2C1_SDAT,
	inout 		          		HPS_KEY,
	inout 		          		HPS_LED,
	inout 		          		HPS_LTC_GPIO,
	output		          		HPS_SD_CLK,
	inout 		          		HPS_SD_CMD,
	inout 		     [3:0]		HPS_SD_DATA,
	output		          		HPS_SPIM_CLK,
	input 		          		HPS_SPIM_MISO,
	output		          		HPS_SPIM_MOSI,
	inout 		          		HPS_SPIM_SS,
	input 		          		HPS_UART_RX,
	output		          		HPS_UART_TX,
	input 		          		HPS_USB_CLKOUT,
	inout 		     [7:0]		HPS_USB_DATA,
	input 		          		HPS_USB_DIR,
	input 		          		HPS_USB_NXT,
	output		          		HPS_USB_STP,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [7:0]		LED,

	//////////// SW //////////
	input 		     [3:0]		SW,

	//////////// GPIO_0, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO_1
);



//=======================================================
//  REG/WIRE declarations
//=======================================================




//=======================================================
//  Structural coding
//=======================================================

wire [2:0] dummy1;

assign LED[7:1] = 7'd0;

CPC2 cpc2_inst (
		.CLK_50(FPGA_CLK1_50),
		.CLK2_50(FPGA_CLK2_50),
		.CLK_12(FPGA_CLK3_50),
		// Control Ports
		.DATA7(),					// Unused
		.DATA6(),					// Unused
		.DATA5(KEY != 2'b11),					// Soft Reset - any key
		.I2C_SCL(HDMI_I2C_SCL),						// INOUT - HDMI
		.I2C_SDA(HDMI_I2C_SDA),						// INOUT - HDMI
		// Disk/activity LED
		.LED(LED[0]),
		// Video port - output
		.VSYNC(HDMI_TX_VS),
		.HSYNC(HDMI_TX_HS),
		.VDE(HDMI_TX_DE),
		.VCLK(HDMI_TX_CLK),
		.R(HDMI_TX_D[23:16]),
		.G(HDMI_TX_D[15:8]),
		.B(HDMI_TX_D[7:0]),
		// Video Audio
		.I2S({dummy1,HDMI_I2S}),	// 4 bits
		.ASCLK(HDMI_SCLK),
		.LRCLK(HDMI_LRCLK),
		.MCLK(HDMI_MCLK),
		// Uart port
		.uart_rx_i(HPS_UART_RX),
		.uart_tx_o(HPS_UART_TX),
		// USB port
		.usb_mode(),
		.usb_suspend(),
		.usb_vm(),
		.usb_vp(),
		.usb_rcv(),
		.usb_vpo(),
		.usb_vmo(),
		.usb_speed(),
		.usb_oen(),
		// SDRAM interface
		.sdram_Dq(),
		.sdram_Addr(),
		.sdram_Ba(), 
		.sdramClk(), 
		.sdram_Cke(), 
		.sdram_Cs_n(), 
		.sdram_Ras_n(), 
		.sdram_Cas_n(), 
		.sdram_We_n(), 
		.sdram_Dqm()
		);

endmodule