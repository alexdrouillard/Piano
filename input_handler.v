

module input_handler (
	input [11:0] level_code, //make level_code bigger
	input clock,
	input user_input,
	input resetn,
	input enable,
	input play,
	output [4:0] score,
	output valid,
	output done_out
);

	wire [11:0] Qout; // Change here
	wire level_active;
	wire rotate;
	wire done;
	wire read_only;
	wire [5:0] read_only_signal = {6{read_only}};
	assign done_out = done;
	assign valid = Qout[11]; // change here
	
	
	basic_counter r_we_there_yet (
		.clock(clock),
		.enable(rotate),
		.resetn(resetn),
		.done(done)
	);

	rotating_register myreg (
		.clock(clock),
		.data_in(level_code),
		.load(enable | play),
		.resetn(resetn),
		.rotate(rotate),
		.Q(Qout)
	);
	
	one_bit_reg read_only_reg (
		.clock(clock),
		.enable(play),
		.data_in(1'b1),
		.resetn(resetn),
		.Q(read_only)
	);
	
	one_bit_reg enabled (
		.clock(clock),
		.enable(enable | play),
		.data_in(1'b1),
		.resetn(resetn),
		.Q(level_active)
	);
	
	one_second_counter mycounter (
		.clock(clock),
		.resetn(resetn),
		.enable(level_active | play),
		.Q(rotate)
	);
	
	input_valid validator (
		.clock(clock),
		.valid(Qout[11]),
		.resetn(resetn),
		.user_input(user_input & ~read_only_signal),
		.next(rotate),
		.score(score)
	);

	//Need a go counter to start rotating the expected input out
	

endmodule

module input_valid (
	input clock,
	input valid,
	input resetn,
	input user_input,
	input next,
	output reg [4:0] score
);

	reg added;
	wire recent_input;

	one_bit_reg current_input (
		.clock(clock),
		.enable(user_input),
		.data_in(1'b1),
		.resetn(resetn | next),
		.Q(recent_input)
	);

	always@(posedge clock) begin
		if (next)
			added <= 1'b0;
		else if (resetn) begin
			score <= 5'd0;
			added <= 1'b0;
		end
		else if (!added) begin
			if (recent_input && valid) begin
				score <= score + 1'b1;
				added = 1'b1;
			end
			else if (recent_input && !valid && score > 5'd0) begin
				score <= score - 1'b1;
				added = 1'b1;
			end
		end			
	end
endmodule
	

module rotating_register (
	input clock,
	input [11:0] data_in, // This needs to be changed
	input load,
	input resetn,
	input rotate,
	output reg [11:0] Q, // This needs to be changed
	output reg done
);

	always@(posedge clock) begin
		if (resetn)
			Q <= 6'd0;
		else if (load)
			Q <= data_in;
		else if (rotate) begin
			Q <= Q << 1;
		end
	end
	
endmodule


//######################################
//#							COUNTER 										  #
//######################################


module one_second_counter (clock, resetn, enable, Q);
	input clock, resetn, enable;
	output reg Q;
	
	localparam CLOCK_SPEED = 26'd25000000; //Use 50000000 for 1 second each, at 10 for testing purposes CHANGE ME FOR NEW STUFF
	
	reg [25:0] sum;
	
	always@(posedge clock) begin
		if (resetn) begin
			sum <= 26'd0;
			Q <= 1'b0;
		end
		else if (sum == CLOCK_SPEED) begin
			sum <= 26'd0;
			Q <= 1'b1;
		end
		else begin
			Q <= 1'b0;
			sum <= sum + 1'b1;
		end
	end
endmodule

module one_bit_reg (clock, enable, data_in, resetn, Q);
	input clock, enable, resetn;
	input data_in;
	output reg Q;
	
	always @(posedge clock or posedge resetn) begin
		if (resetn)
			Q <= 1'b0;
		else if (enable)
			Q <= data_in;
	end

endmodule

module basic_counter (clock, enable, resetn, done);
	input clock, enable, resetn;
	output reg done;
	reg [5:0] sum;
	
	always @(posedge clock) begin
		if (resetn) begin
			sum <= 6'b0;
			done <= 1'b0;
		end
		else if (sum == 6'd12) begin
				done <= 1'b1;
				sum <= 6'b0;
		end
		else if (enable) begin
			done <= 1'b0;
			sum <= sum + 1;
		end
	end
	
endmodule
