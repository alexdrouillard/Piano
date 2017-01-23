module level_mux (
	input clock,
	input resetn,
	input enable,
	output reg [11:0] level_out1,
	output reg [11:0] level_out2,
	output reg [11:0] level_out3,
	output reg [11:0] level_out4,
	output reg [11:0] level_out5,
	output reg [11:0] level_out6,
	output reg [4:0] current_level
);

//LEVEL CODES

	parameter			LEVEL_ONE1 = 12'b1100_0000_0000,
						LEVEL_ONE2 = 12'b0011_0000_0000,
						LEVEL_ONE3 = 12'b0000_1100_0000,
						LEVEL_ONE4 = 12'b0000_0011_0000,
						LEVEL_ONE5 = 12'b0000_0000_1100,
						LEVEL_ONE6 = 12'b0000_0000_0011,
					
						LEVEL_TWO1 = 12'b1111_0000_0000,
						LEVEL_TWO2 = 12'b0000_1111_0000,
						LEVEL_TWO3 = 12'b0000_0000_1111,
						LEVEL_TWO4 = 12'b1111_0000_0000,
						LEVEL_TWO5 = 12'b0000_1111_0000,
						LEVEL_TWO6 = 12'b0000_0000_1111,					
					
					
						LEVEL_THREE1 = 12'b1100_0000_0000,
						LEVEL_THREE2 = 12'b0000_0011_0000,
						LEVEL_THREE3 = 12'b0011_0000_0000,
						LEVEL_THREE4 = 12'b0000_0000_1100,
						LEVEL_THREE5 = 12'b0000_1100_0000,
						LEVEL_THREE6 = 12'b0000_0000_0011,
					
						LEVEL_FOUR1 = 12'b1100_1100_0000,
						LEVEL_FOUR2 = 12'b0000_0000_0000,
						LEVEL_FOUR3 = 12'b0000_0010_0000,
						LEVEL_FOUR4 = 12'b0000_0001_0000,
						LEVEL_FOUR5 = 12'b0000_0000_1000,
						LEVEL_FOUR6 = 12'b0000_0000_0111;
						
						//LEVEL_FIVE1  = 12'b1100_1000_0000,
						//LEVEL_FIVE2  = 12'b0000_0010_0000,
						//LEVEL_FIVE3  = 12'b0110_0000_1010,
						//LEVEL_FIVE4	= 12'b0000_0000_0000,
						//LEVEL_FIVE5  = 12'b0000_0000_0000,
						//LEVEL_FIVE6 = 12'b0000_0000_0000;
					
	
	always@(posedge clock) begin
		case (current_level)
			5'd0: begin
				level_out1 <= LEVEL_ONE1;
				level_out2 <= LEVEL_ONE2;
				level_out3 <= LEVEL_ONE3;
				level_out4 <= LEVEL_ONE4;
				level_out5 <= LEVEL_ONE5;
				level_out6 <= LEVEL_ONE6;
			end
			
			5'd1: begin
				level_out1 <= LEVEL_TWO1;
				level_out2 <= LEVEL_TWO2;
				level_out3 <= LEVEL_TWO3;
				level_out4 <= LEVEL_TWO4;
				level_out5 <= LEVEL_TWO5;
				level_out6 <= LEVEL_TWO6;
			end
			
			5'd2: begin
				level_out1 <= LEVEL_THREE1;
				level_out2 <= LEVEL_THREE2;
				level_out3 <= LEVEL_THREE3;
				level_out4 <= LEVEL_THREE4;
				level_out5 <= LEVEL_THREE5;
				level_out6 <= LEVEL_THREE6;
			end
			
			5'd3: begin
				level_out1 <= LEVEL_FOUR1;
				level_out2 <= LEVEL_FOUR2;
				level_out3 <= LEVEL_FOUR3;
				level_out4 <= LEVEL_FOUR4;
				level_out5 <= LEVEL_FOUR5;
				level_out6 <= LEVEL_FOUR6;
			end
			
			//5'd4: begin
			//	level_out1 <= LEVEL_FIVE1;
			//	level_out2 <= LEVEL_FIVE2;
			//	level_out3 <= LEVEL_FIVE3;
			//	level_out4 <= LEVEL_FIVE4;
			//	level_out5 <= LEVEL_FIVE5;
			//	level_out6 <= LEVEL_FIVE6;
			//end
			
		default: begin
				level_out1 <= LEVEL_ONE1;
				level_out2 <= LEVEL_ONE2;
				level_out3 <= LEVEL_ONE3;
				level_out4 <= LEVEL_ONE4;
				level_out5 <= LEVEL_ONE5;
				level_out6 <= LEVEL_ONE6;
			end
		endcase
	end
		
	
	
	// counter
	always@(posedge clock) begin
		if (resetn)
			current_level = 5'b0;
			
		else 
		if (enable)
			if (current_level == 3'd4)
				current_level <= 1'b0;
			else
				current_level <= current_level + 1'b1;
	end
	
endmodule