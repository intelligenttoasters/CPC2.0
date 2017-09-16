`define LO 1'b0
`define HI 1'b1

//==============================================================
//  Fake PPI Chip - ports are fixed direction A-inout B-in C-out
// Control port is ignored
//==============================================================
module ppi_fake(
	input nreset_i,
	input clk_i,
	input nCS_i,
	input a0,
	input a1,
	input nIORD_i,
	input nIOWR_i,
	input 		[7:0] d_i,
	output reg 	[7:0] d_o,
	input 		[7:0] a_i,
	output reg 	[7:0] a_o,
	input 		[7:0] b_i,
	output reg	[7:0] c_o
	);

	always @(posedge clk_i)
	begin
		if( nreset_i == `LO )
		begin
			d_o <= 8'hff;
			a_o <= 8'hff;
			c_o <= 8'hff;
		end
		else 
		if( nCS_i == `LO )
		begin
			if( nIORD_i == `LO )
				d_o <= ( a1 == `HI ) ? 8'hff :		// No input for port C/control
						 ( a0 == `LO ) ? a_i : b_i;
			if( nIOWR_i == `LO )
			begin
				case( {a1, a0} )
					2'd0:
						a_o <= d_i;
					2'd2:
						c_o <= d_i;
				endcase				
			end
		end
	end
endmodule
