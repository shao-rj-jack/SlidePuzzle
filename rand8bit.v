//This is  a psuedo random bit sequence generator

module rand8bit (
	input clock,
			start,
			stop,
	output [7:0] randNum
	);
	
	reg countReset = 1'b0;
	reg ld_seed = 1'b0;
	reg enable = 1'b0;
	
	always@(posedge clock) begin
		if(~countReset)
			countReset <= 1'b1;
		if(ld_seed)
			ld_seed <= 1'b0;
		else if(start) begin
			ld_seed <= ~ld_seed;
			enable <= 1'b1;
		end
		else if(stop)
			enable <= 1'b0;
	end
	
	wire [7:0] seed;
	
	Counter C0(.clock(clock),
				  .resetn(countReset),
				  .enable(1'b1),
				  .Q(seed));
	defparam C0.bits = 8;
	defparam C0.max = 255; //Counter should never have the value 8'b1111_1111
	
	LFSR_8 LFSR0(.clock(clock),
					 .enable(enable),
					 .ld_seed(ld_seed),
					 .seedData(seed),
					 .outData(randNum));
	
endmodule

module LFSR_8 (
	input clock,
   input enable,
	
	input ld_seed,
   input [7:0] seedData,
 
   output [7:0] outData
   );
 
   reg [8:1] r_LFSR = 0;
   reg              r_XNOR;
	
	
   //Run LFSR when enabled.
   always @(posedge clock) begin
      if (enable == 1'b1)
         begin
            if (ld_seed == 1'b1)
               r_LFSR <= seedData;
            else
               r_LFSR <= {r_LFSR[7:1], r_XNOR};
         end
   end
	
   // Create Feedback Polynomials.  Based on Application Note:
   // http://www.xilinx.com/support/documentation/application_notes/xapp052.pdf
   always @(*) begin
      r_XNOR = r_LFSR[8] ^~ r_LFSR[6] ^~ r_LFSR[5] ^~ r_LFSR[4];
   end
   
   assign outData = r_LFSR[8:1];
   
endmodule 