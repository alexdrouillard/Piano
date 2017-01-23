`timescale 1ns/1ns
`include "input_handler.v"
`include "control_top.v"
`include "hex_decoder.v"

module toptest (
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
	
	I2C_SCLK
	
//ADD VGA LATER	
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

wire resetn;
wire level_one_active;
wire auto_reset;
wire play;

wire [4:0] score1, score2, score3, score4, score5, score6, score_total;

wire [5:0] valid;
wire [5:0] user_input;
wire [5:0] tone_out;
wire [5:0] play_tone;

assign score_total = score1 + score2+ score3 + score4 + score5 + score6;
assign resetn = ~KEY[0];
assign LEDR [5:0] = valid [5:0]; 
assign play_tone = (valid) | (user_input); // and with play later for testing

//
assign user_input[0] = ~GPIO_0[0]; //TEMP, I FUCKED UP
assign user_input[1] = ~GPIO_0[2];
assign user_input[2] = ~GPIO_0[4];
assign user_input[3] = ~GPIO_0[6];
assign user_input[4] = ~GPIO_0[10];
assign user_input[5] = ~GPIO_0[12];

// Internal Registers

reg [18:0] delay_cnt;
wire [18:0] delay;
reg snd;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


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

assign delay = {play_tone[5:0], 13'd3000};

wire [31:0] sound = (play_tone == 0) ? 0 : snd ? 32'd110000000 : -32'd110000000;


assign read_audio_in						= audio_in_available & audio_out_allowed;

assign left_channel_audio_out			= sound;
assign right_channel_audio_out			= sound;
assign write_audio_out						= (audio_in_available & audio_out_allowed) & (play_tone | 5'b11111); // figure this out
	
/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/	
	
control_top controller (
	.clock(CLOCK_50),
	.resetn(resetn),
	.go(~KEY[3]),
	.auto_reset(auto_reset),
	.level_one_active(level_one_active),
	.play(play)
);

//############################################
//# 					INPUT CHANNELS												   #
//############################################
	
input_handler channel_1 (
	.level_code(6'b100000),
	.clock(CLOCK_50),
	.user_input(user_input[0]),
	.resetn(resetn | auto_reset),
	.enable(level_one_active),
	.play(play),
	.score(score1),
	.valid(valid[0])
);
	
input_handler channel_2 (
	.level_code(6'b010000),
	.clock(CLOCK_50),
	.user_input(user_input[1]),
	.resetn(resetn | auto_reset),
	.enable(level_one_active),
	.play(play),
	.score(score2),
	.valid(valid[1])
);

input_handler channel_3 (
	.level_code(6'b001000),
	.clock(CLOCK_50),
	.user_input(user_input[2]),
	.resetn(resetn | auto_reset),
	.enable(level_one_active),
	.play(play),
	.score(score3),
	.valid(valid[2])
);

input_handler channel_4 (
	.level_code(6'b000100),
	.clock(CLOCK_50),
	.user_input(user_input[3]),
	.resetn(resetn | auto_reset),
	.enable(level_one_active),
	.play(play),
	.score(score4),
	.valid(valid[3])
);

input_handler channel_5 (
	.level_code(6'b000010),
	.clock(CLOCK_50),
	.user_input(user_input[4]),
	.resetn(resetn | auto_reset),
	.enable(level_one_active),
	.play(play),
	.score(score5),
	.valid(valid[4])
);

input_handler channel_6 (
	.level_code(6'b000001),
	.clock(CLOCK_50),
	.user_input(user_input[5]),
	.resetn(resetn | auto_reset),
	.enable(level_one_active),
	.play(play),
	.score(score6),
	.valid(valid[5])
);


//####################################################
//#										HEX DECODERS													 #
//####################################################
	
hex_decoder h0 (
	.hex_digit(score1),
	.segments(HEX0)
);
	
hex_decoder h1 (
	.hex_digit(score2),
	.segments(HEX1)
);

hex_decoder h2 (
	.hex_digit(score3),
	.segments(HEX2)
);
	
hex_decoder h3 (
	.hex_digit(score4),
	.segments(HEX3)
);

hex_decoder h4 (
	.hex_digit(score5),
	.segments(HEX4)
);
	
hex_decoder h5 (
	.hex_digit(score6),
	.segments(HEX5)
);
	

endmodule