/*
 * system.c - System operations and CPC control
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

#include "include.h"

// Is the SDRAM initialised?
Bool sramReady()
{
	return (IN( SYSTEM_BASE ) & (SYSTEM_SDRAM_RDY|SYSTEM_SDRAM2_RDY)) ==
			(SYSTEM_SDRAM_RDY|SYSTEM_SDRAM2_RDY);
}

void cpcReset()
{
	cpcResetHold();
	cpcResetRelease();
}

void cpcResetHold()
{
	console("Hold CPC reset");
	OUT(SYSTEM_BASE,IN(SYSTEM_BASE) | SYSTEM_RESET);
}

void cpcResetRelease()
{
	console("Release CPC reset");
	OUT(SYSTEM_BASE,IN(SYSTEM_BASE) & !SYSTEM_RESET);
}

Bool cpcInReset()
{
	return (IN(SYSTEM_BASE) & SYSTEM_RESET) ? true : false;
}
