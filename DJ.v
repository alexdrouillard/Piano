module DJ (
	input clock,
	input resetn,
	input [5:0] user_input,
	input [5:0] other_sound,
	output [31:0] sound_out
);

//TESTING

	parameter 			//DELAY1 = 20'd1, //C4 261.63Hz	
								//DELAY2 = 20'd2, //D4 293.66Hz
								//DELAY3 = 20'd3, //E4 329.63Hz
								//DELAY4 = 20'd4, //F4 349.23Hz
								//DELAY5 = 20'd5, //G4 392.00Hz
								//DELAY6 = 20'd6; //A4 440Hz
								
								DELAY1 = 20'd95554, //C4 261.63Hz	DONT FORGET DIVIDE BY 2
								DELAY2 = 20'd85132, //D4 293.66Hz
								DELAY3 = 20'd75843, //E4 329.63Hz
								DELAY4 = 20'd71586, //F4 349.23Hz
								DELAY5 = 20'd63776, //G4 392.00Hz
								DELAY6 = 20'd56818; //A4 440Hz

	
	
	
	wire [31:0] amplitude_out1, amplitude_out2,  amplitude_out3,  amplitude_out4,  amplitude_out5, amplitude_out6;
	assign sound_out = amplitude_out1 + amplitude_out2 + amplitude_out3 + amplitude_out4 + amplitude_out5 + amplitude_out6;

    oscillator oc1 ( 
		.clock(clock),
		.resetn(resetn),
		.user_input(user_input[0]),
		.other_sound(other_sound[0]),
		.delay(DELAY1),
		.amplitude_out(amplitude_out1)
	);
	
    oscillator oc2 ( 
		.clock(clock),
		.resetn(resetn),
		.user_input(user_input[1]),
		.other_sound(other_sound[1]),
		.delay(DELAY2),
		.amplitude_out(amplitude_out2)
	);
	
	oscillator oc3 ( 
		.clock(clock),
		.resetn(resetn),
		.user_input(user_input[2]),
		.other_sound(other_sound[2]),
		.delay(DELAY3),
		.amplitude_out(amplitude_out3)
	);
	
	oscillator oc4 ( 
		.clock(clock),
		.resetn(resetn),
		.user_input(user_input[3]),
		.other_sound(other_sound[3]),
		.delay(DELAY4),
		.amplitude_out(amplitude_out4)
	);
	
	oscillator oc5 ( 
		.clock(clock),
		.resetn(resetn),
		.user_input(user_input[4]),
		.other_sound(other_sound[4]),
		.delay(DELAY5),
		.amplitude_out(amplitude_out5)
	);
	
	oscillator oc6 ( 
		.clock(clock),
		.resetn(resetn),
		.user_input(user_input[5]),
		.other_sound(other_sound[5]),
		.delay(DELAY6),
		.amplitude_out(amplitude_out6)
	);
	
endmodule

module oscillator ( //gonna need 3-1 mux to make custom sound work
	input clock,
	input resetn,
	input user_input,
	input other_sound,
	input [19:0] delay,
	output [31:0] amplitude_out
);
	
	
	wire flip;
	wire [31:0] amplitude;
	assign amplitude = flip ? 32'd100000000 : -32'd100000000; //volume level
	
	two_to_one_mux_large mybigmux (
		.x(amplitude),
		.y(32'b0),
		.select(user_input),
		.out(amplitude_out)
	);
	
	delay_counter count (
		.clock(clock),
		.resetn(resetn),
		.delay(delay),
		.flip(flip)
	);


endmodule

module delay_counter (
	input clock,
	input resetn,
	input [19:0] delay,
	output reg flip
);
	reg [19:0] count;
	always@(posedge clock) begin
		if (resetn) begin
			flip <= 1'd0;
			count <= 20'd0;
		end
		else if (count == delay) begin //DELAY IS == TO 50MHz / DESIRED FREQUENCY
			flip <= !flip;
			count <= 20'd0;
		end
		else
			count <= count + 1;
	end
endmodule

module two_to_one_mux_large (
	input [31:0] x,
	input [31:0] y,
	input select,
	output [31:0] out
);

	assign out = select ? x : y;
	
endmodule
		
		
			

