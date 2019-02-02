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

// FDC IO Constants
#define FDC_IO 			0x40
#define FDC_DATA 		(FDC_IO | 0x0)
#define FDC_STATUS 		(FDC_IO | 0x1)
#define FDC_CTL 		(FDC_IO | 0x1)
#define FDC_HU			(FDC_IO | 0x2)	// Unit/drive
#define FDC_TR			(FDC_IO | 0x4)	// Track
#define FDC_SC			(FDC_IO | 0x5)	// First sector
#define FDC_FB			(FDC_IO | 0x7)	// Fill byte/format
#define FDC_S0			(FDC_IO | 0x8)	// S0
#define FDC_S1			(FDC_IO | 0x9)	// S1
#define FDC_S2			(FDC_IO | 0xa)	// S2
#define FDC_S3			(FDC_IO | 0xb)	// S3
#define FDC_NM			(FDC_IO | 0xc)	// Number of sectors
#define FDC_TP			(FDC_IO | 0xd)	// Physical track
#define FDC_HRESULT		(FDC_IO | 0xe)	// Operation result
#define FDC_ID 			(FDC_IO | 0xf)
#define FDC_RDY_BIT		(1<<6)
#define FDC_RDY			1
#define FDC_OPCODE_MASK	0x1f

// HRESULT Codes
#define FDC_HRESULT_NO_ERROR 	0x00
#define FDC_HRESULT_NOT_READY 	0x01
#define FDC_HRESULT_RECAL_FAIL 	0x02
#define FDC_HRESULT_ID_NOTFOUND 0x04
#define FDC_HRESULT_PROTECTED	0x08

// FDC Constants
#define FDC_MEMORY_ID		ROMMGR_INST_VID
#define FDC_MEMORY_BASE		0x100000			// After video buffers
#define FDC_SECTOR_SIZE		0x200
#define FDC_DRIVES			4
#define FDC_A				0
#define FDC_B				1
#define FDC_C				2
#define FDC_D				3
#define FDC_MAX_TRACKS 		82
#define FDC_MAX_SECTORS		10
#define FDC_SIDES			2
#define FDC_DISK_RESERVE	((uint32_t)FDC_SECTOR_SIZE * FDC_MAX_SECTORS * FDC_MAX_TRACKS * FDC_SIDES)
#define FDC_TRACK_RESERVE	((uint32_t)FDC_SECTOR_SIZE * FDC_MAX_SECTORS * FDC_SIDES)
#define FDC_DRIVE_BUFFER(dr) 	((uint32_t)(FDC_MEMORY_BASE + (FDC_DISK_RESERVE * dr)))
// Where are the drive status blocks stored?
#define FDC_DRIVE_STATBLK	(FDC_DRIVE_BUFFER(FDC_DRIVES))						// Right after sector data
#define FDC_DRIVE_TRACKS	(FDC_DRIVE_STATBLK + sizeof(struct fdc_statblk))	// Right after disk status block
#define FDC_TRACKINFO_SIZE	(sizeof(struct fdc_track)*FDC_SIDES)
#define FDC_CALC_DATA_ADDR(dr,hu,tr,sc)	(FDC_DRIVE_BUFFER(dr) + (FDC_TRACK_RESERVE * tr) + (FDC_SECTOR_SIZE * (sc + (FDC_MAX_SECTORS*hu))))
#define FDC_CALC_PTRACK_INFO(dr,tr) (FDC_DRIVE_TRACKS+(FDC_TRACKINFO_SIZE*FDC_MAX_TRACKS*dr)+(FDC_TRACKINFO_SIZE * tr))
#define FDC_CALC_HD(hu)		((hu>>2)&1)

#define FDC_MAGIC			"CPC-Disk Inf"
#define FDC_BLANK_SPECIAL	0x8000
#define FDC_BLANK_1S42		( FDC_BLANK_SPECIAL | 0 )
#define FDC_BLANK_1S82		( FDC_BLANK_SPECIAL | 1 )
#define FDC_BLANK_2S42		( FDC_BLANK_SPECIAL | 2 )
#define FDC_BLANK_2S82		( FDC_BLANK_SPECIAL | 3 )
#define FDC_BLANK_1S40		FDC_BLANK_1S42
#define FDC_BLANK_1S80		FDC_BLANK_1S82
#define FDC_BLANK_2S40		FDC_BLANK_2S42
#define FDC_BLANK_2S80		FDC_BLANK_2S82

#define FDC_NO_SLOT			0xffff			// eMMC storage slot not allocated yet

void fdcProcessEvents(void);
void fdcInit(void);
void fdcMount(unsigned char, uint16_t,char *);
void fdcUnmount(unsigned char);
Bool fdcMounted(unsigned char);
void fdcSeekTrack(unsigned char, unsigned char);
void fdcRecalibrate( unsigned char );
Bool fdcFlushMeta( unsigned char );
Bool fdcLoadMeta( unsigned char, unsigned char );
void fdcLoadTrack( unsigned char, unsigned char);
void fdcUnloadTrack( unsigned char, unsigned char);
Bool fdcChanged(unsigned char);
Bool fdcStoreDisk(unsigned char, uint16_t);
Bool fdcLoadDisk(unsigned char, uint16_t);

// Sector and track information
struct fdc_sector {
	uint8_t log_track;
	uint8_t id_byte;
	uint8_t log_head;
	uint32_t sector_data_address;		// Quick pointer to address to save later calcs
};

struct fdc_track {
	Bool formatted;
	uint8_t num_sectors;
	struct fdc_sector sectors[FDC_MAX_SECTORS];
};

struct fdc_status {
	// This data is paged in/out from memory when track seek happens to reduce memory usage
	struct fdc_track one_track[FDC_SIDES];
	uint8_t phy_track;		// 255/TRACK_NOT_LOADED - not loaded or current loaded one_track
	Bool track_changed;
	uint8_t num_tracks;
	uint8_t num_heads;
	Bool write_protect;
	Bool mounted;
	Bool changed;
	uint32_t slot;			// What storage slot do we save back to?
	char descr[33];			// Description for new disks
};

struct fdc_disk_storage {
	uint8_t num_tracks;
	uint8_t num_heads;
	Bool write_protect;
};

#define TRACK_NOT_LOADED 255

struct fdc_statblk {
	char magic[12];						// "CPC-Disk Inf"
	struct fdc_status status[FDC_DRIVES];
	// Align on a boundary
	char unused[16-(((sizeof(struct fdc_status)*FDC_DRIVES) + 12) & 15)];
};

#endif /* INCLUDE_FDC_H_ */
