#include "stdio.h"
#include "fcntl.h"
#include "stdlib.h"
#include "unistd.h"
#include "string.h"

int main(int argc, char**argv)
{
	char buffer[8];
	char out[40];

	int f1 = open ("/dev/hidraw5", O_RDONLY);
	int f2 = open ("/dev/ttyACM0", O_WRONLY);
	while( 1 ) 
	{
		int r = read( f1, buffer, 8 );
		if( r>0 )
		{
			sprintf(out, "%02x %02x %02x %02x %02x %02x %02x %02x\n",
				buffer[0], buffer[1], buffer[2], buffer[3],
				buffer[4], buffer[5], buffer[6], buffer[7] );
			write( f2, out, strlen(out) );
		}
	}
	close(f1);
	close(f2);
}
