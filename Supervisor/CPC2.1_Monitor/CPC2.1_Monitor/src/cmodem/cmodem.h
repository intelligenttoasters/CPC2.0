#ifndef cmodem_h
#define cmodem_h

	#ifdef __SAM4SD32C__
		#include "asf.h"
		#define htonl(x) x
		#define ntohl(x) x
	#else
		#define htonl(x) x
		#define ntohl(x) x
		#define nop() 
	#endif

	#define STX 02
	#define ETX 03
	#define ACK 06
	#define NAK 21
	#define XON 17
	#define XOFF 19
	// End of medium
	#define EM 25

	int packetize(uint8_t *in, int in_size, uint8_t *out, int out_size);
	int depacketize(uint8_t *in, int in_size, uint8_t *out, int out_size);
	uint32_t crc32(uint8_t *message, uint16_t size);
	unsigned reverse(unsigned x);
	uint8_t send( char *src, char *dst );
	int32_t receive(uint8_t **buffer, char *msg);
	
#endif