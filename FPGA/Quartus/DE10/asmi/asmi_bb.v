
module asmi (
	clkin,
	read,
	rden,
	addr,
	reset,
	dataout,
	busy,
	data_valid);	

	input		clkin;
	input		read;
	input		rden;
	input	[23:0]	addr;
	input		reset;
	output	[7:0]	dataout;
	output		busy;
	output		data_valid;
endmodule
