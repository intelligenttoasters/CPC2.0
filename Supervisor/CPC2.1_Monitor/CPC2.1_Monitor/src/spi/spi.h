/*
 * spi.h
 *
 * Created: 4/12/2016 8:36:51 AM
 *  Author: paul
 */ 


#ifndef SPI1_H_
#define SPI1_H_

#define DATA7 IOPORT_CREATE_PIN(PIOC, 25)
#define DATA6 IOPORT_CREATE_PIN(PIOC, 24)
#define DATA5 IOPORT_CREATE_PIN(PIOC, 23)
#define SPI_CHANNELS 16

void spi_handle(void);
void spi_init(void);
Ctrl_status spi_test_unit_ready_0(void);
Ctrl_status spi_read_capacity_0(U32 *);
Bool spi_wr_protect_0(void);
Ctrl_status spi_mem_2_ram_0 (U32 addr, void *ram);
Ctrl_status spi_ram_2_mem_0 (U32 addr, const void *ram);
void spi_ei(void);
void spi_di(void);
Bool slave_ready(void);
void spi_runtime(void);
void master_ready(Bool);
void spi_raw_exchange( char * out, char * in, uint16_t count );
Bool isResetState(void);
void setResetState(Bool state);
void set_channel_handler(char channel, void (*handler)(void));
Bool is_dma_done(void);
Bool is_spi_in_use(void);

#endif /* INCFILE1_H_ */