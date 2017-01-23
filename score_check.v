module score_check ( 
	input [4:0] input_score,
	
	input [11:0] level_code1,
	input [11:0] level_code2,
	input [11:0] level_code3,
	input [11:0] level_code4,
	input [11:0] level_code5,
	input [11:0] level_code6,
	
	input enable,
	input clock,
	input resetn,
	output reg win,
	output reg [1:0] lives
	);
	
	parameter WIDTH = 12,
					  TOLERANCE = 2'd2;
	reg [11:0] count_ones; 
	integer i;

	always @(posedge clock) begin
		count_ones = {WIDTH{1'b0}};  
		for( i = 0; i<WIDTH; i = i + 1) begin
			count_ones = count_ones + level_code1[i] + level_code2[i] + level_code3[i] + level_code4[i] + level_code5[i] + level_code6[i];
		end
	end
	
	always@(posedge clock) begin
		if (resetn) begin
			lives <=2'd3; //count down later
			win <= 1'b0;
		end
		else if (enable && input_score >= count_ones - TOLERANCE)
			win <= 1'b1;
		else if (enable) begin
			win <= 1'b0;
			lives <= lives - 1'b1;
		end
	end
	
endmodule