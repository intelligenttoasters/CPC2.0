/*
 * fdc.c - Manage floppy operations
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

// Stores data on the drive status
struct fdc_statblk dsb;	// Drive status block

#ifdef DEBUG
#define thenDIE(x) { DBG(x); return false; }
#else
#define thenDIE(x) return false
#endif

const char _FDC_ERROR_FILE_[] = "Error opening disk file";
const char _FDC_ERROR_STREAM_[] = "Error streaming out";

// Streaming globals - internal use only
char fdcStreamBuffer[SDC_EMMC_BLOCKSIZE];
int fdcStreamPtr;
int fdcBufferRemain;

// Mount a blank or an existing disk. If blank, description is required in case of save
void fdcMount(unsigned char dr, uint16_t fileid, char * description) {
	unsigned char max_tracks, max_heads;
	struct fdc_status * status;
	uint16_t id;
	char cntr, *p;

	// Check drive for boundary values
	if( dr > FDC_DRIVES ) {
		DBG("Tried to mount invalid drive %d > %d", dr, FDC_DRIVES);
		return;
	}

	if( fdcMounted(dr) )
	{
		DBG("Tried to mount an already mounted drive %d", dr);
		return;
	}

	// Check for maximums
	if( !( fileid & FDC_BLANK_SPECIAL ) )
	{
		fatGetMaximums(NULL, &id);
		if( (fileid & ~FDC_BLANK_SPECIAL ) > id )
		{
			console("Invalid disk id");
			return;
		}
	}

	// Point to the status block for this drive
	status = &dsb.status[dr];

	// If the filename is a special mount then create a blank disk
	if( fileid & FDC_BLANK_SPECIAL )
	{
		if( description == NULL )
		{
			DBG("No file description assigned for new blank disk");
			return;
		}
		// Calculate the drive parameters
		switch(fileid)
		{
		case FDC_BLANK_1S82:
			max_tracks = 82;
			max_heads = 1;
			break;
		case FDC_BLANK_2S82:
			max_tracks = 82;
			max_heads = 2;
			break;
		case FDC_BLANK_2S42:
			max_tracks = 42;
			max_heads = 2;
			break;
		case FDC_BLANK_1S42:
		default:
			max_tracks = 42;
			max_heads = 1;
			break;
		}

		status->phy_track = TRACK_NOT_LOADED;
		status->changed = false;
		status->mounted = true;
		status->write_protect = false;
		status->num_tracks = max_tracks;
		status->num_heads = max_heads;
		status->slot = FDC_NO_SLOT;			// New disk - so no slot

		// Copy in description
		strncpy(status->descr, description, 32);
		p = status->descr;
		// Replace zero with space
		for( cntr=0; cntr<32; cntr++) {
			if(*p == 0) *p = ' ';
			p++;
		}
		status->descr[32] = 0;				// Terminate for output

		// Confirm status
		sprintf(CB,"Mounted blank disk %d",dr);
		console(CB);

		return;
	} else {
		console("Loading disk from eMMC");
		// Just in case of failure, don't leave half updated disk
		status->changed = false;
		status->phy_track = TRACK_NOT_LOADED;
		// Load the disk
		status->mounted = true;			// Assume success
		if( !fdcLoadDisk(dr, fileid ) )
		{
			status->mounted = false;
			console("Failed to mount disk");
		}
		else console("Mounted disk");
	}
}

void fdcUnmount(unsigned char dr) {
	struct fdc_status * stat;
	uint16_t slot;

	// Drive check
	if( dr > FDC_DRIVES ) {
		DBG("Tried to unmount invalid drive %d > %d", dr, FDC_DRIVES);
		return;
	}
	// Mount check
	if( !fdcMounted(dr) )
	{
		DBG("Tried to unmount empty drive %d", dr);
		return;
	}

	// Convenience handle
	stat = &dsb.status[dr];

	// Flush messages
	uartFlush();

	// If the disk has changed, then we need to write it back out to storage
	if( stat->changed )
	{
		console("Writing changed disk back to eMMC");
		outboundFlush();

		// Make sure any data is flushed back to backing memory
		fdcFlushMeta(dr);
		if( stat->slot == FDC_NO_SLOT )
		{
			slot = (stat->slot = fatFindFree(&globals()->fat, FAT_DISK));
			if( slot == -1 )
			{
				console("eMMC full - can't unmount");
				return;
			}
			// Set description
			fatSetContent(&globals()->fat,FAT_DISK , slot, stat->descr );
		}
		fdcStoreDisk(FDC_A, stat->slot);
		console("Stored disk back to eMMC");
	}
	stat->mounted = false;
	sprintf(CB,"Unmounted disk %d",dr);
	console(CB);
}

Bool fdcMounted(unsigned char dr) {
	if( dr > FDC_DRIVES ) {
		DBG("Tried to check mount invalid drive %d > %d", dr, FDC_DRIVES);
		return false;
	}
	return (dsb.status[dr].mounted == true);
}

Bool fdcChanged(unsigned char dr) {
	if( dr > FDC_DRIVES ) {
		DBG("Tried to check invalid drive %d > %d", dr, FDC_DRIVES);
		return false;
	}
	return (dsb.status[dr].changed == true);
}

// Flush the track meta data back to memory
Bool fdcFlushMeta(unsigned char dr) {
	struct fdc_status * status;

	// Drive check
	if( dr > FDC_DRIVES ) {
		DBG("Tried to flush invalid drive %d > %d", dr, FDC_DRIVES);
		return false;
	}

	// Check for a mount
	if( !fdcMounted(dr) )
	{
		console("FDC Tried to flush while unmounted");
		OUT( FDC_HRESULT, FDC_HRESULT_ID_NOTFOUND|FDC_HRESULT_NOT_READY );
		return false;
	}

	// Get a convenience handle to the drive status block
	status = &dsb.status[dr];

	// Do we have to unload a track?
	if( (status->phy_track != TRACK_NOT_LOADED) & (status->track_changed) )
	{
		DBG("Track changed, flushing meta back to memory");
		sramPut(FDC_MEMORY_ID, FDC_CALC_PTRACK_INFO(dr,status->phy_track),
				status->one_track, sizeof(struct fdc_track)*FDC_SIDES);
	}
	return true;
}

// Load the track meta data
Bool fdcLoadMeta(unsigned char dr,unsigned char tp) {
	struct fdc_status * status;

	// Drive check
	if( dr > FDC_DRIVES ) {
		DBG("Tried to unmount invalid drive %d > %d", dr, FDC_DRIVES);
		return false;
	}

	// Check for a mount
	if( !fdcMounted(dr) )
	{
		console("FDC Tried to seek while unmounted");
		OUT( FDC_HRESULT, FDC_HRESULT_ID_NOTFOUND|FDC_HRESULT_NOT_READY );
		return false;
	}

	// Get a convenience handle to the drive status block
	status = &dsb.status[dr];

	// Now load the track meta data for this track
	sramGet(FDC_MEMORY_ID, FDC_CALC_PTRACK_INFO(dr,tp), status->one_track,
			sizeof(struct fdc_track)*FDC_SIDES);

	return true;
}

void fdcInit(void)
{
	unsigned char loop;
	unsigned char dr, track, head, sector;
	struct fdc_status * status;
	struct fdc_track * onetrack;

	sprintf(CB,"Disk initialization, %d drives of max disk size %ld bytes, "
			"status block size %d bytes", FDC_DRIVES, FDC_DISK_RESERVE, sizeof(struct fdc_statblk));
	console(CB);
	// Read the disk status bytes from memory
	sramGet( FDC_MEMORY_ID, FDC_DRIVE_STATBLK, &dsb, sizeof(dsb));

	// Check MAGIC, if not there, initialise FDC memory
	if( strncmp(dsb.magic,FDC_MAGIC,12) != 0 )
	{
		console("Initialising drive status block");
		// Create the magic ID
		memcpy(dsb.magic, FDC_MAGIC, 12);
		for( loop = 0; loop < FDC_DRIVES; loop++ )
		{
			dsb.status[loop].mounted = false;
			dsb.status[loop].changed = false;
			dsb.status[loop].phy_track = TRACK_NOT_LOADED;
		}
	}

	// Populate the default addresses for all disks - once only on disk start
	for( dr = 0; dr < FDC_DRIVES; dr++ )
	{
		// Point to the status block for this drive
		status = &dsb.status[dr];

		for( track = 0; track < FDC_MAX_TRACKS; track++ )
		{
			for( head = 0; head < FDC_SIDES; head++ )
			{
				onetrack = &status->one_track[head];
				onetrack->formatted = false;
				onetrack->num_sectors = 0;		// Is set when formatting
				for( sector = 0; sector < FDC_MAX_SECTORS; sector++ )
				{
					// Set the absolute memory address for storing the sector data
					onetrack->sectors[sector].sector_data_address = FDC_CALC_DATA_ADDR(dr,head,track,sector);
				}
			}
			// Now write the track meta data to the memory
			sramPut(FDC_MEMORY_ID, FDC_CALC_PTRACK_INFO(dr,track),
					status->one_track, sizeof(struct fdc_track)*FDC_SIDES);
		}
	}

	// Seek track 0 on all mounted drives
	for( loop = 0; loop < FDC_DRIVES; loop++ )
	{
		// If mounted, then seek track 0
		if( dsb.status[loop].mounted ) fdcSeekTrack(loop,0);
	}
}

// Seek a track and load it's attributes to memory
void fdcSeekTrack(unsigned char dr, unsigned char tp)
{
	struct fdc_status * status;

	DBG("FDC Seek track [%d]%02d", dr, tp);

	// Drive check
	if( dr > FDC_DRIVES ) {
		DBG("Tried to unmount invalid drive %d > %d", dr, FDC_DRIVES);
		return;
	}

	// Check for a mount
	if( !fdcMounted(dr) )
	{
		console("FDC Tried to seek while unmounted");
		OUT( FDC_HRESULT, FDC_HRESULT_ID_NOTFOUND|FDC_HRESULT_NOT_READY );
		return;
	}

	// Get a convenience handle to the drive status block
	status = &dsb.status[dr];

	// Check for physical track
	if( tp >= status->num_tracks )
	{
		sprintf(CB,"FDC tried to seek beyond end of disk: [D%d]%02d", dr, tp);
		console(CB);
		OUT( FDC_HRESULT, FDC_HRESULT_RECAL_FAIL|FDC_HRESULT_RECAL_FAIL );
		return;
	}

	// Flush track meta-info
	if( !fdcFlushMeta(dr) ) return;

	// Load track meta-info
	if( !fdcLoadMeta(dr,tp) ) return;

	// Record which track we've read in
	status->phy_track = tp;
	status->track_changed = false;
}

// Locate track 0
void fdcRecalibrate( unsigned char dr)
{
	if( !fdcMounted(dr) )
	{
		console("FDC Tried to recalibrate while unmounted");
		OUT( FDC_HRESULT, FDC_HRESULT_ID_NOTFOUND | FDC_HRESULT_NOT_READY );
		return;
	}
	DBG("FDC Recal drive: %d", dr);

	// Now seek track 0 and read the track data
	fdcSeekTrack(dr,0);
}

/*
 * From http://www.cpcwiki.eu/index.php/765_FDC - don't check TR
 * In order to format, read or write a sector on a specific track you must first seek that track using command 0Fh.
 * That'll move the read/write head to the physical track number. If you don't do that then the FDC will attempt to
 * read/write data from/to the current physical track, irrespective of the specified logical track ID.
 */
