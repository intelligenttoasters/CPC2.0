/*
 * cmodem.c
 *
 * Created: 19/11/2016 3:45:42 PM
 *  Author: paul
 *    Desc: This library handles USB communication for binary packet transfer.
 *			It's primary purpose is from PC to device, so the send routine is run on the PC
 */ 

#include "stdio.h"
#include "stdlib.h"
#include "cmodem.h"
#include "sys/types.h"
#include "sys/stat.h"
#include "fcntl.h"
#include "unistd.h"
#include "sys/stat.h"
#include "string.h"

#ifndef BOARD		// Only include if compiling on PC
#include "termios.h"
#include "sys/ioctl.h"
#include "errno.h"
#include "time.h"
#endif

#define TIMEOUT 2
#define RETRIES 500

/* Packetize binary data
 * Returns -1 buffer overflow, otherwise size
 */
int packetize(uint8_t *in, int in_size, uint8_t *out, int out_size)
{
	int cntr;
	uint32_t src;
	void * orig = out;
	
	// Overflow the output buffer
	if( in_size * 8 > (out_size * 6) - 16) return -1;	
	
	// Start character
	*out++=STX;
	
	for( cntr=in_size; cntr>0; cntr-=3 ) {
		// Convert blocks of 3 bytes to 4 bytes
		if( cntr >= 3 ) src = *in++ | *in++ << 8 | *in++ << 16;
		if( cntr == 2 ) src = *in++ | *in++ << 8;
		if( cntr == 1 ) src = *in++;

		// Convert 32-bit integer to printable characters
		*out++ = (src & 0x3f) + 48;
		*out++ = ((src & (0x3f << 6)) >> 6) + 48;
		if( cntr >= 2 ) 
			*out++ = ((src & (0x3f << 12)) >> 12) + 48; 
		if( cntr >= 3 )		
			*out++ = ((src & (0x3f << 18)) >> 18) + 48; 
	}
	
	// End character
	*out++=ETX;
	
	// Return the size of the buffer
	return (void *) out - (void *) orig;
} 

/* De-packetize binary data
 * Returns -1 buffer overflow, -2 malformed packet, otherwise size
 */
int depacketize(uint8_t *in, int in_size, uint8_t *out, int out_size)
{
	int cntr = in_size - 2;
//	uint8_t ch = 0;
	void * orig = out;
	uint32_t src;

	// Overflow the output buffer
	if( (((in_size-2) * 6) & 0xfffff8 ) > (out_size * 8) ) return -1;	

	// Check STX
//	if( *in++ != STX ) return -2;
	
	// Find STX
	while( (*in++ != STX) && (cntr > 0) ) cntr--;
	
	while( cntr > 0 )
	{
		// Place up to 4x6-bit words into a 24 bit variable for splitting 
		src = *in++ - 48 | (*in++ - 48) << 6;
		if( cntr >= 3 )
			src |= (*in++ - 48) << 12;
		if( cntr >= 4 )
			src |= (*in++ - 48) << 18;
			
		*out++ = (src & 0x0000ff) >> 0; 
		if( cntr >= 3 )
			*out++ = (src & 0x00ff00) >> 8; 
		if( cntr >= 4 )
			*out++ = (src & 0xff0000) >> 16;
		
		// Reduce counter by up to four bytes
		cntr -= 4; 
	}
	if( *in++ != ETX ) return -2;
	
	return (void*)out - (void*)orig;
}

// ---------------------------- reverse --------------------------------

// Reverses (reflects) bits in a 32-bit word.
unsigned reverse(unsigned x) {
   x = ((x & 0x55555555) <<  1) | ((x >>  1) & 0x55555555);
   x = ((x & 0x33333333) <<  2) | ((x >>  2) & 0x33333333);
   x = ((x & 0x0F0F0F0F) <<  4) | ((x >>  4) & 0x0F0F0F0F);
   x = (x << 24) | ((x & 0xFF00) << 8) |
       ((x >> 8) & 0xFF00) | (x >> 24);
   return x;
}

// ----------------------------- crc32a --------------------------------

/* This is the basic CRC algorithm with no optimizations. It follows the
logic circuit as closely as possible. */

uint32_t crc32(uint8_t *message, uint16_t size) {
   int i, j, cntr;
   uint32_t byte, crc;

   i = 0; cntr = size;
   crc = 0xFFFFFFFF;
   while (cntr-- != 0) {
      byte = message[i];            // Get next byte.
      byte = reverse(byte);         // 32-bit reversal.
      for (j = 0; j <= 7; j++) {    // Do eight times.
         if ((int)(crc ^ byte) < 0)
              crc = (crc << 1) ^ 0x04C11DB7;
         else crc = crc << 1;
         byte = byte << 1;          // Ready next msg bit.
      }
      i = i + 1;
   }
   return reverse(~crc);
}

/*
 * Send file to tty using 256 byte buffers	
 * Packet is STX, Size - 4 bytes, data - 256 bytes, crc - 4 bytes, etx
 */
