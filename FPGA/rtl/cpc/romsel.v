
//=======================================================
//  ROM selection arbiter
//=======================================================
module romsel(
	// Selection
	input [3:0] selector_i,
	// Output
	output [7:0] d_o,
	// Inputs
	input [7:0] d0_i,
	input [7:0] d5_i,
	input [7:0] d6_i
	);

	assign d_o = 
		(selector_i == 4'd5) ? d5_i :
		(selector_i == 4'd6) ? d6_i :
		d0_i;
	
endmodule
