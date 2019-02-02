#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period "50.0 MHz" [get_ports FPGA_CLK1_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK2_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK3_50]
create_clock -name usb_clk -period 16.667 -waveform {0 8.333} [get_ports {HPS_USB_CLKOUT}]
create_clock -name SD_CLK -period 83.333 -waveform {0 41.666} [get_nets {cpc2_inst|sdmmc|clock_divider0|SD_CLK_O}]

# for enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -clock { cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -min 1 [get_ports {GPIO_1[10] GPIO_1[13] GPIO_1[15] GPIO_1[18] GPIO_1[17] GPIO_1[16] GPIO_1[12] GPIO_1[14] GPIO_1[7] GPIO_1[8] GPIO_1[11]}]
set_input_delay -clock { cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -max 8 [get_ports {GPIO_1[10] GPIO_1[13] GPIO_1[15] GPIO_1[18] GPIO_1[17] GPIO_1[16] GPIO_1[12] GPIO_1[14] GPIO_1[7] GPIO_1[8] GPIO_1[11]}]

set_input_delay -clock { cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -min 1 [get_ports {GPIO_1[28] GPIO_1[30] GPIO_1[32] GPIO_1[35] GPIO_1[34] GPIO_1[33] GPIO_1[29] GPIO_1[31] GPIO_1[26] GPIO_1[25] GPIO_1[27]}]
set_input_delay -clock { cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } -max 8 [get_ports {GPIO_1[28] GPIO_1[30] GPIO_1[32] GPIO_1[35] GPIO_1[34] GPIO_1[33] GPIO_1[29] GPIO_1[31] GPIO_1[26] GPIO_1[25] GPIO_1[27]}]

#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_clocks {usb_clk}]
set_false_path -to [get_clocks {usb_clk}]
# 48MHz - others
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}
# 16MHz - others
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}
# 4MHz - others
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}
# 1MHz - others
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}
# 150MHz - CPC clock
set_false_path -from {cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} 
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|master_clk|master_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}
# 3.072MHz to 1MHz 
set_false_path -from {cpc2_inst|cpc_clocks|cpc_clks_inst|altera_pll_i|general[3].gpll~PLL_OUTPUT_COUNTER|divclk} -to {cpc2_inst|audio_clk|audio_clock_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}
# Reset timer
set_false_path -from {CPC2:cpc2_inst|global_reset:global_reset|reset_counter[*]}

# Don't care signals
set_false_path -to [get_ports {LED[*]}]

#**************************************************************
# Set Multicycle Path
#**************************************************************


#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************

set_max_skew -to [get_ports {HDMI_TX_* }] 12.5
set_max_skew -to [get_ports {HPS_USB_*}] 8
#set_max_skew -to [get_ports {hyper_*}] 2
set_max_skew -from [get_ports {GPIO_1[11]} ] -to [get_ports {GPIO_1[10] GPIO_1[13] GPIO_1[15] GPIO_1[18] GPIO_1[17] GPIO_1[16] GPIO_1[12] GPIO_1[14] GPIO_1[7] GPIO_1[8]}] 5.5
set_max_skew -from [get_ports {GPIO_1[27]} ] -to [get_ports {GPIO_1[28] GPIO_1[30] GPIO_1[32] GPIO_1[35] GPIO_1[34] GPIO_1[33] GPIO_1[29] GPIO_1[31] GPIO_1[26] GPIO_1[25]}] 5.5
