/*
 * include.h
 *
 * Include to include other includes to make a standard set
 * 		of vars and constructs available
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

#ifndef INCLUDE_INCLUDE_H_
#define INCLUDE_INCLUDE_H_

// System definitions
#define SPI_CHANNELS 16

// Some type definitions
#define Bool unsigned char
#define true 1
#define false 0

// IO and special routines
void OUT(char, char);
unsigned char IN(char);

void OUTI( char port, char * buffer, unsigned char size);
void INI( char port, char * buffer, unsigned char size);

inline void NOP() { __asm__("nop"); }
inline void HALT() { __asm__("halt"); }

struct global_vars {
	void (*channel_handler_p[SPI_CHANNELS])(unsigned char *, unsigned char);
	volatile unsigned char spi_in_use;
	volatile unsigned char spi_processed_n;
	unsigned char spi_channel;
	char inbound_comm_buffer[512];
	char outbound_comm_buffer[512];
};

#include "spi.h"
#include "library.h"
#include "stdio_spi.h"

#endif /* INCLUDE_INCLUDE_H_ */
