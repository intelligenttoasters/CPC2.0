/*
 * fpga.h
 *
 * Created: 19/11/2016 3:45:30 PM
 *  Author: paul
 */ 


#ifndef FPGA_H_
#define FPGA_H_

#include "asf.h"

// Start reconfiguration of the FPGA
bool toggle_nconfig(void);

// Send some data down the data lines and toggle the clock
//static inline void dclk(unsigned char data);

// Set up the IO lines for FPGA
void init_fpga_ports(void);

// Program the FPGA
void pgm_fpga_from_usb(char *);

// Reset the FPGA ready for programming
void reset_fpga(void);

// Store a FPGA image in flash
void store_flash_image(void);

// Load a FPGA image from flash
void load_flash_image(void);

#endif /* FPGA_H_ */