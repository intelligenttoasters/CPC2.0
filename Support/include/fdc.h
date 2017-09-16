/*
 * fdc.h - Header file for FDC controller
 *
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

#ifndef INCLUDE_FDC_H_
#define INCLUDE_FDC_H_

#define FDC_IO 			0x40
#define FDC_DATA 		(FDC_IO | 0x0)
#define FDC_STATUS 		(FDC_IO | 0x1)
#define FDC_CTL 		(FDC_IO | 0x1)
#define FDC_HU			(FDC_IO | 0x2)
#define FDC_TR			(FDC_IO | 0x4)
#define FDC_SC			(FDC_IO | 0x5)
#define FDC_FB			(FDC_IO | 0x7)
#define FDC_TP			(FDC_IO | 0xd)
#define FDC_HRESULT		(FDC_IO | 0xe)
#define FDC_ID 			(FDC_IO | 0xf)
#define FDC_RDY_BIT		(1<<6)
#define FDC_RDY			1
#define FDC_OPCODE_MASK	0x1f

void fdcProcessEvents(void);
void fdcInit(void);
void fdcMount();
void fdcUnmount();

#endif /* INCLUDE_FDC_H_ */
