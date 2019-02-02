`define LO 1'b0
`define HI 1'b1

//=======================================================
//  Amstrad 40010 emulator
//=======================================================
module a40010(
	input nreset_i,
	input clk_i,
	input [15:0] a_i,
	input [7:0] d_i,
	input [7:0] dv_i,
	input nWR_i,
	input nRD_i,
	input nMREQ_i,
	input nIORQ_i,
	input nM1,
	output nint_o,
	output nROMEN_o,
	output [5:0] romsel_o,
	output [8:0] ramsel_o,
	input [2:0] video_pixel_i,
	input border_i,
	output [23:0] color_dat_o,
	input vsync_i,
	input hsync_i
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
//	wire nmemwr = nMREQ_i | nWR_i;
	wire nmemrd = nMREQ_i | nRD_i;
	wire niowr = nIORQ_i | nWR_i;
//	wire niord = nIORQ_i | nRD_i;
	wire interrupt_ack = ({nIORQ_i,nM1} == 2'd0);
	
	reg [7:0]	rmr;			// RMR Register
	reg [4:0]	penr;			// PENR Register
	reg [4:0]	inkr[0:16];	// Ink register
	reg [8:0]	mmr;			// MMR Register - expanded for 4M
	reg [7:0]	rom_select;	// Selected ROM
	wire [1:0]	crtc_mode = rmr[1:0];
	
//=======================================================
//  Simulation control
//=======================================================


//=======================================================
//  Combinational logic
//=======================================================
	// If reading memory and if upper mem, then use UR bit of RMR else use LR bit of RMR, remembering RMR is active low
	// Needs a special case not used in the real amstrad because we're using an arbiter, not high impedance bus
	assign nROMEN_o = (nmemrd == `LO) ? (
								(a_i[15:14] == 2'b11) ? rmr[3] : 
								(
									(a_i[15:14] == 2'b00) ? rmr[2] : `HI
								)
							) : `HI;
	
	assign romsel_o = rom_select[5:0];
	
	assign ramsel_o = {mmr[2],mmr[8:3],mmr[1:0]};
	
//=======================================================
//  Structural coding
//=======================================================

// ============= Map video in data to color =============

wire [3:0] mode0data = 
				(video_pixel_i[2] == 2'd0) ? 
					{dv_i[1], dv_i[3], dv_i[5], dv_i[7]} :
					{dv_i[0], dv_i[2], dv_i[4], dv_i[6]};

wire [1:0] mode1data = 
				(video_pixel_i[2:1] == 2'd0) ? {dv_i[3], dv_i[7]} :
				(video_pixel_i[2:1] == 2'd1) ? {dv_i[2], dv_i[6]} :
				(video_pixel_i[2:1] == 2'd2) ? {dv_i[1], dv_i[5]} :
				{dv_i[0], dv_i[4]};

wire mode2data = 
				(video_pixel_i[2:0] == 3'd0) ? dv_i[7] :
				(video_pixel_i[2:0] == 3'd1) ? dv_i[6] :
				(video_pixel_i[2:0] == 3'd2) ? dv_i[5] :
				(video_pixel_i[2:0] == 3'd3) ? dv_i[4] :
				(video_pixel_i[2:0] == 3'd4) ? dv_i[3] :
				(video_pixel_i[2:0] == 3'd5) ? dv_i[2] :
				(video_pixel_i[2:0] == 3'd6) ? dv_i[1] :
				dv_i[0];
				
				
wire [4:0] hw_col = (border_i) ? inkr[16] : (
							(crtc_mode == 2'd0) ? inkr[mode0data] :
							(crtc_mode == 2'd1) ? inkr[mode1data] :
							(crtc_mode == 2'd2) ? inkr[mode2data] :
							inkr[mode0data]
							);

assign color_dat_o = 
	(hw_col == 0) ? 24'h7f7f7f :
	(hw_col == 1) ? 24'h7f7f7f :
	(hw_col == 2) ? 24'h00ff7f :
	(hw_col == 3) ? 24'hffff7f :
	(hw_col == 4) ? 24'h00007f :
	(hw_col == 5) ? 24'hff007f :
	(hw_col == 6) ? 24'h007f7f :
	(hw_col == 7) ? 24'hff7f7f :
	(hw_col == 8) ? 24'hff007f :
	(hw_col == 9) ? 24'hffff7f :
	(hw_col == 10) ? 24'hffff00 :
	(hw_col == 11) ? 24'hffffff :
	(hw_col == 12) ? 24'hff0000 :
	(hw_col == 13) ? 24'hff00ff :
	(hw_col == 14) ? 24'hff7f00 :
	(hw_col == 15) ? 24'hff7fff :
	(hw_col == 16) ? 24'h00007f :
	(hw_col == 17) ? 24'h00ff7f :
	(hw_col == 18) ? 24'h00ff00 :
	(hw_col == 19) ? 24'h00ffff :
	(hw_col == 20) ? 24'h000000 :
	(hw_col == 21) ? 24'h0000ff :
	(hw_col == 22) ? 24'h007f00 :
	(hw_col == 23) ? 24'h007fff :
	(hw_col == 24) ? 24'h7f007f :
	(hw_col == 25) ? 24'h7fff7f :
	(hw_col == 26) ? 24'h7fff00 :
	(hw_col == 27) ? 24'h7fffff :
	(hw_col == 28) ? 24'h7f0000 :
	(hw_col == 29) ? 24'h7f00ff :
	(hw_col == 30) ? 24'h7f7f00 :
	24'h7f7fff;

// ============== Handle PENR, INKR, RMR, MMR ===========
	always @(negedge nreset_i or posedge clk_i)
	begin
		if( nreset_i == 0 )
		begin
			rmr <= 0;
			mmr <= 0;
			penr <= 0;
			inkr[0] <= 0;
			inkr[1] <= 0;
			inkr[2] <= 0;
			inkr[3] <= 0;
			inkr[4] <= 0;
			inkr[5] <= 0;
			inkr[6] <= 0;
			inkr[7] <= 0;
			inkr[8] <= 0;
			inkr[9] <= 0;
			inkr[10] <= 0;
			inkr[11] <= 0;
			inkr[12] <= 0;
			inkr[13] <= 0;
			inkr[14] <= 0;
			inkr[15] <= 0;
			inkr[16] <= 0;
		end
		else begin
			// Only of the gate array/PAL is being addressed
			if( a_i[15:14] == 2'b01 && niowr == `LO )
			begin
				// Handle PENR
				if( d_i[7:6] == 2'b00) 
				begin	
					penr <= d_i[4:0];
				end
				else
				// Handle INKR
				if( d_i[7:6] == 2'b01)
				begin
					inkr[penr] <= d_i[4:0];
				end
				else
				// Handle RMR
				if( d_i[7:6] == 2'b10 )
				begin
					rmr <= d_i;
				end			
			end
			// PAL addressed?
			if( a_i[15] == `LO && niowr == `LO )
			begin
				// Handle MMR
				if( d_i[7:6] == 2'b11)
				begin
					mmr <= {a_i[10:8],d_i[5:0]};	// Extended 4M page
				end
			end
			/* This is not correct - SOFT968 Low Kernel Jumpblock says #38 can be patched
			else if( interrupt_ack )	// TODO: If interrupt ack, enable lower rom
			 rmr[2] = 0;
			*/
		end
	end

// ============== Convert INKR to Colour ================

function inkr2rgb(
	input [4:0] inkr_i
	);
	// TODO: Complete the colour look up table
	inkr2rgb = 
		(inkr_i == 5'b11000) ? 6'b000000 :
		(inkr_i == 5'b00100) ? 6'b000001 :
		(inkr_i == 5'b10101) ? 6'b000010 :
		6'b0;
	
endfunction

// ============== ROM Select ============================
	always @(negedge nreset_i or posedge clk_i)
	begin
		if( nreset_i == `LO )
			rom_select <= 0;
		else begin
			// Only if the ROM select is being addressed
			if( a_i[13] == `LO && niowr == `LO )
			begin
				rom_select <= d_i;
			end
		end
	end

// ============== 300Hz interrupt =======================
// NB - This is super dodgy
	reg [5:0] hsync_cntr = 0, hsync_cntr_old = 0;
	reg [7:0] int_hold = 0;
	reg [1:0] track_hsync = 0, track_vsync = 0, track_rmri = 0, track_intack = 0;
	reg vsync_force_reset = 0;
	reg [2:0] vsync_state = 0;

	// System clear timer, transisions on posedge clock
	wire rmri = ( (a_i[15:14] == 2'b01) && (niowr == `LO) && ( d_i[7:6] == 2'b10 ) && d_i[4] );	
	
	// Falling HSYNC
	wire hsync_fall = (track_hsync == 2'b10);
	wire vsync_rise = (track_vsync == 2'b01);
	wire rmri_rise = (track_rmri == 2'b01);
	wire intack_rise = (track_intack == 2'b01);
	
	// Output int
	assign nint_o = (int_hold == 0);
	
	// Track signals - all these signals change of posedge, so sample neg edge
	always @(negedge clk_i)
	begin
		// HSYNC
		track_hsync <= {track_hsync[0],hsync_i};
		// VSYNC
		track_vsync <= {track_vsync[0],vsync_i};
		// RMRI
		track_rmri <= {track_rmri[0],rmri};
		// Int Ack
		track_intack <= {track_intack[0],interrupt_ack};
	end

	// Increment counter, unless vsync forces a reset
	reg vsync_force_reset_alt = 0;
	always @(negedge clk_i) vsync_force_reset_alt <= vsync_force_reset;
//	wire cntr_trig = hsync_trig | vsync_force | interrupt_ack | rmri;
	always @(posedge clk_i)
	begin
		if ( vsync_force_reset_alt || rmri_rise )
			hsync_cntr <= 0;
		else
		if (intack_rise)
			hsync_cntr <= {1'b0,hsync_cntr[4:0]};
		else
		if( hsync_fall ) hsync_cntr = (hsync_cntr < 51) ? 
				// The mask is if the CPU is acknowledging the interrupt, reset bit 6 of the counter
				(hsync_cntr + 1'b1) & (intack_rise ? 6'b011111 : 6'b111111)	: 0;	

		// VSync state machine, creates the counter reset signal
		case(vsync_state)
			// VSYNC rises
			0: if( vsync_rise ) vsync_state <= 1;
			// Wait for two hsync
			1: if( hsync_fall ) vsync_state <= 2;
			2: if( hsync_fall ) vsync_state <= 3;
			// Now reset the counter
			3: begin
				vsync_force_reset <= 1;
				vsync_state <= 4;
			end
			4: begin
				vsync_force_reset <= 0;
				vsync_state <= 0;
			end
			default:
				vsync_state <= 0;
		endcase
	end
	
	// Interuupt trigger block
	always @(negedge clk_i)
	begin
		// Trigger an interrupt if the counter has rolled over unless it reset between 32 and 50
		if( ( hsync_cntr == 6'd0 ) && (hsync_cntr_old != 6'd0) && ((hsync_cntr_old == 6'd51) || ~hsync_cntr_old[5] ) )
		begin
			int_hold <= 1;
			hsync_cntr_old <= hsync_cntr;			
		end
		else
		begin
			// Hold the int until acknowledged or 6uS (which is when the interrupt routine starts executing)
			// This is a deviation from the spec, which says a 1.4uS pulse on INT - the Verilog CPU didn't respond in time and missed some
			if( interrupt_ack )
				int_hold <= 0;
			else
				if( int_hold > 0 ) int_hold <= (int_hold < 8'd96) ? int_hold + 1'b1 : 0;	// This hold INT until #38 is called	
			hsync_cntr_old <= hsync_cntr;			
		end
	end

endmodule