#ifndef BOARD		// Only include if compiling on PC
uint8_t send( char *src, char *dst )
{
	uint8_t binary_buffer[256 + 8];	// Size(4)+Data(256)+CRC(4)
	uint8_t coded_buffer[362];
	uint8_t eom = EM;
	uint32_t sendbyte = 0;
	uint16_t remain;
	uint8_t update_cntr = 0;
	
	// Open source file
	int sfile = open( src, O_RDONLY );
	
	// Problem opening?
	if( sfile <= 0 ) return 1;	
	
	// Open destination
	int dfile = open( dst, O_RDWR, O_NONBLOCK );

	// Problem opening?
	if( dfile <= 0 ) return 2;

	// Set the DTR flag so the device recognizes the port as open
	int DTR_flag;
	DTR_flag = TIOCM_DTR;
	ioctl(dfile,TIOCMBIS,&DTR_flag); //Set DTR pin

	// Get the time
	time_t t = time(NULL);

	// Get the size of the file
	struct stat st;	stat(src, &st);

	int src_cnt = 0;
	while( src_cnt < st.st_size )
	{
		// Read up to 256 bytes into the binary buffer, after the size
		int r = read( sfile, binary_buffer + 4, 256 );

		// Convert to a known byte order
		int sz = htonl(r);
		
		// Copy in the size
		memcpy( binary_buffer, &sz, 4 );
		
		// Store the CRC, including the size
		uint32_t crc = crc32( binary_buffer, r + 4 );

		// Convert to a known byte order		
		crc = htonl( crc );
		
		// Copy the CRC to the binary buffer at the end
		memcpy( binary_buffer + r + 4, &crc, 4 );

		// Packetize the data for transmission, size r + size + crc
		sz = packetize( binary_buffer, r + 8, coded_buffer, 362 );

		// Status message, % complete and remaining time
		float com = (float)(sendbyte += r) / (float)st.st_size;
		if( (update_cntr++ & 31) == 0 )
			remain = ((float)( time(NULL) - t) / com) * (1.0-com);
		fprintf(stderr,"Complete %3.1f%%, time %ds eta %ds\e[K\r", com * 100.0, (time(NULL) - t), remain);

		// Now repeatedly try to send the data until it's acknowledged
		uint8_t success = 0;
		for( int retries = 0; (retries < RETRIES) && (success == 0); retries++)
		{
			// Now write out the data
			write( dfile, coded_buffer, sz );
	
			// Wait for the ack/nak
			uint8_t response = ACK;
			uint32_t timeout = 0;
			while( ( read( dfile, &response, 1) < 1 ) && (timeout < TIMEOUT) ) {
				timeout++;
				sleep(1);
			}
			if( timeout == TIMEOUT ) 
				fprintf(stderr, "Timeout waiting for ACK, retrying\n");
			else {
				// ACK exits from retry loop
				if( response == ACK )
					success = 1;
				else
					fprintf(stderr, "ACK not received, resending\n");
			}				
		}
		
		// Check the success flag
		if( success == 0 )
		{
			fprintf(stderr,"Failed to get ACK %d times, aborting\n", RETRIES);
			close( dfile );
			close( sfile );
			return 3;
		}
		// Increase the counter by the number read
		src_cnt += r; 
	}

	// Step over the status line
	fprintf(stderr,"\n\r");
		

	// Send the end-of-medium flag
	write( dfile, &eom, 1 );
	
	// Reset the DTR pin to signal the port is closed
	ioctl(dfile,TIOCMBIC,&DTR_flag); //Clear DTR pin

	// Close the files
	close(dfile);
	close(sfile);
	
	fprintf(stderr, "Successfully sent %ld bytes\n", st.st_size );
	
	// Success
	return 0;
}

#endif	// PC compile

#ifdef BOARD		// Only include if compiling on the SAM
/*
 * Receive a file from tty using 256 byte buffers
 * Pass in a buffer for error messages
 */
int32_t receive(uint8_t **buffer_ptr, char *msg) 
{
	uint8_t buffer[363];
	uint8_t *ptr;
	static uint8_t binary_buffer[256 + 8];
	uint8_t i;
	iram_size_t sz;
	bool finished = false;
	

	// Reset the ptr
	ptr = buffer;
	
	// Read a packet up to end-of-text marker
	while(!finished) {
		// Wait for something to be available
		while( (sz = udi_cdc_get_nb_received_data()) == 0 ) nop();	
		// Read the entire buffer for performance reasons
		udi_cdc_read_buf(ptr,sz);
		// Check each character
		for( i=0; i<sz; i++) {
			// If end-of-medium sent then return 0
			if( *ptr == EM ) return 0;
			// If end-of-text/block sent then process the received data
			if( *ptr++ == ETX ) {
				finished = true;
				break;
			}
		}
	}
	
	// Calculate the received size
	int size = (void*)ptr - (void*)buffer;
	
	// If it's less than zero then there was an error reading the file
	if( size <= 0 ) {
		sprintf(msg, "Error occurred: %d", size);
		return -1;
	}

	// Size is how many bytes converted in the packeting process
	size = depacketize(buffer, size, binary_buffer, 256 + 8 );
	
	// If it's less than zero then there was an error depacketizing
	if( size <= 0 ) {
		sprintf(msg, "Error occurred: %d", size);
		return -2;
	}
	
	// Get size from real size from the sent data
	size = *(uint32_t*)(binary_buffer);
		
	// Calculate the CRC
	uint32_t crc = crc32( binary_buffer, size + 4 );
	
	// Compare the CRC in the sent packet
	if( crc == *(uint32_t*)(binary_buffer+size+4) )
		putchar( ACK );
	else
		putchar( NAK );
	
	// Return the size of the buffer
	*buffer_ptr = binary_buffer + 4;
	return size;
}
#endif
