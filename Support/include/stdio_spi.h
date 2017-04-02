/*
 * stdio_spi.h
 *
 * The header file for the STDIO handler through the SPI connection
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

#ifndef INCLUDE_STDIO_SPI_H_
#define INCLUDE_STDIO_SPI_H_

#define SPI_CHANNEL 0

void stdio_init(void);
void spi_puts( void * string);
void putchar( char );
inline void putchari( char );
char getchar(void);
unsigned char spi_avail(void);
void inbound_flush(void);
void outbound_flush(void);
inline Bool spi_connected(void);

#endif /* INCLUDE_STDIO_SPI_H_ */
