/*
 * spi.h
 *
 * SPI headers and key defintions
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

#ifndef INCLUDE_SPI_H_
#define INCLUDE_SPI_H_

#define SPI_BUFFER_OFFSET 2

// How many numbered channels are there
// Status register bit positions (READ)
#define SPI_SR 			0x01
#define IN_EMPTY 		(1<<0)
#define IN_FULL 		(1<<1)
#define OUT_EMPTY 		(1<<2)
#define OUT_FULL 		(1<<3)
#define MASTER_RDY 		(1<<4)
#define CHIP_SEL		(1<<7)

// Control register (WRITE)
#define SPI_CR			0x01
#define SLAVE_RDY		(1<<0)
#define FLUSH			(1<<7)

// Start of connection / End of Transmission for the STDIO
#define SPI_START 	15	// CTRL-O
#define SPI_END		17	// CTRL-Q

// Data register (Read/Write)
#define SPI_DATA		0x00

inline void spiWrite(char data) {
	OUT( SPI_DATA, data );
}

inline char spiRead() {
	return IN( SPI_DATA );
}

inline void spiReady(void)
{
	OUT(SPI_CR, SLAVE_RDY);	// Indicate ready
}

inline void spiFlush(void)
{
	OUT(SPI_CR, FLUSH);	// Flush the inbound / outbound data
}

inline volatile unsigned char spiStatus(void)
{
	return IN( SPI_SR );
}

inline volatile unsigned char spiMasterReady(void)
{
	return IN(SPI_SR) & MASTER_RDY ? 0 : 1;
}

inline volatile unsigned char spiEmptyIn(void)
{
	return IN(SPI_SR) & IN_EMPTY ? 1 : 0;
}

inline volatile unsigned char spiEmptyOut(void)
{
	return IN(SPI_SR) & OUT_EMPTY ? 1 : 0;
}

inline Bool spiGetInUse(void);
inline Bool spiGetProcessed(void);
void spiSetInUse(unsigned char state);
void spiSetProcessed(unsigned char state);
void spiSetHandler(char channel, void (*handler)(unsigned char *, unsigned char));
void spiProcessEvents(void);
unsigned char spiLock(unsigned char);
void * spiGetOutBuffer(void);
void * spiGetInBuffer(void);
void spiExchange( unsigned char channel, unsigned char size );

#endif /* INCLUDE_SPI_H_ */
