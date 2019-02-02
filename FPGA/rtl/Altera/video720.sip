set_global_assignment -entity "video720" -library "lib_video720" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "video720" -library "lib_video720" -name IP_TOOL_VERSION "14.0"
set_global_assignment -entity "video720" -library "lib_video720" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_video720" -name SPD_FILE [file join $::quartus(sip_path) "video720.spd"]

set_global_assignment -library "lib_video720" -name MISC_FILE [file join $::quartus(sip_path) "video720_sim/video720.vo"]
