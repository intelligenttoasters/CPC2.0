/*
 * i2c.c - I2C Interface
 *
 * Interfaces to the I2C port of the HDMI adapter
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

inline void i2cWait(void)
{
//	uint16_t cntr;
//	for( cntr = 0; cntr < 50; cntr++ ) NOP();		// Fix this

	// Read status reg and wait for the transfer in progress flag to clear
	while( (i2cReadReg( I2C_PORT | I2C_SR ) & I2C_TIP) );	// Wait for finish of transfer
}

void hdmi_init()
{
	// Disable core and interrupts
	DBG("Disable I2C core");
	OUT( I2C_PORT | I2C_CTR, !(I2C_EN | I2C_IEN));

	// Write prescale to 100KHz at 48MHz clock / 83Khz at 40MHz
	DBG("Write prescale 0x0030");
	OUT(I2C_PORT | I2C_PRER_LO, 0x60);
	OUT(I2C_PORT | I2C_PRER_HI, 0x00);

	// Try power up to set monitor sense etc
	hdmi_powerup();
}

// Read a data value from the HDMI chip
uint8_t hdmi_read( uint8_t port )
{
	uint8_t dat = 0, ack;

	// Enable the core
	OUT( I2C_PORT | I2C_CTR, I2C_EN);

	// Start bit
	i2cWriteReg( I2C_PORT | I2C_CR, I2C_STA | I2C_WR );

	// Slave address byte - write
	i2cWriteReg( I2C_PORT | I2C_TXR, (HDMI_I2C_ADDR << 1) );
	i2cWriteReg( I2C_PORT | I2C_CR, I2C_WR );
	i2cWait();

	// Record ACK/NAK
	ack = IN(I2C_PORT | I2C_SR) & I2C_RXACK;

	// Only continue if acked
	if( ack == 0 )
	{
		// Base address byte
		i2cWriteReg( I2C_PORT | I2C_TXR, port );
		i2cWriteReg( I2C_PORT | I2C_CR, I2C_WR );
		i2cWait();

		// ReStart bit
		i2cWriteReg( I2C_PORT | I2C_CR, I2C_STA | I2C_STO );

		// Slave address byte - read
		i2cWriteReg( I2C_PORT | I2C_TXR, (HDMI_I2C_ADDR << 1) | 1 );
		i2cWriteReg( I2C_PORT | I2C_CR, I2C_WR );
		i2cWait();

		// Read data from chip, with a NAK so we terminate transfer and leave data line high
		// Note that a '1' is a NAK because it's the line state without asserting the buffer
		i2cWriteReg( I2C_PORT | I2C_CR, I2C_RD | I2C_ACK );
		i2cWait();

		// Read data
		dat = i2cReadReg( I2C_PORT | I2C_RXR );
	}

	// Stop state
	i2cWriteReg( I2C_PORT | I2C_CR, I2C_STO );

	// Wait for bus to be released
	while( i2cReadReg( I2C_PORT | I2C_SR ) & I2C_BUSY );

	// Disable core and interrupts
	OUT( I2C_PORT | I2C_CTR, !(I2C_EN | I2C_IEN));

	// Debug code
	if( ack != 0 ) DBG("HDMI no ACK");

	// Return the data
	return dat;
}

// Write a data value to the HDMI chip
void hdmi_write( uint8_t port, uint8_t value )
{
	uint8_t ack;

	// Enable the core
	OUT( I2C_PORT | I2C_CTR, I2C_EN);

	// Start bit
	i2cWriteReg( I2C_PORT | I2C_CR, I2C_STA | I2C_WR );

	// Slave address byte - write
	i2cWriteReg( I2C_PORT | I2C_TXR, (HDMI_I2C_ADDR << 1) );
	i2cWriteReg( I2C_PORT | I2C_CR, I2C_WR );
	i2cWait();

	// Record ACK/NAK
	ack = IN(I2C_PORT | I2C_SR) & I2C_RXACK;

	// Only continue if we got an ack
	if( ack == 0 )
	{
		// Base address byte
		i2cWriteReg( I2C_PORT | I2C_TXR, port );
		i2cWriteReg( I2C_PORT | I2C_CR, I2C_WR );
		i2cWait();

		// Write data to chip
		i2cWriteReg( I2C_PORT | I2C_TXR, value );
		i2cWriteReg( I2C_PORT | I2C_CR, I2C_WR );
		i2cWait();

		// Record ACK/NAK
		ack = IN(I2C_PORT | I2C_SR) & I2C_RXACK;
	}

	// Stop state
	i2cWriteReg( I2C_PORT | I2C_CR, I2C_STO );

	// Wait for bus to be released
	while( i2cReadReg( I2C_PORT | I2C_SR ) & I2C_BUSY );

	// Disable core and interrupts
	OUT( I2C_PORT | I2C_CTR, !(I2C_EN | I2C_IEN));

	// Debug code
	if( ack != 0 ) DBG("HDMI no ACK");

}

// Set the registers that are set after power up
void hdmi_powerup()
{
//	hdmi_write( 0x41, hdmi_read(0x41) & 0xbf);	// Power up, write 0 to power bit

	// Power up
	hdmi_write( 0x41, 0x10);

	// Write fixed HDMI start up registers
	hdmi_write( 0x98, 0x03 );
	hdmi_write( 0x9a, 0xe0 );
	hdmi_write( 0x9c, 0x30 );
	hdmi_write( 0x9d, 0x61 );
	hdmi_write( 0xa2, 0xa4 );
	hdmi_write( 0xa3, 0xa4 );
	hdmi_write( 0xe0, 0xd0 );
	hdmi_write( 0xf9, 0x00 );
	// Video mode
	hdmi_write( 0x15, 0x00 );		// 24-bit 4:4:4
	hdmi_write( 0x16, 0x34 );
	hdmi_write( 0x17, 0x00 );		// 4:3 aspect

	// HDCP Encryption/DVI mode
	hdmi_write( 0xaf, 0x04 );		// DVI mode

	// Hot plug detection
	hdmi_write( 0x94, 0xc0 );		// Hot plug and monitor sense detection
	hdmi_write( 0xa1, 0x00 );		// Monitor sense, power up channels

}

void hdmi_powerdown()
{
	hdmi_write( 0x41, hdmi_read(0x41) | 0x40);	// Power down, write 1 to power bit
}

void hdmiProcessEvents()
{

	// If monitor sense and PD not high then power down transmitters if not already done
	if( ( ( hdmi_read(0x42) & 0x60 ) != 0x60 ) && !( hdmi_read( 0x41 ) & 0x40 ) )
	{
		hdmi_powerdown();
		DBG("HDMI power down");
		return;
	}

	// Has the hot plug or the monitor sense line changed, and not powered up?
	if(
		// And Monitor detect and HPD active
		( ( hdmi_read( 0x42 ) & 0x60 ) == 0x60 ) &&
		// and not powered up
		( ( hdmi_read( 0x41 ) & 0x40 ) ||
		// Or PLL lock loss
		( ( hdmi_read( 0x9e ) & 0x10 ) == 0 ) )
		)
	{
		hdmi_powerup();
		DBG("HDMI power up");
	}

}
