/*
 * spi.c - SPI Handling of data
 *
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

//
// Record the handler for a particular channel
//
void spiSetHandler(char channel, void (*handler)(unsigned char *, unsigned char))
{
	globals()->channel_handler_p[channel] = handler;
}

//
// This generally only handles inbound data, outbound data is synchronous and waits
//
void spiProcessEvents()
{
	unsigned char channel;
	unsigned char size;
	struct global_vars * glob = globals();
	unsigned char * buffer;

	// SPI events process if not already done
	if( !spiGetInUse() )
	{
		if( !spiGetProcessed() )
		{
			// Calculate the real buffer space
			buffer = spiGetInBuffer() - SPI_BUFFER_OFFSET;

			// Read the data in from the SPI module, fixed size packets
			INI( SPI_DATA, buffer, SPI_BUFFER_OFFSET );			// Read just the header first
			INI( SPI_DATA, buffer + SPI_BUFFER_OFFSET, 128 );	// Then read 128 bytes of data
			INI( SPI_DATA, buffer + SPI_BUFFER_OFFSET + 128, 128 );	// Then read 128 bytes of data
			// Need two blocks because the maximum we can transfer is 255 bytes

			// Process the data
			channel = buffer[0];
			size = buffer[1];

			// Is there a some data and is there a channel handler for this data
			if(( size > 0 ) & ( channel < SPI_CHANNELS ))
				if( globals()->channel_handler_p[channel] != NULL ) globals()->channel_handler_p[channel](buffer + SPI_BUFFER_OFFSET, size);

			// Mark done
			spiSetProcessed(true);

		} else {
			// Master driven process - see what it wants :)
			if( spiMasterReady() & spiLock(0) ) spiExchange(0xff,0);	// Send NOP packet
		}
	}
}

//
// Is the SPI in use
//
inline Bool spiGetInUse()
{
	return globals()->spi_in_use;
}

//
// Has the SPI data been processed yet?
//
inline Bool spiGetProcessed()
{
	return globals()->spi_processed_n == 0;
}

//
// Set the SPI in use
//
void spiSetInUse(unsigned char state)
{
	globals()->spi_in_use = (state == false) ? 0 : 1;
}

//
// Set the SPI data is processed
//
void spiSetProcessed(unsigned char state)
{
	globals()->spi_processed_n = (state == false) ? 1 : 0;
}

//
// Lock the SPI for exclusive use (may be filtered on channel in the future and could reject)
//
unsigned char spiLock(unsigned char channel)
{
	struct global_vars * g = globals();

	// If it's in use then tell the caller
	if( g->spi_in_use ) return false;

	// Record the channel that's locked it
	g->spi_channel = channel;

	// Set it to be in use
	spiSetInUse(true);
	spiSetProcessed(false);

	return true;
}

//
// Get the buffer space, so we don't have to copy data
//
void * spiGetOutBuffer(void)
{
	// Skip over the channel # plus transmit size
	return globals()->outbound_comm_buffer + SPI_BUFFER_OFFSET;
}

//
// Get the buffer space, so we don't have to copy data
//
void * spiGetInBuffer(void)
{
	// Skip over the channel # plus transmit size
	return globals()->inbound_comm_buffer + SPI_BUFFER_OFFSET;
}

//
// Initiate an exchange of data with the master by flagging we're ready
//
void spiExchange( unsigned char channel, unsigned char size )
{
	// For efficiency only get globals once
	struct global_vars * g = globals();

	// Record the channel
	g->outbound_comm_buffer[0] = channel;
	g->outbound_comm_buffer[1] = size;

	// Make sure we flush the inbound / outbound data first
	spiFlush();

	// Send the data to the SPI module
	OUTI( SPI_DATA, g->outbound_comm_buffer, SPI_BUFFER_OFFSET);		// Send the header separate
	OUTI( SPI_DATA + SPI_BUFFER_OFFSET, g->outbound_comm_buffer + SPI_BUFFER_OFFSET, 128);
	OUTI( SPI_DATA + SPI_BUFFER_OFFSET + 128, g->outbound_comm_buffer + SPI_BUFFER_OFFSET + 128, 128);
	// Need two blocks because the maximum we can transfer is 255 bytes

	// Flag we're ready to go!
	spiReady();

}
