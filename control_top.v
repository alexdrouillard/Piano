

module control_top(
    input clock,
    input resetn,
	input go,
	input ih_isdone,
	input [5:0] user_input,
	input win,
	input [1:0] lives,
	input stone_isdone,
	
	output reg auto_reset,
	output reg level_one_active,
	output reg play,
	output reg mute,
	output reg check_score_enable,
	output reg next,
	output reg check_lives_enable,
	output reg play_loss,
	output reg next_level,
	output reg [7:0] current_state,
	output reg hard_reset,
	output reg stone_reset,
	output reg [3:0] draw_screen
    );
	 
	reg[3:0] level;
	reg enable_debug;
	wire [30:0] counter_out;
	 
	debug_counter help (
		.clock(clock),
		.enable(enable_debug),
		.resetn(resetn),
		.count(counter_out)
	);
		
		
    reg [7:0] next_state; 
    localparam  				S_FREEPLAY							= 5'd0,
								S_FREEPLAY_WAIT					= 5'd1,
								S_LEVEL_ONE_RESET 			= 5'd4,
								S_LEVEL_ONE						= 5'd2,
								S_LEVEL_ONE_WAIT				= 5'd3,
								S_PLAY_TONE						= 5'd5,
								S_PLAY_TONE_WAIT  			= 5'd6,
								S_PLAY_TONE_RESET				= 5'd7,
								S_WAIT4USER						= 5'd8,
								S_CHECK_SCORE					= 5'd9,
								S_CHECK_LIVES					= 5'd10,
								S_START								= 5'd11,
								S_PLAY_END_TONE				= 5'd12,
								S_NEXT_LEVEL						= 5'd13,
								S_PLAY_END_TONE_WAIT  	= 5'd14,
								S_WIN_CONDITION				= 5'd15,
								S_WAIT_USER_NEXTLVL     	= 5'd16,
								S_WAITWAIT_USER_NEXTLVL = 5'd17,
								S_GAME_OVER						= 5'd18,
								S_BUFFER								= 5'd19,
								S_BUFFER2							= 5'd20,
								S_WAIT_USER_BUFFER				= 5'd21,
								S_ABS_WIN							= 5'd22,
								S_WINSCREEN							= 5'd23,
								S_WINSCREEN_WAIT					= 5'd24,
								S_GAME_OVER_WAIT					= 5'd25;
						
    
    // Next state logic aka our state table
    always@(*) //changing from *
    begin: state_table 
            case (current_state)
            S_FREEPLAY: 							next_state 			= go ? S_FREEPLAY_WAIT : S_FREEPLAY;
					
				S_FREEPLAY_WAIT:					next_state 			= go ? S_FREEPLAY_WAIT : S_LEVEL_ONE_RESET;
					
				S_LEVEL_ONE_RESET: 				next_state 		    = S_PLAY_TONE;
					
				S_LEVEL_ONE: 							next_state 			= S_LEVEL_ONE_WAIT;
					
				S_LEVEL_ONE_WAIT:		    		next_state 			= ih_isdone ? S_CHECK_SCORE : S_LEVEL_ONE_WAIT;
					
				S_PLAY_TONE: 							next_state 			= S_PLAY_TONE_WAIT;
					
				S_PLAY_TONE_WAIT:					next_state 			= S_PLAY_TONE_RESET;//ih_isdone ? S_PLAY_TONE_RESET : S_PLAY_TONE_WAIT;
					
				S_PLAY_TONE_RESET:				next_state				= S_WAIT4USER;
					
				S_WAIT4USER:							next_state				= (user_input != 6'b0) ? S_WAIT_USER_BUFFER : S_WAIT4USER;
				
				S_WAIT_USER_BUFFER:					next_state				= S_LEVEL_ONE;
					
				S_CHECK_SCORE:						next_state				= S_PLAY_END_TONE;
					
				S_START:									next_state				= S_FREEPLAY;
					
				S_PLAY_END_TONE:					next_state				= S_PLAY_END_TONE_WAIT; //used to be S_PLAY_END_TONE_WAIT
					
				S_PLAY_END_TONE_WAIT:			next_state				= S_BUFFER; //LOOPING HERE FOR NOW
				
				S_BUFFER:								next_state				= S_BUFFER2;
				
				S_BUFFER2:								next_state				= stone_isdone ? S_BUFFER2 : S_WIN_CONDITION;  
					
				S_CHECK_LIVES:						next_state				= (lives == 2'b0) ? S_GAME_OVER : S_WAIT_USER_NEXTLVL;
				
				S_NEXT_LEVEL:							next_state 			= S_LEVEL_ONE_RESET; //was S_LEVEL_ONE_RESET
				
				S_WIN_CONDITION:					next_state				= win ? S_WAIT_USER_NEXTLVL : S_CHECK_LIVES;
				//
				S_WAIT_USER_NEXTLVL:			next_state				= go ? S_WAITWAIT_USER_NEXTLVL : S_WAIT_USER_NEXTLVL;
				//
				S_WAITWAIT_USER_NEXTLVL: 	next_state				= go ? S_WAITWAIT_USER_NEXTLVL : (win ? S_ABS_WIN : S_LEVEL_ONE_RESET); //shaky check me
				
				S_ABS_WIN:					next_state				= (level >= 4'd3) ? S_WINSCREEN : S_NEXT_LEVEL;
				
				S_WINSCREEN:				next_state				= go ? S_WINSCREEN_WAIT : S_WINSCREEN;
				
				S_WINSCREEN_WAIT:			next_state				= go ? S_WINSCREEN_WAIT : S_START;
				
				S_GAME_OVER:				next_state				= go ? S_GAME_OVER_WAIT : S_GAME_OVER;
				
				S_GAME_OVER_WAIT:			next_state				= go ? S_GAME_OVER_WAIT : S_START;
				// we will be done our two operations, start over after
				
            default:     next_state 								= S_FREEPLAY;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(posedge clock)
    begin: enable_signals
        // By default make all our signals 0
		level_one_active 			= 1'b0;
		auto_reset 					= 1'b0;
		play 						= 1'b0;
		mute						= 1'b0;
		check_score_enable			= 1'b0;
		play_loss					= 1'b0;
		check_lives_enable			= 1'b0;
		next_level					= 1'b0;
		hard_reset					= 1'b0;
		stone_reset					= 1'b0;
		next						= 1'b0;
		enable_debug				= 1'b0;

        case (current_state)
			S_LEVEL_ONE_RESET: begin
				auto_reset = 1'b1;
				draw_screen = (level)*(3'd3) + 1'd1 + (3'd3-lives);
				next = 1'b1;
				//temp	
			end
			
			S_LEVEL_ONE: begin
				level_one_active = 1'b1;
				enable_debug = 1'b1;
			end
			
			S_PLAY_TONE: begin
				play = 1'b1;
				enable_debug = 1'b1;
			end
			
			S_PLAY_TONE_RESET: begin
				stone_reset = 1'b1; //was auto reset
			end

			S_LEVEL_ONE_WAIT: begin
				mute = 1'b1;
			end
			
			S_WAIT_USER_BUFFER: begin
				auto_reset = 1'b1;
			end
			
			S_CHECK_SCORE: begin;
				check_score_enable = 1'b1;
			end
			
			S_START: begin
				hard_reset = 1'b1;
				level = 4'd0;
				draw_screen = 4'b0000;
				
			end
			
			S_PLAY_END_TONE: begin
				play_loss = 1'b1;
				draw_screen = (level)*(3'd3) + 1'd1 + (3'd3-lives);
				next = 1'b1;
			end
			
			S_NEXT_LEVEL: begin
				auto_reset = 1'b1; //RECENt
				next_level = 1'b1;
				level = level + 1'b1;
			end
						
			S_FREEPLAY: begin
				draw_screen = 4'b0000;
				next = 1'b1;
				level = 4'd0;
				//temp				
			end
			
			S_WINSCREEN: begin
				draw_screen = 4'b1110;
				next = 1'b1;
			end
			
			S_GAME_OVER: begin
				draw_screen = 4'b1101;
				next = 1'b1;
			end
						
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(resetn) begin
         current_state <= S_START;
		end
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module debug_counter (
	input clock,
	input enable,
	input resetn,
	output reg [30:0] count
);
	
	always@(posedge clock) begin
		if (resetn)
			count <= 31'd310000000;
		else if (enable)
			count <= 31'd310000000;
		else if (count > 31'd0)
			count <= count - 1'b1;
	end
		
endmodule
