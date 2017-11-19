#include "stdio.h"
#include <string.h>
#include "cmodem.h"
#include "termios.h"

int xmain(int argc, char **argv)
{
	uint8_t buffer[256], buffer2[256];
	int i,sz;

	// Clear the buffers	
	memset(buffer,0,256);
	memset(buffer2,0,256);

	sz = htonl(10);
	memcpy( buffer, &sz, 4 );
	for( i = 0; i<10; i++ )
		buffer[i+4] = i;
	// Calculate the CRC on both size and data
	i = crc32(buffer,14);
	memcpy( buffer+14, &i, 4);
	// Packetize this
	sz = packetize(buffer, 18, buffer2, 256);
	printf("%s", buffer2);


	sz = 0x12345678; //htonl(0x12345678);
	memcpy( buffer, &sz, 4);
fprintf(stderr,"htonl: %x %x %x %x\n", buffer[0], buffer[1], buffer[2], buffer[3]);
	memcpy( &sz, buffer, 4 );
fprintf(stderr, "%x\n", sz);
	
	fprintf(stderr, "Size: %d\n", sz = packetize("ABCDEF", 4, buffer, 256));
	printf("%s", buffer);
	fprintf(stderr, "Recovered chars: %d\n", sz = depacketize(buffer,sz,buffer2,4));
	fprintf(stderr, "String: %s\n", buffer2);
	fprintf(stderr, "CRC32: %x\n", crc32("ABCD",4) );
}

/* Main send application */
int main(int argc, char **argv)
{
	// Check we have a file
	if( argc != 3 ) 
	{
		fprintf(stderr, "Usage: %s <file> <device>\n", argv[0] );
		return -1;
	}
	
	// Send the file to the TTY
	uint8_t r = send( argv[1], argv[2] );
	if( r!=0 ) fprintf(stderr,"Error: %d\n", r);	
	
	return 0;
}
