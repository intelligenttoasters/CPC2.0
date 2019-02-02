## Generated SDC file "CPC2.sdc"

## Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus II License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 14.0.0 Build 200 06/17/2014 SJ Web Edition"

## DATE    "Tue Mar 20 21:50:01 2018"

##
## DEVICE  "5CEBA2F17C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************

derive_pll_clocks -use_net_name -create_base_clocks
create_clock -name DATA5_clock -period 50

#**************************************************************
# Create Generated Clock
#**************************************************************

# This is the SDRAM clock against which the SDRAM signals are checked
create_generated_clock -name sdramClk -source master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[5] [get_ports sdramClk] 
create_generated_clock -name VCLK -source master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[2] [get_ports VCLK] 
create_generated_clock -name ASCLK -source audio_clock:audio_clk|audio_clock_0002:audio_clock_inst|altera_pll:altera_pll_i|outclk_wire[0] [get_ports ASCLK]
create_clock -name I2C_SCL -period 1000 -waveform {0 500} [get_ports {I2C_SCL}]

# Dummy clocks
create_clock -name DUMMY1 -period 250 cpc_core:core|YM2149:sounddev|addr[4]
create_clock -name DUMMY2 -period 250 cpc_core:core|ppi_fake:ppi8255|c_o[6]
create_clock -name DUMMY3 -period 250 cpc_core:core|tv80s:cpu|iorq_n

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty -add


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock { DATA5_clock } 0 [get_ports {DATA5}]
set_input_delay -clock { master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[1] } 0 [get_ports {uart_rx_i}]
set_input_delay -clock { master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[1] } 0 [get_ports {I2C_SCL}]
set_input_delay -clock { master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[1] } 0 [get_ports {I2C_SDA}]
set_input_delay -clock { master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[1] } -max 0 [get_ports {usb_vm}]
set_input_delay -clock { master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[1] } -min 0 [get_ports {usb_vm}]
set_input_delay -clock { master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[1] } -max 0 [get_ports {usb_vp}]
set_input_delay -clock { master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[1] } -min 0 [get_ports {usb_vp}]

#**************************************************************
# Set Output Delay
#**************************************************************


#**************************************************************
# Set Clock Groups
#**************************************************************

#**************************************************************
# Set False Path
#**************************************************************


set_false_path -to [get_ports {LED}]
set_false_path -to [get_ports {uart_tx_o}]

set_false_path -from {global_reset:global_reset|reset_counter[*]} -to {*}
set_false_path -from {DATA5_clock} -to {*}
# Not timing critical, flag will filter eventually - multi-cycle
#set_false_path -from {dma:dma|cpu_m2s_synchroniser[2]} -to {*}
#set_false_path -from {dma:dma|cpu_s2m_synchroniser[2]} -to {*}
#set_false_path -from {dma:dma|cpu_abort_synchroniser[2]} -to {*}

# Don't consider hold issues with the clock timing
#set_false_path -from {master_clk|master_clock_inst|altera_pll_i|general[5].gpll~PLL_OUTPUT_COUNTER|divclk} -to [get_ports {sdramClk}]
#set_false_path -from {master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[2]} -to {VCLK}
set_false_path -from {audio_clock:audio_clk|audio_clock_0002:audio_clock_inst|altera_pll:altera_pll_i|outclk_wire[0]} -to {ASCLK}
set_false_path -from {master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[1]} -to {I2C_SCL}

# Reset to heartbeat signal
set_false_path -from [get_ports {DATA5}] -to {DATA7}; set_false_path -from [get_ports {DATA5}] -to {DATA7}

# No path between audio and core clocks - TODO: Check this
set_false_path -from {i2c_master_top:i2c|i2c_master_byte_ctrl:byte_controller|i2c_master_bit_ctrl:bit_controller|scl_oen} -to [get_ports {I2C_SCL}]

