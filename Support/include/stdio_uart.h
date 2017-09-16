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

#ifndef INCLUDE_STDIO_UART_H_
#define INCLUDE_STDIO_UART_H_

#define UART_SR 			0x01
#define UART_IN_EMPTY 		(1<<0)
#define UART_IN_FULL 		(1<<1)
#define UART_OUT_EMPTY 		(1<<2)
#define UART_OUT_FULL 		(1<<3)

// Control register (WRITE)
#define UART_CR				0x01
#define UART_FLUSH			(1<<7)

// Start of connection / End of Transmission for the STDIO
#define UART_START 			15	// CTRL-O
#define UART_END			17	// CTRL-Q

// Data register (Read/Write)
#define UART_DATA			0x00

inline void uartWrite(char data) {
	OUT( UART_DATA, data );
}

inline char uartRead() {
	return IN( UART_DATA );
}

inline void uartFlush(void)
{
	OUT(UART_CR, UART_FLUSH);	// Flush the inbound / outbound data
}

inline volatile unsigned char spiStatus(void)
{
	return IN( UART_SR );
}

void stdioInit(void);
//void spi_puts( void * string);
void putchar( char );
char getchar(void);
unsigned char uartAvail(void);
void inboundFlush(void);
void uartProcessEvents(void);

#endif /* INCLUDE_STDIO_UART_H_ */
