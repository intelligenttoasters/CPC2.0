/*
 * fdc.c - Manage
 *
 * Manages the FDC
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

#define SECTORS 9
#define TRACKS 4
#define SECID 0xc1
#define SECSIZE 512

unsigned char idbyte = SECID;
uint8_t mounted = 1;

struct sector {
	uint8_t data[SECSIZE];
};

struct track {
	struct sector sectors[SECTORS];
};

struct disk {
	struct track onetrack[TRACKS];
};

struct disk mydisk;

void fdcMount() {
	mounted = 1;
	console("Mounted disk");
}

void fdcUnmount() {
	mounted = 0;
	console("Unmounted disk");
}

#define fdcMounted() (mounted == 1)

void fdcInit(void)
{
	char buf[80];
	sprintf(buf, "Initializing mydisk: %d bytes", sizeof(struct disk));
	console(buf);
	sprintf(buf,"mydisk location: %p", &mydisk);
	console(buf);
	// Formats fake disk
	memset( &mydisk, 0xe5, sizeof(struct disk) );
}

void fdcProcessEvents(void)
{
	unsigned char d = IN(FDC_STATUS);
	uint8_t sc, tr, tp, fb;
	char buf[80];

	// Reset status first
	OUT( FDC_HRESULT, 0x00 );

	if( d & FDC_RDY_BIT )
	{
		d &= FDC_OPCODE_MASK;
		sc = IN(FDC_SC);
		tr = IN(FDC_TR);
		fb = IN(FDC_FB);
		switch(d)
		{
			case 0x03: {
				console("FDC Set DMA");
				break;
			}
			case 0x05: {
				if( !fdcMounted() )
				{
					console("FDC Tried to read sector while unmounted");
					OUT( FDC_HRESULT, 0x05 );
				}
				else
				if( (sc & 0xf0) != (idbyte & 0xf0) )
				{
					console("FDC Tried to read wrong sector ID");
					OUT( FDC_HRESULT, 0x04 );
				}
				else
				{
					sprintf(buf,"FDC Write sector %02x", sc); console(buf);
					if( tr < TRACKS )
					{
						INI( FDC_DATA, mydisk.onetrack[tr].sectors[sc - SECID].data, 256 );
						INI( FDC_DATA, mydisk.onetrack[tr].sectors[sc - SECID].data+256, 256 );
					}
				}
				break;
			}
			case 0x06: {
				if( !fdcMounted() )
				{
					console("FDC Tried to write sector while unmounted");
					OUT( FDC_HRESULT, 0x05 );
				}
				else
				if( (sc & 0xf0) != (idbyte & 0xf0) )
				{
					console("FDC Tried to write wrong sector ID");
					OUT( FDC_HRESULT, 0x04 );
				}
				else
				{
					sprintf(buf,"FDC Read sector %02x", sc); console(buf);
					if( tr < TRACKS )
					{
						OUTI( FDC_DATA, mydisk.onetrack[tr].sectors[sc - SECID].data, 256 );
						OUTI( FDC_DATA, mydisk.onetrack[tr].sectors[sc - SECID].data+256, 256 );
					}
				}
				break;
			}
			case 0x07: {
				if( !fdcMounted() )
				{
					console("FDC Tried to recalibrate while unmounted");
					OUT( FDC_HRESULT, 0x03 );
				}
				else
				sprintf(buf, "FDC Recal drive: %02d", IN(FDC_HU)); console(buf);
				break;
			}
			case 0x08: {
				if( !fdcMounted() )
				{
					console("FDC Tried to sense.int while unmounted");
					OUT( FDC_HRESULT, 0x07 );
				}
				else
				console("FDC Sense Int");
				break;
			}
			case 0x0a: {
				if( !fdcMounted() )
				{
					console("FDC Tried to read ID while unmounted");
					OUT( FDC_HRESULT, 0x05 );
				}
				else
				{
					console("FDC Read ID");
					OUT( FDC_ID, idbyte );
				}
				break;
			}
			case 0x0d: {
				if( !fdcMounted() )
				{
					console("FDC Tried to format while unmounted");
					OUT( FDC_HRESULT, 0x05 );
				}
				else
				{
					sprintf(buf, "FDC Format Track :%02d", IN(FDC_TP)); console(buf);
					if( tr < TRACKS )
					{
						IN(FDC_DATA); IN(FDC_DATA);
						idbyte = (IN(FDC_DATA) & 0xf0) | 1;	// Get first sector
						sprintf(buf, "FDC set ID byte to %02x", idbyte); console(buf);
						memset( &mydisk.onetrack[tr], fb, SECTORS*SECSIZE );
					}
				}
				break;
			}
			case 0x0f: {
				tp = IN(FDC_TP);
				if( !fdcMounted() )
				{
					console("FDC Tried to seek while unmounted");
					OUT( FDC_HRESULT, 0x05 );
				}
				else
				if( tp >= TRACKS )
				{
					sprintf(buf,"FDC tried to seek beyond end of disk: %02d",tp); console(buf);
					OUT( FDC_HRESULT, 0x04 );
				}
				else
				sprintf(buf,"FDC Seek track %02d", tp); console(buf);
				break;
			}
			case 0x11:
			case 0x19:
			case 0x1d: {
				sprintf(buf, "FDC unimplemented opcode :%02x", d); console(buf);
				break;
			}
			default: {
				sprintf(buf, "FDC Invalid opcode %02x", d); console(buf);
			}
		}
		OUT(FDC_CTL,FDC_RDY);
	}
}
