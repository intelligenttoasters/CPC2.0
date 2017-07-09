/*
 * include.h
 *
 * Include to include other includes to make a standard set
 * 		of vars and constructs available
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

#ifndef INCLUDE_INCLUDE_H_
#define INCLUDE_INCLUDE_H_

// Debug/SIM flag
//#define DEBUG
//#define SIM

#ifdef DEBUG
	#define DBG(...) {printf(__VA_ARGS__); putchar(10);}
	#define UDBG(...) {printf(__VA_ARGS__); putchar(10);}
	#define UDBGNR(...) printf(__VA_ARGS__);
#else
	#define DBG
	#define UDBG
	#define UDBGNR
#endif

// Some type definitions
#define Bool unsigned char
#define true 1
#define false 0

// IO and special routines
void OUT(char, char);
unsigned char IN(char);

void OUTI( char port, char * buffer, unsigned char size);
void INI( char port, char * buffer, unsigned char size);

#define NOP() __asm__("nop")
#define HALT() __asm__("halt")

struct global_vars {
	char console_buffer[132];
	Bool usb_connected;
	Bool usb_enumerated;
	unsigned int usb_timeout;
};

#define CB (globals()->console_buffer)

#include "stdint.h"
#include "library.h"
#include "stdio_uart.h"
#include "hdmi.h"
#include "keyboard.h"
#include "usb.h"

#endif /* INCLUDE_INCLUDE_H_ */