struct fdc_sector * fdcFindSector(struct fdc_track * one_track, unsigned char side, unsigned char sc)
{
	unsigned char cntr;
	struct fdc_sector * sector;

	if( one_track->formatted ) for( cntr=0; cntr<one_track->num_sectors; cntr++)
	{
		sector = &one_track->sectors[cntr];
		if( (sector->log_head == side) && (sector->id_byte == sc ) ) return sector;
	}
	return NULL;
}

void fdcProcessEvents(void)
{
	unsigned char d = IN(FDC_STATUS);
	uint8_t sc, tr, tp, fb, nm, hu, sz, side;
	unsigned char cntr, dr; //, buf[80];
	struct fdc_status * status;
	struct fdc_track * one_track;
	struct fdc_sector * one_sector;

	// Reset status first
	OUT( FDC_HRESULT, FDC_HRESULT_NO_ERROR );

	if( d & FDC_RDY_BIT )
	{
		d &= FDC_OPCODE_MASK;
		hu = IN(FDC_HU);			// Head/Unit
		sc = IN(FDC_SC);			// Sector number
		tr = IN(FDC_TR);			// Track number
		fb = IN(FDC_FB);			// Fill byte
		nm = IN(FDC_NM);			// Number of sectors
		dr = hu & 0x03;				// Strip drive # from Head/Unit
		side = FDC_CALC_HD(hu);		// Get side
		tp = IN(FDC_TP);			// Physical track number

		// Point to the status block for this disk
		status = &dsb.status[dr];
		one_track = &status->one_track[side];

		DBG("FDC-CMD:%02x",d);
		switch(d)
		{
			case 0x03: {
				console("FDC Set DMA(NOP)");
				break;
			}
			case 0x04: {
				console("Sense Drive S3(NOP)");
				break;
			}
			// Write sector
			case 0x05: {
				if( !fdcMounted(dr) )
				{
					console("FDC Tried to write sector while unmounted");
					OUT( FDC_HRESULT, FDC_HRESULT_NOT_READY |FDC_HRESULT_ID_NOTFOUND);
				}
				else
				{
					if( status->write_protect )
					{
						console("FDC Tried to write protected disk");
						OUT( FDC_HRESULT, FDC_HRESULT_PROTECTED );
					} else {
						sprintf(CB,"FDC Write sector [D%d,H%d] %02x", dr, side, sc);
						console(CB);

						// Find the right sector from the logical values
						if( ( one_sector = fdcFindSector(one_track, side, sc) ) )
						{
							// Faster than INIe
							INI( FDC_DATA, CB, 256 );
							INI( FDC_DATA, CB+256, 256 );
							sramPut(FDC_MEMORY_ID, one_sector->sector_data_address, CB, FDC_SECTOR_SIZE);
							OUT( FDC_HRESULT, FDC_HRESULT_NO_ERROR );

							// Reset the status as we're writing
							status->track_changed = true;
							status->changed = true;

						} else {
							console("FDC Tried to write wrong sector/head/track ID");
							OUT( FDC_HRESULT, FDC_HRESULT_ID_NOTFOUND );
						}
					}
				}
				break;
			}
			// Read sector
			case 0x06: {
				if( !fdcMounted(dr) )
				{
					console("FDC Tried to read sector while unmounted");
					OUT( FDC_HRESULT, FDC_HRESULT_NOT_READY |FDC_HRESULT_ID_NOTFOUND );
				}
				else
				{
					sprintf(CB,"FDC Read sector [D%d,H%d] %02x", dr, side, sc);
					console(CB);

					if( ( one_sector = fdcFindSector(one_track, side, sc) ) )
					{
						sramGet(FDC_MEMORY_ID, one_sector->sector_data_address, CB, FDC_SECTOR_SIZE);
						OUTI( FDC_DATA, CB, 256 );
						OUTI( FDC_DATA, CB+256, 256 );
						OUT( FDC_HRESULT, FDC_HRESULT_NO_ERROR );
					} else {
						console("FDC Tried to read wrong sector/head/track ID");
						OUT( FDC_HRESULT, FDC_HRESULT_ID_NOTFOUND );
					}
				}
				break;
			}
			case 0x07: {
				fdcRecalibrate(dr);
				break;
			}
			case 0x08: {
				if( !fdcMounted(dr) )
				{
					console("FDC Tried to sense.int while unmounted");
					OUT( FDC_HRESULT, FDC_HRESULT_NOT_READY |FDC_HRESULT_ID_NOTFOUND );
				}
				else
				console("FDC Sense Int (NOP)");
				break;
			}
			case 0x0a: {
				if( !fdcMounted(dr) )
				{
					console("FDC Tried to read ID while unmounted");
					OUT( FDC_HRESULT, FDC_HRESULT_ID_NOTFOUND|FDC_HRESULT_NOT_READY );
				}
				else
				{
					fb = 0xff;
					if( status->phy_track != TRACK_NOT_LOADED )
					{
						one_track = &status->one_track[side];

						if( one_track->num_sectors > 0 )
						sc = one_track->sectors[0].id_byte;
						else sc = fb;
					} else sc = fb;

					// Return the ID byte
					OUT( FDC_ID, sc );
					sprintf(CB,"FDC Read ID : [%d]%02x", dr, sc);
					console(CB);
				}
				break;
			}
			case 0x0d: {
				if( !fdcMounted(dr) )
				{
					console("FDC Tried to format while unmounted");
					OUT( FDC_HRESULT, FDC_HRESULT_ID_NOTFOUND|FDC_HRESULT_NOT_READY );
				}
				else
				{
					if( status->write_protect )
					{
						console("FDC Tried to format protected disk");
						OUT( FDC_HRESULT, FDC_HRESULT_PROTECTED );
					} else {
						sprintf(CB, "FDC Format Track : [D%d,H%d] %02d", dr, side, IN(FDC_TP));
						console(CB);

						// Reset the status as we're reformatting
						status->track_changed = true;
						status->changed = true;

						// Updated track attrs
//						one_track = &status->one_track[FDC_CALC_HD(hu)];
						one_track->formatted = true;
						one_track->num_sectors = nm;

#ifndef DEBUG			// Can do it here if not debugging, more efficient
						// Blank sector buffer
						memset( CB, fb, FDC_SECTOR_SIZE );
#endif
						// Read the format data to determine the layout of the tracks
						for( cntr=0; cntr<nm; cntr++)
						{
							// Get the next per-sector logical attributes of these sectors
							tr = IN(FDC_DATA);
							side = IN(FDC_DATA);
							sc = IN(FDC_DATA);
							sz = IN(FDC_DATA);
							// Only on the first sector set attrs

							// Save the track data
							one_sector = &one_track->sectors[cntr];
							one_sector->id_byte = sc;				// Logical sector ID
							one_sector->log_head = side; 			// Logical side/head
							one_sector->log_track = tr;				// Logical track #
#ifdef DEBUG				// If debugging, this buffer gets overwritten
							// Blank sector buffer
							memset( CB, fb, FDC_SECTOR_SIZE );
#endif
							// Write sector to memory
							sramPut(FDC_MEMORY_ID, one_sector->sector_data_address, CB, FDC_SECTOR_SIZE);
						}
						OUT( FDC_HRESULT, FDC_HRESULT_NO_ERROR );
					}
				}
				break;
			}
			case 0x0f: {
				fdcSeekTrack(dr, tp);
				break;
			}
			case 0x11:
			case 0x19:
			case 0x1d: {
				sprintf(CB, "FDC unimplemented opcode :%02x", d);
				console(CB);
				break;
			}
			default: {
				sprintf(CB, "FDC Invalid opcode %02x", d);
				console(CB);
			}
		}
		OUT(FDC_CTL,FDC_RDY);
	}
}

