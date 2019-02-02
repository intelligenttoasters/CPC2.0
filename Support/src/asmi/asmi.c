/*
 * asmi.c - ASMI Interface - stored disk and ROM images
 *
 * Part of the CPC2 project: http://intelligenttoasters.blog
 * Copyright (C)2018  Intelligent.Toasters@gmail.com
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
#include "stdio.h"

void asmiAddress(uint32_t address)
{
	OUT( ASMI_ADDRESS0, (address >> 0) & 0xff);
	OUT( ASMI_ADDRESS1, (address >> 8) & 0xff);
	OUT( ASMI_ADDRESS2, (address >> 16) & 0xff);
	OUT( ASMI_ADDRESS3, (address >> 24) & 0xff);
}

unsigned char asmiRead()
{
	OUT( ASMI_CTL, 0 );					// Trigger - data irrelevant
	while( !asmiReady() ) NOP();
	return IN(ASMI_DATA);
}

unsigned char asmiStatus(void)
{
	return IN(ASMI_STATUS);
}

void asmiCopyROM(unsigned char rom_id, unsigned char rom_loc)
{
	unsigned char c;
	uint16_t c2;
	char * buffer = globals()->console_buffer;
	uint32_t asmiROMaddr;

	// Check for OOB input
	if(rom_id > ROM_COUNT ) {
		DBG("Invalid ROM ID specified - not available in flash");
		return;
	}
	if( rom_loc > 64 ) {
		DBG("Invalid ROM location specified only 0-63 + ROM_LOWER is valid");
		return;
	}

	// Calculate the ROM address in the flash
	asmiROMaddr = (ROM_BASE + ROM_LOC(rom_id));

	// Diag message
	sprintf(globals()->console_buffer,"Copying ROM from 0x%08lx to ROM %d", asmiROMaddr, rom_loc);
	console(globals()->console_buffer);

	// Set the ASMI ROM address
	asmiAddress(asmiROMaddr);
	DBG("Reading ROM at 0x%02x%02x%02x%02x", IN(ASMI_ADDRESS3),IN(ASMI_ADDRESS2),IN(ASMI_ADDRESS1),IN(ASMI_ADDRESS0));

	// Set the ROM location
	romSetWriteAddress(rom_loc);

	// Copy the data from ASMI to SRAM in 2K chunks
	for( c = 0; c<8; c++ )
	{
		for( c2=0;c2<2048;c2++) buffer[c2] = asmiRead();
		romSendData(buffer, 2048);
	}
}
