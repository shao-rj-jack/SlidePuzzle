module timer(SW, HEX0, CLOCK_50);
	input [9:0] SW;
	input CLOCK_50;
	output [6:0] HEX0;
	
	wire Enable;
	wire [3:0] Count;
	
	RateDivider rd0(.clock(CLOCK_50), .pulse(Enable));
	
	Counter count0(.clock(CLOCK_50), .resetn(SW[9]), .enable(Enable), .Q(Count));
	defparam count0.bits = 4;
	defparam count0.max = 16;
	
	hex_decoder hex0(.X(Count), .M(HEX0));
	
endmodule

module RateDivider(input clock, output reg pulse);
	//if counter is at zero, set pulse to 1 for one tick
	reg Clear_b = 1'b0; //set clock to 0 at runtime
	reg [24:0] counter;
	
	always @(posedge clock) begin
		if(~Clear_b) begin
			counter <= 50000000 - 1; //50M - 1. repeats every 1 second
			Clear_b <= 1'b1;
			pulse <= 1'b0;
		end else if (counter == 0) begin
			counter <= 50000000 - 1; //50M - 1. repeats every 1 second
			pulse <= 1'b1;
		end else if (pulse) begin
			pulse <= 1'b0;
			counter <= counter - 1;
		end else
			counter <= counter - 1;
	end
endmodule

module hex_decoder(input [3:0] X, output [6:0] M);
	assign M[0] = ~((X[3] | X[2] | X[1] | ~X[0]) &
					  (X[3] | ~X[2] | X[1] | X[0]) &
					  (~X[3] | X[2] | ~X[1] | ~X[0]) &
					  (~X[3] | ~X[2] | X[1] | ~X[0]));
	
	assign M[1] = ~((X[3] | ~X[2] | X[1] | ~X[0]) &
					  (X[3] | ~X[2] | ~X[1] | X[0]) &
					  (~X[3] | X[2] | ~X[1] | ~X[0]) &
					  (~X[3] | ~X[2] | X[1] | X[0]) &
					  (~X[3] | ~X[2] | ~X[1] | X[0]) &
					  (~X[3] | ~X[2] | ~X[1] | ~X[0]));
	
	assign M[2] = ~((X[3] | X[2] | ~X[1] | X[0]) &
					  (~X[3] | ~X[2] | X[1] | X[0]) &
					  (~X[3] | ~X[2] | ~X[1] | X[0]) &
					  (~X[3] | ~X[2] | ~X[1] | ~X[0]));
	
	assign M[3] = ~((X[3] | X[2] | X[1] | ~X[0]) &
					  (X[3] | ~X[2] | X[1] | X[0]) &
					  (X[3] | ~X[2] | ~X[1] | ~X[0]) &
					  (~X[3] | X[2] | X[1] | ~X[0]) &
					  (~X[3] | X[2] | ~X[1] | X[0]) &
					  (~X[3] | ~X[2] | ~X[1] | ~X[0]));
	
	assign M[4] = ~((X[3] | X[2] | X[1] | ~X[0]) &
					  (X[3] | X[2] | ~X[1] | ~X[0]) &
					  (X[3] | ~X[2] | X[1] | X[0]) &
					  (X[3] | ~X[2] | X[1] | ~X[0]) &
					  (X[3] | ~X[2] | ~X[1] | ~X[0]) &
					  (~X[3] | X[2] | X[1] | ~X[0]));
	
	assign M[5] = ~((X[3] | X[2] | X[1] | ~X[0]) &
					  (X[3] | X[2] | ~X[1] | X[0]) &
					  (X[3] | X[2] | ~X[1] | ~X[0]) &
					  (X[3] | ~X[2] | ~X[1] | ~X[0]) &
					  (~X[3] | ~X[2] | X[1] | ~X[0]));
	
	assign M[6] = ~((X[3] | X[2] | X[1] | X[0]) &
					  (X[3] | X[2] | X[1] | ~X[0]) &
					  (X[3] | ~X[2] | ~X[1] | ~X[0]) &
					  (~X[3] | ~X[2] | X[1] | X[0]));
endmodule 