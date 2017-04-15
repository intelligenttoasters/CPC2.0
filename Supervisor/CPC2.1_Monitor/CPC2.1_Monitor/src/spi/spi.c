/*
 * spi.c - Handles requests through the SPI port
 *
 * Created: 2/12/2016 4:21:21 PM
 *  Author: paul
 */ 

#include "asf.h"
#include "main.h"

static volatile Bool spi_dma_done = true;
static Bool spi_in_use = false;

void spi_init()
{
	// Initialize MRAM at 40MHz
	struct spi_device device = {0};
	spi_master_init	( SPI );
	spi_master_setup_device(SPI, &device, SPI_MODE_0, 40000000, 0);	// Change rate back to 40MHz
	device.id = 1;
	spi_master_setup_device(SPI, &device, SPI_MODE_0, 40000000, 0); // Change rate back to 40MHz
	spi_enable( SPI );
	
	// Write enable
	device.id = 0;
	spi_select_device(SPI, &device);
	spi_write_single ( SPI, 0x06 );
	spi_deselect_device(SPI, &device);

	// Write status to unprotect all banks
	spi_select_device(SPI, &device);
	spi_write_single ( SPI, 0x01 );
	spi_write_single ( SPI, 0xf3 );
	spi_deselect_device(SPI, &device);
}

Ctrl_status spi_test_unit_ready_0(void)
{
	return CTRL_GOOD;
}

Ctrl_status spi_read_capacity_0(U32 * size)
{
	// Size is fixed at 32KB
	*size = 64;
	return CTRL_GOOD;
}

Bool spi_wr_protect_0(void)
{
	return false;
}

Ctrl_status spi_mem_2_ram_0 (U32 addr, void *ram)
{
	struct spi_device device = {
		.id = 0
	};

	// Address is in sectors, so multiply by sector size
	addr = addr * SECTOR_SIZE;
	
	// Read data bytes
	spi_select_device(SPI, &device);
	delay_us(1);										// Makes no sense, but OK it's needed
	spi_write_single ( SPI, 0x03 );						// Read command
	delay_us(1);										// Makes no sense, but OK it's needed
	spi_write_single ( SPI, (addr & 0xff00) >> 8 );		// Address-high
	delay_us(1);										// Makes no sense, but OK it's needed
	spi_write_single ( SPI, (addr & 0xff) );			// Address-low
	delay_us(1);										// Makes no sense, but OK it's needed
	spi_read_packet(SPI, ram, SECTOR_SIZE );			// Read a packet
	spi_deselect_device(SPI, &device);					// Deselect
	return CTRL_GOOD;
}

Ctrl_status spi_ram_2_mem_0 (U32 addr, const void *ram)
{
	struct spi_device device = {
		.id = 0
	};

	// Address is in sectors, so multiply by sector size
	addr = addr * SECTOR_SIZE;

	// Write data bytes
	spi_select_device(SPI, &device);
	delay_us(1);										// Makes no sense, but OK it's needed
	spi_write_single ( SPI, 0x02 );						// Write command
	delay_us(1);										// Makes no sense, but OK it's needed
	spi_write_single ( SPI, (addr & 0xff00) >> 8 );		// Address-high
	delay_us(1);										// Makes no sense, but OK it's needed
	spi_write_single ( SPI, (addr & 0xff) );			// Address-low
	delay_us(1);										// Makes no sense, but OK it's needed
	spi_write_packet(SPI, ram, SECTOR_SIZE );			// Write a packet
	spi_deselect_device(SPI, &device);
	
	return CTRL_GOOD;	
}

// Is the slave ready to start
Bool slave_ready()
{
	return ioport_get_pin_level( DATA7 );
}

static inline void set_master_ready(Bool yn)
{
	ioport_set_pin_level(DATA6, !yn);	// Indicate master ready	
	spi_in_use = yn;
}

void master_ready(Bool state)
{
	set_master_ready(state);
}

Bool isResetState()
{
	return ioport_get_pin_level( DATA5 );	
}

void setResetState(Bool state)
{
	ioport_set_pin_level( DATA5, state );
}

void spi_raw_exchange( char * out, char * in, uint16_t count )
{
	// transfer packets
	pdc_packet_t pkt1;
	pdc_packet_t pkt2;

	// Make sure the slave ready
	while( !slave_ready() ) process_events();

	// Chip enable
	struct spi_device device = {.id = 1};
	spi_select_device(SPI, &device);

	/* Initialize PDC data packet for transfer */
	pkt1.ul_addr = (uint32_t) in;
	pkt1.ul_size = count;
	pkt2.ul_addr = (uint32_t) out;
	pkt2.ul_size = count;
	/* Configure PDC for data receive */
	pdc_rx_init(spi_get_pdc_base(SPI), &pkt1, NULL);
	pdc_tx_init(spi_get_pdc_base(SPI), &pkt2, NULL);

	spi_dma_done = false;

	/* Enable PDC transfers */
	pdc_enable_transfer(spi_get_pdc_base(SPI), PERIPH_PTCR_RXTEN | PERIPH_PTCR_TXTEN);
	spi_ei();
}


void spi_ei()
{
	spi_dma_done = false;
	// Enable interrupts
	spi_enable_interrupt(SPI, SPI_IER_ENDTX | SPI_IER_ENDRX);
	NVIC_EnableIRQ(SPI_IRQn);
}

void spi_di(void)
{
	// Disable ALL interrupts except these
	spi_disable_interrupt(SPI, SPI_IDR_ENDTX | SPI_IDR_ENDRX);
}

// TODO: Getting hung here
// Interrupt handler
ISR(SPI_Handler)
{
	struct spi_device device = {.id = 1};
	
	// Set signal for done
	spi_dma_done = true;
	
	// Indicate to slave we're done
	set_master_ready(false);
	
	// Disable further interrupts
	spi_di();

	// Chip disable
	spi_deselect_device(SPI, &device);
}

void spi_runtime()
{
	// Set the runtime control pins for Super->FPGA
	ioport_set_pin_mode(DATA7, IOPORT_MODE_PULLDOWN);	// Slave ready is pulled down
	ioport_set_pin_dir(DATA7, IOPORT_DIR_INPUT);		// Retask DATA7 as input for slave ready
	ioport_set_pin_level(DATA5, false);					// Allow slave to assert DATA7 lines	
}

void set_channel_handler(char channel, void (*handler)(void))
{
	globals.channel_handler_p[channel] = handler;	
}

Bool is_dma_done()
{
	return spi_dma_done;
}

Bool is_spi_in_use(void)
{
	return spi_in_use;
}