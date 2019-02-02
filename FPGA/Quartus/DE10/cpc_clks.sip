set_global_assignment -entity "cpc_clks" -library "lib_cpc_clks" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "cpc_clks" -library "lib_cpc_clks" -name IP_TOOL_VERSION "14.0"
set_global_assignment -entity "cpc_clks" -library "lib_cpc_clks" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_cpc_clks" -name SPD_FILE [file join $::quartus(sip_path) "cpc_clks.spd"]

set_global_assignment -library "lib_cpc_clks" -name MISC_FILE [file join $::quartus(sip_path) "cpc_clks_sim/cpc_clks.vo"]
