/*
 * stdio_spi.c
 *
 * STDIO support routines to interface to the SPI module
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

#include "include.h"
#include "string.h"

// Local static variables
static unsigned char stdio_inbound_buffer[128];
static unsigned char inbuffer_entries;

//
// Stores incoming keyboard data in small buffer - overflow is lost
//
void uartProcessEvents()
{
	// Repeat until no more characters
	while (1) {
		// Is there any more received data?
		if( IN(UART_SR) & UART_IN_EMPTY ) return;

		if( inbuffer_entries <= 127 )
			// Store data
			stdio_inbound_buffer[inbuffer_entries++] = IN(UART_DATA);
		else
			// Discard in data
			IN(UART_DATA);
	};
}
//
// Initialise the SPI STDIO module
//
void stdioInit()
{
	inboundFlush();
}

//
// Send a single character to the STDIO
//
int putchar( int data )
{
	while( IN(UART_SR) & UART_OUT_FULL);	// Wait if buffer full
	uartWrite( data );
	// Translate LF to CR+LF
	if( data == 10 ) putchar( 13 );
	return 0;
}
//
// How many bytes are available in the input buffer?
//
unsigned char uartAvail()
{
	return inbuffer_entries;
}
//
// Get a single character from the input buffer
//
int getchar()
{
	// Get the first character from the buffer
	char r = stdio_inbound_buffer[0];

	// Return 0 if no entries
	if( inbuffer_entries == 0 ) return 0;

	// If there is more than one character in the inbound buffer, then shift everything up
	if( inbuffer_entries > 1 )
		memcpy( stdio_inbound_buffer, stdio_inbound_buffer + 1, 7 /*inbuffer_entries*/);

	// Reduce the count of characters in the buffer
	inbuffer_entries--;

	// Return the received character
	return r;
}

//
// Flush the inbound buffer discarding the input
//
void inboundFlush()
{
	uartFlush();
	inbuffer_entries = 0;
}

void outboundFlush()
{
	while( ! (IN(UART_SR) & UART_OUT_EMPTY)) processEvents();	// Wait if buffer not empty
}
