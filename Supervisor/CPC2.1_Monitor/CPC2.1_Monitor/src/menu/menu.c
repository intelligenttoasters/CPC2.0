/*
 * menu.c
 *
 * Created: 26/12/2016 7:44:51 PM
 *  Author: paul
 */ 

#include "main.h"

static Bool option_hold = false;

static const char *codes[] = {
	"\e[2J",
	"\e[%d;%dH",
	"\e[%dm",
	"\e[K",
	"\e[A",
	"\e[B",
	"\e[C",
	"\e[D",
	"\e[s",
	"\e[u"
};

#define MENU_ITEMS 8
static const char *menu_item[] = {
	" 0 - Connect to CPC",
	" 1 - Upload FPGA image to device",
	" 2 - Upload FPGA image to device and connect to monitor port",
	" 3 - Upload FPGA image to flash",
	" 4 - Upload FPGA image to flash and reset supervisor",
	" 5 - Reset supervisor",
	" 6 - Clear FPGA image from flash",
	" 7 - Toggle support CPU reset signal"
};

static const char *messages[] = {
	"CPC2.0 Monitor V0.1.1 - Main Menu",// 0
	"Options: ",						// 1
	"Select: ",							// 2
	"Waiting for program...",			// 3
	"Flash image reset",				// 4
	"Resetting device",					// 5
	"Sure? Y/N",						// 6
	"Connected to device"				// 7
};

void menu()
{
	uint8_t cntr, option = 0;

	while(true)
	{
		// Wait for connection
		while( !isPortOpen()) nop();
		
		// Reset attrs
		ATTR(NORM);
		GRA(CLS);

		// Print the last message
		LOCATE( 1, 20 );
		printf("Last message: \n\r%s\n\rSupport CPU is in %s state", globals.returnMessage, isResetState() ? "reset" : "running");

		// Print the title
		LOCATE( 2, 1 );
		M(0);	// Title

		LOCATE( 5, 3 );
		GRA(SAVE);
		M(1);	// Options
		GRA(REST);
		GRA(DOWN);
		GRA(DOWN);

		for( cntr=0; cntr<MENU_ITEMS; cntr++ )
		{
			GRA(SAVE);
			printf(menu_item[cntr]);
			GRA(REST);
			GRA(DOWN);
		}
		GRA(DOWN);
		GRA(DOWN);
		GRA(DOWN);
		GRA(SAVE);
		GRA(UP);		
		GRA(UP);
		
		M(2);	// Selection prompt

		// Get option (not null!)
		while( 1 ) {
			if (!isPortOpen()) break;
			if( stdio_ready() )
				if( (option = getchar()) != 0 ) {
					if( ( option >= '0' ) && ( option <= '9' ) ) break;
					option = option & 0xDF;	// Make upper case
					if( ( (option & 0xDF) >= 'A' ) && ( (option & 0xDF) <= 'Z' ) ) break;
				}
			process_events();
		}

		if (isPortOpen())
		{
			// Relocate cursor back
			GRA(REST);
			
			switch( option )
			{
				case '0':
					GRA(CLS);
					LOCATE(0,0);
					M(7);	// Waiting
					LOCATE(0,1);
					vterm_init();
					option_hold = true;
					while(option_hold) process_events();
					break;
				case '1':
					M(3);	// Waiting
					pgm_fpga_from_usb(globals.returnMessage);
					delay_ms(500);
					break;
				case '2':
					M(3);	// Waiting
					pgm_fpga_from_usb(globals.returnMessage);
					delay_ms(500);
//					monitor();
					break;
				case '3':
					M(3);	// Waiting
					store_flash_image();
					break;
				case '4':
					M(3);	// Waiting
					store_flash_image();
					M(5);	// Resetting
					delay_s(1);
					return;	// Returning causes a reset
				case '5':
					M(5);	// Resetting
					return;
				case '6':
					M(6);
					if( getchar() != 'Y' ) 
					{
						sprintf(globals.returnMessage,"Aborted erase");
						break;
					}
					// Otherwise
					memset( globals.flash_buffer, 0, SECTOR_SIZE );
					ram_2_memory(LUN_ID_MRAM_MEM, 0, globals.flash_buffer);
					sprintf(globals.returnMessage, messages[4]);	// Reset flash
					break;
				case '7':
					setResetState(!isResetState());
					break;
			}
		}
	}
}

// Flag that holds a menu option running, preventing the menu being displayed over STDOUT data
void finished_option_hold()
{
	option_hold = false;
}

// Called at every opportunity to process stuff that needs processing
void process_events()
{	
	// SPI events
	if( !is_spi_in_use() )
		for( int cntr=0; cntr < SPI_CHANNELS; cntr++ )
			if( !is_spi_in_use() && ( globals.channel_handler_p[cntr] != NULL )) globals.channel_handler_p[cntr]();
}

