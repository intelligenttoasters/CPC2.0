/*
 * rommgr.c
 *
 * ROM Manager manages ROMS!
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

// Load initial ROMs to SDRAM
void romInit()
{
	unsigned char cntr;
	uint16_t assignment, id;

	// Clear all ROMs
	romClear(0xff);

	// Ensure the arbiter isn't frozen for both memories
	OUT( ROMMGR_CTL, ROMMGR_RESUME );
	OUT( ROMMGR_CTL + ROMMGR_INSTANCE_SPAN, ROMMGR_RESUME );

	// Copy the configured ROMs to SRAM
	console("Setting CPC personality");

	// Copy all ROMs into memory from ASMI or SDC/MMC
	for( cntr=0; cntr<=ROM_LOWER; cntr++ )
	{
		if( (assignment = CONFIG.roms[cntr]) != (uint16_t) -1 )
		{
			id = assignment & ~ROMMGR_SDC;
			if( assignment & ROMMGR_SDC )
				fatCopyROM(&globals()->fat, id, cntr);
			else
				asmiCopyROM(id, cntr);
		}
	}

}

// Indicate ROM is populated, 0-63 or 255 for all
void romClear(unsigned char rom)
{
	if( rom == 0xff ) OUT( ROMMGR_FLAGS, ROMMGR_ROMCLR );
	else OUT( ROMMGR_FLAGS, ROMMGR_ROMNONE | (rom&0x3f) );
}

// Set the DMA pointers to the ROM address, parameter is ROM number
void romSetWriteAddress(unsigned char rom)
{
	uint16_t calcAddr;

	// Mask ROM so that it's sane
	if( rom != ROM_LOWER ) rom = rom & ROMMGR_ROMMASK;

	// Calculate the top two bytes of the SDRAM offset
	calcAddr = (ROMMGR_ROMCONSTANT | rom)<<6;

	// Display ROM address
	if( rom != ROM_LOWER )
		sprintf(CB,"Storing ROM %d at %04x00", rom, calcAddr);
	else	// TODO: Change
		sprintf(CB,"Storing ROM %d at %04x00", rom, calcAddr);
	console(CB);

	// Set the address to the buffer pointer
	OUT( ROMMGR_ADDR0, 0x00 );	// Address of ROM 0 0x400000
	OUT( ROMMGR_ADDR1, calcAddr & 0xff );
	OUT( ROMMGR_ADDR2, (calcAddr >> 8) );
	OUT( ROMMGR_ADDR3, 0 );

	// Indicate ROM is populated
	if( rom != ROM_LOWER ) OUT( ROMMGR_FLAGS, ROMMGR_ROMPOP | rom );
}

// Post ROM data to the SDRAM, requires romSetWriteAddress to be run first
void romSendData( char * buffer, uint16_t size)
{
	// Control the bus
	OUT( ROMMGR_CTL, ROMMGR_PAUSE );
	// Send the ROM to the memory
	OUTIe( ROMMGR_DATA, buffer, size );
	// Resume the bus
	OUT( ROMMGR_CTL, ROMMGR_RESUME );
}

// Put data to SRAM
void sramPut( uint8_t instance, uint32_t address, void * buffer, uint16_t size)
{
	uint8_t offs =  (ROMMGR_INSTANCE_SPAN * instance);

	if( instance >= ROMMGR_MAX_INSTANCES ) {
		DBG("Invalid memory instance");
		return;
	}

#ifdef DEBUGx
	if( address > 0x800000 ) DBG("Invalid RAM address %08lx",address);
	DBG("sramPut @ 0x%08lx",address);
#endif

	// Store the address
	OUT( ROMMGR_ADDR0 + offs, address & 0xff );
	OUT( ROMMGR_ADDR1 + offs, (address >> 8)&0xff );
	OUT( ROMMGR_ADDR2 + offs, (address >> 16)&0xff );
	OUT( ROMMGR_ADDR3 + offs, (address >> 24)&0xff );

	// Pause CPC to save generic memory
	OUT( ROMMGR_CTL + offs, ROMMGR_PAUSE );
	// Wait for ACK
	if( !cpcInReset() || (instance != ROMMGR_INST_CPC))
		while((IN( ROMMGR_CTL + offs ) & ROMMGR_PAUSE) == 0);

	// Send the ROM to the memory
	OUTIe( ROMMGR_DATA + offs, buffer, size );
	// Resume the CPC
	OUT( ROMMGR_CTL + offs, ROMMGR_RESUME );
	// Wait for ACK to clear
	if( !cpcInReset() || (instance != ROMMGR_INST_CPC))
		while((IN( ROMMGR_CTL + offs ) & ROMMGR_PAUSE) != 0);

}

// Get data from SRAM
void sramGet( uint8_t instance, uint32_t address, void * buffer, uint16_t size)
{
	uint8_t offs =  (ROMMGR_INSTANCE_SPAN * instance);

	if( instance >= ROMMGR_MAX_INSTANCES ) {
		DBG("Invalid memory instance");
		return;
	}

#ifdef DEBUGx
	if( address > 0x800000 ) DBG("Invalid RAM address %08lx",address);
	DBG("sramGet @ 0x%08lx",address);
#endif

	// Store the address
	OUT( ROMMGR_ADDR0 + offs, address & 0xff );
	OUT( ROMMGR_ADDR1 + offs, (address >> 8)&0xff );
	OUT( ROMMGR_ADDR2 + offs, (address >> 16)&0xff );
	OUT( ROMMGR_ADDR3 + offs, (address >> 24)&0xff );

	// Pause CPC to save generic memory
	OUT( ROMMGR_CTL + offs, ROMMGR_PAUSE );
	// Wait for ACK if not in reset
	if( !cpcInReset() || (instance != ROMMGR_INST_CPC))
		while((IN( ROMMGR_CTL + offs ) & ROMMGR_PAUSE) == 0);
	// Send the ROM to the memory
	INIe( ROMMGR_DATA + offs, buffer, size );
	// Resume the CPC
	OUT( ROMMGR_CTL + offs, ROMMGR_RESUME );
	// Wait for ACK to clear
	if( !cpcInReset() || (instance != ROMMGR_INST_CPC))
		while((IN( ROMMGR_CTL + offs ) & ROMMGR_PAUSE) != 0);
}
