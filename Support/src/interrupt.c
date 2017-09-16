/*
 * interrupt.c - Interrupt handler
 *
 * This handles interrupts of both NMI and INT
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
#include "include.h"
#include "interrupt.h"

// Just a stub at the moment, no NMI functions
void nmi_handler(void)
{

}

//
// Called at any time. Check the interrupt handler for the source
//
void int_handler(void)
{
	unsigned char int_src;
	// Read the interrupt source and reset the interupt line
	int_src = IN(INTERRUPT_CONTROLLER_BASE);
	// Did the SPI trigger this interrupt
	if( int_src & INT_UART )
	{
	}
}
