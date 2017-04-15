/*
 * flash.c
 *
 * Created: 4/12/2016 1:27:03 PM
 *  Author: paul
 */ 

#include "asf.h"
#include "main.h"

//#define BLOCK_OFFSET 100
#define BLOCK_OFFSET 200

// NAND Flash management structure
static struct nand_flash_ecc nf_ecc;

void flash_init()
{
	nand_flash_ecc_initialize( &nf_ecc, 0, BOARD_NF_COMMAND_ADDR, BOARD_NF_ADDRESS_ADDR, BOARD_NF_DATA_ADDR );
}

Ctrl_status flash_test_unit_ready(void)
{
	return CTRL_GOOD;
}

Ctrl_status flash_read_capacity(U32 * size)
{
	*size = PAGES_PER_BLOCK * NUM_BLOCKS;
	return CTRL_GOOD;
}

bool flash_wr_protect(void)
{
	return false;
}

Ctrl_status flash_mem_2_ram (U32 addr, void *ram)
{	
	U16 block = addr >> LOG2_PAGES_PER_BLOCK;
	U16 page = addr & ((1<<LOG2_PAGES_PER_BLOCK)-1);

	if( ( nand_flash_ecc_read_page(&nf_ecc, block + BLOCK_OFFSET, page, ram, globals.flash_spare) == 0 ) && (globals.flash_spare[0] == 0xff) )
		return CTRL_GOOD;
	
	return CTRL_FAIL;
}

Ctrl_status flash_ram_2_mem (U32 addr, const void *ram)
{	
	U16 block = addr >> LOG2_PAGES_PER_BLOCK;
	U16 page = addr & ((1<<LOG2_PAGES_PER_BLOCK)-1);
	
	if( page == 0 )	// First page write, then erase block
	{
		if( nand_flash_raw_erase_block(&nf_ecc.raw, block + BLOCK_OFFSET ) != 0 )
			return CTRL_FAIL;
		
	}
	// Clear spare / don't write to spare	
	memset(globals.flash_spare,255,SPARE_SIZE);
	
	if( nand_flash_ecc_write_page(&nf_ecc, block + BLOCK_OFFSET, page, ram, globals.flash_spare) == 0 )
		return CTRL_GOOD;

	return CTRL_FAIL;
}

