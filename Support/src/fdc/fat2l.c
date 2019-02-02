/*
 * fat2l.c - Second layer for FAT file system
 *
 * Sits on top of the eMMC/SD layer
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

#include "stdio.h"
#include "string.h"
#include "include.h"

#define thenDIE(msg) return returnError(msg)

const char _NOINIT_[] = "NOINIT";
const char _NOFILE_[] = "NOFILE";

// Count the bits
char bitCount(char b)
{
	char r = 0, c = 0;

	for( c = 0; c<8; c++ )
	{
		if( b&1 ) r++;
		b = b>>1;
	}
	return r;
}


Bool returnError( char * msg )
{
	DBG( "Action failed: %s", msg );
	return false;
}

// Initialise the FAT FS on top of the SD/MMC layer
Bool fatInit()
{
	struct fat_work * f = &globals()->fat;
	struct fat_sys_block * b = (struct fat_sys_block *) f->buffer;
	uint32_t blkids[FAT_BLKID_COUNT] = FAT_BLKID_SIZES;
	unsigned char cntr;
	uint32_t work, work1, work2;
	uint16_t per1, per2;

	// Set up
	f->ready = false;

	if( !sdcReadBlock(&globals()->sd_buf, FAT_SYSBLK, (char*) b) )
		thenDIE("Fatal error: can't read eMMC root block" );

	if( b->signature != FAT_SIGNATURE )
	{
		console("File system signature not found - creating new file system");

		// Create a blank block
		memset(b,0,SDC_EMMC_BLOCKSIZE);

		// Calculate the block maps
		b->section_ptr[0] = (work = FAT_SYSBLK);
		for( cntr=1; cntr<FAT_BLKID_COUNT; cntr++ )
			work = (b->section_ptr[cntr] = work + blkids[cntr-1]);

		// Set up base parameters
		b->signature = FAT_SIGNATURE;
		// Discard lower 3 bits - round down to 8 blks
		b->total_blocks = sdcGetLastBlk();
		b->max_rom = FAT_MAX_ROM;

		// Calculate actual MAX disk
		work1 = ((b->total_blocks - b->section_ptr[FAT_BLKID_DISKDATA]) / FAT_MAX_DISK_SIZE) - 1;
		work1 &= 0xfffffff8;	// Must be a multiple of 8 disks for the disk map to work
		b->max_disk = min(work1, FAT_MAX_DISK);

		sprintf(b->unused, "CPC2 - File System V1 2018-12-28");

		// Write the block out
		if( !sdcWriteBlock(&globals()->sd_buf, FAT_SYSBLK, (char*) b) )
			thenDIE("Fatal Error creating system block");

		// Create the block map
		fatReadSysBlk(f);
		memset(f->blkmap, 0, FAT_BLKMAP_SIZE );
		fatWriteBlkMap(f);

		// Complete
		console("Format complete");

	}
	// Read the system block and populate working area
	fatReadSysBlk(f);
	// Read the block map
	fatReadBlkMap(f);
	// Signal ready
	globals()->fat.ready = true;

	// Calculate percentage
	work1 = f->useddisk;
	work1 = work1 * 100;
	per1 = work1 / f->maxdisk;

	// Calculate percentage
	work2 = f->usedrom;
	work2 = work2 * 100;
	per2 = work2 / f->maxrom;

	// Reset working variables
	f->open_file_ptr = 0;

	// Check for number of blocks since formatting
	if( f->total_blk < sdcGetLastBlk() )
		thenDIE("FATAL: storage size changed since formatting");

	// Print storage stats
	sprintf(CB, "Storage status:\n\t\tROMs  : %u of %u (%u%% full)\n\t\tDisks : %u of %u (%u%% full)",
	f->usedrom, f->maxrom, per2, f->useddisk, f->maxdisk, per1);
	console(CB);

	f->ready = true;

	return true;
}

Bool fatWriteBlkMap(struct fat_work * f)
{
	if( !sdcWriteBlock(&globals()->sd_buf, f->section_ptr[FAT_BLKID_OCCUPA],
			f->blkmap ) ) thenDIE("Error writing BlkMap#1");
	if( !sdcWriteBlock(&globals()->sd_buf, f->section_ptr[FAT_BLKID_OCCUPA]+1,
			f->blkmap+SDC_EMMC_BLOCKSIZE ) ) thenDIE("Error writing BlkMap#2");
	return true;
}

Bool fatReadBlkMap(struct fat_work * f)
{
	int cntr, r;
	uint8_t * p;

	if( !sdcReadBlock(&globals()->sd_buf, f->section_ptr[FAT_BLKID_OCCUPA],
			f->blkmap ) ) thenDIE("Error reading BlkMap#1");
	if( !sdcReadBlock(&globals()->sd_buf, f->section_ptr[FAT_BLKID_OCCUPA]+1,
			f->blkmap+SDC_EMMC_BLOCKSIZE ) ) thenDIE("Error reading BlkMap#2");

	// Count the number of 1-bits
	p = f->blkmap;

	// Start with ROMs
	r = 0;
	for( cntr=0; cntr<f->maxrom>>3; cntr++) r += bitCount(*(p++));
	f->usedrom = r;

	// Then move onto disks
	r = 0;
	for( cntr=0; cntr<f->maxdisk>>3; cntr++) r += bitCount(*(p++));
	f->useddisk = r;
	return true;
}

Bool fatReadSysBlk(struct fat_work * f)
{
	struct fat_sys_block * b = (struct fat_sys_block *) f->buffer;
	char cntr;

	if( !sdcReadBlock(&globals()->sd_buf, FAT_SYSBLK, (char *) b) )
		thenDIE("Fatal Error reading system block");

	// Store main characteristics
	f->total_blk = b->total_blocks;
	for( cntr=0; cntr<FAT_BLKID_COUNT; cntr++ )
		f->section_ptr[cntr] = b->section_ptr[cntr];
	//f->section_ptr
	f->maxrom = b->max_rom;
	f->usedrom = (uint16_t) -1;
	f->maxdisk = b->max_disk;
	f->useddisk = (uint16_t) -1;

	return true;
}

Bool fatCheckPop( struct fat_work * f, uint16_t id )
{
	uint16_t gross = id >> 3;
	uint8_t mask = 1<<(id & 7);
	return (f->blkmap[gross] & mask);
}

Bool fatStdChecks(struct fat_work * f, char type, uint16_t id, Bool checkpop)
{
	if( !f->ready ) thenDIE(_NOINIT_);

	if( type == FAT_ROM )
	{
		if( id >= f->maxrom ) thenDIE(_NOFILE_);
	} else {
		if( id >= f->maxdisk ) thenDIE(_NOFILE_);
	}

	if( checkpop )
		if( !fatCheckPop( f, (type == FAT_ROM) ? id : f->maxrom + id ) ) thenDIE(_NOFILE_);

	return true;
}

Bool fatOpen(struct fat_work * f, char type, uint16_t id, char op)
{
	uint32_t p;

	if( !fatStdChecks(f,type,id, (op == FAT_READ ) ) ) return false;

	p = f->section_ptr[(type == FAT_ROM) ? FAT_BLKID_ROMDATA : FAT_BLKID_DISKDATA];

	if( type == FAT_ROM ) {
		f->open_file_ptr = p + (id * FAT_MAX_ROM_SIZE);
		f->open_file_cntr = FAT_MAX_ROM_SIZE;
	} else {
		f->open_file_ptr = p + (id * FAT_MAX_DISK_SIZE);
		f->open_file_cntr = FAT_MAX_DISK_SIZE;
	}

	return true;
}

Bool fatClose(struct fat_work * f )
{
	if( !f->ready ) thenDIE(_NOINIT_);

	if( f->open_file_ptr )
	{
		f->open_file_ptr = 0;
		f->open_file_cntr = 0;
		return true;
	}
	else return false;
}

Bool fatReformat(struct fat_work * f, uint32_t security_key)
{
	if( security_key != 0xdeadbeef) return false;

	sdcBlockErase(&globals()->sd_buf,0,f->total_blk);

	return fatInit();

}

// Read a block from the selected file, must be SDC_EMMC_BLOCKSIZE
Bool fatReadBlock(struct fat_work * f, char * buffer)
{
	if( ( f->open_file_cntr == 0 ) || ( f->open_file_ptr == 0 ) ) return false;

	if( !sdcReadBlock( &globals()->sd_buf, f->open_file_ptr, buffer) )
		thenDIE("Error reading file");

	f->open_file_cntr--;
	f->open_file_ptr++;

	return true;
}

// Write a block to the selected file, must be SDC_EMMC_BLOCKSIZE
Bool fatWriteBlock(struct fat_work * f, char * buffer)
{
	if( ( f->open_file_cntr == 0 ) || ( f->open_file_ptr == 0 ) ) return false;

	if( !sdcWriteBlock( &globals()->sd_buf, f->open_file_ptr, buffer) )
		thenDIE("Error writing file");

	f->open_file_cntr--;
	f->open_file_ptr++;

	return true;
}

// Find a free ROM or disk slot
uint16_t fatFindFree( struct fat_work * f, char type)
{
	int cntr, remain;
	char work, cntr2;
	uint16_t ret;

	// Default return value for failure
	ret = (uint16_t) -1;

	// Calculate the BYTES not bits to work through
	if( type == FAT_ROM ) {
		cntr = 0;
		remain = (f->maxrom>>3);
	} else {
		cntr = (f->maxrom>>3);
		remain = (f->maxdisk>>3);
	}

	// Locate a free slot
	for( ; remain > 0; remain-- )
	{
		if( ( work = f->blkmap[cntr] ) != 0xff )
		{
			// Found byte, find bit
			if( type == FAT_ROM )
				ret = (cntr << 3);
			else
				ret = ((cntr - (f->maxrom>>3))<<3);

			cntr2 = 0;
			while( work & 1 )
			{
				work = work >> 1;
				cntr2++;
			}
			ret |= cntr2;
			break;
		}
		cntr++;
	}
	return ret;
}

// Populates a rom or disk
Bool fatSetContent(struct fat_work * f, char type, uint16_t id, char * descr )
{
	uint32_t blk;
	uint16_t p, gross, fine;
	char cntr;
	char name[33];

	if( !fatStdChecks(f, type, id, false ) ) return false;

	// First populate the blockmap
	if( type == FAT_ROM ) p = id;
	else p = f->maxrom + id;

	// Calculate the byte and bit offsets
	gross = p >> 3;
	fine = 1<<(p&7);

	// If description is NULL then blank the entry, else mark populated
	if( descr == NULL )
		f->blkmap[gross] &= ~fine;
	else
		f->blkmap[gross] |= fine;

	// Save the updates
	fatWriteBlkMap(f);

	// If we're blanking the position, do nothing more
	if( descr == NULL ) return true;

	// Now save the description
	if( type == FAT_ROM )
		blk = f->section_ptr[FAT_BLKID_ROMDESC];
	else
		blk = f->section_ptr[FAT_BLKID_DISKDESC];

	gross = id >> 4;			// Calculate block offset
	fine = (id & 15)<<5;		// 32 bytes per description, offset inside blk
	blk += gross;				// Contains the calculated disk blk number

	// Read the data, update and write back
	sdcReadBlock(&globals()->sd_buf, blk, f->buffer);
	strncpy(name,descr,32);		// Copy up to 32 characters
	// Pad name with spaces
	for( cntr = strlen(descr); cntr<32; cntr++ ) name[cntr] = ' ';
	memcpy( f->buffer + fine, name, 32 );	// Write name
	sdcWriteBlock(&globals()->sd_buf, blk, f->buffer);

	return true;
}

// Get a ROM or disk description
// Buffer must be 33 characters long to accommodate string terminator
Bool fatGetDescription(struct fat_work * f, char type, uint16_t id, char * descr )
{
	uint32_t blk;
	uint16_t gross, fine;

	if( !fatStdChecks(f, type, id, true ) ) return false;

	// Now get the description
	if( type == FAT_ROM )
		blk = f->section_ptr[FAT_BLKID_ROMDESC];
	else
		blk = f->section_ptr[FAT_BLKID_DISKDESC];

	gross = id >> 4;			// Calculate block offset
	fine = (id & 15)<<5;		// 32 bytes per description, offset inside blk
	blk += gross;				// Contains the calculated disk blk number

	// Read the data, update and write back
	sdcReadBlock(&globals()->sd_buf, blk, f->buffer);
	memcpy(descr,f->buffer + fine, 32);		// Copy up to 32 characters
	descr[32] = 0;
	return true;
}

// Copy a ROM from eMMC to working storage
Bool fatCopyROM(struct fat_work * f, uint16_t rom_id, unsigned char rom_loc)
{
	unsigned char c;

	if( rom_loc > ROM_LOWER ) {
		DBG("Invalid ROM location specified only 0-63 + ROM_LOWER is valid");
		return false;
	}

	// Open the file if valid
	if( ! fatOpen(f, FAT_ROM, rom_id, FAT_READ) ) return false;

	// Diag message
	sprintf(CB,"Copying ROM from eMMC(%d) to ROM %d", rom_id, rom_loc);
	console(CB);

	// Set the ROM location
	romSetWriteAddress(rom_loc);

	// Copy the data from eMMC to SRAM in SDC_EMMC_BLOCKSIZE byte chunks
	for( c = 0; c<32; c++ )
	{
		fatReadBlock(f, f->buffer);
		romSendData(f->buffer, SDC_EMMC_BLOCKSIZE);
	}

	return true;
}

// Populate the config
Bool fatGetConfig(char * buffer, int size)
{
	uint32_t p = globals()->fat.section_ptr[FAT_BLKID_CONFIG];
	uint16_t cntr = size;

	while(cntr>0)
	{
		if( !sdcReadBlock(&globals()->sd_buf, p, globals()->fat.buffer) ) return false;
		memcpy(buffer,globals()->fat.buffer,min(cntr,SDC_EMMC_BLOCKSIZE));
		p++;
		buffer += SDC_EMMC_BLOCKSIZE;
		cntr -= min( cntr, SDC_EMMC_BLOCKSIZE);
	}
	return true;
}
Bool fatPutConfig(char * buffer, int size)
{
	uint32_t p = globals()->fat.section_ptr[FAT_BLKID_CONFIG];
	uint16_t cntr = size;

	while(cntr>0)
	{
		memset(globals()->fat.buffer,0,SDC_EMMC_BLOCKSIZE);
		memcpy(globals()->fat.buffer,buffer,min(cntr,SDC_EMMC_BLOCKSIZE));
		if( !sdcWriteBlock(&globals()->sd_buf, p, globals()->fat.buffer) ) return false;
		p++;
		buffer += SDC_EMMC_BLOCKSIZE;
		cntr -= min( cntr, SDC_EMMC_BLOCKSIZE);
	}
	return true;
}

void fatGetMaximums(uint16_t * roms, uint16_t * disks)
{
	if( roms != NULL ) *roms = globals()->fat.maxrom;
	if( disks != NULL ) *disks = globals()->fat.maxdisk;
}
