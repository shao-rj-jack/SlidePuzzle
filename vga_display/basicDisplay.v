`timescale 1ns/1ns

module basicDisplay
	(
		clk,						//	On Board 50 MHz
		// custom inputs and outputs
		resetn,
		address,
		ID,
		plot,
		load_sprite,
		sprite_sel,
		done,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   				//	VGA Clock
		VGA_HS,					//	VGA H_SYNC
		VGA_VS,					//	VGA V_SYNC
		VGA_BLANK_N,			//	VGA BLANK
		VGA_SYNC_N,				//	VGA SYNC
		VGA_R,   				//	VGA Red[9:0]
		VGA_G,	 				//	VGA Green[9:0]
		VGA_B   					//	VGA Blue[9:0]
	);

	input	clk;				//	50 MHz
	input resetn;
	input [3:0] address, ID;
	input plot, load_sprite;
	input [2:0] sprite_sel;
	output done;
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	reg [5:0] colour; //6 bits of colour, 2 per channel

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(clk),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 2;
		defparam VGA.BACKGROUND_IMAGE = "./vga_display/start_screen.mif";
	
	wire [5:0] sprite0_out;
	wire [5:0] sprite1_out;
	wire [5:0] sprite2_out;
	wire [5:0] sprite3_out;
	
	always@(*) begin
		case(sprite_sel)
			3'b000: colour = sprite0_out;
			3'b001: colour = sprite1_out;
			3'b010: colour = sprite2_out;
			3'b011: colour = sprite3_out;
			3'b100: colour = sprite1_out;
			3'b101: colour = sprite1_out;
			3'b110: colour = sprite1_out;
			3'b111: colour = sprite1_out;
			default: colour = sprite0_out;
		endcase
	end
	
	wire newImage;
	
	wire [4:0] deltaX, deltaY;
	wire [7:0] wipeX;
	wire [6:0] wipeY;
	
	wire [14:0] pxAddress;
	
	display_datapath d0(.address(address),
							  .ID(ID),
							  .deltaX(deltaX),
							  .deltaY(deltaY),
							  .wipeX(wipeX),
							  .wipeY(wipeY),
							  .x(x),
							  .y(y),
							  .pxAddress(pxAddress),
							  .newImage(newImage));
	
	display_control c0(.clk(clk),
							 .resetn(resetn),
							 .plot(plot),
							 .deltaX(deltaX),
							 .deltaY(deltaY),
							 .wipeX(wipeX),
							 .wipeY(wipeY),
							 .writeEn(writeEn),
							 .load_sprite(load_sprite),
							 .newImage(newImage),
							 .done(done));
	
	//Define sprites here
	sprite0rom s0(.address(pxAddress),
					  .clock(clk),
					  .q(sprite0_out));
	
	sprite1rom s1(.address(pxAddress),
					  .clock(clk),
					  .q(sprite1_out));
	
	sprite2rom s2(.address(pxAddress),
					  .clock(clk),
					  .q(sprite2_out));
	
	sprite3rom s3(.address(pxAddress),
					  .clock(clk),
					  .q(sprite3_out));
	
endmodule

module display_datapath(address, ID, deltaX, deltaY, wipeX, wipeY, x, y, pxAddress, newImage);
	input [3:0] address, ID;
	input newImage;
	
	input [4:0] deltaX, deltaY;
	input [7:0] wipeX;
	input [6:0] wipeY;

	output reg [7:0] x;
	output reg [6:0] y;
	
	output reg [14:0] pxAddress;
	
	reg [6:0] Qx, Qy;
	reg [6:0] Qsx, Qsy;
	
	//Mux for Qx, Qy
	always@(*) begin
		case(address)
			4'd0:  begin Qx =  28; Qy = 20; end
			4'd1:  begin Qx =  54; Qy = 20; end
			4'd2:  begin Qx =  80; Qy = 20; end
			4'd3:  begin Qx = 106; Qy = 20; end
			4'd4:  begin Qx =  28; Qy = 40; end
			4'd5:  begin Qx =  54; Qy = 40; end
			4'd6:  begin Qx =  80; Qy = 40; end
			4'd7:  begin Qx = 106; Qy = 40; end
			4'd8:  begin Qx =  28; Qy = 60; end
			4'd9:  begin Qx =  54; Qy = 60; end
			4'd10: begin Qx =  80; Qy = 60; end
			4'd11: begin Qx = 106; Qy = 60; end
			4'd12: begin Qx =  28; Qy = 80; end
			4'd13: begin Qx =  54; Qy = 80; end
			4'd14: begin Qx =  80; Qy = 80; end
			4'd15: begin Qx = 106; Qy = 80; end
		endcase
	end
	
	//Mux for Qsx, Qsy
	always@(*) begin
		case(ID)
			4'd0:  begin Qsx =  28; Qsy = 20; end
			4'd1:  begin Qsx =  54; Qsy = 20; end
			4'd2:  begin Qsx =  80; Qsy = 20; end
			4'd3:  begin Qsx = 106; Qsy = 20; end
			4'd4:  begin Qsx =  28; Qsy = 40; end
			4'd5:  begin Qsx =  54; Qsy = 40; end
			4'd6:  begin Qsx =  80; Qsy = 40; end
			4'd7:  begin Qsx = 106; Qsy = 40; end
			4'd8:  begin Qsx =  28; Qsy = 60; end
			4'd9:  begin Qsx =  54; Qsy = 60; end
			4'd10: begin Qsx =  80; Qsy = 60; end
			4'd11: begin Qsx = 106; Qsy = 60; end
			4'd12: begin Qsx =  28; Qsy = 80; end
			4'd13: begin Qsx =  54; Qsy = 80; end
			4'd14: begin Qsx =  80; Qsy = 80; end
			4'd15: begin Qsx = 106; Qsy = 80; end
		endcase
	end
	
	//mux for wipe/draw
	always@(*) begin
		if(~newImage) begin
			x = 8'd0 + Qx + deltaX;
			y = 7'd0 + Qy + deltaY;
			
			if(deltaX == 25)
				pxAddress = (160 * (Qsy + deltaY)) + Qsx;
			else
				pxAddress = (160 * (Qsy + deltaY)) + Qsx + deltaX + 1;
		end else begin
			x = wipeX;
			y = wipeY;
			
			if(wipeX == 159)
				pxAddress = (160 * wipeY);
			else
				pxAddress = (160 * wipeY) + wipeX + 1;
		end
	end
endmodule

module display_control(clk, resetn, plot, deltaX, deltaY, wipeX, wipeY, writeEn, load_sprite, newImage, done);
	input clk, resetn, plot, load_sprite;
	output reg writeEn, newImage, done;
	
	reg dxE, dyE, wxE, wyE;
	reg [3:0] current_state, next_state;
	
	localparam BEGIN			= 4'b0000,
				  SQUPAUSE		= 4'b0001,
				  SQUCOUNTX 	= 4'b0010,
				  SQUCOUNTY 	= 4'b0011,
				  BEGINWIPE		= 4'b0100,
				  WBEGINPAUSE	= 4'b0101,
				  WIPECOUNTX 	= 4'b0110,
				  WIPECOUNTY 	= 4'b0111,
				  DONE 			= 4'b1000;
	
	output [4:0] deltaX, deltaY;
	
	Counter dx26(clk, resetn, dxE, deltaX);
	defparam dx26.bits = 5;
	defparam dx26.max = 26;
	Counter dy20(clk, resetn, dyE, deltaY);
	defparam dy20.bits = 5;
	defparam dy20.max = 20;
	
	output [7:0] wipeX;
	output [6:0] wipeY;
	
	Counter wx160(clk, resetn, wxE, wipeX);
	defparam wx160.bits = 8;
	defparam wx160.max = 160;
	Counter wy120 (clk, resetn, wyE, wipeY);
	defparam wy120.bits = 7;
	defparam wy120.max = 120;
	
	//Next state logic
	always@(*) begin
		case(current_state)
			BEGIN: 	if(~load_sprite)
								next_state[3:0] = plot ? SQUPAUSE : BEGIN;
						else
								next_state[3:0] = WBEGINPAUSE;
			SQUPAUSE:		next_state[3:0] = SQUCOUNTX;
			SQUCOUNTX: 		next_state[3:0] = (deltaX==5'd24) ? SQUCOUNTY : SQUCOUNTX;
			SQUCOUNTY: 		next_state[3:0] = (deltaY==5'd19) ? DONE : SQUCOUNTX;
			WBEGINPAUSE:	next_state[3:0] = BEGINWIPE;
			BEGINWIPE:		next_state[3:0] = WIPECOUNTX;
			WIPECOUNTX: 	next_state[3:0] = (wipeX==8'd158) ? WIPECOUNTY : WIPECOUNTX;
			WIPECOUNTY: 	next_state[3:0] = (wipeY==7'd119) ? DONE : WIPECOUNTX;
			DONE: 			next_state[3:0] = BEGIN;
			default: 		next_state[3:0] = BEGIN;
		endcase
	end
	
	//output logic / datapath controls
	always@(*) begin
		dxE = 1'b0;
		dyE = 1'b0;
		wxE = 1'b0;
		wyE = 1'b0;
		writeEn = 1'b0;
		newImage = 1'b0;
		done = 1'b0;
		
		case(current_state)
			SQUCOUNTX: begin
				writeEn = 1'b1;
				dxE = 1'b1;
			end
			SQUCOUNTY: begin
				writeEn = 1'b1;
				dxE = 1'b1;
				dyE = 1'b1;
			end
			WBEGINPAUSE: begin
				newImage = 1'b1;
			end
			BEGINWIPE: begin
				newImage = 1'b1;
			end
			WIPECOUNTX: begin
				writeEn = 1'b1;
				newImage = 1'b1;
				wxE = 1'b1;
			end
			WIPECOUNTY: begin
				writeEn = 1'b1;
				newImage = 1'b1;
				wxE = 1'b1;
				wyE = 1'b1;
			end
			DONE: begin
				done = 1'b1;
			end
		endcase
	end
	
	//update current state
	always@(posedge clk) begin
		if(~resetn)
			current_state <= BEGIN;
		else
			current_state <= next_state;
	end
endmodule 