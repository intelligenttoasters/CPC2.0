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

// Redefine putchar
//#define putchar(_PARAM_) _putchar(_PARAM_)
//#define getchar(_DUMMY_) _getchar()

// IO and special routines
void OUT_(unsigned char, unsigned char);
#define OUT(a,b) OUT_(((unsigned char) ((a)&0xff)), ((unsigned char) ((b)&0xff)))

unsigned char IN_(unsigned char);
#define IN(a) IN_(((unsigned char) (a&0xff)))

void OUTI( char port, char * buffer, unsigned char size);
void INI( char port, char * buffer, unsigned char size);

#define NOP() __asm__("nop")
#define HALT() __asm__("halt")

#define CB (globals()->console_buffer)

#include "stdint.h"
#include "library.h"
#include "stdio_uart.h"
#include "hdmi.h"
#include "keyboard.h"
#include "usb.h"
#include "phy.h"
#include "fdc.h"
#include "system.h"
#include "rommgr.h"
#include "asmi.h"
#include "sdc.h"
#include "fat2l.h"
#include "config.h"

struct global_vars {
	char console_buffer[2048];
	Bool usb_connected;
	Bool usb_enumerated;
	unsigned int usb_timeout;
	struct sd_response sd_buf;
	struct fat_work fat;
	struct config config;
};

#endif /* INCLUDE_INCLUDE_H_ */