Bool fdcStreamDataOut(char * buffer, int size )
{
	// Initial processing
	if( fdcBufferRemain == -1 )	fdcBufferRemain = SDC_EMMC_BLOCKSIZE; // Remaining space

	// Now process
	while( size > 0 ) {
		// Ready to stream?
		if( size >= fdcBufferRemain )
		{
			// Copy in just what will fit
			memcpy( &fdcStreamBuffer[fdcStreamPtr], buffer, fdcBufferRemain );
			if( !fatWriteBlock(&globals()->fat, fdcStreamBuffer) ) thenDIE(_FDC_ERROR_STREAM_);

			// Calculate what's left
			size -= fdcBufferRemain;
			buffer += fdcBufferRemain;		// This was a 2 day BUG!!! :(

			// Now reset the pointers to go around again
			fdcStreamPtr = 0;
			fdcBufferRemain = SDC_EMMC_BLOCKSIZE;

		} else {	// just copy into buffer
			memcpy( &fdcStreamBuffer[fdcStreamPtr], buffer, size );
			fdcStreamPtr += size;
			fdcBufferRemain -= size;
			size=0;
		}
	}

	return true;
}
Bool fdcStreamDataIn(char * buffer, int size )
{
	// Initial processing
	if( fdcBufferRemain == -1 )	// Pre-read
	{
		if( !fatReadBlock(&globals()->fat, fdcStreamBuffer) ) thenDIE(_FDC_ERROR_STREAM_);
		fdcBufferRemain = SDC_EMMC_BLOCKSIZE;
		fdcStreamPtr = 0;
	}
	while( size > 0 ) {
		// Ready to stream?
		if( size >= fdcBufferRemain )
		{
			// Copy out just what will fit
			memcpy( buffer, &fdcStreamBuffer[fdcStreamPtr], fdcBufferRemain );

			// Move buffer pointer
			buffer += min(fdcBufferRemain,size);

			// Calculate what's left
			size -= fdcBufferRemain;

			// Now read next block, reset the pointers to go around again
			if( !fatReadBlock(&globals()->fat, fdcStreamBuffer) ) thenDIE(_FDC_ERROR_STREAM_);
			fdcStreamPtr = 0;
			fdcBufferRemain = SDC_EMMC_BLOCKSIZE;
		} else {	// just copy into buffer
			memcpy( buffer, &fdcStreamBuffer[fdcStreamPtr], size );
			fdcStreamPtr += size;
			fdcBufferRemain -= size;
			size = 0;
		}
	}
	return true;
}
void fdcStreamClear()
{
	fdcStreamPtr = 0;
	fdcBufferRemain = -1;
}

