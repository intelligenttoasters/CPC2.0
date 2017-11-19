;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.6.0 #9615 (Linux)
;--------------------------------------------------------
	.module stdio_spi
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _stdio_channel_handler
	.globl _strlen
	.globl _process_events
	.globl _spiExchange
	.globl _spiGetOutBuffer
	.globl _spiLock
	.globl _spiSetHandler
	.globl _spiSetProcessed
	.globl _spiSetInUse
	.globl _stdio_init
	.globl _spi_puts
	.globl _putchari
	.globl _putchar
	.globl _outbound_flush
	.globl _spi_avail
	.globl _getchar
	.globl _inbound_flush
	.globl _spi_connected
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
Fstdio_spi$stdio_inbound_buffer$0$0==.
_stdio_inbound_buffer:
	.ds 8
Fstdio_spi$stdio_outbound_buffer$0$0==.
_stdio_outbound_buffer:
	.ds 82
Fstdio_spi$inbuffer_entries$0$0==.
_inbuffer_entries:
	.ds 1
Fstdio_spi$outbuffer_entries$0$0==.
_outbuffer_entries:
	.ds 1
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
Fstdio_spi$stdio_connected$0$0==.
_stdio_connected:
	.ds 1
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
	G$stdio_channel_handler$0$0	= .
	.globl	G$stdio_channel_handler$0$0
	C$stdio_spi.c$36$0$0	= .
	.globl	C$stdio_spi.c$36$0$0
;../src/stdio_spi/stdio_spi.c:36: void stdio_channel_handler(unsigned char *buffer, unsigned char size)
;	---------------------------------
; Function stdio_channel_handler
; ---------------------------------
_stdio_channel_handler::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	C$stdio_spi.c$41$1$68	= .
	.globl	C$stdio_spi.c$41$1$68
;../src/stdio_spi/stdio_spi.c:41: if( size == 1 )
	ld	a,6 (ix)
	dec	a
	jr	NZ,00106$
	C$stdio_spi.c$44$2$69	= .
	.globl	C$stdio_spi.c$44$2$69
;../src/stdio_spi/stdio_spi.c:44: if ( buffer[0] == SPI_START )
	ld	l,4 (ix)
	ld	h,5 (ix)
	ld	c,(hl)
	ld	a,c
	sub	a, #0x0f
	jr	NZ,00102$
	C$stdio_spi.c$46$3$70	= .
	.globl	C$stdio_spi.c$46$3$70
;../src/stdio_spi/stdio_spi.c:46: stdio_connected = true;
	ld	hl,#_stdio_connected + 0
	ld	(hl), #0x01
	C$stdio_spi.c$47$3$70	= .
	.globl	C$stdio_spi.c$47$3$70
;../src/stdio_spi/stdio_spi.c:47: inbuffer_entries = 0;
	ld	hl,#_inbuffer_entries + 0
	ld	(hl), #0x00
	C$stdio_spi.c$48$3$70	= .
	.globl	C$stdio_spi.c$48$3$70
;../src/stdio_spi/stdio_spi.c:48: outbuffer_entries = 0;
	ld	hl,#_outbuffer_entries + 0
	ld	(hl), #0x00
	C$stdio_spi.c$49$3$70	= .
	.globl	C$stdio_spi.c$49$3$70
;../src/stdio_spi/stdio_spi.c:49: return;
	jp	00111$
00102$:
	C$stdio_spi.c$52$2$69	= .
	.globl	C$stdio_spi.c$52$2$69
;../src/stdio_spi/stdio_spi.c:52: if ( buffer[0] == SPI_END )
	ld	a,c
	sub	a, #0x11
	jr	NZ,00106$
	C$stdio_spi.c$54$3$71	= .
	.globl	C$stdio_spi.c$54$3$71
;../src/stdio_spi/stdio_spi.c:54: stdio_connected = false;
	ld	hl,#_stdio_connected + 0
	ld	(hl), #0x00
	C$stdio_spi.c$55$3$71	= .
	.globl	C$stdio_spi.c$55$3$71
;../src/stdio_spi/stdio_spi.c:55: inbuffer_entries = 0;
	ld	hl,#_inbuffer_entries + 0
	ld	(hl), #0x00
	C$stdio_spi.c$56$3$71	= .
	.globl	C$stdio_spi.c$56$3$71
;../src/stdio_spi/stdio_spi.c:56: outbuffer_entries = 0;
	ld	hl,#_outbuffer_entries + 0
	ld	(hl), #0x00
	C$stdio_spi.c$57$3$71	= .
	.globl	C$stdio_spi.c$57$3$71
