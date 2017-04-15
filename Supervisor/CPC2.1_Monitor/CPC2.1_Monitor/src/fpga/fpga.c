/*
 * fpga.c
 *
 * Created: 19/11/2016 3:45:42 PM
 *  Author: paul
 *    Desc: This library will program the FPGA from bitstreams passed to it either via STDIO(USB) or via a data request callback
 */ 

#include "main.h"
#include "delay.h"
#define START_PAGE 0

bool toggle_nconfig(void)
{
	ioport_set_pin_level(NCONFIG, false);
	ioport_set_pin_level(NCONFIG, true);
	return ioport_get_pin_level(NSTATUS);
}

static inline void dclk(unsigned char data) // Want this to be inline
{
	ioport_set_port_level(FPGA_PORT, CONFIG_DATA_MASK, (data << 18) );
	// Send clock high then low
	ioport_set_pin_level(DCLK, true); 
	ioport_set_pin_level(DCLK, false);
	// Send again, because we expect a compressed bitstream, which had a dclk-to-data = 2
	ioport_set_pin_level(DCLK, true); 
	ioport_set_pin_level(DCLK, false);
}

void init_fpga_ports(void)
{
	// Set the initial conditions
	dclk(0);
	
	// Hold nConfig low and keep it there, a reboot in the controller should reboot the FPGA
	ioport_set_pin_level(NCONFIG, false);

	// Set the pull ups
	ioport_set_pin_mode(NSTATUS, IOPORT_MODE_PULLUP);
	ioport_set_pin_mode(CONF_DONE, IOPORT_MODE_PULLUP);

	// Set the pin directions
	ioport_set_pin_dir(DCLK, IOPORT_DIR_OUTPUT);
	ioport_set_pin_dir(CONF_DONE, IOPORT_DIR_INPUT);
	ioport_set_port_dir(FPGA_PORT, CONFIG_DATA_MASK, IOPORT_DIR_OUTPUT);
	ioport_set_pin_dir(NSTATUS, IOPORT_DIR_INPUT);
	ioport_set_pin_dir(NCONFIG, IOPORT_DIR_OUTPUT);
}

void pgm_fpga_from_usb(char *status_msg)
{
	U8 *buffer;
	int32_t result;
	U32 total = 0;
	bool nstatus;
	
	// Clear the message buffer
	memset( status_msg, 0, 40 );
	
	// Make sure FPGA ports are right
	init_fpga_ports();
	
	// Reset FPGA
	reset_fpga();

	// Read some data until an error or done
	while( ( result = receive(&buffer, status_msg) ) > 0 )
	{
		// Accumulate the total for reporting
		total += result;
		
		// Transmit data to FPGA
		for( int cntr=0; cntr<result; cntr++ )
			dclk(buffer[cntr]);	// Transmit the data
	}
	
	// Spec requires two additional DCLK after config sent
	dclk(0); dclk(0);
	
	// Check if there was an error in the USB transmission
	if( result < 0 )
		sprintf(status_msg,"Error receiving file after %ld bytes",total);
	else {
		// If not, then check the config done pin is released
		// Check the config done pin
		if(ioport_get_pin_level(CONF_DONE) == false)
		{
			nstatus = ioport_get_pin_level(NSTATUS);
			sprintf(status_msg,"Failed to configure after receiving %ld bytes, status=%d",total,nstatus);
		}
		else
		// Show what's received
			sprintf(status_msg,"Received %ld bytes, and CONF_DONE released",total);
	}
	
	// Switch back to SPI runtime
	spi_runtime();
}

void reset_fpga(void)
{
	// Minimum nConfig pulse width is 2uS
	ioport_set_pin_level(NCONFIG, false);
	delay_us(2);
	ioport_set_pin_level(NCONFIG, true);
	
	// Wait for nSTATUS to go high
	while( ( ioport_get_pin_level(NSTATUS) ) == 0 ) nop();
	
	// The specification calls for a 2uS delay after nStatus goes high
	delay_us(2);	
}
//__attribute__((optimize(0)))
void store_flash_image(void) 
{
	U8 buffer[1<<LOG2_PAGE_SIZE], *ptr, *ptr2;
	U32 total = 0, thispage = 0, result;	
	U32 page = START_PAGE;
	
	while(1)
	{
		// Point to buffer
		ptr = buffer; 
		ptr2 = ptr;
		
		// How many bytes this page
		thispage = 0;
		
		// Read some data until an error or done
		while( ( result = receive(&ptr, globals.returnMessage) ) > 0 )
		{
			// Accumulate the total for reporting
			total += result;
			thispage += result;
			
			// Copy data from ptr into buffer
			memcpy( ptr2, ptr, result );
			
			// Move pointer forward
			ptr2 += result;
			
			if( (thispage == PAGE_SIZE) )
			{
				if( ram_2_memory(LUN_ID_FLASH_MEM, page++, buffer) != CTRL_GOOD)
				{
					while(1);
				}
				ptr = buffer;
				ptr2 = ptr;
				thispage = 0;
			}
			
		}
		if( result == 0 ) 
		{
			// Store last page
			if( ram_2_memory(LUN_ID_FLASH_MEM, page++, buffer) != CTRL_GOOD)
			{
				printf("Error!");
				while(1);
			}
			break;		
		}
	}

	// Store total in MRAM
	memset( buffer, 0, SECTOR_SIZE );
	memcpy( buffer, &total, sizeof( total ) );
	ram_2_memory(LUN_ID_MRAM_MEM, 0, &buffer);
};

void load_flash_image(void)
{
	long total, size, write_size;
	U32 page = START_PAGE;
	
	// Get flash image size
	memory_2_ram(LUN_ID_MRAM_MEM, 0, globals.flash_buffer);
	memcpy( &size, globals.flash_buffer, sizeof( size ) );

	// No image is stored
	if( size == 0 ) return;
	
	// Remember total for summary
	total = size;

	// Reset FPGA
	reset_fpga();

	while( size > 0 )
	{
		// Read first page
		if( memory_2_ram(LUN_ID_FLASH_MEM, page++, globals.flash_buffer) != CTRL_GOOD )
		{
			while(1) nop();
		}

		// Calculate the final size, either page size or remaining bytes
		write_size = min(PAGE_SIZE, size);

		// Transmit data to FPGA
		for( int cntr=0; cntr<write_size; cntr++ )
			dclk(globals.flash_buffer[cntr]);	// Transmit the data

		// Will be negative or zero if done
		size -= PAGE_SIZE;
	}
	
	// Spec requires two additional DCLK after config sent
	dclk(0); dclk(0);

	// If not, then check the config done pin is released
	// Check the config done pin
	if(ioport_get_pin_level(CONF_DONE) == false)
	{
		sprintf(globals.returnMessage,"Failed to configure after loading %ld bytes from flash, status=%d",total,ioport_get_pin_level(NSTATUS));
	}
	else
	// Show what's received
	sprintf(globals.returnMessage,"Loaded %ld bytes from flash, and CONF_DONE released",total);
}