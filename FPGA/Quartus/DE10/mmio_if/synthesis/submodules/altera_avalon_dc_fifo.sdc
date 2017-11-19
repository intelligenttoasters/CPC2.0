# $File: //acds/rel/14.0/ip/sopc/components/altera_avalon_dc_fifo/altera_avalon_dc_fifo.sdc $
# $Revision: #1 $
# $Date: 2014/02/16 $
# $Author: swbranch $
#-------------------------------------------------------------------------------
# TimeQuest constraints to cut all false timing paths across asynchronous 
# clock domains. The paths are from the Gray Code read and write pointers to
# their respective synchronizer banks.

set_false_path -from [get_registers {*|in_wr_ptr_gray[*]}] -to [get_registers {*|altera_dcfifo_synchronizer_bundle:write_crosser|altera_std_synchronizer:sync[*].u|din_s1}]

set_false_path -from [get_registers {*|out_rd_ptr_gray[*]}] -to [get_registers {*|altera_dcfifo_synchronizer_bundle:read_crosser|altera_std_synchronizer:sync[*].u|din_s1}]

# add in false path for simple dual clock memory inference

set mem_regs [get_registers -nowarn *|altera_avalon_dc_fifo:*|mem*];
if {![llength [query_collection -report -all $mem_regs]] > 0} {
	set mem_regs [get_registers -nowarn altera_avalon_dc_fifo:*|mem*];
}
set internal_out_payload_regs [get_registers -nowarn *|altera_avalon_dc_fifo:*|internal_out_payload*];
if {![llength [query_collection -report -all $internal_out_payload_regs]] > 0} {
	set internal_out_payload_regs [get_registers -nowarn altera_avalon_dc_fifo:*|internal_out_payload*];
}
if {[llength [query_collection -report -all $internal_out_payload_regs]] > 0 && [llength [query_collection -report -all $mem_regs]] > 0} {
	set_false_path -from $mem_regs -to $internal_out_payload_regs
}
