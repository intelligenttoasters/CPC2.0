/*
 * sdc.c - SDC Interface
 *
 * Interface to SD Card
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
#include "string.h"

// TODO: Remove
#pragma disable_warning 85

struct sd_response * cmd_buffer;

Bool sdcAbort;

void sdcInternalCallback(uint32_t user, struct sd_response * b)
{
	char card_state;

	// Some errors?
	if( b->state != SUCCESS )
	{
		b->state = DEAD;
		console("Error initialising eMMC");
		return;
	}

	// Check card state - should be in standby
	card_state = ( ( b->last_response >> 9 ) & 0xf );
	if( card_state != 3 )
	{
		sprintf(CB,"eMMC is ready, but not in standby state??? (%d)", card_state);
		console(CB);
		return;
	}

	// Otherwise all good!
	console("eMMC initialised");

	// Set the speed
	sdcSetClk(SDC_CLK_12M);		// TODO: Must be a switch to go high speed - more errors when fast

	// Find the last block for IOCTL operations
	sdcSetLastBlk(sdcGetLastBlk());

	// All done!
	b->state = IDLE;
}

void sdcInit(struct sd_response * buffer)
{
	sprintf(CB,"Initialising SDC controller, voltage %ldmV",
			sdcGetReg(SDC_REG_VOLTAGE) );
	console(CB);

	sdcSetReg(SDC_REG_RESET, 1);
	sdcSetClk(SDC_CLK_400);
	sdcSetIFBits(SDC_BITS1);
	sdcSetReg( SDC_REG_RESET, 0);
	sdcSetReg( SDC_REG_CMD_TIMEOUT, 256 );
	sdcSetReg( SDC_REG_DATA_TIMEOUT, 20000);
	sdcSetReg(SDC_REG_CMD_EV_ENABLE,SDC_CEV_ANY);	// Set events enable for all
	sdcSetReg(SDC_REG_DATA_EV_ENABLE,SDC_DEV_ANY);	// Set events enable for all

	buffer->head = 0;
	buffer->tail = 0;
	buffer->state = INITIALISING;
	cmd_buffer->retries = 0;
	buffer->last_operation = '-';					// No operation yet
	buffer->lastblk = 0;

	// Store sd_response pointer for processEvents
	cmd_buffer = buffer;

	// Initialise eMMC
	sdcQueueCmd(
			SDC_CMD(0, SDC_CMD_NO_TFR, SDC_CMD_NOCHK_CMD,
			SDC_CMD_NOCHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_NONE ), 0x00000000,
			sdcInternalCallback, 0, SDC_MASK_NONE, 0, SDC_STATUS_NOWAIT);
	// Send Op Conditions
	sdcQueueCmd(
			SDC_CMD(1, SDC_CMD_NO_TFR, SDC_CMD_NOCHK_CMD,
			SDC_CMD_NOCHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ), 0x40FF8000,
			sdcInternalCallback, 1, 0x80000000, 0x80000000, SDC_STATUS_WAIT);
	// Send CID
	sdcQueueCmd(
			SDC_CMD(2, SDC_CMD_NO_TFR, SDC_CMD_NOCHK_CMD,
			SDC_CMD_NOCHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_LONG ), 0x00000000,
			sdcInternalCallback, 2, 0, 0, SDC_STATUS_NOWAIT);
	// Set Address
	sdcQueueCmd(
			SDC_CMD(3, SDC_CMD_NO_TFR, SDC_CMD_CHK_CMD,
			SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ),
			((uint32_t) SDC_EMMC_ADDR<<16),
			sdcInternalCallback, 3, 0x00000100, 0x00000100, SDC_STATUS_WAIT);
	// Wait for 'Ready for data' - bit 8 of CSR
	sdcQueueCmd( SDC_CMD(13, SDC_CMD_NO_TFR, SDC_CMD_CHK_CMD,
			SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ),
			((uint32_t) SDC_EMMC_ADDR<<16),
			sdcInternalCallback, 13, 0x00000100, 0x00000100, SDC_STATUS_WAIT);

	// This queue gets processed in processEvents()

}

void sdcSetReg( unsigned char reg, uint32_t data )
{
#ifdef DEBUG
	// Registers are on a 4-byte word boundary, so error out if lower bits are not zero
	if( reg & 3 ) {
		DBG("SDC register is not word aligned");
		return;
	}
#endif

	// Set the address registers
	OUT( (unsigned char) SDC_REG_A, reg);
	OUT( SDC_REG_A+1, 0);
	OUT( SDC_REG_A+2, 0);
	OUT( SDC_REG_A+3, 0);

	// Set the data registers
	OUT( SDC_REG_D, 	(data >> 0 ) & 0xff);
	OUT( SDC_REG_D+1, 	(data >> 8 ) & 0xff);
	OUT( SDC_REG_D+2, 	(data >> 16 ) & 0xff);
	OUT( SDC_REG_D+3, 	(data >> 24 ) & 0xff);

	// Set the control registers
	OUT( SDC_REG_C,	SDC_CTL_GO | SDC_CTL_WE | SDC_CALC_SEL(0xf));

}

uint32_t sdcGetReg( unsigned char reg )
{
#ifdef DEBUG
	// Registers are on a 4-byte word boundary, so error out if lower bits are not zero
	if( reg & 3 ) {
		DBG("SDC register is not word aligned");
		return -1;
	}
#endif

	// Set the address registers
	OUT( SDC_REG_A, reg);
	OUT( SDC_REG_A+1, 0);
	OUT( SDC_REG_A+2, 0);
	OUT( SDC_REG_A+3, 0);

	// Set the control registers
	OUT( SDC_REG_C,	SDC_CTL_GO | SDC_CALC_SEL(0xf));

	// Wait for the operation to finish
	while( IN(SDC_REG_S) & SDC_STAT_BUSY ) NOP();

	// Get the data registers
	return 	(uint32_t) IN( SDC_REG_D+0 ) << 0 	|
			(uint32_t) IN( SDC_REG_D+1 ) << 8 	|
			(uint32_t) IN( SDC_REG_D+2 ) << 16 |
			(uint32_t) IN( SDC_REG_D+3 ) << 24;

}

// Set the clock output speed
// Div = 1/2 input clock / input value+1
void sdcSetClk( unsigned char div)
{
	sprintf(CB,"Clocking SDC controller to %ldHz", (SDC_SRC_CLK>>1) / (div+1) );
	console(CB);

	sdcSetReg( SDC_REG_CLOCK_DIVIDER, div);

}

void sdcSetIFBits( unsigned char b )
{
	if( ( b != SDC_BITS4 ) && (b != SDC_BITS1 ) )
	{
		DBG("Invalid SDC bit setting");
		return;
	}
	sprintf(CB,"Changing SDC controller to %c bits", (b == SDC_BITS4) ? '4' : '1' );
	console(CB);
	sdcSetReg( SDC_REG_CONTROL, b);
}

void sdcWaitEvent( unsigned char ev )
{
	while( ! ( sdcGetReg(SDC_REG_CMD_EV_STATUS) & ev ) );
}

void sdcClearEvents()
{
	while( ( sdcGetReg(SDC_REG_CMD_EV_STATUS) & SDC_CEV_ANY ) )
		sdcSetReg( SDC_REG_CMD_EV_STATUS, 0 );
	while( ( sdcGetReg(SDC_REG_DATA_EV_STATUS) & SDC_DEV_ANY ) )
		sdcSetReg( SDC_REG_DATA_EV_STATUS, 0 );
	sdcAbort = false;
}

// Queue a command for processing
// Use SDC_CMD macro to create 32-bit command
void sdcQueueCmd( 	uint32_t cmd, uint32_t arg, void(*cb)(uint32_t, struct sd_response *), uint32_t user,
					uint32_t response_mask, uint32_t response,
					Bool waitResult)
{
	struct sd_queue * p;

#ifdef DEBUG
	// Check there's space in the queue
	if( sdcQueueFull(cmd_buffer) )
	{
		DBG("SDC Queue is full");
		return;
	}
	if(cmd_buffer->state == DEAD)
	{
		DBG("Card is not in a usable state");
		return;
	}
#endif

	// Add an item to the queue
	p = &cmd_buffer->queue[(cmd_buffer->head&7)];
	p->cmd = cmd;
	p->arg = arg;
	p->callback = cb;
	p->user = user;
	p->mask = response_mask;
	p->response = response;
	p->wait = waitResult;
	cmd_buffer->head = (cmd_buffer->head + 1) & 0xf;
}

Bool sdcQueueFull( struct sd_response * p)
{
	return ((((p->head)&7)==((p->tail)&7))&&(p->head!=p->tail));
}

Bool sdcQueueEmpty( struct sd_response * p)
{
	return (p->head==p->tail);
}
inline void sdcClearQueue()
{
	if(( cmd_buffer->state != DEAD )&&( cmd_buffer->state != INITIALISING ))
	{
		cmd_buffer->head = cmd_buffer->tail = 0;
		cmd_buffer->state = IDLE;
	}
}

// Send a command - command structure, response type, buffer for response
// Use SDC_CMD macro to create 32-bit command
void sdcSendCmd( uint32_t cmd, uint32_t arg )
{
	sdcClearEvents();

	// Send commmand structure generated with SDC_CMD macro
	sdcSetReg(SDC_REG_COMMAND, cmd );
	// send argument - triggers core to start transmitting
	sdcSetReg(SDC_REG_ARGUMENT, arg );
}
inline Bool sdcIsBusy()
{
	return ( cmd_buffer->state == BUSY );
}
inline Bool sdcIsReady()
{
	return ( cmd_buffer->state == SUCCESS );
}

void sdcProcessCallback(uint32_t user, struct sd_response * b)
{
//	DBG("Process Error Analysis, CMD: %ld Last Result: %08lx Success:%d User:%ld", b->last_cmd, b->last_response, b->state, user);
	sdcAbort = 1;
}

void sdcProcessEvents(void)
{
	void (* callback)(uint32_t, struct sd_response *);
	struct sd_queue * p;
	uint32_t r;

	// Get a handle to the queue item
	p = &cmd_buffer->queue[cmd_buffer->tail&7];

	// What if there is a command in progress?
	if( ( cmd_buffer->state == IDLE ) || ( cmd_buffer->state == INITIALISING ) )
	{
		// Nothing to process if head and tail are the same
		if( cmd_buffer->head == cmd_buffer->tail ) return;

		// Mark busy
		cmd_buffer->state = BUSY;

		// Send the actual command
		sdcSendCmd(p->cmd, p->arg);

		return;

	} else if( cmd_buffer->state == BUSY ) {
		// Is there a command action?
		r = (sdcGetReg(SDC_REG_CMD_EV_STATUS) & SDC_CEV_ANY);
		if( r )
		{
			// Save the last item
			cmd_buffer->last_cmd = p->cmd;
			cmd_buffer->last_arg = p->arg;
			cmd_buffer->last_response = sdcGetReg( SDC_REG_RESPONSE0 );
			cmd_buffer->last_user = p->user;

			// If there's a failure , retry several times then call back with state failed
			if( r & SDC_CEV_ERROR )
			{
				sprintf(CB, "SDC Hard Error :%08lx", r );
				console(CB);
				if( cmd_buffer->retries < SDC_MAX_RETRIES )
				{
					//DBG("Hard retry");
					cmd_buffer->retries++;
					sdcSendCmd(p->cmd, p->arg);
					return;
				} else {													// Else fail
					sdcClearQueue();
					sdcClearEvents();
					// Get current card status - wait for tran state
					sdcQueueCmd( SDC_CMD(13, SDC_CMD_NO_TFR, SDC_CMD_CHK_CMD,
							SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ),
							((uint32_t) SDC_EMMC_ADDR<<16),
							sdcProcessCallback, 13, 0x00000900, 0x00000900, SDC_STATUS_WAIT);
					while(sdcAbort == false) sdcProcessEvents();
					cmd_buffer->state = FAILED;
					callback = p->callback;
					callback(p->user, cmd_buffer);
					return;
				}
			}

			// Got through so reset the retry counter
			cmd_buffer->retries = 0;

			//DBG("C: %ld, %08lx & %08lx = %08lx EV:%08lx", p->user, cmd_buffer->last_response, p->mask, p->response, r);
			// Check mask
			if( (cmd_buffer->last_response & p->mask) != p->response )
			{
				// Check for retry
				if( p->wait )
				{
					//DBG("Retrying");
					sdcSendCmd(p->cmd, p->arg);
					return;
				}
				// Failed check
				sprintf(CB, "SDC unexpected response :%08lx", cmd_buffer->last_response);
				console(CB);
				sdcClearQueue();
				cmd_buffer->state = FAILED;
				callback = p->callback;
				callback(p->user, cmd_buffer);
				return;
			}
			// Success, so move to next queued item
			cmd_buffer->tail = (cmd_buffer->tail + 1) & 0xf;

			// If there's another queued item, then initiate that
			if( !sdcQueueEmpty( cmd_buffer ) )
			{
				p = &cmd_buffer->queue[cmd_buffer->tail&7];

				sdcSendCmd(p->cmd, p->arg);
			} else {	// No more queued items
				cmd_buffer->state = SUCCESS;
				// Call the callback
				callback = p->callback;
				callback(p->user,cmd_buffer);
			}
		}
	}
}

// Direction Callback
void sdcDirectionCallback(uint32_t user, struct sd_response * b)
{
#ifdef DEBUG
	if( b->state != SUCCESS )
	DBG("Direction Error, CMD: %ld Last Result: %08lx Success:%d User:%ld", b->last_cmd, b->last_response, b->state, user);
#endif
	sdcAbort = true;
}

// Deselects and reselects card for switching from RD 'R', WR 'W' or Erase 'E'
void sdcSetDirection(struct sd_response * p, char op)
{
	// Make sure the queue is clear
	sdcClearQueue();
	sdcClearEvents();

	if( p->last_operation != op )
	{
		//DBG(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Switch Direction <<<<<<<<<<<<<<<<<<<<<<<<<<<<");
		if( p->last_operation != '-' )
		{
			sdcQueueCmd( SDC_CMD(7, SDC_CMD_NO_TFR, SDC_CMD_NOCHK_CMD, // No response for desel
					SDC_CMD_NOCHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_NONE ), 0x00000000,
					sdcDirectionCallback, 7, 0x00000000, 0x00000000, SDC_STATUS_NOWAIT);

			// Get current card status - wait for standby state
			sdcQueueCmd( SDC_CMD(13, SDC_CMD_NO_TFR, SDC_CMD_CHK_CMD,
					SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ),
					((uint32_t) SDC_EMMC_ADDR<<16),
					sdcDirectionCallback, 13, 0x00000700, 0x00000700, SDC_STATUS_WAIT);
		}

		// Select card
		sdcQueueCmd(SDC_CMD(7, SDC_CMD_NO_TFR, SDC_CMD_CHK_CMD,
					SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ),
					((uint32_t) SDC_EMMC_ADDR<<16),
					sdcDirectionCallback, 7, 0x00000100, 0x00000100, SDC_STATUS_WAIT);

		// Wait for commands finish
		while( sdcAbort == false ) sdcProcessEvents();
	}
	p->last_operation = op;
}

// Read Callback
void sdcReadCallback(uint32_t user, struct sd_response * b)
{
#ifdef DEBUG
	if( b->state != SUCCESS )
	DBG("Read Error, CMD: %ld Last Result: %08lx Success:%d User:%ld", b->last_cmd, b->last_response, b->state, user);
#endif
	sdcAbort = true;
}

// Read a block asynchronously into a blockram buffer
Bool sdcReadBlock( struct sd_response * p, uint32_t blk, char * buffer)
{
	uint32_t x;

	// If last operation was NOP or Write
	sdcSetDirection(p,'R');

	// Make sure the queue is clear
	sdcClearQueue();
	sdcClearEvents();

	// Get current card status - wait for tran state
	sdcQueueCmd( SDC_CMD(13, SDC_CMD_NO_TFR, SDC_CMD_CHK_CMD,
			SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ),
			((uint32_t) SDC_EMMC_ADDR<<16),
			sdcReadCallback, 13, 0x00000900, 0x00000900, SDC_STATUS_WAIT);

	// Read a block
	sdcQueueCmd( SDC_CMD(17, SDC_CMD_RD_TFR, SDC_CMD_CHK_CMD,
			SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ), blk,
			sdcReadCallback, 17, 0x00000100, 0x00000100, SDC_STATUS_NOWAIT);

	// Wait for transfer finish - status is 0 when engine not "IDLE"
	while( sdcGetReg( SDC_REG_DATA_EV_STATUS) == 0 ) sdcProcessEvents();

	// Top 16 bits of Card Satus hold most of the error bits, make sure they're zero
	if ( ( cmd_buffer->state == SUCCESS ) && ((cmd_buffer->last_response>>16) == 0) )
	{
		// Copy data from buffer to main memory
		sdcTfrIn( buffer );
		return true;
	} else return false;
}

// Transfer the SDC data from temporary block ram to main memory
void sdcTfrIn( char * buffer )
{
	OUT( SDC_BRS_AL, 0 );
	OUT( SDC_BRS_AH, 0 );
	OUT( SDC_BRS_C, SDC_BRS_RD );
	INIe(SDC_BRS_D, buffer, SDC_EMMC_BLOCKSIZE);
	OUT( SDC_BRS_C,SDC_BRS_TERM);
}

// Transfer the SDC data from main memory to temporary block ram
void sdcTfrOut( char * buffer )
{
	OUT( SDC_BRS_AL, 0 );
	OUT( SDC_BRS_AH, 0 );
	OUT( SDC_BRS_C, SDC_BRS_WR );
	OUTIe(SDC_BRS_D, buffer, SDC_EMMC_BLOCKSIZE);
	OUT( SDC_BRS_C,SDC_BRS_TERM);
}

// Write Callback
void sdcWriteCallback(uint32_t user, struct sd_response * b)
{
#ifdef DEBUG
	if( b->state != SUCCESS )
	{
		DBG("Write Error, CMD: %ld Last Result: %08lx Success:%d User:%ld", b->last_cmd, b->last_response, b->state, user);
	}
#endif
}

// Read a block asynchronously into a blockram buffer
Bool sdcWriteBlock( struct sd_response * p, uint32_t blk, char * buffer)
{
	uint32_t x,y;

	// If last operation was NOP or Write
	sdcSetDirection(p,'W');

	// Copy data from buffer to main memory
	sdcTfrOut( buffer );

	// Make sure the queue is clear
	sdcClearQueue();
	sdcClearEvents();

	// Get current card status - wait for tran state
	sdcQueueCmd( SDC_CMD(13, SDC_CMD_NO_TFR, SDC_CMD_CHK_CMD,
			SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ),
			((uint32_t) SDC_EMMC_ADDR<<16),
			sdcWriteCallback, 13, 0x00000900, 0x00000900, SDC_STATUS_WAIT);

	// Write a block
	sdcQueueCmd( SDC_CMD(24, SDC_CMD_WR_TFR, SDC_CMD_CHK_CMD,
			SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ), blk,
			sdcWriteCallback, 24, 0x00000100, 0x00000100, SDC_STATUS_NOWAIT);

	// Wait for transfer finish - status is 0 when engine not "IDLE"
	while(sdcGetReg( SDC_REG_DATA_EV_STATUS) == 0) sdcProcessEvents();

	// Top 16 bits of Card Satus hold most of the error bits, make sure they're zero
	return ( ( cmd_buffer->state == SUCCESS ) && ((cmd_buffer->last_response>>16) == 0) );
}

// If you know what it is, set last blk here. Otherwise use disk_getlastblk to find it
uint32_t sdcSetLastBlk(uint32_t blk)
{
	// Check the last block provided is correct
	if( sdcReadBlock(cmd_buffer, blk, CB) ) return (cmd_buffer->lastblk = blk);
	else {
		DBG("Invalid last block provided");
		return 0;
	}
}

uint32_t sdcGetLastBlk()
{
	uint32_t top_block = SDC_MAX_BLOCKS, bottom_block = 0, checkblk = SDC_MAX_BLOCKS>>1;

	if( cmd_buffer->lastblk == 0 )
	{
		console("Seeking last block of storage");
		while( true )
		{
			if( !sdcReadBlock(cmd_buffer, checkblk, CB ) )
			{
				top_block = checkblk - 1;
				if( ( top_block == bottom_block ) || (top_block - bottom_block <= 1) )
				{
					sprintf(CB, "Found last block %lu, capacity is %luMB", bottom_block, bottom_block>>11);
					console(CB);
					return bottom_block;
				}
				checkblk = ((top_block - bottom_block) >> 1) + bottom_block;
			} else {
				if( ( top_block == bottom_block ) || (top_block - bottom_block <= 1) )
				{
					sprintf(CB, "Found last block %lu, capacity is %luMB", checkblk, checkblk>>11);
					console(CB);
					return checkblk;
				}
				bottom_block = checkblk;
				checkblk = ((top_block - bottom_block) >> 1) + bottom_block;
			}
		}
	} else {
		return cmd_buffer->lastblk;
	}
}

// Erase Callback
void sdcEraseCallback(uint32_t user, struct sd_response * b)
{
	sdcAbort = true;
}
// Erase blocks on the eMMC
void sdcBlockErase(struct sd_response * p, uint32_t first, uint32_t last)
{
	uint32_t x;

	console("Initiating eMMC erase");

	sdcSetDirection(p, 'E');

	// Make sure the queue is clear
	sdcClearQueue();
	sdcClearEvents();

	// Get current card status - wait for tran state
	sdcQueueCmd( SDC_CMD(13, SDC_CMD_NO_TFR, SDC_CMD_CHK_CMD,
			SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ),
			((uint32_t) SDC_EMMC_ADDR<<16),
			sdcEraseCallback, 13, 0x00000900, 0x00000900, SDC_STATUS_WAIT);
	// Set erase block low
	sdcQueueCmd( SDC_CMD(35, SDC_CMD_NO_TFR, SDC_CMD_CHK_CMD,
			SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ),
			first,
			sdcEraseCallback, 35, 0x00000900, 0x00000900, SDC_STATUS_WAIT);
	// Set erase block high
	sdcQueueCmd( SDC_CMD(36, SDC_CMD_NO_TFR, SDC_CMD_CHK_CMD,
			SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ),
			last,
			sdcEraseCallback, 36, 0x00000900, 0x00000900, SDC_STATUS_WAIT);
	// Do erase
	sdcQueueCmd( SDC_CMD(38, SDC_CMD_NO_TFR, SDC_CMD_CHK_CMD,
			SDC_CMD_CHK_CRC,SDC_CMD_NOCHK_BUSY,SDC_CMD_R_SHORT ),
			0, sdcEraseCallback, 38, 0x00000900, 0x00000900, SDC_STATUS_WAIT);

	// Wait for last command to finish
	while(!sdcAbort) sdcProcessEvents();

	console("Erase complete");
}
