/*
 * main.c
 *
 * Main supervisor code
 * Part of the CPC2 project: http://intelligenttoasters.blog
 * Copyright (C)2017  Intelligent.Toasters@gmail.com
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, you can find a copy here:
 * https://www.gnu.org/licenses/gpl-3.0.en.html
 *
 */

#include "stdio.h"
#include "string.h"
#include "stdint.h"
#include "include.h"
#include "version.h"

#include "../build/rom1.h"

uint32_t dummy;

// Initialize the system
void init()
{
//	char c;
//	uint16_t c2;

	char buffer[512];

	// Hold CPC in reset
	cpcResetHold();

	// Clear out the global variables
	memset( globals(), 0, sizeof( struct global_vars ) );

	// Initialize STDIO
	stdioInit();

	// Start the boot process
	puts("\033[2J\033[H");
	puts("CPC2.0 Boot Log - Supervisor OS, build " __VERSION__); ul();
	console("Starting");

	sprintf(buffer, "Write protect below %04x", IN(0x50)<< 8);
	console( buffer );

	// Wait for SDRAM to be ready
	console( "Waiting for SRAM1+2" );
	while( !sramReady() ) NOP();

	// Initialise the SDC and wait before continuing
	sdcInit(&globals()->sd_buf);

	// Initialise before continuing
	while( globals()->sd_buf.state != IDLE) earlyEvents();

	// Initialise the FATfs layer
	fatInit();
	while( !globals()->fat.ready ) earlyEvents();

	// Initialise the configuration settings
	configInit();

	// Initialize the HDMI adapter
	hdmi_init();

	// Initialise ROMS, copying from storage to SRAM
	romInit();

	// Initialise the FDC controller
	fdcInit();

	// USB PHY Init
	//phy_init();							// TODO: More

	// Initialise the usb interface
	//usbInit();

	// Initialise the keyboard emulator
	key_clear();

	// Initialise the keyboard interface
	kbdInit();

	// Release CPC reset
	cpcResetRelease();

}

void dumpdata(char * buffer)
{
	int cntr, cntr2;

	outboundFlush();

	for( cntr=0; cntr<512; cntr+=16) {
		printf("%04x ", cntr);
		for(cntr2=0; cntr2<16; cntr2++)
			printf("%02x ", buffer[cntr+cntr2]);
		putchar(32);
		for(cntr2=0; cntr2<16; cntr2++)
			printf("%c", ((buffer[cntr+cntr2]>32) && (buffer[cntr+cntr2]<127)) ? buffer[cntr+cntr2] : 32);
		printf("\n");
		outboundFlush();
	}
	printf("\n");
}

