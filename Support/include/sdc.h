/*
 * sdc.h - SDC settings
 *
 * Compile time settings for SDC
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

#ifndef INCLUDE_SDC_H_
#define INCLUDE_SDC_H_

// eMMC relative address
#define SDC_EMMC_ADDR 0x0001
#define SDC_EMMC_BLOCKSIZE 512
#define SDC_MAX_RETRIES 2
#define SDC_MAX_BLOCKS	(2097152*8)	// 8GB max

// Multiplexer addresses - SD i/f
#define SDC_BASE 0xa0
#define SDC_REG_D (SDC_BASE|0x00)	// Data
#define SDC_REG_A (SDC_BASE|0x04)	// Address
#define SDC_REG_C (SDC_BASE|0x08)	// Control
#define SDC_REG_S (SDC_BASE|0x08)	// Status

// Control Bits
#define SDC_CTL_GO		0x80
#define SDC_CTL_WE		0x40
#define SDC_SEL_MASK	0x3C
#define SDC_SEL_SHIFT	2
#define SDC_CALC_SEL(d)	((d<<2)&SDC_SEL_MASK)

// Status Bits
#define SDC_STAT_BUSY	0x01


// Multiplexer addresses memory spooler
#define SDC_BRS_BASE 0xb0
#define SDC_BRS_AL (SDC_BRS_BASE|0x00)	// Address low
#define SDC_BRS_AH (SDC_BRS_BASE|0x01)	// Address high
#define SDC_BRS_D (SDC_BRS_BASE|0x08)	// Data In/Out
#define SDC_BRS_C (SDC_BRS_BASE|0x0f)	// Control
#define SDC_BRS_S (SDC_BRS_BASE|0x0f)	// Status

// Control Bits
#define SDC_BRS_RD		0x01
#define SDC_BRS_WR		0x02
#define SDC_BRS_TERM	0x80




// SD Controller Registers
#define SDC_REG_ARGUMENT 		0x00
#define SDC_REG_COMMAND	 		0x04
#define SDC_REG_RESPONSE0 		0x08
#define SDC_REG_RESPONSE1 		0x0c
#define SDC_REG_RESPONSE2 		0x10
#define SDC_REG_RESPONSE3 		0x14
#define SDC_REG_DATA_TIMEOUT	0x18
#define SDC_REG_CONTROL	 		0x1c
#define SDC_REG_CMD_TIMEOUT		0x20
#define SDC_REG_CLOCK_DIVIDER	0x24
#define SDC_REG_RESET	 		0x28
#define SDC_REG_VOLTAGE 		0x2c
#define SDC_REG_CAPABILITIES	0x30
#define SDC_REG_CMD_EV_STATUS	0x34
#define SDC_REG_CMD_EV_ENABLE	0x38
#define SDC_REG_DATA_EV_STATUS	0x3c
#define SDC_REG_DATA_EV_ENABLE	0x40
#define SDC_REG_BLK_SIZE 		0x44
#define SDC_REG_BLK_COUNT 		0x48
#define SDC_REG_DMA_ADDR 		0x60

// Event status bits
#define SDC_CEV_COMPL			0x01
#define SDC_CEV_ERROR			0x02
#define SDC_CEV_TIMEO			0x04
#define SDC_CEV_CRC				0x08
#define SDC_CEV_INDEX_E			0x10
#define SDC_CEV_ANY				0x1f
#define SDC_DEV_ANY				0x0f

// Misc
#define SDC_BITS1				0
#define SDC_BITS4				1
#define SDC_SRC_CLK				((uint32_t) 48000000)
#define SDC_CLK_100				239		// 100KHz
#define SDC_CLK_400				59		// 400KHz
#define SDC_CLK_12M				1		// 12MHz
#define SDC_CLK_24M				0		// 24MHz	- Beware! this didn't work on my chip

// SD Command defines
#define SDC_CMD_R_NONE			0		// Responses
#define SDC_CMD_R_SHORT			1		// Short (48 bit)
#define SDC_CMD_R_LONG			2		// Long (136 bit)
#define SDC_CMD_NOCHK_BUSY		0		// Check for busy flag or not
#define SDC_CMD_CHK_BUSY		1		// after command
#define SDC_CMD_NOCHK_CRC		0		// Check the CRC - a response with CRC needed
#define SDC_CMD_CHK_CRC			1
#define SDC_CMD_NOCHK_CMD		0		// Check the returned CMD, response must
#define SDC_CMD_CHK_CMD			1		// return the command for this to work
#define SDC_CMD_NO_TFR			0		// Transfer or not?
#define SDC_CMD_RD_TFR			1
#define SDC_CMD_WR_TFR			2

// Macros to construct command
#define SDC_CMD(cmd,tr,ci,crc,busy,resp) ((cmd&0x3f)<<8 | tr<<5 | ci<<4 | crc<<3 | busy<<2 | resp)

// Queue command macros
#define SDC_MASK_ALL			0xFFFFFFFF
#define SDC_MASK_NONE			0x00000000
#define SDC_STATUS_NOWAIT		false
#define SDC_STATUS_WAIT			true

enum sdc_state { IDLE, BUSY, FAILED, SUCCESS, INITIALISING, DEAD };

struct sd_queue
{
	uint32_t cmd;
	uint32_t arg;
	uint32_t user;
	void (* callback)(uint32_t, struct sd_response *);
	uint32_t mask;
	uint32_t response;
	Bool wait;						// Wait for result (such as busy)
};

struct sd_response
{
	struct sd_queue queue[8];		// Maximum 8 queued commands
	unsigned char head, tail;
	char * buffer;					// Pointer to working buffer
	char state;
	char retries;
	// 'R' or 'W' - if switched, then a mandatory CMD7 deselct, reselect to switch operations
	char last_operation;
	uint32_t last_cmd;
	uint32_t last_arg;
	uint32_t last_response;
	uint32_t last_user;
	uint32_t lastblk;
};

void sdcInit(struct sd_response *);
void sdcProcessEvents(void);
void sdcSetReg( unsigned char, uint32_t );
uint32_t sdcGetReg( unsigned char );
void sdcSetClk( unsigned char );
void sdcSetIFBits( unsigned char );
void sdcWaitEvent( unsigned char );
void sdcClearEvents(void);
void sdcSendCmd( uint32_t, uint32_t );
void sdcQueueCmd( uint32_t, uint32_t, void(*cb)(uint32_t, struct sd_response*), uint32_t, uint32_t, uint32_t, Bool );
Bool sdcQueueFull( struct sd_response * );
Bool sdcQueueEmpty( struct sd_response * );
Bool sdcIsBusy(void);
Bool sdcIsReady(void);
Bool sdcReadBlock( struct sd_response *, uint32_t, char *);
Bool sdcWriteBlock( struct sd_response *, uint32_t, char *);
void sdcClearQueue(void);
void sdcTfrIn( char * );
void sdcTfrOut( char * );
uint32_t sdcSetLastBlk(uint32_t);
uint32_t sdcGetLastBlk(void);
void sdcBlockErase(struct sd_response *, uint32_t, uint32_t);

#endif /* INCLUDE_SDC_H_ */
