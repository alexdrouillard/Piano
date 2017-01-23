`timescale 1ns/1ns
`include "input_handler.v"
`include "control_top.v"
`include "hex_decoder.v"
`include "score_check.v"
`include "play_stone.v"
`include "DJ.v"

module piano (
	SW, 
	KEY, 
	GPIO_0,
	
	
	LEDR,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	
	//Inputs
	CLOCK_50,
	CLOCK_27,
	
	AUD_ADCDAT,
	
	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,
	
	I2C_SDAT,
	
	// Outputs
	AUD_XCK,
	AUD_DACDAT,
	
	I2C_SCLK,
	
	//VGA
	VGA_CLK,   						//	VGA Clock
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK_N,					//	VGA BLANK
	VGA_SYNC_N,						//	VGA SYNC
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B
	
//ADD VGA LATER	
);

//############################################################################
//#										VGA								     #
//############################################################################

//ALEX USE THESE
	//choose which screen to draw
	wire [3:0] next_screen;
	//draw the screen
	wire next;
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
			



/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input		[35:0]	GPIO_0;
input				CLOCK_50;
input				CLOCK_27;
input		[3:0]	KEY;
input		[9:0]	SW;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				I2C_SCLK;

output		[9:0]	LEDR;
output		[6:0]	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires

wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;

//my wires

//######################
//#		CONTROL SIGNALS  		  #
//######################
wire resetn;
wire level_one_active;
wire auto_reset;
wire play;
wire ih_isdone;
wire mute;
wire win;
wire check_score_enable;
wire check_lives_enable;
wire play_loss;
wire play_stone_go;
wire next_level;
wire hard_reset;
wire stone_reset;

wire [1:0] lives;

wire [4:0] score1, score2, score3, score4, score5, score6, score_total;
wire [4:0] current_level;

wire [5:0] muter;
wire [5:0] valid;
wire [5:0] user_input;
wire [5:0] tone_out;
wire [5:0] play_tone;
wire [5:0] play_stone_sound;

wire [7:0] current_state; //DEBUG

wire [11:0] level_out1;
wire [11:0] level_out2;
wire [11:0] level_out3;
wire [11:0] level_out4;
wire [11:0] level_out5;
wire [11:0] level_out6;

wire [31:0] dj_out;

assign muter = {6{mute}};
assign score_total = score1 + score2+ score3 + score4 + score5 + score6;
assign resetn = ~KEY[0];

assign LEDR[5]		= SW[0] & valid[0];
assign LEDR[4]		= SW[0] & valid[1];
assign LEDR[3]		= SW[0] & valid[2];
assign LEDR[2]		= SW[0] & valid[3];
assign LEDR[1]		= SW[0] & valid[4];
assign LEDR[0]		= SW[0] & valid[5];
 
assign LEDR [9]	= play_stone_go;
//replace me with a mux later for better looking code
assign play_tone = (valid & (~muter)) | (user_input) | (play_stone_sound & {6{play_stone_go}}); // and with play later for testing

//
assign user_input[0] = GPIO_0[0];
assign user_input[1] = GPIO_0[2];
assign user_input[2] = GPIO_0[4];
assign user_input[3] = GPIO_0[6];
assign user_input[4] = GPIO_0[10];
assign user_input[5] = GPIO_0[12];

// Internal Registers

reg [18:0] delay_cnt;
wire [18:0] delay;
reg snd;

//###########################################################
//#															DJ																 #
//###########################################################

DJ mixdat (
	.clock(CLOCK_50),
	.resetn(resetn | hard_reset),
	.user_input(play_tone),
	.other_sound(),
	.sound_out(dj_out)
);


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50) begin
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign delay = {play_tone[5:0], 13'd0000};

wire [31:0] sound = (play_tone == 0) ? 0 : snd ? 32'd110000000 : -32'd110000000;


assign read_audio_in						= audio_in_available & audio_out_allowed;

assign left_channel_audio_out			= dj_out; // was sound
assign right_channel_audio_out			= dj_out;
assign write_audio_out						= (audio_in_available & audio_out_allowed) & ((play_tone | 5'b11111) || play_stone_go); // figure this out
	
/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(resetn),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.I2C_SCLK					(I2C_SCLK),
	.I2C_SDAT					(I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(resetn)
);

//##########################################
//#						FSM						 # 
//##########################################
	
	
control_top controller (
	.clock(CLOCK_50),
	.resetn(resetn),
	.go(~KEY[3]),
	.ih_isdone(ih_isdone),
	.user_input(user_input),
	.win(win),
	.lives(lives),
	.stone_isdone(play_stone_go),
	
	.auto_reset(auto_reset),
	.level_one_active(level_one_active),
	.play(play),
	.mute(mute),
	.check_score_enable(check_score_enable),
	.next(next),
	.check_lives_enable(check_lives_enable),
	.play_loss(play_loss),
	.next_level(next_level),
	.current_state(current_state),
	.hard_reset(hard_reset),
	.stone_reset(stone_reset),
	.draw_screen(next_screen) //CHHANGE THESE
);

//############################################
//# 					INPUT CHANNELS												   #
//############################################
	
input_handler channel_1 (
	.level_code(level_out1), //Change these
	.clock(CLOCK_50),
	.user_input(user_input[0]),
	.resetn(resetn | auto_reset),
	.enable(level_one_active),
	.play(play),
	.score(score1),
	.valid(valid[0]),
	.done_out(ih_isdone)
);
	
input_handler channel_2 (
	.level_code(level_out2),
	.clock(CLOCK_50),
	.user_input(user_input[1]),
	.resetn(resetn | auto_reset | hard_reset),
	.enable(level_one_active),
	.play(play),
	.score(score2),
	.valid(valid[1])
);

input_handler channel_3 (
	.level_code(level_out3),
	.clock(CLOCK_50),
	.user_input(user_input[2]),
	.resetn(resetn | auto_reset | hard_reset),
	.enable(level_one_active),
	.play(play),
	.score(score3),
	.valid(valid[2])
);

input_handler channel_4 (
	.level_code(level_out4),
	.clock(CLOCK_50),
	.user_input(user_input[3]),
	.resetn(resetn | auto_reset | hard_reset),
	.enable(level_one_active),
	.play(play),
	.score(score4),
	.valid(valid[3])
);

input_handler channel_5 (
	.level_code(level_out5),
	.clock(CLOCK_50),
	.user_input(user_input[4]),
	.resetn(resetn | auto_reset | hard_reset),
	.enable(level_one_active),
	.play(play),
	.score(score5),
	.valid(valid[4])
);

input_handler channel_6 (
	.level_code(level_out6),
	.clock(CLOCK_50),
	.user_input(user_input[5]),
	.resetn(resetn | auto_reset | hard_reset),
	.enable(level_one_active),
	.play(play),
	.score(score6),
	.valid(valid[5])
);

//####################################################
//#					SCORE CHECKER					 #
//####################################################

score_check checker (
	.input_score(score_total),
	
	.level_code1(level_out1),
	.level_code2(level_out2),
	.level_code3(level_out3),
	.level_code4(level_out4),
	.level_code5(level_out5),
	.level_code6(level_out6),
	//change me later
	.enable(check_score_enable),
	.clock(CLOCK_50),
	.resetn(resetn | hard_reset),
	.win(win),
	.lives(lives)
);

//####################################################
//#						STONE					     #
//####################################################

play_stone stone (
	.clock(CLOCK_50),
	.enable(play_loss),
	.resetn(resetn | auto_reset | hard_reset | stone_reset),
	.win(win),
	.play_stone_go(play_stone_go),
	.play_stone_sound(play_stone_sound)
);

//####################################################
//#											LEVEL MUX													 #
//####################################################

level_mux lelmux (
	.clock(CLOCK_50),
	.resetn(resetn | hard_reset),
	.enable(next_level),
	.level_out1(level_out1),
	.level_out2(level_out2),
	.level_out3(level_out3),
	.level_out4(level_out4),
	.level_out5(level_out5),
	.level_out6(level_out6),
	.current_level(current_level)
);

//####################################################
//#										HEX DECODERS													 #
//####################################################
	
hex_decoder h0 (
	.hex_digit(lives),
	.segments(HEX0)
);
	
hex_decoder h1 (
	.hex_digit(level_out1),
	.segments(HEX1)
);

hex_decoder h2 (
	.hex_digit(),
	.segments(HEX2)
);
	
hex_decoder h3 (
	.hex_digit(current_level[3:0]),
	.segments(HEX3)
);

hex_decoder h4 (
	.hex_digit(),
	.segments(HEX4)
);
	
hex_decoder h5 (
	.hex_digit(score_total[3:0]),
	.segments(HEX5)
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