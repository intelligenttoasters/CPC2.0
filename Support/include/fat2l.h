/*
 * fat2l.h - Second layer for FAT file system
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


#ifndef INCLUDE_FAT2L_H_
#define INCLUDE_FAT2L_H_

#define FAT_SIGNATURE 	((uint64_t) 0xaa55BABECAFE55aa)
#define FAT_SYSBLK			0	// Logical block number of system block - can be used to offset start
#define FAT_BLKID_SYS		0
#define FAT_BLKID_FIRMWARE	1
#define FAT_BLKID_CONFIG	2
#define FAT_BLKID_OCCUPA	3
#define FAT_BLKID_ROMDESC	4
#define FAT_BLKID_ROMDATA	5
#define FAT_BLKID_RFU		6
#define FAT_BLKID_DISKDESC	7
#define FAT_BLKID_DISKDATA	8
#define FAT_BLKID_COUNT		9
#define	FAT_BLKID_SIZES		{8, 128, 8, 8, 64, 32768, (uint32_t) 262144, 448, (uint32_t) -1}

#define FAT_MAX_ROM			1024
#define FAT_MAX_DISK		7168
#define FAT_MAX_DISK_SIZE	1664		// In blocks
#define FAT_MAX_ROM_SIZE	32

#define FAT_ROM				0
#define FAT_DISK			1

// Convenience macros
#define FAT_BLKMAP_SIZE		((FAT_MAX_ROM+FAT_MAX_DISK)>>3)
#define FAT_READ			0
#define FAT_WRITE			1

struct fat_sys_block
{
	uint64_t 	signature;
	uint32_t 	total_blocks;
	uint32_t 	section_ptr[9];
	uint16_t	max_rom;
	uint16_t	max_disk;
	char 		unused[492];
};

struct fat_dirent
{
	char description[32][16];			// If first char is 0xff then no entry
};

struct fat_work
{
	Bool 		ready;
	uint8_t 	buffer[SDC_EMMC_BLOCKSIZE];
	uint32_t 	total_blk;
	uint8_t 	blkmap[FAT_BLKMAP_SIZE];
	uint32_t 	section_ptr[9];
	uint16_t	maxrom;
	uint16_t	usedrom;
	uint16_t	maxdisk;
	uint16_t	useddisk;
	uint32_t	open_file_ptr;
	uint16_t	open_file_cntr;
};

Bool fatInit();
Bool fatWriteBlkMap(struct fat_work *);
Bool fatReadBlkMap(struct fat_work *);
Bool fatReadSysBlk(struct fat_work *);
Bool fatOpen(struct fat_work *, char, uint16_t, char);
Bool fatClose(struct fat_work *);
Bool fatReformat(struct fat_work *, uint32_t);
Bool fatReadBlock(struct fat_work *, char *);
Bool fatWriteBlock(struct fat_work *, char *);
uint16_t fatFindFree( struct fat_work *, char );
Bool fatSetContent(struct fat_work *, char, uint16_t, char * );
Bool fatGetDescription(struct fat_work *, char, uint16_t, char * );
Bool fatCopyROM(struct fat_work *, uint16_t, unsigned char);
Bool fatGetConfig(char *, int);
Bool fatPutConfig(char *, int);
void fatGetMaximums(uint16_t *, uint16_t *);

#endif /* INCLUDE_FAT2L_H_ */
