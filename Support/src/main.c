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

// Initialize the system
void init()
{
	// Clear out the global variables
	memset( globals(), 0, sizeof( struct global_vars ) );

	// Initialize STDIO
	stdioInit();

	// Start the boot process
	puts("CPC2.0 Boot Log - Supervisor OS, build " __VERSION__); ul();
	console("Starting");

	// Initialise the keyboard emulator
	key_clear();

	// Initialize the HDMI adapter
	hdmi_init();

	// Initialise the usb interface
	kbdInit();
}

// Main function
void main(void)
{
	char c;

	// Run system intitialization
	init();

/*
	for( xx = 0; xx<250; xx++ )
		processEvents();

	// Scan the tape port
	cc = 0; dd = 0;
	while( true )
	{
		// Add the bit
//		dd = (dd << 1) | ( IN(0x40) & 1 );
		cc = (cc<5) ? cc + 1 : 0;	// 0-5
		if( cc == 0 )
		{
//			printf("%c",dd+32);
			printf("%x",(IN(0x40)>>4)&3);
			dd = 0;
		}
	}
*/

//	printf("CTS Calculated : %02x %02x %02x\n", hdmi_read(0x04),hdmi_read(0x05),hdmi_read(0x06));
	// Echo the characters back to the user
	while( true )
	{
		while(uartAvail() == 0) processEvents();
		c = getchar();
		hdmi_write(0x96,0);
		printf("CTS Calculated : %02x %02x %02x INT:%02x\n", hdmi_read(0x04),hdmi_read(0x05),hdmi_read(0x06),hdmi_read(0x96));
		putchar( c );
	}

}
