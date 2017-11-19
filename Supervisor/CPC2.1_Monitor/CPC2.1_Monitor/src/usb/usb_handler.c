/*
 * CFile1.c
 *
 * Created: 19/11/2016 8:11:29 PM
 *  Author: paul
 */ 

#include "main.h"

// Port 0 state register
volatile enum uint8_t {init,ready,open,closed} port0_state = init;

// Callback variable
//static void (*connect_callback)(U8, U8) = NULL;

// This is called  upon DTR/RTS by the terminal (or on receive in the case of the Windows upload script)
void cdc_connect_event(U8 port, bool state) 
{
	if( port == 0 )
	{
		if( state == true ) 
			port0_state = open;
		else
 			port0_state = closed;
	}
	//if( (*connect_callback != NULL ) ) connect_callback(port, state);
}

// This is typically called by the host PC after enumeration to set the baud rate
void cdc_coding_set(uint8_t port, usb_cdc_line_coding_t * cfg)
{
	if( port == 0 ) {
		// Prevent an open followed by a baud rate set from corrupting the state
		port0_state = (port0_state != open) ? ready : open;
	}
}

// Returns port state
bool isPortOpen(void)
{
	return port0_state == open;
}

void cdc_init()
{
	port0_state = init;
}