void fdcStreamFlush()
{
	fatWriteBlock(&globals()->fat, fdcStreamBuffer);
	fdcStreamPtr = 0;
	fdcBufferRemain = -1;
}

// Stores the floppy disk structures to eMMC
Bool fdcStoreDisk(unsigned char drive, uint16_t slot)
{
	char track, side, sector;
	struct fdc_disk_storage disk;
	struct fdc_status * stat;
	struct fdc_track * tr;
	struct fdc_sector * sc;

	// Check drive
	if( drive > FDC_DRIVES ) thenDIE("Tried to store invalid drive");
	stat = &dsb.status[drive];

	// Open file - if possible
	if( !fatOpen(&globals()->fat, FAT_DISK, slot, FAT_WRITE) ) thenDIE(_FDC_ERROR_FILE_);

	// Reset the stream structure
	fdcStreamClear();

	// Now go through and process disk
	disk.num_heads = stat->num_heads;
	disk.num_tracks = stat->num_tracks;
	disk.write_protect = stat->write_protect;
	if( !fdcStreamDataOut( (char*) &disk, sizeof(disk) ) ) return false;

	for( track = 0; track < disk.num_tracks; track ++ )
	{
		fdcLoadMeta(drive, track);	// Get track info from memory
		for( side = 0; side < disk.num_heads; side++ )
		{
			tr = &stat->one_track[side];
			// Stream out track info, one side
			fdcStreamDataOut( (char*) tr, sizeof(struct fdc_track));
			// Stream out sector data
			for( sector = 0; sector < tr->num_sectors; sector++ )
			{
				sc = &tr->sectors[sector];
				// Stream out the data
				sramGet(FDC_MEMORY_ID, sc->sector_data_address, CB, FDC_SECTOR_SIZE);
				fdcStreamDataOut(CB, FDC_SECTOR_SIZE);
			}
		}
	}
	fdcStreamFlush();
	return true;
}

