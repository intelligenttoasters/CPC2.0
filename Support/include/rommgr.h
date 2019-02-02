/*
 * rommgr.h - Header file for ROM manager
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

#ifndef INCLUDE_ROMMGR_H_
#define INCLUDE_ROMMGR_H_

#define ROMMGR_BASE 	0x70
#define ROMMGR_ADDR_OFS 8
#define ROMMGR_ADDR0 	(ROMMGR_BASE+ROMMGR_ADDR_OFS+0)
#define ROMMGR_ADDR1 	(ROMMGR_BASE+ROMMGR_ADDR_OFS+1)
#define ROMMGR_ADDR2 	(ROMMGR_BASE+ROMMGR_ADDR_OFS+2)
#define ROMMGR_ADDR3 	(ROMMGR_BASE+ROMMGR_ADDR_OFS+3)
#define ROMMGR_FLAGS	(ROMMGR_BASE+12)
#define ROMMGR_CTL 		(ROMMGR_BASE+15)
#define ROMMGR_DATA 	(ROMMGR_BASE)
#define ROMMGR_INSTANCE_SPAN 0x10	// There are two memory chips, where's the next located
#define ROMMGR_MAX_INSTANCES 2
#define ROMMGR_INST_CPC 0			// CPC Memory
#define ROMMGR_INST_VID 1			// Video memory

// Indicates ROM not RAM is being addressed
#define ROMMGR_ROMCONSTANT 0x100
#define ROMMGR_ROMMASK 0x3f			// Max 64 ROMs
#define ROMMGR_ROMPOP 0x80	// Indicates ROM is populated, output to ROMFLAGS OR'd with ROM #
#define ROMMGR_ROMNONE 0x40	// Indicates ROM is not populated, output to ROMFLAGS XOR'd with ROM #
#define ROMMGR_ROMCLR 0xc0	// Clears all ROMs from list

#define ROMMGR_PAUSE 0x80	// Pauses CPC while ROMs updated
#define ROMMGR_RAMCTL 0x40	// Special case to manage the control signals in the SRAM
#define ROMMGR_RESUME 0x00	// Resume CPC

// Control code
#define ROMMGR_ID0 	0x00000000
#define ROMMGR_ID1 	0x00000001
#define ROMMGR_CTL0 0x00001000
#define ROMMGR_CTL1 0x00001001

// ROM location code
#define ROMMGR_ASMI	0x0000
#define ROMMGR_SDC	0x8000

void romInit(void);
void romSetWriteAddress(unsigned char rom);
void romClear(unsigned char);
void romSendData( char *, uint16_t);
void sramPut( uint8_t instance, uint32_t address, void * buffer, uint16_t size);
void sramGet( uint8_t instance, uint32_t address, void * buffer, uint16_t size);

#endif /* INCLUDE_ROMMGR_H_ */
