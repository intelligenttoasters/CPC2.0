/*
 * asmi.h - ASMI Interface - stored disk and ROM images
 *
 * Accesses stored disk and ROM images
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


#ifndef INCLUDE_ASMI_H_
#define INCLUDE_ASMI_H_

#define ASMI_BASE 		0x90
#define ASMI_DATA 		ASMI_BASE
#define ASMI_ADDRESS0 	(ASMI_BASE+8)
#define ASMI_ADDRESS1 	(ASMI_BASE+9)
#define ASMI_ADDRESS2 	(ASMI_BASE+10)
#define ASMI_ADDRESS3 	(ASMI_BASE+11)
#define ASMI_STATUS		(ASMI_BASE+15)
#define ASMI_CTL		(ASMI_BASE+15)

#define ASMI_STATUS_BUSY 0x01
#define ASMI_STATUS_READY 0x80

// ROM Images
#define ROM_BASE ((uint32_t)0x800000)
#define ROM_LOC(X) ((uint32_t)((uint32_t)X<<14))
// ROM ID numbers
#define ROM_464 0
#define ROM_6128 1
#define ROM_BASIC10 2
#define ROM_BASIC11 3
#define ROM_AMSDOS 4
#define ROM_MAXAM 5
#define ROM_PARADOS 6
#define ROM_CPM1 7
#define ROM_CPM2 8
#define ROM_BOULDERDASH 9
#define ROM_INVADERS 10
#define ROM_HARVEY 11
#define ROM_MANIC 12
#define ROM_PACMAN 13
#define ROM_PROTEXT 14
#define ROM_RODOS 15
#define ROM_DEFEND 16
#define ROM_DONKEY 17
#define ROM_THRUST 18
#define ROM_AMRAM2 19
#define ROM_PROSPELL 20

#define ROM_COUNT 21

// Define the lower ROM position
#define ROM_LOWER 64

void asmiAddress(uint32_t);
void asmiCopyROM(unsigned char, unsigned char);
unsigned char asmiStatus(void);
unsigned char asmiRead(void);

#define asmiReady() (~(asmiStatus() & ASMI_STATUS_BUSY))

#endif /* INCLUDE_ASMI_H_ */
