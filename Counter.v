// Useful counter

module Counter(clock, resetn, enable, Q);
	parameter bits = 8, max = 256;
	input clock, resetn, enable;
	output reg [bits-1:0] Q;
	
	reg clear = 1'b0;
	
	always @(posedge clock) begin
		if(~clear) begin
			Q <= 0;
			clear <= 1'b1;
		end
		else if(~resetn)
			Q <= 0;
		else if (Q == max - 1 && enable)
			Q <= 0;
		else if (enable)
			Q <= Q + 1;
	end
endmodule 