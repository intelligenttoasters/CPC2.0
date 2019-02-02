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


#ifndef INCLUDE_PHY_H_
#define INCLUDE_PHY_H_

// USB controller port
#define USB_PORT			0x60

// Port address registers
#define USB_REG_DATA		(USB_PORT | 0x00)
#define USB_REG_ID			(USB_PORT | 0x01)
#define USB_RXD				(USB_PORT | 0x0c)
#define USB_CTL				(USB_PORT | 0x0f)	// Write
#define USB_STAT			(USB_PORT | 0x0f)	// Read

// Control bits
#define USB_CTL_WRITE		(1<<0)
#define USB_CTL_READ		(1<<1)

// Status bits
#define USB_STAT_DONE		(1<<4)

// RXD Bits
#define USB_SPEED_LOW		0x02
#define USB_SPEED_HIGH		0x01
#define USB_SPEED_NC		0x00
#define USB_SPEED_MASK		0x03
#define USB_SPEED() ( phy_rxd() & USB_SPEED_MASK )

// Registers
#define USB_VEN_LOW			0x00
#define USB_VEN_HIGH		0x01
#define USB_PRD_LOW			0x02
#define USB_PRD_HIGH		0x03
#define USB_FUNCTION		0x04
#define USB_INTERFACE		0x07
#define USB_OTG				0x0a
#define USB_INT_RISE		0x0d
#define USB_INT_FALL		0x10
#define USB_INT_STATUS		0x13
#define USB_INT_LATCH		0x14
#define USB_DEBUG			0x15
#define USB_SCRATCH			0x16

// Register moderators
#define USB_MOD_SET			1
#define USB_MOD_CLEAR		2

void phy_init(void);
char phy_reg_read(char);
void phy_reg_write(char, char);

inline char phy_status(void) { return IN(USB_STAT); }
inline char phy_rxd(void) { return IN(USB_RXD); }

#endif /* INCLUDE_PHY_H_ */
