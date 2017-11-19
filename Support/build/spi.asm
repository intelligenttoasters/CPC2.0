;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.0 #9615 (Linux)
;--------------------------------------------------------
	.module spi
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _int_handler
	.globl _globals
	.globl _INI
	.globl _OUTI
	.globl _IN
	.globl _OUT
	.globl _spiSetHandler
	.globl _spiProcessEvents
	.globl _spiGetInUse
	.globl _spiGetProcessed
	.globl _spiSetInUse
	.globl _spiSetProcessed
	.globl _spiLock
	.globl _spiGetOutBuffer
	.globl _spiGetInBuffer
	.globl _spiExchange
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	G$spiSetHandler$0$0	= .
	.globl	G$spiSetHandler$0$0
	C$spi.c$31$0$0	= .
	.globl	C$spi.c$31$0$0
;../src/spi/spi.c:31: void spiSetHandler(char channel, void (*handler)(unsigned char *, unsigned char))
;	---------------------------------
; Function spiSetHandler
; ---------------------------------
_spiSetHandler::
	C$spi.c$33$1$75	= .
	.globl	C$spi.c$33$1$75
;../src/spi/spi.c:33: globals()->channel_handler_p[channel] = handler;
	call	_globals
	ld	iy,#2
	add	iy,sp
	ld	a,0 (iy)
	add	a, a
	ld	e, a
	ld	d,#0x00
	add	hl,de
	ld	iy,#3
	add	iy,sp
	ld	a,0 (iy)
	ld	(hl),a
	inc	hl
	ld	a,1 (iy)
	ld	(hl),a
	C$spi.c$34$1$75	= .
	.globl	C$spi.c$34$1$75
	XG$spiSetHandler$0$0	= .
	.globl	XG$spiSetHandler$0$0
	ret
	G$spiProcessEvents$0$0	= .
	.globl	G$spiProcessEvents$0$0
	C$spi.c$39$1$75	= .
	.globl	C$spi.c$39$1$75
;../src/spi/spi.c:39: void spiProcessEvents()
;	---------------------------------
; Function spiProcessEvents
; ---------------------------------
_spiProcessEvents::
	push	ix
	ld	ix,#0
	add	ix,sp
	dec	sp
	C$spi.c$43$1$76	= .
	.globl	C$spi.c$43$1$76
;../src/spi/spi.c:43: struct global_vars * glob = globals();
	call	_globals
	C$spi.c$47$1$76	= .
	.globl	C$spi.c$47$1$76
;../src/spi/spi.c:47: if( !spiGetInUse() )
	call	_spiGetInUse
	ld	a,l
	or	a, a
	jp	NZ,00115$
	C$spi.c$49$2$77	= .
	.globl	C$spi.c$49$2$77
;../src/spi/spi.c:49: if( !spiGetProcessed() )
	call	_spiGetProcessed
	ld	a,l
	or	a, a
	jp	NZ,00110$
	C$spi.c$52$3$78	= .
	.globl	C$spi.c$52$3$78
;../src/spi/spi.c:52: buffer = spiGetInBuffer() - SPI_BUFFER_OFFSET;
	call	_spiGetInBuffer
	ex	de,hl
	C$spi.c$55$3$78	= .
	.globl	C$spi.c$55$3$78
;../src/spi/spi.c:55: INI( SPI_DATA, buffer, SPI_BUFFER_OFFSET );			// Read just the header first
	push	de
	ld	a,#0x02
	push	af
	inc	sp
	push	de
	xor	a, a
	push	af
	inc	sp
	call	_INI
	pop	af
	pop	af
	pop	de
	C$spi.c$56$1$76	= .
	.globl	C$spi.c$56$1$76
