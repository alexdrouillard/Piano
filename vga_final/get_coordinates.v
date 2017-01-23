module get_coordinates(
	input clock, reset, 
	
	//draw next screen, active high
	input next,
	
	//choose which screen to draw
	input [3:0] next_screen,	
	
	output reg [7:0] x,
	output reg [6:0] y,
	output [2:0] colour_out,
	output reg enable);

	//address and colours
	reg [14:0] address_reg;
	wire [2:0] colour_start, colour_level1_3lives, colour_level1_2lives, colour_level1_1life, colour_level2_3lives, colour_level2_2lives, colour_level2_1life, colour_level3_3lives, colour_level3_2lives, colour_level3_1life, colour_level4_3lives, colour_level4_2lives, colour_level4_1life, colour_lose, colour_win;

	//read data from memory
	reg read;

	//address counter
	always@ (posedge clock or posedge next or negedge reset)
	begin
		if (!reset) begin
			address_reg <= 15'd0;
			x <= 8'd0;
			y <= 7'd0;
			
			read <= 1'b1;
			enable <= 1'b1;
		end
		
		else if (next) begin
			address_reg <= 15'd0;
			x <= 8'd0;
			y <= 7'd0;
			
			read <= 1'b1;
			enable <= 1'b1;	
		end
			
		else if (address_reg != 16'd19200) begin
			address_reg <= address_reg + 1;
			
			x <= address_reg % 160;
			y <= address_reg / 160;
			
			read <= 1'b1;
			enable <= 1'b1;			
		end
		
		else begin
			address_reg <= 16'd19200;
			x <= 8'b0;
			y <= 7'b0;
			
			enable <= 1'b0;
			read <= 1'b0;
		end
	end

	//selects colour for appropriate screen
	colour_selector COL0 (
		.screen(next_screen),
		
		.colour_start(colour_start),
		
		.colour_level1_3lives(colour_level1_3lives),
		.colour_level1_2lives(colour_level1_2lives),
		.colour_level1_1life(colour_level1_1life),
		
		.colour_level2_3lives(colour_level2_3lives),
		.colour_level2_2lives(colour_level2_2lives),
		.colour_level2_1life(colour_level2_1life),
		
		.colour_level3_3lives(colour_level3_3lives),
		.colour_level3_2lives(colour_level3_2lives),
		.colour_level3_1life(colour_level3_1life),
		
		.colour_level4_3lives(colour_level4_3lives),
		.colour_level4_2lives(colour_level4_2lives),
		.colour_level4_1life(colour_level4_1life),
		
		.colour_lose(colour_lose),
		.colour_win(colour_win),
		.colour(colour_out)
		);

	//memory blocks with images
	start_memory MEM0 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_start)
		);
		
	level1_3lives_memory MEM1 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level1_3lives)
		);
		
	level1_2lives_memory MEM2 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level1_2lives)
		);
		
	level1_1life_memory MEM3 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level1_1life)
		);
		
	level2_3lives_memory MEM4 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level2_3lives)
		);
		
	level2_2lives_memory MEM5 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level2_2lives)
		);
		
	level2_1life_memory MEM6 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level2_1life)
		);
		
	level3_3lives_memory MEM7 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level3_3lives)
		);
		
	level3_2lives_memory MEM8 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level3_2lives)
		);
		
	level3_1life_memory MEM9 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level3_1life)
		);
		
	level4_3lives_memory MEM10 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level4_3lives)
		);
		
	level4_2lives_memory MEM11 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level4_2lives)
		);
		
	level4_1life_memory MEM12 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_level4_1life)
		);
		
	win_memory MEM13 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_win)
		);
		
	lose_memory MEM14 (
		.address(address_reg),
		.clock(clock),
		.rden(read),
		.q(colour_lose)
		);
		
endmodule

module colour_selector (
	input [3:0] screen,
	input [2:0] colour_start, colour_level1_3lives, colour_level1_2lives, colour_level1_1life, colour_level2_3lives, colour_level2_2lives, colour_level2_1life, colour_level3_3lives, colour_level3_2lives, colour_level3_1life, colour_level4_3lives, colour_level4_2lives, colour_level4_1life, colour_lose, colour_win,
	
	output reg [2:0] colour);
	
	always@ (*)
	begin
		case (screen)
			
			4'b0000: colour = colour_start;
			
			4'b0001: colour = colour_level1_3lives;
			
			4'b0010: colour = colour_level1_2lives;
			
			4'b0011: colour = colour_level1_1life;
			
			4'b0100: colour = colour_level2_3lives;
			
			4'b0101: colour = colour_level2_2lives;
			
			4'b0110: colour = colour_level2_1life;
			
			4'b0111: colour = colour_level3_3lives;
			
			4'b1000: colour = colour_level3_2lives;
			
			4'b1001: colour = colour_level3_1life;
			
			4'b1010: colour = colour_level4_3lives;
			
			4'b1011: colour = colour_level4_2lives;
			
			4'b1100: colour = colour_level4_1life;
			
			4'b1101: colour = colour_lose;
			
			4'b1110: colour = colour_win;
			
			default: colour = 3'b000;
			
		endcase
	end
endmodule
	
	
