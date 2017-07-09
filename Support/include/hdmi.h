/*
 * i2c.h
 *
 * <one line to give the program's name and a brief idea of what it does.>
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

#ifndef INCLUDE_HDMI_H_
#define INCLUDE_HDMI_H_

#define I2C_PORT 0x20
#define HDMI_I2C_ADDR (0x72 >> 1)

#define i2c_addr(NUM) ((NUM << 4) & 0x70)

#define i2cWriteReg( reg, data ) OUT( I2C_PORT | ((reg) & 0x0f), data )
#define i2cReadReg( reg ) IN(I2C_PORT | ((reg) & 0x0f))
inline void i2cWait(void);
void hdmi_init();
uint8_t hdmi_read( uint8_t port );
void hdmi_write( uint8_t port, uint8_t value );
void hdmi_powerup(void);
void hdmiProcessEvents(void);

#include "i2c_master.h"

#endif /* INCLUDE_HDMI_H_ */
