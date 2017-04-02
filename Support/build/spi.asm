;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.0 #9615 (Linux)
;--------------------------------------------------------
	.module spi
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
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
	C$spi.c$29$0$0	= .
	.globl	C$spi.c$29$0$0
;../src/spi/spi.c:29: void spiSetHandler(char channel, void (*handler)(unsigned char *, unsigned char))
;	---------------------------------
; Function spiSetHandler
; ---------------------------------
_spiSetHandler::
	C$spi.c$31$1$69	= .
	.globl	C$spi.c$31$1$69
;../src/spi/spi.c:31: globals()->channel_handler_p[channel] = handler;
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
	C$spi.c$32$1$69	= .
	.globl	C$spi.c$32$1$69
	XG$spiSetHandler$0$0	= .
	.globl	XG$spiSetHandler$0$0
	ret
	G$spiProcessEvents$0$0	= .
	.globl	G$spiProcessEvents$0$0
	C$spi.c$37$1$69	= .
	.globl	C$spi.c$37$1$69
;../src/spi/spi.c:37: void spiProcessEvents()
;	---------------------------------
; Function spiProcessEvents
; ---------------------------------
_spiProcessEvents::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	dec	sp
	C$spi.c$41$1$70	= .
	.globl	C$spi.c$41$1$70
;../src/spi/spi.c:41: struct global_vars * glob = globals();
	call	_globals
	C$spi.c$45$1$70	= .
	.globl	C$spi.c$45$1$70
;../src/spi/spi.c:45: if( !spiGetInUse() )
	call	_spiGetInUse
	ld	a, l
	or	a, a
	jp	NZ,00113$
	C$spi.c$47$2$71	= .
	.globl	C$spi.c$47$2$71
;../src/spi/spi.c:47: if( !spiGetProcessed() )
	call	_spiGetProcessed
	ld	a,l
	or	a, a
	jp	NZ,00108$
	C$spi.c$50$3$72	= .
	.globl	C$spi.c$50$3$72
;../src/spi/spi.c:50: buffer = spiGetInBuffer() - SPI_BUFFER_OFFSET;
	call	_spiGetInBuffer
	ld	c,l
	ld	b,h
	C$spi.c$53$3$72	= .
	.globl	C$spi.c$53$3$72
;../src/spi/spi.c:53: INI( SPI_DATA, buffer, SPI_BUFFER_OFFSET );			// Read just the header first
	push	bc
	ld	a,#0x02
	push	af
	inc	sp
	push	bc
	xor	a, a
	push	af
	inc	sp
	call	_INI
	pop	af
	pop	af
	pop	bc
	C$spi.c$54$1$70	= .
	.globl	C$spi.c$54$1$70
;../src/spi/spi.c:54: INI( SPI_DATA, buffer + SPI_BUFFER_OFFSET, 128 );	// Then read 128 bytes of data
	ld	hl,#0x0002
	add	hl,bc
	ld	-2 (ix),l
	ld	-1 (ix),h
	push	bc
	ld	a,#0x80
	push	af
	inc	sp
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	xor	a, a
	push	af
	inc	sp
	call	_INI
	pop	af
	pop	af
	pop	bc
	C$spi.c$55$3$72	= .
	.globl	C$spi.c$55$3$72
;../src/spi/spi.c:55: INI( SPI_DATA, buffer + SPI_BUFFER_OFFSET + 128, 128 );	// Then read 128 bytes of data
	ld	hl,#0x0082
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
	call	_INI
	pop	af
	pop	af
	pop	bc
	C$spi.c$59$3$72	= .
	.globl	C$spi.c$59$3$72
;../src/spi/spi.c:59: channel = buffer[0];
	ld	a,(bc)
	ld	-3 (ix),a
	C$spi.c$60$3$72	= .
	.globl	C$spi.c$60$3$72
;../src/spi/spi.c:60: size = buffer[1];
	ld	l, c
	ld	h, b
	inc	hl
	ld	c,(hl)
	C$spi.c$63$3$72	= .
	.globl	C$spi.c$63$3$72