// Loads a disk image from eMMC
Bool fdcLoadDisk(unsigned char drive, uint16_t slot)
{
	char track, side, sector;
	struct fdc_disk_storage disk;
	struct fdc_status * stat;
	struct fdc_track * tr;
	struct fdc_sector * sc;

	// Check drive
	if( drive > FDC_DRIVES ) thenDIE("Tried to load invalid drive");
	stat = &dsb.status[drive];

	// Open file - if possible
	if( !fatOpen(&globals()->fat, FAT_DISK, slot, FAT_READ) ) thenDIE(_FDC_ERROR_FILE_);

	// Reset the stream structure
	fdcStreamClear();

	// Read the disk header
	if( !fdcStreamDataIn( (char*) &disk, sizeof(disk) ) ) return false;
	stat->num_heads = disk.num_heads;
	stat->num_tracks = disk.num_tracks;
	stat->write_protect = disk.write_protect;
	stat->slot = slot;

	// Process each track
	for( track = 0; track < disk.num_tracks; track ++ )
	{
		fdcLoadMeta(drive,track);
		for( side = 0; side < disk.num_heads; side++ )
		{
			tr = &stat->one_track[side];

			// Stream in track info, one side
			if( !fdcStreamDataIn( (char*) tr, sizeof(struct fdc_track) ) ) thenDIE(_FDC_ERROR_FILE_);

			// Stream in sector data
			for( sector = 0; sector < tr->num_sectors; sector++ )
			{
				sc = &tr->sectors[sector];
				// This attribute is invalid from the loaded data, so update it
				sc->sector_data_address = FDC_CALC_DATA_ADDR(drive,side,track,sector);
				// Stream in the data
				if( !fdcStreamDataIn(CB, FDC_SECTOR_SIZE) ) thenDIE(_FDC_ERROR_FILE_);
				sramPut(FDC_MEMORY_ID, sc->sector_data_address, CB, FDC_SECTOR_SIZE);
			}
		}
		// Flush to memory
		stat->phy_track = track;
		stat->track_changed = true;
		fdcFlushMeta(drive);	// Get track info from memory
	}
	return true;
}

