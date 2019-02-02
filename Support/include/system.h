/*
 * sdram.h
 *
 * <one line to give the program's name and a brief idea of what it does.>
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

#ifndef INCLUDE_SYSTEM_H_
#define INCLUDE_SYSTEM_H_

#define SYSTEM_BASE 0xff

#define SYSTEM_RESET 0x01
#define SYSTEM_CLKHOLD 0x02
#define SYSTEM_SDRAM_RDY 0x80
#define SYSTEM_SDRAM2_RDY 0x40

Bool sramReady(void);
void cpcReset(void);
void cpcResetHold(void);
void cpcResetRelease(void);
Bool cpcInReset(void);
void cpcPause(void);
void cpcUnpause(void);
#endif /* INCLUDE_SYSTEM_H_ */
