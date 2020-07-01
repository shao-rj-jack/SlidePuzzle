module gameLogic_control(
	input clock,
			resetN,
			move,
			//wipe, not gonna use this yet
			done,
			startGame,
	input [3:0] selected_ID,
	
	output reg startRand,
				  stopRand,
				  ld_begin_rand,
				  ld_next_rand,
				  ld_new_empty,
				  ld_b_addr,
				  ld_other_addr,
				  ld_other_ID,
				  mv_other,
				  mv_b,
				  writeEN,
				  plot,
				  ld_sprite,
	
	output [2:0] sprite_sel,
	output [3:0] out_address,
	
	output [7:0] moveCount
	);
	
	reg [4:0] current_state = 5'b00000;
	reg [4:0] next_state = 5'b00000;
	
	localparam RAND_INIT		= 5'b00000,
				  SET_EMPTY		= 5'b00001,
				  RAND_NEXT		= 5'b00010,
				  RAND_SAVE_ID = 5'b00011,
				  RAND_SWAP		= 5'b00100,
				  RAND_CONT		= 5'b00101,
				  RAND_END		= 5'b00110,
				  NEXT_ADDRESS	= 5'b00111,
				  PRINT_BOARD	= 5'b01000,
				  PRINT_WAIT	= 5'b01001,
				  LOOK_BLANK	= 5'b01010,
				  LOOK_NEXT		= 5'b01011,
				  LOOK_PAUSE	= 5'b01100,
				  FOUND_BLANK	= 5'b01101,
				  SAVE_OTHER	= 5'b01110,
				  SAVE_ID		= 5'b01111,
				  MOVE_OTHER	= 5'b10000,
				  MOVE_BLANK	= 5'b10001,
				  RESET			= 5'b10010,
				  MOVE_PAUSE	= 5'b10011,
				  START_PRINT	= 5'b10100,
				  CHECK_W_SET	= 5'b10101,
				  CHECK_W		= 5'b10110,
				  CHECK_W_WAIT = 5'b10111,
				  WIN_CONFIRM	= 5'b11000,
				  CHECK_LOSE	= 5'b11001,
				  LOSE_CONFIRM = 5'b11010,
				  SPRITE_PRINT	= 5'b11011,
				  SPRITE_P_W	= 5'b11100,
				  SPRITE_P_W2	= 5'b11101;
	
	reg bpEn, resetCount;
	
	Counter addrloop0(.clock(clock), .resetn(resetCount), .enable(bpEn), .Q(out_address));
	defparam addrloop0.bits = 4;
	defparam addrloop0.max = 16;
	
	reg randCountEn;
	wire [5:0] iterNum;
	Counter randIter(.clock(clock), .resetn(resetN), .enable(randCountEn), .Q(iterNum));
	defparam randIter.bits = 6;
	defparam randIter.max = 64;
	
	reg countEn;
	Counter moveCount0(.clock(clock), .resetn(resetN), .enable(countEn), .Q(moveCount));
	defparam moveCount0.bits = 8;
	defparam moveCount0.max = 101;
	
	reg [2:0] spriteSel;
	assign sprite_sel = spriteSel;
	
	always@(*)
		begin
			case (current_state)
				RAND_INIT:		next_state[4:0] = startGame ? SET_EMPTY : RAND_INIT; //wait until game starts to randomize
				SET_EMPTY:		next_state[4:0] = RAND_NEXT;
				RAND_NEXT:		next_state[4:0] = RAND_SAVE_ID;
				RAND_SAVE_ID:	next_state[4:0] = RAND_SWAP;
				RAND_SWAP:		next_state[4:0] = RAND_CONT;
				RAND_CONT:		next_state[4:0] = (iterNum == 6'b111111) ? RAND_END : RAND_NEXT; //Switch 63 tiles before starting
				RAND_END:		next_state[4:0] = START_PRINT;
				
				START_PRINT:	next_state[4:0] = startGame ? START_PRINT : SPRITE_P_W2;
				
				SPRITE_P_W2:	next_state[4:0] = SPRITE_PRINT;
				SPRITE_PRINT:	next_state[4:0] = SPRITE_P_W;
				SPRITE_P_W: 	next_state[4:0] = done ? RESET : SPRITE_P_W;
				
				PRINT_BOARD:	next_state[4:0] = PRINT_WAIT; 
				PRINT_WAIT:		//Wait until the basic display says that it is done printing
				begin
					if(done)		next_state[4:0] = (out_address == 4'b1111) ? CHECK_W_SET : NEXT_ADDRESS; //once the last address (15) has been printed, continue
				end
				NEXT_ADDRESS:	next_state[4:0] = PRINT_BOARD;
				LOOK_BLANK:		next_state[4:0] = (selected_ID == 4'b1111) ? FOUND_BLANK : LOOK_NEXT; //loop through the tiles until 15 is found
				LOOK_NEXT:		next_state[4:0] = LOOK_PAUSE;
				LOOK_PAUSE:		next_state[4:0] = LOOK_BLANK;
				FOUND_BLANK:	next_state[4:0] = move ? MOVE_PAUSE : FOUND_BLANK;
				MOVE_PAUSE:		next_state[4:0] = move ? MOVE_PAUSE : SAVE_OTHER;
				SAVE_OTHER:		next_state[4:0] = SAVE_ID;
				SAVE_ID:			next_state[4:0] = MOVE_OTHER;
				MOVE_OTHER:		next_state[4:0] = MOVE_BLANK;
				MOVE_BLANK:		next_state[4:0] = RESET;
				RESET:			next_state[4:0] = PRINT_BOARD;
				
				CHECK_W_SET:	next_state[4:0] = CHECK_W_WAIT;
				
				CHECK_W: 		begin
										if(out_address != 4'b1111)
											begin
												if(selected_ID == out_address) next_state[4:0] = CHECK_W_WAIT;
												else next_state[4:0] = CHECK_LOSE;
											end
										else
											begin
												if(selected_ID == out_address) next_state[4:0] = WIN_CONFIRM; // checks the last square
												else next_state[4:0] = CHECK_LOSE;
											end
									end
									
				CHECK_W_WAIT:	next_state[4:0] = CHECK_W;
							  
				WIN_CONFIRM:	next_state[4:0] = WIN_CONFIRM;
				
				CHECK_LOSE:		next_state[4:0] = (moveCount == 100) ? LOSE_CONFIRM : LOOK_BLANK;
				
				LOSE_CONFIRM:	next_state[4:0] = LOSE_CONFIRM;
				
				default: 		next_state[4:0] = RESET;
			endcase
		end
	
	always@(*)
		begin
			startRand 		= 1'b0;
			stopRand			= 1'b0;
			randCountEn 	= 1'b0;
			ld_begin_rand	= 1'b0;
			ld_next_rand 	= 1'b0;
			ld_new_empty	= 1'b0;
			
			ld_sprite		= 1'b0;
			
			ld_b_addr 		= 1'b0;
			ld_other_addr	= 1'b0;
			ld_other_ID 	= 1'b0;
			mv_other 		= 1'b0;
			mv_b 				= 1'b0;
			
			writeEN 			= 1'b0;
			plot 				= 1'b0;
			bpEn 				= 1'b0;
			resetCount 		= 1'b1;
			
			countEn			= 1'b0;
			
			case (current_state)
				RAND_INIT: begin
					spriteSel = 3'b000;
					startRand = 1'b1;
				end
				SET_EMPTY: begin
					ld_begin_rand = 1'b1;
				end
				RAND_NEXT: begin
					ld_next_rand = 1'b1;
					randCountEn = 1'b1;
				end
				RAND_SAVE_ID: begin
					ld_other_ID = 1'b1;
				end
				RAND_SWAP: begin
					mv_other = 1'b1;
					writeEN = 1'b1;
				end
				RAND_CONT: begin
					ld_new_empty = 1'b1;
				end
				RAND_END: begin
					mv_b = 1'b1;
					writeEN = 1'b1;
					stopRand = 1'b1;
				end
				SPRITE_PRINT: begin
					ld_sprite = 1'b1;
					spriteSel = 3'b001;
				end
				PRINT_BOARD: begin
					plot = 1'b1;
				end
				NEXT_ADDRESS: begin
					bpEn = 1'b1;
				end
				LOOK_NEXT: begin
					bpEn = 1'b1;
				end
				FOUND_BLANK: begin
					ld_b_addr = 1'b1;
				end
				SAVE_OTHER: begin
					ld_other_addr = 1'b1;
				end
				SAVE_ID: begin
					ld_other_ID = 1'b1;
				end
				MOVE_OTHER: begin
					mv_other = 1'b1;
					writeEN = 1'b1;
				end
				MOVE_BLANK: begin
					mv_b = 1'b1;
					writeEN = 1'b1;
				end
				RESET: begin
					resetCount = 1'b0;
				end
				
				CHECK_W_SET: resetCount = 1'b0;
				
				CHECK_W: bpEn = 1'b1;
				
				WIN_CONFIRM: begin
					ld_sprite = 1'b1;
					spriteSel = 3'b011;
				end
				
				CHECK_LOSE: countEn = 1'b1;
				
				LOSE_CONFIRM: begin
					ld_sprite = 1'b1;
					spriteSel = 3'b010;
				end
				
				default: ;
			endcase
		end
		
	always@(posedge clock)
	begin
		if(~resetN)
			current_state[4:0] <= RESET;
		else
			current_state[4:0] <= next_state[4:0];
	end
	
endmodule 