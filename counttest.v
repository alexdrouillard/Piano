module counttest (
	input [11:0] test,
	output [5:0] sum
);

	parameter WIDTH = 12;
	// NOTE: $clog2 was added in 1364-2005, not supported in 1364-1995 or 1364-2001
	reg [5:0] count_ones; 
	assign sum = count_ones;
	integer idx;

	always @* begin
		count_ones = {WIDTH{1'b0}};  
		for( idx = 0; idx<WIDTH; idx = idx + 1) begin
			count_ones = count_ones + test[idx];
		end
	end
endmodule