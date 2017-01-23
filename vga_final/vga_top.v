module vga_top
	(
		clock,						//	On Board 50 MHz
		next,
		next_screen, 
		
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   							//	VGA Blue[9:0]
	);
	
	//ALEX USE THESE
	//choose which screen to draw
	input [3:0] next_screen;
	//draw the screen
	input next;
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	// Create the colour, x, y and writeEn wires that are inputs to the vga module.
	wire [2:0] colour;
	wire [7:0] X;
	wire [6:0] Y;
	wire writeEn;
	
	//25 MHz clock
	wire clock_25;
	
	// reset delay gives some time for peripherals to initialize
	wire DLY_RST;
	Reset_Delay RST(
		.iCLK(CLOCK_50),
		.oRESET(DLY_RST)
		);	

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours
	vga_adapter VGA(
			.resetn((DLY_RST) || (~next && 1'b0)),
			.clock(CLOCK_50),
			.colour(colour),
			.x(X),
			.y(Y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK)
			);
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;

	vga_pll newclock(
		.clock_in(CLOCK_50),
		.clock_out(clock_25)
		);
			
	get_coordinates GET (
		.clock(clock_25),
		.reset(DLY_RST),
		.next(next),
		.next_screen(next_screen),
		.x(X),
		.y(Y),
		.colour_out(colour),
		.enable(writeEn)
		);
			
endmodule

module Reset_Delay (iCLK, oRESET);
	input iCLK;
	output reg oRESET;
	reg [19:0] Cont;

	always@(posedge iCLK)
	begin
		if(Cont!=20'hFFFFF) begin
			Cont <= Cont + 1'b1;
			oRESET <= 1'b0;
		end
		
		else
		oRESET <= 1'b1;
	end
endmodule
