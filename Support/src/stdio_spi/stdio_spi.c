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
static unsigned char stdio_inbound_buffer[8];
static unsigned char stdio_outbound_buffer[_STD_WIDTH_ + 2];
static unsigned char inbuffer_entries, outbuffer_entries;
static Bool stdio_connected = false;

//
// Stores incoming keyboard data in small buffer - overflow is lost
//
void stdio_channel_handler(unsigned char *buffer, unsigned char size)
{
	unsigned char sz;

	// Flow control for handler
	if( size == 1 )
	{
		// Did the start character get sent, if so note the connection state
		if ( buffer[0] == SPI_START )
		{
			stdio_connected = true;
			inbuffer_entries = 0;
			outbuffer_entries = 0;
			return;
		}
		// Did the stop character get sent, if so note the connection state
		if ( buffer[0] == SPI_END )
		{
			stdio_connected = false;
			inbuffer_entries = 0;
			outbuffer_entries = 0;
			return;
		}
	}

	// Ignore overflow
	if( inbuffer_entries == 8 ) return;

	// Calculate size of incoming data
	sz = min(size, 8 - inbuffer_entries);
	// Store incoming data
	memcpy( stdio_inbound_buffer + inbuffer_entries, buffer, sz);

	// Increase the counter by the number of received characters
	inbuffer_entries += sz;

	// Defensive programming
	if( inbuffer_entries > 8 ) inbuffer_entries = 8;
}
//
// Initialise the SPI STDIO module
//
void stdio_init()
{
	// Set up the STDIO handler
	spiSetHandler(0, &stdio_channel_handler);
	inbuffer_entries = 0;
	outbuffer_entries = 0;
	spiSetInUse(false);
	spiSetProcessed(true);
	stdio_connected = false;
}
//
// Print a string in a single transaction - very performant
//
void spi_puts( void * string )
{

	// Get the size of the string to send
	int size = strlen( string );

	// Lock for channel 0 use
	while(!spiLock(0)) process_events();

	// Copy the data to the outbound buffer
	memcpy( spiGetOutBuffer(), string, size );	// Note it doesn't copy the terminating zero

	// Send it, channel 0, size bytes
	spiExchange( SPI_CHANNEL, size );

}

//
// Putchar - immediate - needed because we buffer usual putchar for efficiency
//
inline void putchari( char data ) { putchar(data); outbound_flush(); }

//
// Send a single character to the STDIO
//
void putchar( char data )
{
	// Ignore if no connection
	if( !stdio_connected ) return;

	// Store the data
	stdio_outbound_buffer[outbuffer_entries++] = data;

	// Compare to LF and add CR if needed
	if( data == _LF_ ) stdio_outbound_buffer[outbuffer_entries++] = _CR_;

	// If sending line feed or buffer is full then send
	if( ( data == _LF_ ) || ( outbuffer_entries >= _STD_WIDTH_ ) ) outbound_flush();
}
//
// FLushes the buffer out to output
//
void outbound_flush()
{
	// Add the null terminator
	stdio_outbound_buffer[outbuffer_entries] = 0;

	// Send the data out
	spi_puts(stdio_outbound_buffer);

	// Reset the buffer
	outbuffer_entries = 0;
}
//
// How many bytes are available in the input buffer?
//
unsigned char spi_avail()
{
	return inbuffer_entries;
}
//
// Get a single character from the input buffer
//
char getchar()
{
	// Get the first character from the buffer
	char r = stdio_inbound_buffer[0];

	// Return 0 if no entries
	if( inbuffer_entries == 0 ) return 0;

	// If there is more than one character in the inbound buffer, then shift everything up
	if( inbuffer_entries > 1 )
		memcpy( stdio_inbound_buffer, stdio_inbound_buffer + 1, inbuffer_entries);

	// Reduce the count of characters in the buffer
	inbuffer_entries--;

	// Return the received character
	return r;
}

//
// Flush the inbound buffer discarding the input
//
void inbound_flush()
{
	inbuffer_entries = 0;
}

//
// Is the STDIO console connected?
//
inline Bool spi_connected()
{
	return stdio_connected;
}
