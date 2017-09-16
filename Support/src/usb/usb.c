/*
 * usb.c
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

#include "include.h"
#include "stdio.h"

unsigned char lastReport[8];

unsigned char usbInit(void)
{
	unsigned char cntr;

	// Reset core and set to host mode, next statement gives enough time to initialise core
	OUT(HOST_CONTROL,3);
	for( cntr=0; cntr<10; cntr++ ) NOP();

	// Reset any USB connected device
	deviceReset();

	// Reset all interrupts
	OUT(HOST_INTERRUPT_STATUS, 0xf);	// Clear all interrupts

	// Return host version
	return IN(HOST_VERSION);
}

void deviceReset(void)
{
	unsigned int cntr;
	UDBG("Reset..");
	// Reset device by sending SE0 for 20ms
	OUT(HOST_TX_LINE_CONTROL,4);
	#ifndef SIM
	for( cntr=0; cntr<60000; cntr++);
	#endif
	// Then pause for a bit longer
	OUT(HOST_TX_LINE_CONTROL,0);
	#ifndef SIM
	for( cntr=0; cntr<10000; cntr++);
	#endif
	UDBG("Reset done");
}

// Read from an USB device
unsigned char usbIn( unsigned char address, unsigned char endpoint, char * buffer )
{
	// 2000 is 1ms, maxtime is 100ms
	unsigned long timeout = 0, maxtime = 200000;
	unsigned char read_count = 0;
	unsigned char size, cntr;

	while( (timeout < 1024 ) )
	{
		// Clear the FIFO buffers
		OUT(HOST_TX_FIFO_CONTROL,1);
		OUT(HOST_RX_FIFO_CONTROL,1);

		OUT(HOST_TX_ADDR,address);
		OUT(HOST_TX_ENDP,endpoint);
		OUT(HOST_TX_TRANS_TYPE,1); 							// In transaction
		OUT(HOST_INTERRUPT_STATUS, 0xf);					// Clear all interrupts
		OUT(HOST_TX_CONTROL, 1);							// Start the IN transaction

		// Wait for completion (up to maxtime)
		while( ( (IN(HOST_INTERRUPT_STATUS) & 1) == 0) && (timeout < maxtime ) ) timeout++;
		// Complete and all error bits zero
		if( ( IN(HOST_INTERRUPT_STATUS) & 1 ) && ( ( IN(HOST_RX_STATUS) & 0x3f) == 0 ) )
		{
			size = IN(HOST_RX_FIFO_DATA_COUNT_LSB);
			for( cntr = 0; cntr < size; cntr++ )
			{
				*buffer = IN(HOST_RX_FIFO_DATA);
				buffer++;
				read_count++;
			}
			return read_count;
		}
	}
	return 0;
}

// Can return if high speed plugged in
uint8_t usbProcessConnection()
{
	// If not connected go straight back
	if( IN(HOST_RX_CONNECT_STATE) == 0 ) return false;

	// Reset to apply speed resistor
	deviceReset();

	// If not connected go straign back
	if( IN(HOST_RX_CONNECT_STATE) == 0 ) return false;

	if( IN(HOST_RX_CONNECT_STATE) == 2 )
	{
		console("No full speed support..please use a USB1.x device");
		while( IN(HOST_RX_CONNECT_STATE) != 0 );
		UDBG("Unplugged");
		return false;
	}

	// Confirmed connected low speed
	sprintf(CB,"USB Connected %s speed device", ((IN(HOST_RX_CONNECT_STATE) == 1) ? "low" : "high"));
	console(CB);

	return true;
}

// Send to an USB device
uint8_t _usbOut( unsigned char address, unsigned char endpoint, unsigned char type, char * buffer, unsigned char size )
{
	unsigned char cntr, byte, retry = 0;
	unsigned int wait;

	while( true )
	{
		// Clear the FIFO buffers
		OUT(HOST_TX_FIFO_CONTROL,1);
		OUT(HOST_RX_FIFO_CONTROL,1);

		// Now address the device
		OUT(HOST_TX_ADDR,address);
		OUT(HOST_TX_ENDP,endpoint);

		UDBGNR("TX:a%d=ep%d)...", address, endpoint);
		// Get descriptor
		for( cntr=0; cntr<size; cntr++ )
		{
			byte = *(buffer+cntr);
			OUT(HOST_TX_FIFO_DATA,byte);
			UDBGNR("%02x ", byte);
		}
		UDBG(0);

		// Setup packet
		OUT(HOST_TX_TRANS_TYPE,type);

		// Clear interrupt flags first
		OUT(HOST_INTERRUPT_STATUS, 0xf);

		// SEND!!!
		OUT(HOST_TX_CONTROL, 1);

		// Wait for completion
		while(!(IN(HOST_INTERRUPT_STATUS) & 1));

		// Received an ACK!
		if( ( IN(HOST_RX_STATUS) & 0x40 ) ) break;
		UDBG("No ACK, stat %02x", IN(HOST_RX_STATUS));
		if( retry++ >= 8 ) return false;		// Retry 16 times

		// Sleep for a bit
		for( wait = 0; wait<20000; wait++ ) NOP();
	}
	return true;
}

unsigned char getDescriptor(unsigned char *buffer, unsigned char addr, unsigned char descType, unsigned char descIdx, unsigned int maxLen)
{
	unsigned char cnt1, cnt2, cnt3;
	unsigned int cntr;
	unsigned char usbDescriptorReq[] 	= {0x80, 0x06, descIdx, descType, 0x00, 0x00, maxLen & 0xff, (maxLen & 0xff00)>>8 };

	// Cnt2 is bytes remaining
	cnt2 = (descType != USB_CONFIG_DESC ) ? 0xff : maxLen;
	// cnt3 is the array position
	cnt3 = 0;

	if( usbControl(addr, 0, usbDescriptorReq) )
	{

		while(cnt2 != 0 )
		{
			cnt1 = usbIn( addr, 0, &buffer[cnt3] );
			if( cnt1 == 0 )
			{
				UDBG("E-NoRD desc");
				return 0;
			}
			// If first time through, set the cntr remaining
			if( cnt2 == 0xff ) cnt2 = buffer[0];
			// Add the number of bytes in this packet or remaining to total count
			cnt3 += min(cnt2,8);
			// Reduce the countdown to completion
			cnt2 -= min(cnt2,8);
		}

		UDBGNR("CONF-L:%d, data: ", cnt3);
		for( cntr=0; cntr<cnt3; cntr++ )
			UDBGNR("%02x ", buffer[cntr]);
		UDBG(0);

		return cnt3;
	}

	return 0;
}

uint8_t setAddress(unsigned char *buffer, unsigned char addr)

{
	unsigned char usbSetAddrReq[] = {0x00, 0x05, addr, 0x00, 0x00, 0x00, 0x00, 0x00};
	UDBG("Set addr %d", addr);
	if( usbSetup( usbSetAddrReq ) )
	{
		// Does it return anything?
		if( usbIn( 0, 0, buffer ) == 0 )
			return true;	// No then it's OK
		else
			return false;
	}
	return false;
}

unsigned char * usbGetString( unsigned char index, unsigned char *usbbuffer, unsigned char usbsize, unsigned char *strbuffer, unsigned char maxChars )
{
	struct usbString *str;
	unsigned char cntr, maxcnt;

	// Get one of the strings
	if( getDescriptor( usbbuffer, USB_DEVICE_ADDRESS, USB_STRING_DESC, index, usbsize ) )
	{
		str = (struct usbString *) usbbuffer;
		maxcnt = min(maxChars, str->length>>1)-1;
		for(cntr=0 ; cntr<maxcnt ; cntr++)
			strbuffer[cntr] = str->chars[cntr];
		strbuffer[cntr] = 0;
		return strbuffer;
	}
	UDBG("NoSTR %d", index);
	strbuffer[0] = 0;
	return strbuffer;
}

uint8_t setConfig(unsigned char *buffer, unsigned char addr, unsigned char config)
{
	unsigned char usbSetConfig[] = {0x00, 0x09, config, 0x00, 0x00, 0x00, 0x00, 0x00};
	UDBG("SetConf %d", config);
	if( usbControl( addr, 0, usbSetConfig ) )
	{
		// Does it return anything?
		if( usbIn( USB_DEVICE_ADDRESS, 0, buffer ) == 0 )
			return true;	// No then it's OK
		else
			return false;
	}
	return false;
}

uint8_t enumerate()
{
	unsigned int cntr;
	unsigned char buffer[128], strbuffer[64], configLen, manu, prod, serial, config_num, stat;
	struct usbDeviceDescriptor *dev;
	struct usbConfigDescriptor *config;
	struct usbIfaceDescriptor *interface;
	struct usbEndPt *ept;
	struct usbGeneric *generic;

	for(cntr=0; cntr<4; cntr++) {
		while( !usbProcessConnection() );
		UDBG("Initializing USB device...");
		// Address is zero initially, so hard code it here
		if (getDescriptor( buffer, 0, USB_DEVICE_DESC, 0, 0x40 ) > 0) break;
	}
	dev = (struct usbDeviceDescriptor *) buffer;
	// Clear to end of line
	if( cntr==4 )
	{
		UDBG("Error - Suspending device");
		return false;
	}

	UDBG("Max packet size: %d", dev->maxpacket);
	UDBG("Num configs: %d", dev->configs);
	sprintf(CB, "USB VID:%04X PID:%04X", dev->vendor, dev->product);
	console(CB);

	// Store these because the next read of the USB will overwrite these values
	manu = dev->strManu;
	prod = dev->strProd;
	serial = dev->strSerial;

	// Reset USB device
	deviceReset();

	// Set address
	if( !setAddress(buffer, USB_DEVICE_ADDRESS) )
	{
		UDBG("Set address failed");
		return false;
	}

	if( manu ) {
		sprintf(globals()->console_buffer,"USB Manufacturer: %s", usbGetString(manu, buffer, 128, strbuffer, 64 ));
		console(globals()->console_buffer);
	}
	if( prod ) {
		sprintf(globals()->console_buffer,"USB Product: %s", usbGetString(prod, buffer, 128, strbuffer, 64 ));
		console(globals()->console_buffer);
	}
	if( serial ) {
		sprintf(globals()->console_buffer,"USB Serial: %s", usbGetString(serial, buffer, 128, strbuffer, 64 ));
		console(globals()->console_buffer);
	}

	UDBG("Getting config descriptor");
	if( !getDescriptor( buffer, USB_DEVICE_ADDRESS, USB_CONFIG_DESC, 0, 0x9 ) )
	{
		UDBG("Failed to get config 0");
		return false;
	}
	config = (struct usbConfigDescriptor *) buffer;
	configLen = config->totalLength;
	config_num = config->configValue;

	UDBG("First config is: %d", config_num);

	// Reget the device config, with the correct length
	if( !getDescriptor( buffer, USB_DEVICE_ADDRESS, USB_CONFIG_DESC, 0, configLen ) )
	{
		UDBG("Failed to get config 0");
		return false;
	}
	// Next descriptor starts immediately after device config descriptor
	interface = (struct usbIfaceDescriptor *) ((unsigned char *) buffer + config->length);
	UDBG("Endpoints: %d, Class:%d, Subclass:%d, Proto: %d, Length: %d", interface->epts, interface->class, interface->subclass, interface->proto, interface->length);

	// Check a boot keyboard is inserted and not anything else, class HID(3), subclass boot(1), protocol keyboard(1)
	if( interface->class != 0x03 || interface->subclass != 0x01 || interface->proto != 0x01 )
	{
		UDBG("Device is not a boot keyboard, restarting");
		return false;
	}
	// Find the endpoint descriptor (skip over HID descriptors)
	generic = (struct usbGeneric *) ((unsigned char *) interface + interface->length);
	while( generic->type != 5 ) {
		generic = (struct usbGeneric *) ((unsigned char *) generic + generic->length);
	}
	ept = (struct usbEndPt *) generic;

	UDBG("Endpoint: %02x, interval :%d", ept->ep, ept->interval);

	stat = !setConfig(buffer, USB_DEVICE_ADDRESS, config_num);
	if( stat ) console("Failed to set USB configuration");

	return true;
}

unsigned char * getReport(unsigned char * buffer)
{
	unsigned int cntr;
	if( usbIn( USB_DEVICE_ADDRESS, 0x1, buffer ) != 0 )
	{
		if( buffer[0] != lastReport[0] ||
			buffer[1] != lastReport[1] ||
			buffer[2] != lastReport[2] ||
			buffer[3] != lastReport[3] ||
			buffer[4] != lastReport[4] ||
			buffer[5] != lastReport[5] ||
			buffer[6] != lastReport[6] ||
			buffer[7] != lastReport[7] )
		{
			for(cntr=0; cntr<8; cntr++) lastReport[cntr] = buffer[cntr];
			return buffer;
		}
		else
			return 0;
	}
	else {
		// Is RX timed out
		if (IN(HOST_RX_STATUS) & 0x08)
			globals()->usb_timeout++;
		else
			globals()->usb_timeout = 0;

		// Check for timeout
		if( globals()->usb_timeout >= 16 )
		{
			console("USB disconnected");
			globals()->usb_connected = false;
			globals()->usb_enumerated = false;
			globals()->usb_timeout = 0;
		}
		return 0;
	}
}
