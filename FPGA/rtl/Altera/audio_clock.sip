set_global_assignment -entity "audio_clock" -library "lib_audio_clock" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "audio_clock" -library "lib_audio_clock" -name IP_TOOL_VERSION "14.0"
set_global_assignment -entity "audio_clock" -library "lib_audio_clock" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_audio_clock" -name SPD_FILE [file join $::quartus(sip_path) "audio_clock.spd"]

set_global_assignment -library "lib_audio_clock" -name MISC_FILE [file join $::quartus(sip_path) "audio_clock_sim/audio_clock.vo"]
