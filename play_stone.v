module play_stone (
	input clock,
	input enable,
	input resetn,
	input win,
	output play_stone_go,
	output [5:0] play_stone_sound
	);
	
	assign play_stone_sound = win ? 6'b000_001 : 6'b111_111; // was 
		
	//always@(posedge clock) begin
	//	if (resetn) begin
	//		start_count <= 1'b0;
	//	end
	//	else if (start_count == 1'b1) begin
	//		start_count <= 1'b0;
	//	end
	//	else if (enable) begin
	//		start_count <= 1'b1;
	//	end
	//end
	
	go_counter gocounter (
		.start_count(enable), //was start
		.clock(clock),
		.resetn(resetn),
		.counter_out(),
		.reg_out(play_stone_go)
	);

endmodule

		
module go_counter (start_count, clock, resetn, counter_out, reg_out);
	input start_count, clock, resetn;
	output reg_out;
	output [25:0] counter_out;
	
	wire reg_to_counter;
	reg reset_register;
	
	assign reg_out = reg_to_counter;
		
	one_bit_reg onebitreg (
		.clock(clock),
		.enable(start_count),
		.data_in(1'b1),
		.resetn(resetn | reset_register),
		.Q(reg_to_counter)
	);
	
	twentysix_bit_counter two_six_bitcounter (
		.clock(clock),
		.enable(reg_to_counter),
		.resetn(resetn),
		.Q(counter_out)
	);
	
	always @(posedge clock) begin
		if (resetn)
			reset_register <= 0;
		else if (counter_out == 26'd50000000) //CHANGE TO 50000000
			reset_register <= 1;
		else
			reset_register <= 0;
	end
	
endmodule

module twentysix_bit_counter (
	clock,
	enable,
	resetn,
	Q
	);
	
	input clock, enable, resetn;
	output reg [25:0] Q;
	
	always @(posedge clock or posedge resetn) begin
		if (resetn)
			Q <= 15'd0;
		else if (enable)
			Q <= Q + 1;
	end
endmodule
			
			