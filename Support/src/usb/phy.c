/*
 * phy.c - Physical interface handler
 *
 * Handles the physical interface to USB
 *
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
#include "stdio.h"

void phy_init(void)
{
	// Reset
// TODO: why not work - hang
//	phy_reg_write(USB_FUNCTION+USB_MOD_SET, 0x20);

	// IDs
	sprintf(CB,"USB Vendor %02x%02x:%02x%02x",
			phy_reg_read(USB_VEN_HIGH), phy_reg_read(USB_VEN_LOW),
			phy_reg_read(USB_PRD_HIGH), phy_reg_read(USB_PRD_LOW)
			);
	console(CB);

	// Clear all interrupt bits
	phy_reg_write(USB_INT_RISE + USB_MOD_CLEAR,0xff);
	phy_reg_write(USB_INT_FALL + USB_MOD_CLEAR,0xff);

	// Drive 5V supply, pull down data
	phy_reg_write(USB_OTG, 0x26);

	// Default interface control
	phy_reg_write(USB_INTERFACE, 0x00);

	// Enable low speed transceiver, with pull downs
	phy_reg_write(USB_FUNCTION, 0x46);

#ifdef DEBUG
	// POC test on scratch
	phy_reg_write(USB_SCRATCH, 0x55);
	printf("USB Scratch test result: %02x\n", phy_reg_read(USB_SCRATCH));
#endif

}

// Read a register from the USB3300 controller
uint8_t phy_reg_read(uint8_t reg)
{
	// Select register
	OUT( USB_REG_ID, reg );
	// Trigger read process
	OUT( USB_CTL, USB_CTL_READ );
	// Wait for finish
	while( ! ( IN(USB_STAT) & USB_STAT_DONE ) ) NOP();
	// Return data
	return IN( USB_REG_DATA );
}

// Write a register to the USB3300 controller
void phy_reg_write(uint8_t reg, uint8_t data)
{
	// Select register
	OUT( USB_REG_ID, reg );
	// Provide output data
	OUT( USB_REG_DATA, data );
	// Trigger write process
	OUT( USB_CTL, USB_CTL_WRITE );
	// Wait for finish
	while( ! ( IN(USB_STAT) & USB_STAT_DONE ) ) NOP();
}

