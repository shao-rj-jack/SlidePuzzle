module gameLogic(
	input [3:0] KEY,
	
	input CLOCK_50,
	
	inout PS2_CLK,
	inout PS2_DAT,
	
	output	[9:0] LEDR,
	output	[6:0] HEX0,
	output	[6:0] HEX1,
	
	output [6:0] HEX4,
	output [6:0] HEX5,
	
	output			VGA_CLK,   				//	VGA Clock
	output			VGA_HS,				//	VGA H_SYNC
	output			VGA_VS,					//	VGA V_SYNC
	output			VGA_BLANK_N,				//	VGA BLANK
	output			VGA_SYNC_N,				//	VGA SYNC
	output	[7:0]	VGA_R,   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G,	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B   				//	VGA Blue[7:0]
	);
	
	wire [3:0] RAM_address,	//Address into the RAM module from datapath
				  addr_loop,	//Current address from Controlpath
				  data_in,		//ID used to update RAM
				  ram_out;		//value of RAM at RAM_address
	
	wire [7:0] rand8;
	
	wire startRand,
		  stopRand,
		  ld_begin_rand,
		  ld_next_rand,
		  ld_new_empty,
		  ld_b_addr,
		  ld_other_addr,
		  ld_other_ID,
		  mv_b,
		  mv_other,
		  writeEN,
		  plot,
		  wipe,
		  done,
		  move,
		  start,
		  ld_sprite;
	
	wire [2:0] sprite_sel;
	
	wire [2:0] direction;
	wire [7:0] moveCount;
	
	gameLogic_datapath d0(
		.clock(CLOCK_50),
		.resetN(KEY[3]),
		.keyboard_input(direction),
		.randnum(rand8[3:0]),
		.b_address(addr_loop),
		.ram_ID(ram_out),
		
		//ld from controlpath
		.ld_begin_rand(ld_begin_rand),
		.ld_next_rand(ld_next_rand),
		.ld_new_empty(ld_new_empty),
		.ld_b_addr(ld_b_addr),
		.ld_other_addr(ld_other_addr),
		.ld_other_ID(ld_other_ID),
		.mv_other(mv_other),
		.mv_b(mv_b),
		
		.address_out(RAM_address),
		.ID_out(data_in)
		);
		
	gameLogic_control c0(
		.clock(CLOCK_50),
		.resetN(KEY[3]), // for now
		.move(move),
		.startGame(start),
		.done(done),
		.selected_ID(ram_out),
		//.wipe(~KEY[]), // from datapath
		
		// to datapath
		.ld_begin_rand(ld_begin_rand),
		.ld_next_rand(ld_next_rand),
		.ld_new_empty(ld_new_empty),
		.ld_b_addr(ld_b_addr),
		.ld_other_addr(ld_other_addr),
		.ld_other_ID(ld_other_ID),
		.mv_b(mv_b),
		.mv_other(mv_other),
		
		// to Random
		.startRand(startRand),
		.stopRand(stopRand),
		
		.writeEN(writeEN), // to RAM
		
		// to VGA
		.plot(plot),
		.out_address(addr_loop),
		.ld_sprite(ld_sprite),
		.sprite_sel(sprite_sel),
		//.wipe_VGA(wipe) omitted for now
		
		.moveCount(moveCount)
		);
		
	/*gameLogic_buffer b0(
		.memory_id(id_in),
		.clock(CLOCK_50),
		.resetN(KEY[3]), // for now
		
		// from control
		.idle(idle),
		.ld_next_address(ld_next_address),
		
		// to datapath
		.current_address(current_address),
		.next_id(next_id),
		.counter_address(counter_address)
		);*/
		
	basicDisplay bd0(
				.clk(CLOCK_50),
				.resetn(~start),
				.address(addr_loop), // from control
				.ID(ram_out), // from RAM
				.plot(plot),
				.load_sprite(ld_sprite),
				.sprite_sel(sprite_sel),
				.done(done),

				// The ports below are for the VGA output.  Do not change.
				.VGA_CLK(VGA_CLK),
				.VGA_HS(VGA_HS),
				.VGA_VS(VGA_VS),
				.VGA_BLANK_N(VGA_BLANK_N),
				.VGA_SYNC_N(VGA_SYNC_N),
				.VGA_R(VGA_R),
				.VGA_G(VGA_G),
				.VGA_B(VGA_B));
				
	ram16x4 r0(.address(RAM_address),
				  .clock(CLOCK_50),
				  .data(data_in),
				  .wren(writeEN),
				  .q(ram_out));
	
	rand8bit rand0(.clock(CLOCK_50),
						.start(startRand),
						.stop(stopRand),
						.randNum(rand8));
						
	keyboard_decoder decode0(
	.CLOCK_50(CLOCK_50),
	.resetn(KEY[3]),
	
	.PS2_CLK(PS2_CLK),
	.PS2_DAT(PS2_DAT),
	
	// LEDR tests value of direction, HEX displays last received keyboard code (to be deleted later)
	.LEDR(LEDR[9:0]),
	.HEX0(HEX0[6:0]),
	.HEX1(HEX1[6:0]),
	
	.direction(direction),
	.move(move),
	.start(start)
);

Hexadecimal_To_Seven_Segment hex5(
	// Inputs
	.hex_number(moveCount[7:4]),

	// Outputs
	.seven_seg_display(HEX5)
);

Hexadecimal_To_Seven_Segment hex4(
	// Inputs
	.hex_number(moveCount[3:0]),

	// Outputs
	.seven_seg_display(HEX4)
);

endmodule 