;../src/spi/spi.c:56: INI( SPI_DATA, buffer + SPI_BUFFER_OFFSET, 128 );	// Then read 128 bytes of data
	ld	c, e
	ld	b, d
	inc	bc
	inc	bc
	push	bc
	push	de
	ld	a,#0x80
	push	af
	inc	sp
	push	bc
	xor	a, a
	push	af
	inc	sp
	call	_INI
	pop	af
	pop	af
	pop	de
	pop	bc
	C$spi.c$57$3$78	= .
	.globl	C$spi.c$57$3$78
;../src/spi/spi.c:57: INI( SPI_DATA, buffer + SPI_BUFFER_OFFSET + 128, 128 );	// Then read 128 bytes of data
	ld	iy,#0x0082
	add	iy, de
	push	bc
	push	de
	ld	a,#0x80
	push	af
	inc	sp
	push	iy
	xor	a, a
	push	af
	inc	sp
	call	_INI
	pop	af
	pop	af
	pop	de
	pop	bc
	C$spi.c$61$3$78	= .
	.globl	C$spi.c$61$3$78
;../src/spi/spi.c:61: channel = buffer[0];
	ld	a,(de)
	ld	-1 (ix),a
	C$spi.c$62$3$78	= .
	.globl	C$spi.c$62$3$78
;../src/spi/spi.c:62: size = buffer[1];
	ex	de,hl
	inc	hl
	ld	e,(hl)
	C$spi.c$65$3$78	= .
	.globl	C$spi.c$65$3$78
;../src/spi/spi.c:65: if(( size > 0 ) & ( channel < SPI_CHANNELS ))
	ld	a,-1 (ix)
	sub	a, #0x10
	ld	a,#0x00
	rla
	ld	d,e
	and	a,d
	jr	Z,00104$
	C$spi.c$66$3$78	= .
	.globl	C$spi.c$66$3$78
