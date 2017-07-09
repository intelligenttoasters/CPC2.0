/*
 * library.c
 *
 * General library routines for the application
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
#include "stdio.h"

// Log file message number
static unsigned long msgno = 0;

// GLobal variables
static struct global_vars global_variables;

// Function to return the global handle for global variables
inline struct global_vars * globals()
{
	return &global_variables;
}
// Process events - add events to this list as required
inline void processEvents()
{
	uartProcessEvents();
	hdmiProcessEvents();
	kbdProcessEvents();
}

// Log a console message
void console(char *msg)
{
	printf("[%08ld] %s\n", msgno++, msg);
}

// Print an underline
void ul()
{
	int cntr;
	for( cntr=0; cntr<_STD_WIDTH_ - 1; cntr++) putchar('=');
	putchar('\n');
}