#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -from {uart_rx_i} -to {usart:usart_con|track_rx[0]} -hold -end 3
set_multicycle_path -from {usb_vm} -to {usbHost:usb|usbSerialInterfaceEngine:u_usbSerialInterfaceEngine|readUSBWireData:u_readUSBWireData|RxBitsInSyncReg1[0]} -hold -end 2
set_multicycle_path -from {usb_vp} -to {usbHost:usb|usbSerialInterfaceEngine:u_usbSerialInterfaceEngine|readUSBWireData:u_readUSBWireData|RxBitsInSyncReg1[1]} -hold -end 2

# Multi cycle from SDRAM data to SDRAM clock 
#set_multicycle_path -from [get_clocks {master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[0]}] -to [get_clocks {sdramClk}] -setup -start 2
#set_multicycle_path -from [get_clocks {master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[0]}] -to [get_clocks {sdramClk}] -hold -start 2
set_max_skew -to [get_ports {sdram_*}] 2.5
# Delay the source synchronous clock
set_min_delay -to sdramClk 3.0

#**************************************************************
# Set Maximum Delay
#**************************************************************

#SDRAM requires 1.5nS set-up time, assuming 0.5ns PCB trace delays, 2ns tSU (max) + 2ns tH (min)
set_output_delay -clock [get_clocks sdramClk] -max 2 [get_ports sdram_*]
set_output_delay -clock [get_clocks sdramClk] -min -2 [get_ports sdram_*] -add_delay
set_input_delay -clock [get_clocks sdramClk] -max 1 [get_ports sdram_Dq[*]]
set_input_delay -clock [get_clocks sdramClk] -min -1 [get_ports sdram_Dq[*]] -add_delay

# Video as above
set_output_delay -clock [get_clocks VCLK] 0 [get_ports VCLK]
set_output_delay -clock [get_clocks VCLK] -max 2 [get_ports VSYNC]
set_output_delay -clock [get_clocks VCLK] -min -1 [get_ports VSYNC] -add_delay
set_output_delay -clock [get_clocks VCLK] -max 2 [get_ports HSYNC]
set_output_delay -clock [get_clocks VCLK] -min -1 [get_ports HSYNC] -add_delay
set_output_delay -clock [get_clocks VCLK] -max 2 [get_ports R[*]]
set_output_delay -clock [get_clocks VCLK] -min -1 [get_ports R[*]] -add_delay
set_output_delay -clock [get_clocks VCLK] -max 2 [get_ports G[*]]
set_output_delay -clock [get_clocks VCLK] -min -1 [get_ports G[*]] -add_delay
set_output_delay -clock [get_clocks VCLK] -max 2 [get_ports B[*]]
set_output_delay -clock [get_clocks VCLK] -min -1 [get_ports B[*]] -add_delay
set_output_delay -clock [get_clocks VCLK] -max 2 [get_ports VDE]
set_output_delay -clock [get_clocks VCLK] -min -1 [get_ports VDE] -add_delay
set_output_delay -clock [get_clocks VCLK] -max 2 [get_ports VDE]
set_output_delay -clock [get_clocks VCLK] -min -1 [get_ports VDE] -add_delay
# Audio
set_output_delay -clock [get_clocks ASCLK] 0 [get_ports ASCLK]
set_output_delay -clock [get_clocks ASCLK] -max 2 [get_ports I2S[*]]
set_output_delay -clock [get_clocks ASCLK] -min -1 [get_ports I2S[*]] -add_delay
set_output_delay -clock [get_clocks ASCLK] -max 2 [get_ports LRCLK]
set_output_delay -clock [get_clocks ASCLK] -min -1 [get_ports LRCLK] -add_delay

#USB
set_output_delay -clock { master_clock:master_clk|master_clock_0002:master_clock_inst|altera_pll:altera_pll_i|outclk_wire[1] } 0 [get_ports {usb_*}]

#I2C_SDA
set_output_delay -clock { I2C_SCL } 0 [get_ports {I2C_SDA}]

#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************
set_input_delay -clock { altera_reserved_tck } 1 [get_ports {altera_reserved_*}]
set_output_delay -clock { altera_reserved_tck } 1 [get_ports {altera_reserved_*}]

