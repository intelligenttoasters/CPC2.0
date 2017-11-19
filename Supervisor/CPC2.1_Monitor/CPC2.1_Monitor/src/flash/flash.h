/*
 * flash.h
 *
 * Created: 4/12/2016 1:25:11 PM
 *  Author: paul
 */ 


#ifndef FLASH_H_
#define FLASH_H_

void flash_init(void);
Ctrl_status flash_test_unit_ready(void);
Ctrl_status flash_read_capacity(U32 *);
bool flash_wr_protect(void);
Ctrl_status flash_mem_2_ram (U32 addr, void *ram);
Ctrl_status flash_ram_2_mem (U32 addr, const void *ram);

#define LOG2_PAGE_SIZE			11
#define LOG2_PAGES_PER_BLOCK	6
#define LOG2_BLOCK_SIZE			(LOG2_PAGE_SIZE + LOG2_PAGES_PER_BLOCK)
#define NUM_BLOCKS				8192
#define LOG2_SPARE_SIZE			6

#define PAGE_SIZE		(1 << LOG2_PAGE_SIZE)
#define SPARE_SIZE		(1 << LOG2_SPARE_SIZE)
#define PAGES_PER_BLOCK		(1 << LOG2_PAGES_PER_BLOCK)
#define BLOCK_SIZE		(1 << LOG2_BLOCK_SIZE)
#define MEM_SIZE		(NUM_BLOCKS * BLOCK_SIZE)

#endif /* FLASH_H_ */