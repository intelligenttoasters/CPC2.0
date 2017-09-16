/*
 * keyboard.h
 *
 * Keyboard header file
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

#ifndef INCLUDE_KEYBOARD_H_
#define INCLUDE_KEYBOARD_H_

#define KEY_IO 0x30
#define KEY_CR (KEY_IO | 0xf)
#define KEY_CR_RESET (1<<7)
#define KEY_CR_APPLY (1)

#define KEY_MOD_CTRL (1<<9)
#define KEY_MOD_SHIFT (1<<8)

enum keynums {
	KEY_UP, KEY_RIGHT, KEY_DOWN, KEY_F9, KEY_F6, KEY_F3, KEY_ENTER, KEY_FDOT,
	KEY_LEFT, KEY_COPY, KEY_F7, KEY_F8, KEY_F5, KEY_F1, KEY_F2, KEY_F0,
	KEY_CLR, KEY_LSQUARE, KEY_RETURN, KEY_RSQUARE, KEY_F4, KEY_SHIFT, KEY_BSLASH, KEY_CTRL,
	KEY_CARET, KEY_HYPHEN, KEY_AT, KEY_P, KEY_SEMI, KEY_COLON, KEY_FSLASH, KEY_DOT,
	KEY_0, KEY_9, KEY_O, KEY_I, KEY_L, KEY_K, KEY_M, KEY_COMMA,
	KEY_8, KEY_7, KEY_U, KEY_Y, KEY_H, KEY_J, KEY_N, KEY_SPACE,
	KEY_6, KEY_5, KEY_R, KEY_T, KEY_G, KEY_F, KEY_B, KEY_V,
	KEY_4, KEY_3, KEY_E, KEY_W, KEY_S, KEY_D, KEY_C, KEY_X,
	KEY_1, KEY_2, KEY_ESC, KEY_Q, KEY_TAB, KEY_A, KEY_CAPS, KEY_Z,
	KEY_J1UP, KEY_J1DOWN, KEY_J1LEFT, KEY_J1RIGHT, KEY_J1FIRE, KEY_J1FIRE2, KEY_J1FIRE3, KEY_DEL,
	KEY_NOKEY
			};

void key_down(uint8_t[] );
void key_up(uint8_t[] );
void key_clear(void);

enum state_t {keyup, keydown};
typedef enum state_t state;

void kbdProcessEvents(void);
void kbdInit(void);

#endif /* INCLUDE_KEYBOARD_H_ */
