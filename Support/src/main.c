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
	stdio_init();
}

// Main function
void main(void)
{
	// Run system intitialization
	init();

	// Wait for the console to get connected
	// Normally this won't happen as the system needs to run even without a console
	while(!spi_connected()) process_events();

	// Start the boot process
	puts("\033[2J\033[HCPC2.0 Boot Log - Supervisor OS, build " __VERSION__); ul();
	console("Bringing up video controller");

	// Echo the characters back to the user
	while( true )
	{
		while(spi_avail() == 0) process_events();
		putchari( getchar() );
	}
}