;../src/spi/spi.c:63: if(( size > 0 ) & ( channel < SPI_CHANNELS ))
	ld	a,-3 (ix)
	sub	a, #0x10
	ld	a,#0x00
	rla
	ld	b,c
	and	a,b
	jr	Z,00104$
	C$spi.c$64$3$72	= .
	.globl	C$spi.c$64$3$72
;../src/spi/spi.c:64: if( globals()->channel_handler_p[channel] != NULL ) globals()->channel_handler_p[channel](buffer + SPI_BUFFER_OFFSET, size);
	push	bc
	call	_globals
	pop	bc
	ld	a,-3 (ix)
	add	a, a
	ld	b,a
	ld	e,b
	ld	d,#0x00
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	a, (hl)
	or	a,e
	jr	Z,00104$
	push	bc
	call	_globals
	pop	bc
	ld	e,b
	ld	d,#0x00
	add	hl,de
	ld	a, (hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	a,c
	push	af
	inc	sp
	pop	de
	pop	bc
	push	bc
	push	de
	push	bc
	call	___sdcc_call_hl
	pop	af
	inc	sp
00104$:
	C$spi.c$67$3$72	= .
	.globl	C$spi.c$67$3$72
;../src/spi/spi.c:67: spiSetProcessed(true);
	ld	a,#0x01
	push	af
	inc	sp
	call	_spiSetProcessed
	inc	sp
	jr	00113$
00108$:
	C$spi.h$76$6$76	= .
	.globl	C$spi.h$76$6$76
;../include/spi.h:76: return IN(SPI_SR) & MASTER_RDY ? 0 : 1;
	ld	a,#0x01
	push	af
	inc	sp
	call	_IN
	inc	sp
	bit	4, l
	jr	Z,00115$
	ld	c,#0x00
	jr	00116$
00115$:
	ld	c,#0x01
00116$:
	C$spi.c$71$3$73	= .
	.globl	C$spi.c$71$3$73
;../src/spi/spi.c:71: if( spiMasterReady() & spiLock(0) ) spiExchange(0xff,0);	// Send NOP packet
	push	bc
	xor	a, a
	push	af
	inc	sp
	call	_spiLock
	inc	sp
	pop	bc
	ld	a,c
	and	a,l
	jr	Z,00113$
	ld	hl,#0x00ff
	push	hl
	call	_spiExchange
	pop	af
00113$:
	ld	sp, ix
	pop	ix
	C$spi.c$74$1$70	= .
	.globl	C$spi.c$74$1$70
	XG$spiProcessEvents$0$0	= .
	.globl	XG$spiProcessEvents$0$0
	ret
	G$spiGetInUse$0$0	= .
	.globl	G$spiGetInUse$0$0
	C$spi.c$79$1$70	= .
	.globl	C$spi.c$79$1$70
;../src/spi/spi.c:79: inline Bool spiGetInUse()
;	---------------------------------
; Function spiGetInUse
; ---------------------------------
_spiGetInUse::
	C$spi.c$81$1$77	= .
	.globl	C$spi.c$81$1$77
;../src/spi/spi.c:81: return globals()->spi_in_use;
	call	_globals
	ld	de, #0x0020
	add	hl, de
	ld	l,(hl)
	C$spi.c$82$1$77	= .
	.globl	C$spi.c$82$1$77
	XG$spiGetInUse$0$0	= .
	.globl	XG$spiGetInUse$0$0
	ret
	G$spiGetProcessed$0$0	= .
	.globl	G$spiGetProcessed$0$0
	C$spi.c$87$1$77	= .
	.globl	C$spi.c$87$1$77
;../src/spi/spi.c:87: inline Bool spiGetProcessed()
;	---------------------------------
; Function spiGetProcessed
; ---------------------------------
_spiGetProcessed::
	C$spi.c$89$1$78	= .
	.globl	C$spi.c$89$1$78
;../src/spi/spi.c:89: return globals()->spi_processed_n == 0;
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
	C$spi.c$90$1$78	= .
	.globl	C$spi.c$90$1$78
	XG$spiGetProcessed$0$0	= .
	.globl	XG$spiGetProcessed$0$0
	ret
	G$spiSetInUse$0$0	= .
	.globl	G$spiSetInUse$0$0
	C$spi.c$95$1$78	= .
	.globl	C$spi.c$95$1$78
;../src/spi/spi.c:95: void spiSetInUse(unsigned char state)
;	---------------------------------
; Function spiSetInUse
; ---------------------------------
_spiSetInUse::
	C$spi.c$97$1$80	= .
	.globl	C$spi.c$97$1$80
;../src/spi/spi.c:97: globals()->spi_in_use = (state == false) ? 0 : 1;
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
	C$spi.c$98$1$80	= .
	.globl	C$spi.c$98$1$80
	XG$spiSetInUse$0$0	= .
	.globl	XG$spiSetInUse$0$0
	ret
	G$spiSetProcessed$0$0	= .
	.globl	G$spiSetProcessed$0$0
	C$spi.c$103$1$80	= .
	.globl	C$spi.c$103$1$80
;../src/spi/spi.c:103: void spiSetProcessed(unsigned char state)
;	---------------------------------
; Function spiSetProcessed
; ---------------------------------
_spiSetProcessed::
	C$spi.c$105$1$82	= .
	.globl	C$spi.c$105$1$82
;../src/spi/spi.c:105: globals()->spi_processed_n = (state == false) ? 1 : 0;
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
	C$spi.c$106$1$82	= .
	.globl	C$spi.c$106$1$82
	XG$spiSetProcessed$0$0	= .
	.globl	XG$spiSetProcessed$0$0
	ret
	G$spiLock$0$0	= .
	.globl	G$spiLock$0$0
	C$spi.c$111$1$82	= .
	.globl	C$spi.c$111$1$82
;../src/spi/spi.c:111: unsigned char spiLock(unsigned char channel)
;	---------------------------------
; Function spiLock
; ---------------------------------
_spiLock::
	C$spi.c$113$1$84	= .
	.globl	C$spi.c$113$1$84
;../src/spi/spi.c:113: struct global_vars * g = globals();
	call	_globals
	ld	c,l
	ld	b,h
	C$spi.c$116$1$84	= .
	.globl	C$spi.c$116$1$84
;../src/spi/spi.c:116: if( g->spi_in_use ) return false;
	push	bc
	pop	iy
	ld	a,32 (iy)
	or	a, a
	jr	Z,00102$
	ld	l,#0x00
	ret
00102$:
	C$spi.c$119$1$84	= .
	.globl	C$spi.c$119$1$84
;../src/spi/spi.c:119: g->spi_channel = channel;
	ld	hl,#0x0022
	add	hl,bc
	ld	iy,#2
	add	iy,sp
	ld	a,0 (iy)
	ld	(hl),a
	C$spi.c$122$1$84	= .
	.globl	C$spi.c$122$1$84
;../src/spi/spi.c:122: spiSetInUse(true);
	ld	a,#0x01
	push	af
	inc	sp
	call	_spiSetInUse
	inc	sp
	C$spi.c$123$1$84	= .
	.globl	C$spi.c$123$1$84
;../src/spi/spi.c:123: spiSetProcessed(false);
	xor	a, a
	push	af
	inc	sp
	call	_spiSetProcessed
	inc	sp
	C$spi.c$125$1$84	= .
	.globl	C$spi.c$125$1$84
;../src/spi/spi.c:125: return true;
	ld	l,#0x01
	C$spi.c$126$1$84	= .
	.globl	C$spi.c$126$1$84
	XG$spiLock$0$0	= .
	.globl	XG$spiLock$0$0
	ret
	G$spiGetOutBuffer$0$0	= .
	.globl	G$spiGetOutBuffer$0$0
	C$spi.c$131$1$84	= .
	.globl	C$spi.c$131$1$84
;../src/spi/spi.c:131: void * spiGetOutBuffer(void)
;	---------------------------------
; Function spiGetOutBuffer
; ---------------------------------
_spiGetOutBuffer::
	C$spi.c$134$1$86	= .
	.globl	C$spi.c$134$1$86
;../src/spi/spi.c:134: return globals()->outbound_comm_buffer + SPI_BUFFER_OFFSET;
	call	_globals
	ld	bc,#0x0223
	add	hl,bc
	inc	hl
	inc	hl
	C$spi.c$135$1$86	= .
	.globl	C$spi.c$135$1$86
	XG$spiGetOutBuffer$0$0	= .
	.globl	XG$spiGetOutBuffer$0$0
	ret
	G$spiGetInBuffer$0$0	= .
	.globl	G$spiGetInBuffer$0$0
	C$spi.c$140$1$86	= .
	.globl	C$spi.c$140$1$86
;../src/spi/spi.c:140: void * spiGetInBuffer(void)
;	---------------------------------
; Function spiGetInBuffer
; ---------------------------------
_spiGetInBuffer::
	C$spi.c$143$1$88	= .
	.globl	C$spi.c$143$1$88
;../src/spi/spi.c:143: return globals()->inbound_comm_buffer + SPI_BUFFER_OFFSET;
	call	_globals
	ld	bc,#0x0023
	add	hl,bc
	inc	hl
	inc	hl
	C$spi.c$144$1$88	= .
	.globl	C$spi.c$144$1$88
	XG$spiGetInBuffer$0$0	= .
	.globl	XG$spiGetInBuffer$0$0
	ret
	G$spiExchange$0$0	= .
	.globl	G$spiExchange$0$0
	C$spi.c$149$1$88	= .
	.globl	C$spi.c$149$1$88
;../src/spi/spi.c:149: void spiExchange( unsigned char channel, unsigned char size )
;	---------------------------------
; Function spiExchange
; ---------------------------------
_spiExchange::
	push	ix
	ld	ix,#0
	add	ix,sp
	C$spi.c$152$1$90	= .
	.globl	C$spi.c$152$1$90
;../src/spi/spi.c:152: struct global_vars * g = globals();
	call	_globals
	ld	c,l
	ld	b,h
	C$spi.c$155$3$95	= .
	.globl	C$spi.c$155$3$95
;../src/spi/spi.c:155: g->outbound_comm_buffer[0] = channel;
	ld	hl,#0x0223
	add	hl,bc
	ex	de,hl
	ld	a,4 (ix)
	ld	(de),a
	C$spi.c$156$1$90	= .
	.globl	C$spi.c$156$1$90
;../src/spi/spi.c:156: g->outbound_comm_buffer[1] = size;
	ld	hl,#0x0224
	add	hl,bc
	ld	a,5 (ix)
	ld	(hl),a
	C$spi.h$66$4$93	= .
	.globl	C$spi.h$66$4$93
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
	C$spi.c$163$1$90	= .
	.globl	C$spi.c$163$1$90
;../src/spi/spi.c:163: OUTI( SPI_DATA + SPI_BUFFER_OFFSET, g->outbound_comm_buffer + SPI_BUFFER_OFFSET, 128);
	ld	hl,#0x0225
	add	hl,bc
	ex	de,hl
	push	bc
	ld	a,#0x80
	push	af
	inc	sp
	push	de
	ld	a,#0x02
	push	af
	inc	sp
	call	_OUTI
	pop	af
	pop	af
	pop	bc
	C$spi.c$164$1$90	= .
	.globl	C$spi.c$164$1$90
;../src/spi/spi.c:164: OUTI( SPI_DATA + SPI_BUFFER_OFFSET + 128, g->outbound_comm_buffer + SPI_BUFFER_OFFSET + 128, 128);
	ld	hl,#0x02a5
	add	hl,bc
	ld	c,l
	ld	b,h
	ld	a,#0x80
	push	af
	inc	sp
	push	bc
	ld	a,#0x82
	push	af
	inc	sp
	call	_OUTI
	pop	af
	C$spi.h$61$4$96	= .
	.globl	C$spi.h$61$4$96
;../include/spi.h:61: OUT(SPI_CR, SLAVE_RDY);	// Indicate ready
	ld	hl, #0x0101
	ex	(sp),hl
	call	_OUT
	pop	af
	C$spi.c$168$3$95	= .
	.globl	C$spi.c$168$3$95
;../src/spi/spi.c:168: spiReady();
	pop	ix
	C$spi.c$170$3$95	= .
	.globl	C$spi.c$170$3$95
	XG$spiExchange$0$0	= .
	.globl	XG$spiExchange$0$0
	ret
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