;../src/spi/spi.c:66: if( globals()->channel_handler_p[channel] != NULL ) globals()->channel_handler_p[channel](buffer + SPI_BUFFER_OFFSET, size);
	push	bc
	push	de
	call	_globals
	pop	de
	pop	bc
	ld	a,-1 (ix)
	add	a, a
	ld	d, a
	add	a,l
	ld	l,a
	ld	a,h
	adc	a, #0x00
	ld	h,a
	ld	a, (hl)
	inc	hl
	ld	h,(hl)
	or	a,h
	jr	Z,00104$
	push	bc
	push	de
	call	_globals
	pop	de
	pop	bc
	ld	a,l
	add	a, d
	ld	l,a
	ld	a,h
	adc	a, #0x00
	ld	h,a
	ld	a, (hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	a,e
	push	af
	inc	sp
	push	bc
	call	___sdcc_call_hl
	pop	af
	inc	sp
00104$:
	C$spi.c$69$3$78	= .
	.globl	C$spi.c$69$3$78
;../src/spi/spi.c:69: spiSetProcessed(true);
	ld	a,#0x01
	push	af
	inc	sp
	call	_spiSetProcessed
	inc	sp
	jr	00115$
00110$:
	C$spi.h$76$6$82	= .
	.globl	C$spi.h$76$6$82
;../include/spi.h:76: return IN(SPI_SR) & MASTER_RDY ? 0 : 1;
	ld	a,#0x01
	push	af
	inc	sp
	call	_IN
	inc	sp
	bit	4, l
	jr	NZ,00115$
	C$spi.c$74$3$79	= .
	.globl	C$spi.c$74$3$79
;../src/spi/spi.c:74: if ( spiLock(0) ) spiExchange(0xff,0);	// Send NOP packet
	xor	a, a
	push	af
	inc	sp
	call	_spiLock
	inc	sp
	ld	a,l
	or	a, a
	jr	Z,00115$
	ld	hl,#0x00ff
	push	hl
	call	_spiExchange
	pop	af
00115$:
	inc	sp
	pop	ix
	C$spi.c$77$1$76	= .
	.globl	C$spi.c$77$1$76
	XG$spiProcessEvents$0$0	= .
	.globl	XG$spiProcessEvents$0$0
	ret
	G$spiGetInUse$0$0	= .
	.globl	G$spiGetInUse$0$0
	C$spi.c$82$1$76	= .
	.globl	C$spi.c$82$1$76
;../src/spi/spi.c:82: inline Bool spiGetInUse()
;	---------------------------------
; Function spiGetInUse
; ---------------------------------
_spiGetInUse::
	C$spi.c$84$1$83	= .
	.globl	C$spi.c$84$1$83
;../src/spi/spi.c:84: return (globals()->spi_in_use) ? true : false;
	call	_globals
	ld	de, #0x0020
	add	hl, de
	ld	a,(hl)
	or	a, a
	jr	Z,00103$
	ld	l,#0x01
	ret
00103$:
	ld	l,#0x00
	C$spi.c$85$1$83	= .
	.globl	C$spi.c$85$1$83
	XG$spiGetInUse$0$0	= .
	.globl	XG$spiGetInUse$0$0
	ret
	G$spiGetProcessed$0$0	= .
	.globl	G$spiGetProcessed$0$0
	C$spi.c$90$1$83	= .
	.globl	C$spi.c$90$1$83
;../src/spi/spi.c:90: inline Bool spiGetProcessed()
;	---------------------------------
; Function spiGetProcessed
; ---------------------------------
_spiGetProcessed::
	C$spi.c$92$1$84	= .
	.globl	C$spi.c$92$1$84
;../src/spi/spi.c:92: return globals()->spi_processed_n == 0;
	call	_globals
	ld	de, #0x0021
	add	hl, de
	ld	a,(hl)
	or	a, a
	jr	NZ,00103$
	ld	a,#0x01
	jr	00104$
00103$:
	xor	a,a
00104$:
	ld	l,a
	C$spi.c$93$1$84	= .
	.globl	C$spi.c$93$1$84
	XG$spiGetProcessed$0$0	= .
	.globl	XG$spiGetProcessed$0$0
	ret
	G$spiSetInUse$0$0	= .
	.globl	G$spiSetInUse$0$0
	C$spi.c$98$1$84	= .
	.globl	C$spi.c$98$1$84
;../src/spi/spi.c:98: void spiSetInUse(unsigned char state)
;	---------------------------------
; Function spiSetInUse
; ---------------------------------
_spiSetInUse::
	C$spi.c$100$1$86	= .
	.globl	C$spi.c$100$1$86
;../src/spi/spi.c:100: globals()->spi_in_use = (state == false) ? 0 : 1;
	call	_globals
	ld	bc,#0x0020
	add	hl,bc
	ld	iy,#2
	add	iy,sp
	ld	a,0 (iy)
	or	a,a
	jr	NZ,00103$
	ld	c,a
	jr	00104$
00103$:
	ld	c,#0x01
00104$:
	ld	(hl),c
	C$spi.c$101$1$86	= .
	.globl	C$spi.c$101$1$86
	XG$spiSetInUse$0$0	= .
	.globl	XG$spiSetInUse$0$0
	ret
	G$spiSetProcessed$0$0	= .
	.globl	G$spiSetProcessed$0$0
	C$spi.c$106$1$86	= .
	.globl	C$spi.c$106$1$86
;../src/spi/spi.c:106: void spiSetProcessed(unsigned char state)
;	---------------------------------
; Function spiSetProcessed
; ---------------------------------
_spiSetProcessed::
	C$spi.c$108$1$88	= .
	.globl	C$spi.c$108$1$88
;../src/spi/spi.c:108: globals()->spi_processed_n = (state == false) ? 1 : 0;
	call	_globals
	ld	bc,#0x0021
	add	hl,bc
	ld	iy,#2
	add	iy,sp
	ld	a,0 (iy)
	or	a, a
	jr	NZ,00103$
	ld	c,#0x01
	jr	00104$
00103$:
	ld	c,#0x00
00104$:
	ld	(hl),c
	C$spi.c$109$1$88	= .
	.globl	C$spi.c$109$1$88
	XG$spiSetProcessed$0$0	= .
	.globl	XG$spiSetProcessed$0$0
	ret
	G$spiLock$0$0	= .
	.globl	G$spiLock$0$0
	C$spi.c$114$1$88	= .
	.globl	C$spi.c$114$1$88
;../src/spi/spi.c:114: unsigned char spiLock(unsigned char channel)
;	---------------------------------
; Function spiLock
; ---------------------------------
_spiLock::
	C$spi.c$116$1$90	= .
	.globl	C$spi.c$116$1$90
;../src/spi/spi.c:116: struct global_vars * g = globals();
	call	_globals
	ld	c,l
	ld	b,h
	C$spi.c$119$1$90	= .
	.globl	C$spi.c$119$1$90
;../src/spi/spi.c:119: if( g->spi_in_use ) return false;
	push	bc
	pop	iy
	ld	a,32 (iy)
	or	a, a
	jr	Z,00102$
	ld	l,#0x00
	ret
00102$:
	C$spi.c$122$1$90	= .
	.globl	C$spi.c$122$1$90
;../src/spi/spi.c:122: g->spi_channel = channel;
	ld	hl,#0x0022
	add	hl,bc
	ld	iy,#2
	add	iy,sp
	ld	a,0 (iy)
	ld	(hl),a
	C$spi.c$125$1$90	= .
	.globl	C$spi.c$125$1$90
;../src/spi/spi.c:125: spiSetInUse(true);
	ld	a,#0x01
	push	af
	inc	sp
	call	_spiSetInUse
	inc	sp
	C$spi.c$126$1$90	= .
	.globl	C$spi.c$126$1$90
;../src/spi/spi.c:126: spiSetProcessed(false);
	xor	a, a
	push	af
	inc	sp
	call	_spiSetProcessed
	inc	sp
	C$spi.c$128$1$90	= .
	.globl	C$spi.c$128$1$90
;../src/spi/spi.c:128: return true;
	ld	l,#0x01
	C$spi.c$129$1$90	= .
	.globl	C$spi.c$129$1$90
	XG$spiLock$0$0	= .
	.globl	XG$spiLock$0$0
	ret
	G$spiGetOutBuffer$0$0	= .
	.globl	G$spiGetOutBuffer$0$0
	C$spi.c$134$1$90	= .
	.globl	C$spi.c$134$1$90
;../src/spi/spi.c:134: void * spiGetOutBuffer(void)
;	---------------------------------
; Function spiGetOutBuffer
; ---------------------------------
_spiGetOutBuffer::
	C$spi.c$137$1$92	= .
	.globl	C$spi.c$137$1$92
;../src/spi/spi.c:137: return globals()->outbound_comm_buffer + SPI_BUFFER_OFFSET;
	call	_globals
	ld	bc,#0x0223
	add	hl,bc
	inc	hl
	inc	hl
	C$spi.c$138$1$92	= .
	.globl	C$spi.c$138$1$92
	XG$spiGetOutBuffer$0$0	= .
	.globl	XG$spiGetOutBuffer$0$0
	ret
	G$spiGetInBuffer$0$0	= .
	.globl	G$spiGetInBuffer$0$0
	C$spi.c$143$1$92	= .
	.globl	C$spi.c$143$1$92
;../src/spi/spi.c:143: void * spiGetInBuffer(void)
;	---------------------------------
; Function spiGetInBuffer
; ---------------------------------
_spiGetInBuffer::
	C$spi.c$146$1$94	= .
	.globl	C$spi.c$146$1$94
;../src/spi/spi.c:146: return globals()->inbound_comm_buffer + SPI_BUFFER_OFFSET;
	call	_globals
	ld	bc,#0x0023
	add	hl,bc
	inc	hl
	inc	hl
	C$spi.c$147$1$94	= .
	.globl	C$spi.c$147$1$94
	XG$spiGetInBuffer$0$0	= .
	.globl	XG$spiGetInBuffer$0$0
	ret
	G$spiExchange$0$0	= .
	.globl	G$spiExchange$0$0
	C$spi.c$152$1$94	= .
	.globl	C$spi.c$152$1$94
;../src/spi/spi.c:152: void spiExchange( unsigned char channel, unsigned char size )
;	---------------------------------
; Function spiExchange
; ---------------------------------
_spiExchange::
	push	ix
	ld	ix,#0
	add	ix,sp
	C$spi.c$155$1$96	= .
	.globl	C$spi.c$155$1$96
;../src/spi/spi.c:155: struct global_vars * g = globals();
	call	_globals
	ld	c,l
	ld	b,h
	C$spi.c$157$1$96	= .
	.globl	C$spi.c$157$1$96
;../src/spi/spi.c:157: g->outbound_comm_buffer[0] = channel;
	ld	hl,#0x0223
	add	hl,bc
	ex	de,hl
	ld	a,4 (ix)
	ld	(de),a
	C$spi.c$158$1$96	= .
	.globl	C$spi.c$158$1$96
;../src/spi/spi.c:158: g->outbound_comm_buffer[1] = size;
	ld	hl,#0x0224
	add	hl,bc
	ld	a,5 (ix)
	ld	(hl),a
	C$spi.h$66$4$99	= .
	.globl	C$spi.h$66$4$99
;../include/spi.h:66: OUT(SPI_CR, FLUSH);	// Flush the inbound / outbound data
	push	bc
	push	de
	ld	hl,#0x8001
	push	hl
	call	_OUT
	pop	af
	pop	de
	ld	a,#0x02
	push	af
	inc	sp
	push	de
	xor	a, a
	push	af
	inc	sp
	call	_OUTI
	pop	af
	pop	af
	pop	bc
	C$spi.c$165$1$96	= .
	.globl	C$spi.c$165$1$96
;../src/spi/spi.c:165: OUTI( SPI_DATA, g->outbound_comm_buffer + SPI_BUFFER_OFFSET, 128);
	ld	hl,#0x0225
	add	hl,bc
	ex	de,hl
	push	bc
	ld	a,#0x80
	push	af
	inc	sp
	push	de
	xor	a, a
	push	af
	inc	sp
	call	_OUTI
	pop	af
	pop	af
	pop	bc
	C$spi.c$166$1$96	= .
	.globl	C$spi.c$166$1$96
;../src/spi/spi.c:166: OUTI( SPI_DATA, g->outbound_comm_buffer + SPI_BUFFER_OFFSET + 128, 128);
	ld	hl,#0x02a5
	add	hl,bc
	ld	c,l
	ld	b,h
	ld	a,#0x80
	push	af
	inc	sp
	push	bc
	xor	a, a
	push	af
	inc	sp
	call	_OUTI
	pop	af
	C$spi.h$61$4$102	= .
	.globl	C$spi.h$61$4$102
;../include/spi.h:61: OUT(SPI_CR, SLAVE_RDY);	// Indicate ready
	ld	hl, #0x0101
	ex	(sp),hl
	call	_OUT
	pop	af
	C$spi.c$173$1$96	= .
	.globl	C$spi.c$173$1$96
;../src/spi/spi.c:173: while( spiGetInUse() ) int_handler();
00101$:
	C$spi.c$84$4$105	= .
	.globl	C$spi.c$84$4$105
;../src/spi/spi.c:84: return (globals()->spi_in_use) ? true : false;
	call	_globals
	ld	de, #0x0020
	add	hl, de
	ld	a,(hl)
	or	a, a
	jr	Z,00107$
	C$spi.c$173$1$96	= .
	.globl	C$spi.c$173$1$96
;../src/spi/spi.c:173: while( spiGetInUse() ) int_handler();
	call	_int_handler
	jr	00101$
00107$:
	pop	ix
	C$spi.c$176$1$96	= .
	.globl	C$spi.c$176$1$96
	XG$spiExchange$0$0	= .
	.globl	XG$spiExchange$0$0
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
