/**
 * \file
 *
 * \brief SAM4S Xplained Pro board configuration
 *
 * Copyright (C) 2012-2015 Atmel Corporation. All rights reserved.
 *
 * \asf_license_start
 *
 * \page License
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 * 3. The name of Atmel may not be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 * 
 * 4. This software may only be redistributed and used in connection with an
 *    Atmel microcontroller product.
 * 
 * THIS SOFTWARE IS PROVIDED BY ATMEL "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT ARE
 * EXPRESSLY AND SPECIFICALLY DISCLAIMED. IN NO EVENT SHALL ATMEL BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * \asf_license_stop
 */
/*
 * Support and FAQ: visit <a href="http://www.atmel.com/design-support/">Atmel Support</a>
 */

#ifndef CONF_BOARD_H
#define CONF_BOARD_H

/* Confirm NAND is onboard */
#define CONF_BOARD_NAND

/** NandFlash pins definition: OE. */
#define PIN_EBI_NANDOE    (PIO_PC9_IDX)
#define PIN_EBI_NANDOE_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

/** NandFlash pins definition: WE. */
#define PIN_EBI_NANDWE    (PIO_PC10_IDX)
#define PIN_EBI_NANDWE_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

/** NandFlash pins definition: CLE. */
#define PIN_EBI_NANDCLE    (PIO_PC17_IDX)
#define PIN_EBI_NANDCLE_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

/** NandFlash pins definition: ALE. */
#define PIN_EBI_NANDALE    (PIO_PC16_IDX)
#define PIN_EBI_NANDALE_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

/** NandFlash pins definition: DATA. */
#define PIN_EBI_NANDIO_0    (PIO_PC0_IDX)
#define PIN_EBI_NANDIO_0_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

#define PIN_EBI_NANDIO_1    (PIO_PC1_IDX)
#define PIN_EBI_NANDIO_1_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

#define PIN_EBI_NANDIO_2    (PIO_PC2_IDX)
#define PIN_EBI_NANDIO_2_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

#define PIN_EBI_NANDIO_3    (PIO_PC3_IDX)
#define PIN_EBI_NANDIO_3_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

#define PIN_EBI_NANDIO_4    (PIO_PC4_IDX)
#define PIN_EBI_NANDIO_4_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

#define PIN_EBI_NANDIO_5    (PIO_PC5_IDX)
#define PIN_EBI_NANDIO_5_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

#define PIN_EBI_NANDIO_6    (PIO_PC6_IDX)
#define PIN_EBI_NANDIO_6_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

#define PIN_EBI_NANDIO_7    (PIO_PC7_IDX)
#define PIN_EBI_NANDIO_7_FLAGS    (PIO_PERIPH_A | PIO_PULLUP)

/** Nandflash chip enable pin definition. */
#define PIN_NF_CE_IDX    (PIO_PC14_IDX)
#define PIN_NF_CE_FLAGS    (PIO_TYPE_PIO_OUTPUT_1 | PIO_DEFAULT)

/** Nandflash ready/busy pin definition. */
/* The new board use this definition */
#define PIN_NF_RB_IDX    (PIO_PB13_IDX)
#define PIN_NF_RB_FLAGS    (PIO_INPUT | PIO_PULLUP)

/* Chip select number for nand */
#define BOARD_NAND_CS    0

/** Address for transferring command bytes to the nandflash. */
#define BOARD_NF_COMMAND_ADDR   0x60400000
/** Address for transferring address bytes to the nandflash. */
#define BOARD_NF_ADDRESS_ADDR   0x60200000
/** Address for transferring data bytes to the nandflash. */
#define BOARD_NF_DATA_ADDR      0x60000000
/* Bus width for NAND */
#define CONF_NF_BUSWIDTH    8

/* Access timing for NAND */
#define CONF_NF_SETUP_TIMING (SMC_SETUP_NWE_SETUP(0) \
| SMC_SETUP_NCS_WR_SETUP(1) \
| SMC_SETUP_NRD_SETUP(0) \
| SMC_SETUP_NCS_RD_SETUP(1))
#define CONF_NF_PULSE_TIMING (SMC_PULSE_NWE_PULSE(2) \
| SMC_PULSE_NCS_WR_PULSE(3) \
| SMC_PULSE_NRD_PULSE(4) \
| SMC_PULSE_NCS_RD_PULSE(4))
#define CONF_NF_CYCLE_TIMING (SMC_CYCLE_NWE_CYCLE(4) \
| SMC_CYCLE_NRD_CYCLE(7))

// Set up the SPI port
#define CONF_BOARD_SPI
#define CONF_BOARD_SPI_NPCS0
#define CONF_BOARD_SPI_NPCS1
#define CONF_BOARD_SPI_NPCS1_GPIO PIO_PA31_IDX
#define CONF_BOARD_SPI_NPCS1_FLAGS ( PIO_PERIPH_A | PIO_DEFAULT )

// IO Port Configuration
#define FPGA_PORT	IOPORT_PIOC
#define DCLK		IOPORT_CREATE_PIN(PIOC, 26)
#define NCONFIG		IOPORT_CREATE_PIN(PIOC, 27)
#define NSTATUS		IOPORT_CREATE_PIN(PIOC, 28)
#define CONF_DONE	IOPORT_CREATE_PIN(PIOC, 29)

#define CONFIG_DATA_MASK	0x03FC0000	// Pins PIOC 18-25

#define ACCESS_MEM_TO_RAM_ENABLED

#endif /* CONF_BOARD_H */