// Main function
void main(void)
{
	unsigned char c, buffer[512];
	uint32_t x = 0;
	uint16_t y;
	struct fat_sys_block * b = (struct fat_sys_block *) CB;

	// Run system intitialization
	init();
/*
	while(true) {
		while( USB_SPEED() == USB_SPEED_NC ) NOP();

		switch( USB_SPEED() )
		{
		case USB_SPEED_HIGH: printf("High speed device connected\n"); break;
		case USB_SPEED_LOW: printf("Low speed device connected\n"); break;
		default: break;
		}

		while( USB_SPEED() != USB_SPEED_NC ) NOP();
		printf("USB Disconnect\n");
	}
*/

	//keyCapture();
	while( true )
	{
		// Get next
		while(uartAvail() == 0) processEvents();
		c = getchar();
		if( c == 'M' ) { fdcMount(FDC_A, FDC_BLANK_2S80,"Empty 2S82"); continue; }	// Mount existing disk
		if( c == 'm' ) { fdcMount(FDC_A, 0, NULL); continue; }	// Mount existing disk
		if( c == 'u' ) { fdcUnmount(FDC_A); continue; }
		if( c == '?' ) { console(fdcMounted(FDC_A)?"Mounted":"Unmounted"); continue; }
		if( c == 'c' ) { console(fdcChanged(FDC_A)?"Changed":"Unchanged"); continue; }
		if( c == 'r' ) { cpcReset(); continue; }
		if( c == 'R' ) { __asm__("jp 0"); }
		if( c == 'k' ) { keyCapture(); continue; }
		if( c == 'l' ) {
			x=sdcGetLastBlk();
		}
		if( c == 'n' ) {
			x = globals()->fat.section_ptr[FAT_BLKID_DISKDESC];
			DBG("Repositioned over names, go for read");
		}
		if( c == '0' ) {
			x = globals()->fat.section_ptr[FAT_BLKID_DISKDATA];
			DBG("Repositioned over data, go for read");
		}
		if( c == '1' ) {
			DBG("Starting read %lu",x);
			memset( buffer, 0, 512 );
			if( sdcReadBlock(&globals()->sd_buf, x, buffer) )
			dumpdata(buffer); else {
				DBG("Error %08lx", globals()->sd_buf.last_response);
			}
			memset( buffer, 0xff, 512 ); continue;
		}
		if( c == '-' ) {
			x -= 1;
			DBG("New block ID: %ld",x);
			continue;
		}
		if( c == '+' ) {
			x += 1;
			DBG("New block ID: %ld",x);
			continue;
		}
		if( c == '2' ) {
			DBG("Starting write %lu",x);
			memset( buffer, 0xff, 512 );
			sprintf(buffer, "Hello world");
			sprintf(buffer+(512-11),"end of sec");
			if(sdcWriteBlock(&globals()->sd_buf, x, buffer))
			{
				DBG("Written new sector");
			} else {
				DBG("Error %08lx", globals()->sd_buf.last_response);
			}
			continue;
		}
		if( c == 'T' ) {
			DBG("Testing function - WRITE");
			DBG("Finding free : %d", x = fatFindFree(&globals()->fat, FAT_ROM));
			DBG("Populate :%d", fatSetContent(&globals()->fat,FAT_ROM, x, "Debug ROM" ));
			DBG("Open file %d", fatOpen( &globals()->fat, FAT_ROM, x, FAT_WRITE));
			DBG("Ptr:%08lx, cnt: %u", globals()->fat.open_file_ptr, globals()->fat.open_file_cntr);

			y = 0;
			for( x=0; x<32; x++)
			{
				if( y < sizeof(rom_data) ) memcpy(globals()->fat.buffer, &rom_data[y], 512);
				else memset( globals()->fat.buffer, 255, 512 );
				y += 512;
				fatWriteBlock( &globals()->fat, (char*) globals()->fat.buffer);
			}
			DBG("Done");
			continue;
		}
		if( c == 't' ) {
			DBG("Testing function - READ");
			DBG("Get descr :%d", fatGetDescription(&globals()->fat,FAT_ROM, 0, buffer ));
			DBG("Result: >%s<", buffer);
			CONFIG.roms[33] = (uint16_t) -1;
			CONFIG.roms[63] = ROMMGR_SDC | 0;
			CONFIG_UPDATE;
		}

		if( c == 'X' ) {
			configNew( &globals()->config );
			CONFIG_UPDATE;
			DBG("Reset config");
			continue;
		}

		if( c == 'x' ) {
			configNew( &globals()->config );
			CONFIG.roms[ROM_LOWER] = ROMMGR_ASMI | ROM_6128;
			CONFIG.roms[0] = ROMMGR_ASMI | ROM_BASIC11;
			CONFIG.roms[7] = ROMMGR_ASMI | ROM_AMSDOS;
			CONFIG.roms[6] = ROMMGR_ASMI | ROM_MAXAM;
			CONFIG.roms[5] = ROMMGR_ASMI | ROM_PROTEXT;
			CONFIG.roms[4] = ROMMGR_ASMI | ROM_RODOS;
			CONFIG.roms[3] = ROMMGR_ASMI | ROM_HARVEY;
			CONFIG_UPDATE;
			DBG("Added ROMs to config");
			continue;
		}

		if( c == 'E' ) { fatReformat(&globals()->fat, 0xdeadbeef); continue; }
		// TODO: HUH? Restarts app? A bug in the HDMI driver? or the interrupt processing?
		if( c == 'h' ) {
			hdmi_write(0x96,0);
			DBG("CTS Calculated : %02x %02x %02x INT:%02x\n", hdmi_read(0x04),hdmi_read(0x05),hdmi_read(0x06),hdmi_read(0x96));
			HALT();//while(1) processEvents();
		}
	}

}
