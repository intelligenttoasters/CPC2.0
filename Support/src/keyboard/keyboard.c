/*
 * keyboard_if.c
 *
 * Keyboard interface - maps HID messages to physical key number and presses/releases keys
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

#include "stdio.h"
#include "include.h"
#include "string.h"

enum keynums keynums;

void pause(void)
{
	unsigned long cntr;
	for( cntr = 0; cntr<30000L; cntr++ ) NOP();
}

// Convert a HID code to a symbol code
uint16_t hid_to_sym(uint8_t hid, uint16_t modifier)
{
	// Raw, unshifted
	uint16_t map_raw[] = {
		KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY,
		KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G, KEY_H, KEY_I,
		KEY_J, KEY_K, KEY_L, KEY_M, KEY_N, KEY_O, KEY_P, KEY_Q, KEY_R,
		KEY_S, KEY_T, KEY_U, KEY_V, KEY_W, KEY_X, KEY_Y, KEY_Z,
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0,
		KEY_RETURN, KEY_ESC, KEY_DEL, KEY_TAB, KEY_SPACE, KEY_HYPHEN, KEY_HYPHEN | KEY_MOD_SHIFT,
		KEY_LSQUARE, KEY_RSQUARE, KEY_BSLASH, KEY_NOKEY, KEY_SEMI, KEY_7 | KEY_MOD_SHIFT,
		KEY_NOKEY, KEY_COMMA, KEY_DOT, KEY_FSLASH, KEY_CAPS,
		// F1-PAGE UP
		/*KEY_NOKEY*/KEY_J1FIRE, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY,
		KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY,
		KEY_CLR, KEY_NOKEY, KEY_NOKEY, KEY_RIGHT, KEY_LEFT, KEY_DOWN, KEY_UP, KEY_COPY, KEY_FSLASH,
		KEY_COLON | KEY_MOD_SHIFT, KEY_HYPHEN, KEY_SEMI | KEY_MOD_SHIFT, KEY_ENTER, KEY_F1, KEY_F2, KEY_F3,
		KEY_F4, KEY_F5, KEY_F6, KEY_F7, KEY_F8, KEY_F9, KEY_F0, KEY_FDOT
	};

	// Shifted map
	uint16_t map_shift[] = {
		KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY,
		KEY_A|KEY_MOD_SHIFT, KEY_B|KEY_MOD_SHIFT, KEY_C|KEY_MOD_SHIFT, KEY_D|KEY_MOD_SHIFT, KEY_E|KEY_MOD_SHIFT,
		KEY_F|KEY_MOD_SHIFT, KEY_G|KEY_MOD_SHIFT, KEY_H|KEY_MOD_SHIFT, KEY_I|KEY_MOD_SHIFT,
		KEY_J|KEY_MOD_SHIFT, KEY_K|KEY_MOD_SHIFT, KEY_L|KEY_MOD_SHIFT, KEY_M|KEY_MOD_SHIFT, KEY_N|KEY_MOD_SHIFT,
		KEY_O|KEY_MOD_SHIFT, KEY_P|KEY_MOD_SHIFT, KEY_Q|KEY_MOD_SHIFT, KEY_R|KEY_MOD_SHIFT,
		KEY_S|KEY_MOD_SHIFT, KEY_T|KEY_MOD_SHIFT, KEY_U|KEY_MOD_SHIFT, KEY_V|KEY_MOD_SHIFT, KEY_W|KEY_MOD_SHIFT,
		KEY_X|KEY_MOD_SHIFT, KEY_Y|KEY_MOD_SHIFT, KEY_Z|KEY_MOD_SHIFT,
		KEY_1|KEY_MOD_SHIFT, KEY_AT, KEY_3|KEY_MOD_SHIFT, KEY_4|KEY_MOD_SHIFT, KEY_5|KEY_MOD_SHIFT, KEY_NOKEY,
		KEY_6 | KEY_MOD_SHIFT, KEY_COLON | KEY_MOD_SHIFT,
		KEY_8|KEY_MOD_SHIFT, KEY_9|KEY_MOD_SHIFT,
		KEY_RETURN, KEY_ESC, KEY_DEL|KEY_MOD_SHIFT, KEY_TAB|KEY_MOD_SHIFT, KEY_SPACE, KEY_0|KEY_MOD_SHIFT, KEY_SEMI | KEY_MOD_SHIFT,
		KEY_LSQUARE|KEY_MOD_SHIFT, KEY_RSQUARE|KEY_MOD_SHIFT, KEY_AT|KEY_MOD_SHIFT, KEY_NOKEY, KEY_COLON,
		KEY_2 | KEY_MOD_SHIFT,
		KEY_NOKEY, KEY_COMMA |KEY_MOD_SHIFT, KEY_DOT|KEY_MOD_SHIFT, KEY_FSLASH|KEY_MOD_SHIFT, KEY_CAPS,
		// F1-PAGE UP
		KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY,
		KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY, KEY_NOKEY,
		KEY_CLR, KEY_NOKEY, KEY_NOKEY, KEY_RIGHT|KEY_MOD_SHIFT, KEY_LEFT|KEY_MOD_SHIFT, KEY_DOWN|KEY_MOD_SHIFT,
		KEY_UP|KEY_MOD_SHIFT, KEY_COPY|KEY_MOD_SHIFT, KEY_FSLASH,
		KEY_COLON | KEY_MOD_SHIFT, KEY_HYPHEN, KEY_SEMI | KEY_MOD_SHIFT, KEY_ENTER, KEY_F1, KEY_F2, KEY_F3,
		KEY_F4, KEY_F5, KEY_F6, KEY_F7, KEY_F8, KEY_F9, KEY_F0, KEY_FDOT
	};

	// Only check the first 0x63 keys
	if( hid > 0x63 ) return KEY_NOKEY;

	// Return the correct code
	switch( modifier )
	{
		case 0:
			return map_raw[hid];
		case KEY_MOD_SHIFT:
			return map_shift[hid];
		case KEY_MOD_CTRL:
			return map_raw[hid] | KEY_MOD_CTRL;
		case (KEY_MOD_CTRL | KEY_MOD_SHIFT):
			return map_shift[hid] | KEY_MOD_CTRL | KEY_MOD_SHIFT;
		default:
			return KEY_NOKEY;
	}
}

