/*
 * support_app.c - uploads memory to support system - IPL
 *
 * Created: 15/04/2017 8:28:03 PM
 *  Author: paul
 */ 

#include <asf.h>
#include "main.h"

U8 in[256], *ptr;
U32 result, total;

void upload_memory()
{
	// Initiate reset and hold
	setResetState(true);

	total = 0;
	
	// Read some data into output buffer until an error or done
	while( ( result = receive(&ptr, globals.returnMessage) ) > 0 )
	{
		total += result;
		// Send the data across the SPI in DMA mode (DMA both ends)
		spi_raw_exchange_no_handshake( ptr, in, result );
		while(!is_dma_done());
	}
	sprintf(globals.returnMessage,"Finished uploading %d bytes, holding in reset", total );

}