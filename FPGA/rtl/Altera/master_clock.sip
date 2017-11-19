set_global_assignment -entity "master_clock" -library "lib_master_clock" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "master_clock" -library "lib_master_clock" -name IP_TOOL_VERSION "14.0"
set_global_assignment -entity "master_clock" -library "lib_master_clock" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_master_clock" -name SPD_FILE [file join $::quartus(sip_path) "master_clock.spd"]

set_global_assignment -library "lib_master_clock" -name MISC_FILE [file join $::quartus(sip_path) "master_clock_sim/master_clock.vo"]
