/*
 * usb.h
 *
 * Main USB handler
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

#ifndef INCLUDE_USB_H_
#define INCLUDE_USB_H_

// USB SIE
#define HOST_TX_CONTROL 0xb0
#define HOST_TX_TRANS_TYPE 0xb1
#define HOST_TX_LINE_CONTROL 0xb2
#define HOST_TX_SOF_ENABLE 0xb3
#define HOST_TX_ADDR 0xb4
#define HOST_TX_ENDP 0xb5
#define HOST_FRAME_NUM_MSP 0xb6
#define HOST_FRAME_DUM_LSP 0xb7
#define HOST_INTERRUPT_STATUS 0xb8
#define HOST_INTERRUPT_MASK 0xb9
#define HOST_RX_STATUS 0xba
#define HOST_RX_PID 0xbb
#define HOST_RX_ADDR 0xbc
#define HOST_RX_ENDP 0xbd
#define HOST_RX_CONNECT_STATE 0xbe
#define HOST_RX_TIMER_MSB 0xbf
#define HOST_RX_FIFO_DATA 0xc0
#define HOST_RX_FIFO_DATA_COUNT_MSB 0xc2
#define HOST_RX_FIFO_DATA_COUNT_LSB 0xc3
#define HOST_RX_FIFO_CONTROL 0xc4
#define HOST_TX_FIFO_DATA 0xd0
#define HOST_TX_FIFO_CONTROL 0xd4
#define HOST_CONTROL 0xe0
#define HOST_VERSION 0xe1

#define USB_DEVICE_ADDRESS 1

#define USB_DEVICE_DESC 1
#define USB_CONFIG_DESC 2
#define USB_STRING_DESC 3

// Use macros for execution efficiency
#define usbOut(A,E,B,S) _usbOut(A,E,3,B,S)
#define usbSetup(B) _usbOut(0, 0, 0, B, 8)
#define usbControl(A,E,B) _usbOut(A,E,0,B,8)

struct usbDeviceDescriptor {
	unsigned char length, type;
	unsigned int version;
	unsigned char class, subclass, protocol, maxpacket;
	unsigned int vendor, product, prodver;
	unsigned char strManu, strProd, strSerial, configs;
};

struct usbConfigDescriptor {
	unsigned char length, type;
	unsigned int totalLength;
	unsigned char interfaces, configValue, strConf, attr, maxPwr;
};

struct usbIfaceDescriptor {
	unsigned char length, type, ifnum, alt, epts, class, subclass, proto, strDesc;
};

struct usbString {
	unsigned char length, type;
	unsigned int chars[1023];
};

struct usbEndPt {
	unsigned char length, type, ep, attr, maxpkt, interval;
};

struct usbHID {
	unsigned char length, type;
	unsigned int version;
	unsigned char country, count, descType;
	unsigned int descLength;
};

struct usbGeneric {
	unsigned char length, type;
};


#define BIT_(X) (1<<X)
enum {
	KEYBOARD_MODIFIER_LEFTCTRL   = BIT_(0),
	KEYBOARD_MODIFIER_LEFTSHIFT  = BIT_(1),
	KEYBOARD_MODIFIER_LEFTALT    = BIT_(2),
	KEYBOARD_MODIFIER_LEFTGUI    = BIT_(3),
	KEYBOARD_MODIFIER_RIGHTCTRL  = BIT_(4),
	KEYBOARD_MODIFIER_RIGHTSHIFT = BIT_(5),
	KEYBOARD_MODIFIER_RIGHTALT   = BIT_(6),
	KEYBOARD_MODIFIER_RIGHTGUI   = BIT_(7)
};

#define ENTRY(A,B,C) case A: return (modifiers & (KEYBOARD_MODIFIER_LEFTSHIFT | KEYBOARD_MODIFIER_RIGHTSHIFT)) ? C : B;

#define HID_KEYCODE_TABLE(MOD) \
    ENTRY( 0x04, 'a', 'A' )\
    ENTRY( 0x05, 'b', 'B' )\
    ENTRY( 0x06, 'c', 'C' )\
    ENTRY( 0x07, 'd', 'D' )\
    ENTRY( 0x08, 'e', 'E' )\
    ENTRY( 0x09, 'f', 'F' )\
    ENTRY( 0x0a, 'g', 'G' )\
    ENTRY( 0x0b, 'h', 'H' )\
    ENTRY( 0x0c, 'i', 'I' )\
    ENTRY( 0x0d, 'j', 'J' )\
    ENTRY( 0x0e, 'k', 'K' )\
    ENTRY( 0x0f, 'l', 'L' )\
    ENTRY( 0x10, 'm', 'M' )\
    ENTRY( 0x11, 'n', 'N' )\
    ENTRY( 0x12, 'o', 'O' )\
    ENTRY( 0x13, 'p', 'P' )\
    ENTRY( 0x14, 'q', 'Q' )\
    ENTRY( 0x15, 'r', 'R' )\
    ENTRY( 0x16, 's', 'S' )\
    ENTRY( 0x17, 't', 'T' )\
    ENTRY( 0x18, 'u', 'U' )\
    ENTRY( 0x19, 'v', 'V' )\
    ENTRY( 0x1a, 'w', 'W' )\
    ENTRY( 0x1b, 'x', 'X' )\
    ENTRY( 0x1c, 'y', 'Y' )\
    ENTRY( 0x1d, 'z', 'Z' )\
    ENTRY( 0x1e, '1', '!' )\
    ENTRY( 0x1f, '2', '@' )\
    ENTRY( 0x20, '3', '#' )\
    ENTRY( 0x21, '4', '$' )\
    ENTRY( 0x22, '5', '%' )\
    ENTRY( 0x23, '6', '^' )\
    ENTRY( 0x24, '7', '&' )\
    ENTRY( 0x25, '8', '*' )\
    ENTRY( 0x26, '9', '(' )\
    ENTRY( 0x27, '0', ')' )\
    ENTRY( 0x28, '\r', '\r' )\
    ENTRY( 0x29, '\e', '\e' )\
    ENTRY( 0x2a, '\b', '\b' )\
    ENTRY( 0x2b, '\t', '\t' )\
    ENTRY( 0x2c, ' ', ' '  )\
    ENTRY( 0x2d, '-', '_' )\
    ENTRY( 0x2e, '=', '+' )\
    ENTRY( 0x2f, '[', '{' )\
    ENTRY( 0x30, ']', '}' )\
    ENTRY( 0x31, '\\', '|' )\
    ENTRY( 0x32, '#', '~' ) /* TODO non-US keyboard */ \
    ENTRY( 0x33, ';', ':' )\
    ENTRY( 0x34, '\'', '\"' )\
    ENTRY( 0x35, 0, 0 )\
    ENTRY( 0x36, ',', '<' )\
    ENTRY( 0x37, '.', '>' )\
    ENTRY( 0x38, '/', '?' )\
    ENTRY( 0x39, 0, 0 ) /* TODO CapsLock, non-locking key implementation*/ \
    ENTRY( 0x54, '/', '/' )\
    ENTRY( 0x55, '*', '*' )\
    ENTRY( 0x56, '-', '-' )\
    ENTRY( 0x57, '+', '+' )\
    ENTRY( 0x58, '\r', '\r' )\
    ENTRY( 0x59, '1', 0 ) /* numpad1 & end */ \
    ENTRY( 0x5a, '2', 0 )\
    ENTRY( 0x5b, '3', 0 )\
    ENTRY( 0x5c, '4', 0 )\
    ENTRY( 0x5d, '5', '5' )\
    ENTRY( 0x5e, '6', 0 )\
    ENTRY( 0x5f, '7', 0 )\
    ENTRY( 0x60, '8', 0 )\
    ENTRY( 0x61, '9', 0 )\
    ENTRY( 0x62, '0', 0 )\
    ENTRY( 0x63, '0', 0 )\
    ENTRY( 0x67, '=', '=' )



void usbInit(void);
void deviceReset(void);
unsigned char usbIn( unsigned char address, unsigned char endpoint, char * buffer );
uint8_t usbProcessConnection();
uint8_t _usbOut( unsigned char address, unsigned char endpoint, unsigned char type, char * buffer, unsigned char size );
unsigned char getDescriptor(unsigned char *buffer, unsigned char addr, unsigned char descType, unsigned char descIdx, unsigned int maxLen);
uint8_t setAddress(unsigned char *buffer, unsigned char addr);
unsigned char * usbGetString( unsigned char index, unsigned char *usbbuffer, unsigned char usbsize, unsigned char *strbuffer, unsigned char maxChars );
uint8_t setConfig(unsigned char *buffer, unsigned char addr, unsigned char config);
uint8_t enumerate();
unsigned char * getReport(unsigned char *buffer);
void usbProcessEvents(/*events*/);

#endif /* INCLUDE_USB_H_ */
