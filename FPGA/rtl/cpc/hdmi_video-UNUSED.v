`include "system.v"

module hdmi_video (
	input CLOCK_50_i,
	input reset_i,
	output hdmi_clk_o,
	output hdmi_de_o,
	output hdmi_vs_o,
	output hdmi_hs_o,
	output [23:0] hdmi_d_o,
	output [15:0] a_o,
	output vram_clk_o,
	input [23:0] color_dat_i,
	output [2:0] video_pixel_o,
	output border_o,
	input [15:0] video_offset_i
	);

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire inDisplayArea;
reg [10:0] CounterX = 0;
reg [9:0] CounterY = 0;

// These are actual pixel cursors res 800x600
wire [9:0] cursorx;
wire [9:0] cursory;
wire [9:0] bitmapx;
wire [9:0] bitmapy;

wire inbitmap_area;

//=======================================================
//  Combinational logic
//=======================================================
// if in bitmap area, show blue, if border area show green, else nothing
assign hdmi_d_o = { (inDisplayArea) ? color_dat_i : 24'd0 };
assign hdmi_de_o = inDisplayArea;

assign hdmi_hs_o = (CounterX >= 128) || (CounterY < 4) ; 	// change this value to move the display horizontally
assign hdmi_vs_o = (CounterY >= 4); 		// change this value to move the display vertically
assign inDisplayArea = (CounterX >= 216) && (CounterX < 1016) && (CounterY >= 27) && (CounterY < 627);

// These are actual pixel cursors res 800x600
assign cursorx = (inDisplayArea) ? CounterX - 10'd216 : 1'b0;
assign cursory = (inDisplayArea) ? CounterY - 10'd27 : 1'b0;

// Now work out if we're in the bitmapped area or border area
assign inbitmap_area = (cursorx >= 80) && (cursorx < 719) && (cursory >= 100) && (cursory < 500);

// What's our position in the  bitmap area
assign bitmapx = (inbitmap_area) ? cursorx - 10'd80 : 10'd0;
assign bitmapy = (inbitmap_area) ? cursory - 10'd100 : 10'd0;

// Calculate our ram address
// Offset + (raster row offset 0-7 X h800) + line 0-200 * 80 + X (excluding bit positions) 
wire [13:0] rastercalc = video_offset_i[10:0] + (bitmapy[3:1] << 11) + (bitmapy[9:4] * 7'd80) + bitmapx[9:3];
assign a_o = {video_offset_i[15:14], rastercalc};

// Send pixel number within video data byte
assign video_pixel_o = bitmapx[2:0];

// Send border signal
assign border_o = (inDisplayArea) && !(inbitmap_area);

//=======================================================
//  Simulation control
//=======================================================
`ifndef SIMULATION
	wire video_clock;
	wire vram_clock;
	// PLL - gives us various clocks from 50MHz
	hdmi_clock video_clk(
		.inclk0( CLOCK_50_i ),
		.areset( reset_i ),    //   reset.reset
		.c0(video_clock), 	// outclk0.clk
		.c1(vram_clock) 		// outclk1.clk 4x video clock, so after 2 clocks data is available for strobe in
	);
				
`else
	// 40MHz clock
	reg video_clock = 0;
	reg vram_clock = 0;
	always begin
		#12 video_clock <= 1;
		#24 video_clock <= 0;
	end
	// 120MHz clock
	always begin
		#4 vram_clock <= 1;
		#4 vram_clock <= 0;
		#4 vram_clock <= 1;
		#5 vram_clock <= 0;
		#4 vram_clock <= 1;
		#4 vram_clock <= 0;
	end
`endif

assign hdmi_clk_o = video_clock;
assign vram_clk_o = vram_clock;

//=======================================================
//  Structural coding
//=======================================================

wire CounterXmaxed = (CounterX==11'd1055);

always @(posedge video_clock)
	CounterX <= (CounterXmaxed) ? 11'd0 : CounterX + 1'b1;

always @(posedge video_clock)
	if(CounterXmaxed) CounterY <= (CounterY == 627) ? 10'd0 : CounterY + 1'b1;

	
endmodule
