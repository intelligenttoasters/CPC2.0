
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
	input [7:0] d1_i,
	input [7:0] d2_i,
	input [7:0] d3_i,
	input [7:0] d4_i,
	input [7:0] d5_i,
	input [7:0] d6_i,
	input [7:0] d7_i,
	input [7:0] d8_i,
	input [7:0] d9_i,
	input [7:0] d10_i,
	input [7:0] d11_i,
	input [7:0] d12_i,
	input [7:0] d13_i,
	input [7:0] d14_i,
	input [7:0] d15_i
	);

	assign d_o = 
		(selector_i == 4'd1) ? d1_i :
		(selector_i == 4'd2) ? d2_i :
		(selector_i == 4'd3) ? d3_i :
		(selector_i == 4'd4) ? d4_i :
		(selector_i == 4'd5) ? d5_i :
		(selector_i == 4'd6) ? d6_i :
		(selector_i == 4'd7) ? d7_i :
		(selector_i == 4'd8) ? d8_i :
		(selector_i == 4'd9) ? d9_i :
		(selector_i == 4'd10) ? d10_i :
		(selector_i == 4'd11) ? d11_i :
		(selector_i == 4'd12) ? d12_i :
		(selector_i == 4'd13) ? d13_i :
		(selector_i == 4'd14) ? d14_i :
		(selector_i == 4'd15) ? d15_i :
		d0_i;
	
endmodule