;../src/stdio_spi/stdio_spi.c:57: return;
	jr	00111$
00106$:
	C$stdio_spi.c$62$1$68	= .
	.globl	C$stdio_spi.c$62$1$68
;../src/stdio_spi/stdio_spi.c:62: if( inbuffer_entries == 8 ) return;
	ld	a,(#_inbuffer_entries + 0)
	sub	a, #0x08
	jr	Z,00111$
	jr	00108$
	jr	00111$
00108$:
	C$stdio_spi.c$65$1$68	= .
	.globl	C$stdio_spi.c$65$1$68
;../src/stdio_spi/stdio_spi.c:65: sz = min(size, 8 - inbuffer_entries);
	ld	hl,#_inbuffer_entries + 0
	ld	c, (hl)
	ld	b,#0x00
	ld	a,#0x08
	sub	a, c
	ld	c,a
	ld	a,#0x00
	sbc	a, b
	ld	b,a
	ld	a, 6 (ix)
	ld	d, #0x00
	sub	a, c
	ld	a,d
	sbc	a, b
	jp	PO, 00147$
	xor	a, #0x80
00147$:
	jp	M,00113$
	ld	hl,#_inbuffer_entries
	ld	a,#0x08
	sub	a, (hl)
	jr	00114$
00113$:
	ld	a,6 (ix)
00114$:
	ld	-2 (ix),a
	C$stdio_spi.c$68$1$68	= .
	.globl	C$stdio_spi.c$68$1$68
;../src/stdio_spi/stdio_spi.c:68: memcpy( stdio_inbound_buffer + inbuffer_entries, buffer, sz);
	ld	bc,#_stdio_inbound_buffer+0
	ld	hl,(_inbuffer_entries)
	ld	h,#0x00
	add	hl,bc
	ld	c,4 (ix)
	ld	b,5 (ix)
	ld	e,-2 (ix)
	ld	d,#0x00
	push	de
	push	bc
	push	hl
	call	_memcpy
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	C$stdio_spi.c$71$1$68	= .
	.globl	C$stdio_spi.c$71$1$68
;../src/stdio_spi/stdio_spi.c:71: inbuffer_entries += sz;
	ld	hl,#_inbuffer_entries
	ld	a,(hl)
	add	a, -2 (ix)
	ld	(hl),a
	C$stdio_spi.c$74$1$68	= .
	.globl	C$stdio_spi.c$74$1$68
;../src/stdio_spi/stdio_spi.c:74: if( inbuffer_entries > 8 ) inbuffer_entries = 8;
	ld	a,#0x08
	ld	iy,#_inbuffer_entries
	sub	a, 0 (iy)
	jr	NC,00111$
	ld	0 (iy),#0x08
00111$:
	ld	sp, ix
	pop	ix
	C$stdio_spi.c$75$1$68	= .
	.globl	C$stdio_spi.c$75$1$68
	XG$stdio_channel_handler$0$0	= .
	.globl	XG$stdio_channel_handler$0$0
	ret
	G$stdio_init$0$0	= .
	.globl	G$stdio_init$0$0
	C$stdio_spi.c$79$1$68	= .
	.globl	C$stdio_spi.c$79$1$68
;../src/stdio_spi/stdio_spi.c:79: void stdio_init()
;	---------------------------------
; Function stdio_init
; ---------------------------------
_stdio_init::
	C$stdio_spi.c$82$1$72	= .
	.globl	C$stdio_spi.c$82$1$72
;../src/stdio_spi/stdio_spi.c:82: spiSetHandler(0, &stdio_channel_handler);
	ld	hl,#_stdio_channel_handler
	push	hl
	xor	a, a
	push	af
	inc	sp
	call	_spiSetHandler
	pop	af
	inc	sp
	C$stdio_spi.c$83$1$72	= .
	.globl	C$stdio_spi.c$83$1$72
;../src/stdio_spi/stdio_spi.c:83: inbuffer_entries = 0;
	ld	hl,#_inbuffer_entries + 0
	ld	(hl), #0x00
	C$stdio_spi.c$84$1$72	= .
	.globl	C$stdio_spi.c$84$1$72
;../src/stdio_spi/stdio_spi.c:84: outbuffer_entries = 0;
	ld	hl,#_outbuffer_entries + 0
	ld	(hl), #0x00
	C$stdio_spi.c$85$1$72	= .
	.globl	C$stdio_spi.c$85$1$72
;../src/stdio_spi/stdio_spi.c:85: spiSetInUse(false);
	xor	a, a
	push	af
	inc	sp
	call	_spiSetInUse
	inc	sp
	C$stdio_spi.c$86$1$72	= .
	.globl	C$stdio_spi.c$86$1$72
;../src/stdio_spi/stdio_spi.c:86: spiSetProcessed(true);
	ld	a,#0x01
	push	af
	inc	sp
	call	_spiSetProcessed
	inc	sp
	C$stdio_spi.c$87$1$72	= .
	.globl	C$stdio_spi.c$87$1$72
;../src/stdio_spi/stdio_spi.c:87: stdio_connected = false;
	ld	hl,#_stdio_connected + 0
	ld	(hl), #0x00
	C$stdio_spi.c$88$1$72	= .
	.globl	C$stdio_spi.c$88$1$72
	XG$stdio_init$0$0	= .
	.globl	XG$stdio_init$0$0
	ret
	G$spi_puts$0$0	= .
	.globl	G$spi_puts$0$0
	C$stdio_spi.c$92$1$72	= .
	.globl	C$stdio_spi.c$92$1$72
;../src/stdio_spi/stdio_spi.c:92: void spi_puts( void * string )
;	---------------------------------
; Function spi_puts
; ---------------------------------
_spi_puts::
	push	af
	C$stdio_spi.c$95$1$74	= .
	.globl	C$stdio_spi.c$95$1$74
;../src/stdio_spi/stdio_spi.c:95: int size = strlen( string );
	ld	hl, #4
	add	hl, sp
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	push	bc
	call	_strlen
	pop	af
	inc	sp
	inc	sp
	push	hl
	C$stdio_spi.c$98$1$74	= .
	.globl	C$stdio_spi.c$98$1$74
;../src/stdio_spi/stdio_spi.c:98: while(!spiLock(0)) process_events();
00101$:
	xor	a, a
	push	af
	inc	sp
	call	_spiLock
	inc	sp
	ld	a,l
	or	a, a
	jr	NZ,00103$
	call	_process_events
	jr	00101$
00103$:
	C$stdio_spi.c$101$1$74	= .
	.globl	C$stdio_spi.c$101$1$74
;../src/stdio_spi/stdio_spi.c:101: memcpy( spiGetOutBuffer(), string, size );	// Note it doesn't copy the terminating zero
	call	_spiGetOutBuffer
	pop	bc
	push	bc
	push	bc
	ld	iy,#6
	add	iy,sp
	ld	c,0 (iy)
	ld	b,1 (iy)
	push	bc
	push	hl
	call	_memcpy
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	C$stdio_spi.c$104$1$74	= .
	.globl	C$stdio_spi.c$104$1$74
;../src/stdio_spi/stdio_spi.c:104: spiExchange( SPI_CHANNEL, size );
	ld	hl, #0+0
	add	hl, sp
	ld	b, (hl)
	push	bc
	inc	sp
	xor	a, a
	push	af
	inc	sp
	call	_spiExchange
	pop	af
	pop	af
	C$stdio_spi.c$106$1$74	= .
	.globl	C$stdio_spi.c$106$1$74
	XG$spi_puts$0$0	= .
	.globl	XG$spi_puts$0$0
	ret
	G$putchari$0$0	= .
	.globl	G$putchari$0$0
	C$stdio_spi.c$111$1$74	= .
	.globl	C$stdio_spi.c$111$1$74
;../src/stdio_spi/stdio_spi.c:111: inline void putchari( char data ) { putchar(data); outbound_flush(); }
;	---------------------------------
; Function putchari
; ---------------------------------
_putchari::
	ld	hl, #2+0
	add	hl, sp
	ld	a, (hl)
	push	af
	inc	sp
	call	_putchar
	inc	sp
	C$stdio_spi.c$111$1$76	= .
	.globl	C$stdio_spi.c$111$1$76
	XG$putchari$0$0	= .
	.globl	XG$putchari$0$0
	jp  _outbound_flush
	G$putchar$0$0	= .
	.globl	G$putchar$0$0
	C$stdio_spi.c$116$1$76	= .
	.globl	C$stdio_spi.c$116$1$76
;../src/stdio_spi/stdio_spi.c:116: void putchar( char data )
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
	push	ix
	ld	ix,#0
	add	ix,sp
	C$stdio_spi.c$119$1$78	= .
	.globl	C$stdio_spi.c$119$1$78
;../src/stdio_spi/stdio_spi.c:119: if( !stdio_connected ) return;
	ld	a,(#_stdio_connected + 0)
	or	a, a
	jr	Z,00108$
	C$stdio_spi.c$122$1$78	= .
	.globl	C$stdio_spi.c$122$1$78
;../src/stdio_spi/stdio_spi.c:122: stdio_outbound_buffer[outbuffer_entries++] = data;
	ld	bc,#_stdio_outbound_buffer+0
	ld	iy,#_outbuffer_entries
	ld	e,0 (iy)
	inc	0 (iy)
	ld	l,e
	ld	h,#0x00
	add	hl,bc
	ld	a,4 (ix)
	ld	(hl),a
	C$stdio_spi.c$125$1$78	= .
	.globl	C$stdio_spi.c$125$1$78
;../src/stdio_spi/stdio_spi.c:125: if( data == _LF_ ) stdio_outbound_buffer[outbuffer_entries++] = _CR_;
	ld	a,4 (ix)
	sub	a, #0x0a
	jr	NZ,00122$
	ld	a,#0x01
	jr	00123$
00122$:
	xor	a,a
00123$:
	ld	e,a
	or	a, a
	jr	Z,00104$
	ld	iy,#_outbuffer_entries
	ld	d,0 (iy)
	inc	0 (iy)
	ld	l,d
	ld	h,#0x00
	add	hl,bc
	ld	(hl),#0x0d
00104$:
	C$stdio_spi.c$128$1$78	= .
	.globl	C$stdio_spi.c$128$1$78
;../src/stdio_spi/stdio_spi.c:128: if( ( data == _LF_ ) || ( outbuffer_entries >= _STD_WIDTH_ ) ) outbound_flush();
	ld	a,e
	or	a, a
	jr	NZ,00105$
	ld	a,(#_outbuffer_entries + 0)
	sub	a, #0x50
	jr	C,00108$
00105$:
	call	_outbound_flush
00108$:
	pop	ix
	C$stdio_spi.c$129$1$78	= .
	.globl	C$stdio_spi.c$129$1$78
	XG$putchar$0$0	= .
	.globl	XG$putchar$0$0
	ret
	G$outbound_flush$0$0	= .
	.globl	G$outbound_flush$0$0
	C$stdio_spi.c$133$1$78	= .
	.globl	C$stdio_spi.c$133$1$78
;../src/stdio_spi/stdio_spi.c:133: void outbound_flush()
;	---------------------------------
; Function outbound_flush
; ---------------------------------
_outbound_flush::
	C$stdio_spi.c$136$1$79	= .
	.globl	C$stdio_spi.c$136$1$79
;../src/stdio_spi/stdio_spi.c:136: stdio_outbound_buffer[outbuffer_entries] = 0;
	ld	bc,#_stdio_outbound_buffer+0
	ld	hl,(_outbuffer_entries)
	ld	h,#0x00
	add	hl,bc
	ld	(hl),#0x00
	C$stdio_spi.c$139$1$79	= .
	.globl	C$stdio_spi.c$139$1$79
;../src/stdio_spi/stdio_spi.c:139: spi_puts(stdio_outbound_buffer);
	push	bc
	call	_spi_puts
	pop	af
	C$stdio_spi.c$142$1$79	= .
	.globl	C$stdio_spi.c$142$1$79
;../src/stdio_spi/stdio_spi.c:142: outbuffer_entries = 0;
	ld	hl,#_outbuffer_entries + 0
	ld	(hl), #0x00
	C$stdio_spi.c$143$1$79	= .
	.globl	C$stdio_spi.c$143$1$79
	XG$outbound_flush$0$0	= .
	.globl	XG$outbound_flush$0$0
	ret
	G$spi_avail$0$0	= .
	.globl	G$spi_avail$0$0
	C$stdio_spi.c$147$1$79	= .
	.globl	C$stdio_spi.c$147$1$79
;../src/stdio_spi/stdio_spi.c:147: unsigned char spi_avail()
;	---------------------------------
; Function spi_avail
; ---------------------------------
_spi_avail::
	C$stdio_spi.c$149$1$80	= .
	.globl	C$stdio_spi.c$149$1$80
;../src/stdio_spi/stdio_spi.c:149: return inbuffer_entries;
	ld	iy,#_inbuffer_entries
	ld	l,0 (iy)
	C$stdio_spi.c$150$1$80	= .
	.globl	C$stdio_spi.c$150$1$80
	XG$spi_avail$0$0	= .
	.globl	XG$spi_avail$0$0
	ret
	G$getchar$0$0	= .
	.globl	G$getchar$0$0
	C$stdio_spi.c$154$1$80	= .
	.globl	C$stdio_spi.c$154$1$80
;../src/stdio_spi/stdio_spi.c:154: char getchar()
;	---------------------------------
; Function getchar
; ---------------------------------
_getchar::
	C$stdio_spi.c$157$1$81	= .
	.globl	C$stdio_spi.c$157$1$81
;../src/stdio_spi/stdio_spi.c:157: char r = stdio_inbound_buffer[0];
	ld	bc,#_stdio_inbound_buffer+0
	ld	a,(bc)
	ld	e,a
	C$stdio_spi.c$160$1$81	= .
	.globl	C$stdio_spi.c$160$1$81
;../src/stdio_spi/stdio_spi.c:160: if( inbuffer_entries == 0 ) return 0;
	ld	a,(#_inbuffer_entries + 0)
	or	a,a
	jr	NZ,00102$
	ld	l,a
	ret
00102$:
	C$stdio_spi.c$163$1$81	= .
	.globl	C$stdio_spi.c$163$1$81
;../src/stdio_spi/stdio_spi.c:163: if( inbuffer_entries > 1 )
	ld	a,#0x01
	ld	iy,#_inbuffer_entries
	sub	a, 0 (iy)
	jr	NC,00104$
	C$stdio_spi.c$164$1$81	= .
	.globl	C$stdio_spi.c$164$1$81
;../src/stdio_spi/stdio_spi.c:164: memcpy( stdio_inbound_buffer, stdio_inbound_buffer + 1, inbuffer_entries);
	inc	bc
	ld	l,0 (iy)
	ld	h,#0x00
	push	de
	push	hl
	push	bc
	ld	hl,#_stdio_inbound_buffer
	push	hl
	call	_memcpy
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	de
00104$:
	C$stdio_spi.c$167$1$81	= .
	.globl	C$stdio_spi.c$167$1$81
;../src/stdio_spi/stdio_spi.c:167: inbuffer_entries--;
	ld	hl, #_inbuffer_entries+0
	dec	(hl)
	C$stdio_spi.c$170$1$81	= .
	.globl	C$stdio_spi.c$170$1$81
;../src/stdio_spi/stdio_spi.c:170: return r;
	ld	l,e
	C$stdio_spi.c$171$1$81	= .
	.globl	C$stdio_spi.c$171$1$81
	XG$getchar$0$0	= .
	.globl	XG$getchar$0$0
	ret
	G$inbound_flush$0$0	= .
	.globl	G$inbound_flush$0$0
	C$stdio_spi.c$176$1$81	= .
	.globl	C$stdio_spi.c$176$1$81
;../src/stdio_spi/stdio_spi.c:176: void inbound_flush()
;	---------------------------------
; Function inbound_flush
; ---------------------------------
_inbound_flush::
	C$stdio_spi.c$178$1$82	= .
	.globl	C$stdio_spi.c$178$1$82
;../src/stdio_spi/stdio_spi.c:178: inbuffer_entries = 0;
	ld	hl,#_inbuffer_entries + 0
	ld	(hl), #0x00
	C$stdio_spi.c$179$1$82	= .
	.globl	C$stdio_spi.c$179$1$82
	XG$inbound_flush$0$0	= .
	.globl	XG$inbound_flush$0$0
	ret
	G$spi_connected$0$0	= .
	.globl	G$spi_connected$0$0
	C$stdio_spi.c$184$1$82	= .
	.globl	C$stdio_spi.c$184$1$82
;../src/stdio_spi/stdio_spi.c:184: inline Bool spi_connected()
;	---------------------------------
; Function spi_connected
; ---------------------------------
_spi_connected::
	C$stdio_spi.c$186$1$83	= .
	.globl	C$stdio_spi.c$186$1$83
;../src/stdio_spi/stdio_spi.c:186: return stdio_connected;
	ld	iy,#_stdio_connected
	ld	l,0 (iy)
	C$stdio_spi.c$187$1$83	= .
	.globl	C$stdio_spi.c$187$1$83
	XG$spi_connected$0$0	= .
	.globl	XG$spi_connected$0$0
	ret
	.area _CODE
	.area _INITIALIZER
Fstdio_spi$__xinit_stdio_connected$0$0 == .
__xinit__stdio_connected:
	.db #0x00	; 0
	.area _CABS (ABS)