// Clear the keyboard of all pressed keys
void key_clear(void)
{
	OUT( KEY_CR, KEY_CR_RESET );
}

// Calling this actions all changes made with action_rc
void update(void)
{
	OUT( KEY_CR, KEY_CR_APPLY );
//	pause();
}

/*
// Usage: printf("USB-KEY %c %d %d %d %d %d %d %d %d \n", mapKey(buffer[0], buffer[2]), buffer[0], buffer[1], buffer[2], buffer[3], buffer[4], buffer[5], buffer[6], buffer[7]);

unsigned char mapKey(unsigned char modifiers, unsigned char scancode)
{
	switch( scancode )
	{
	HID_KEYCODE_TABLE()
	}
	return 0;
}
*/

void kbdProcessEvents(void)
{
	unsigned char buffer[8];
	unsigned char keyMatrix[10];	// 80-key Amstrad keyboard
	uint8_t row, col, cntr;
	uint16_t modifiers, cpc_key;

	// If we don't think USB is plugged in, check
	if( !globals()->usb_connected )
	{
		if( !( globals()->usb_connected = usbProcessConnection() ) )
			globals()->usb_enumerated = false;
			return;
	}

	// OK, connected low speed device, so enumerate it
	if( !globals()->usb_enumerated )
		// If not enumerated properly then return
		if( !( globals()->usb_enumerated = enumerate() ) ) return;

	// If there's a report
	if( getReport(buffer) ) {
		// Then map the input keys to the amstrad output matrix
		memset( keyMatrix, 0, 10 );		// Clear the matrix
		// Calculate the HID modifiers
		modifiers =
				((buffer[0] & (KEYBOARD_MODIFIER_LEFTSHIFT | KEYBOARD_MODIFIER_RIGHTSHIFT)) ? KEY_MOD_SHIFT : 0) |
				((buffer[0] & (KEYBOARD_MODIFIER_LEFTCTRL | KEYBOARD_MODIFIER_RIGHTCTRL)) ? KEY_MOD_CTRL : 0);

		// Loop through all 6 possible concurrent keys in the HID report
		for( cntr=2; cntr<8; cntr++)
		{
			// Get the CPC key and modifier
			cpc_key = KEY_NOKEY;
			if( buffer[cntr] != 0 ) cpc_key = hid_to_sym(buffer[cntr], modifiers);

			// No actual key returned then process
			if( cpc_key != KEY_NOKEY )
			{
				// Calculate row & col
				row = (cpc_key & 0xff) >> 3;
				col = cpc_key & 7;

				// Check the row is valid
				if( row <= 9 ) keyMatrix[row] |= (1<<col);	// Set to 1 the key we want to press

				// Set the shift/control
				if( cpc_key & KEY_MOD_SHIFT ) keyMatrix[2] |= (1<<5);	// Apply shift
				if( cpc_key & KEY_MOD_CTRL ) keyMatrix[2] |= (1<<7);	// Apply control
			}
		}

		// Now send the keys
		for( cntr=0; cntr<10; cntr++)
			OUT( KEY_IO | cntr, keyMatrix[cntr] );

		// Update the key matrix
		update();
	}
}

void kbdInit(void)
{
	unsigned char vernum = usbInit();
	sprintf(CB,"USB core version %d.%d", vernum>>4, vernum&0xf);
	console(CB);

}
