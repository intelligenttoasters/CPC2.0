/*
 * vterm.c
 *
 * Created: 4/03/2017 9:45:04 PM
 *  Author: paul
 */ 

#include "main.h"
//#include "pdc.h"

static char buffer_out[512];
static char buffer_in[512];

void process_buffer(void);

void vterm_init()
{
	// Ensure the support CPU is running
	setResetState( false );

	// Register the channel handler
	set_channel_handler(0, &terminal_handler );	

	// Open the port
	buffer_out[0] = 0;		// Channel 1
	buffer_out[1] = 1;		// STDIO data - 1 byte
	buffer_out[2] = 15;		// Open port
	process_buffer();
}

void vterm_end()
{
	// Close the port
	buffer_out[0] = 0;		// Channel 1
	buffer_out[1] = 1;		// STDIO data - 1 byte
	buffer_out[2] = 17;		// Close port
	process_buffer();

	while( !is_dma_done() ) nop();
		
	// DeRegister the channel handler
	set_channel_handler(0, NULL );
	
	// Tell the menu that we're done
	finished_option_hold();
}

static Bool terminal_processed = true;
void terminal_handler()
{
	char typed = 0;
	
	// If port aborted
	if (!isPortOpen()) {
		vterm_end();
		return;
	}

	// Process last action
	if( is_dma_done() && !terminal_processed )
	{	
		master_ready(false);
		if( buffer_in[0] == 0 )
		{
			int sz = buffer_in[1];
			if( sz > 0 ) for( int cntr=0; cntr<sz; cntr++) putchar( buffer_in[2+cntr] );
		}
		terminal_processed = true;
	}
	
	// Check if there is anything typed to send
	if( stdio_ready() )
	{
		// Get the character to send
		typed = getchar();

		// If the ESC key is pressed, this escapes back to the menu
		if( typed == 27 )
		{
			vterm_end();
			return;
		}
		
		buffer_out[0] = 0;		// Channel 1
		buffer_out[1] = 1;		// STDIO data - 1 byte
		buffer_out[2] = typed;	// Data to send

	} else {					// Nothing to send
		buffer_out[0] = 0xff;	// Channel NOP
		buffer_out[1] = 0x0;	// Zero bytes
	}
	
	// Handle the buffer just populated
	process_buffer();
}

void process_buffer(void)
{
	// If we're not sending to NOP channel or the slave is requesting a transfer then do it
	if( ( buffer_out[0] != 0xff ) || slave_ready() ) {
		terminal_processed = false;
		
		master_ready(true);										// Master is ready to send
		spi_raw_exchange( buffer_out, buffer_in, 258 );		// Raw exchange
	}
}
