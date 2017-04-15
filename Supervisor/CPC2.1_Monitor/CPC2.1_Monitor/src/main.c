/**
 * main.c
 *
 * Main boot routine
 *
 */
#define GLOBAL_SET_STRUCT	// Sets the global variables here

#include <asf.h>
#include "main.h"

// External functions
//void process_ui(void);

void globals_init()
{
	for( int cntr=0; cntr<SPI_CHANNELS; cntr++ )
		globals.channel_handler_p[cntr] = NULL;
}

int main (void)
{
	while( true ) 
	{
		// Set up global variables
		globals_init();

		// Set up the board
		board_init();

		// Show the menu
		menu();
		
		// Disable the USB
		udc_stop();
		reset_fpga();
	}
}

