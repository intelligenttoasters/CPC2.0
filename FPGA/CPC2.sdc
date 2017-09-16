## Generated SDC file "cpc.sdc"

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

## DATE    "Sat Dec 03 23:31:28 2016"

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

create_clock -name {SPI_SCK} -period 25.000 -waveform { 0.000 12.500 } [get_ports { SPI_SCK }]
create_clock -name {CLK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports { CLK_50 }]
create_clock -name {support_clock} -period 42.000 -waveform { 0.000 21.000 } 


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {SPI_SCK}] -rise_to [get_clocks {SPI_SCK}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {SPI_SCK}] -rise_to [get_clocks {SPI_SCK}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {SPI_SCK}] -fall_to [get_clocks {SPI_SCK}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {SPI_SCK}] -fall_to [get_clocks {SPI_SCK}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {SPI_SCK}] -rise_to [get_clocks {SPI_SCK}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {SPI_SCK}] -rise_to [get_clocks {SPI_SCK}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {SPI_SCK}] -fall_to [get_clocks {SPI_SCK}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {SPI_SCK}] -fall_to [get_clocks {SPI_SCK}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



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
