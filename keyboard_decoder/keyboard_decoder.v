module keyboard_decoder (
	input CLOCK_50,
	input resetn,
	
	inout PS2_CLK,
	inout PS2_DAT,
	
	// testing LEDs, to be deleted later
	output [9:0] LEDR,
	output [6:0] HEX0,
	output [6:0] HEX1,
	
	output reg [2:0] direction,
	output reg move,
	output reg start
);

localparam direction_no_input	= 3'b000,
			  direction_up			= 3'b001,
			  direction_down		= 3'b010,
			  direction_left		= 3'b011,
			  direction_right		= 3'b100,
			  make_code				= 8'he0,
			  break_code			= 8'hf0,
			  enter_code			= 8'h5a;

// states to read directional input			  
localparam S_IDLE				= 1'd0,
			  S_INPUT			= 1'd1;
			  
wire [7:0] ps2_key_data;
wire ps2_key_pressed;

reg [7:0] last_data_received, ld_data;
reg current_state, next_state;

// reads keyboard input as last_data_received
always @(posedge CLOCK_50)
begin
	if (~resetn)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed)
		last_data_received <= ps2_key_data;
end

// states for reading last_data_received into ld_data on arrow button press and detecting release of buttons
always @(*)
	case (current_state)
		S_IDLE:		next_state = (last_data_received == make_code) ? S_INPUT : S_IDLE;
		S_INPUT:		next_state = (last_data_received == break_code) ? S_IDLE : S_INPUT;
		default:		next_state = S_IDLE;
	endcase

// ld_data register, updates according to state
always @(*)
	case (current_state)
		S_IDLE:	begin
						move = 1'b0;
						start = 1'b0;
					end
			
		S_INPUT:	begin
						move = 1'b1;
						if(last_data_received == enter_code) start = 1'b1;
					end
	endcase

// decodes ld_data to direction output to gameLogic
always @(*)
	case (last_data_received)
		8'h75: 	direction = direction_up;
		8'h72: 	direction = direction_down;
		8'h6b: 	direction = direction_left;
		8'h74: 	direction = direction_right;
		// default: direction = direction_no_input;
	endcase

// testing LEDs, to be deleted later
assign LEDR[2:0] = direction;
assign LEDR[9] = move;
assign LEDR[7] = start;

// state DFF
always @(posedge CLOCK_50)
begin
	if (~resetn)
		current_state <= S_IDLE;
	else
		current_state <= next_state;
end
	
PS2_Controller PS2 (
	// inputs
	.CLOCK_50 (CLOCK_50),
	.reset (~resetn),
	
	// bidirectionals
	.PS2_CLK (PS2_CLK),
	.PS2_DAT (PS2_DAT),
	
	// outputs
	.received_data (ps2_key_data),
	.received_data_en (ps2_key_pressed)
);

// testing HEX displays, to be deleted later
Hexadecimal_To_Seven_Segment Segment0 (
	// inputs
	.hex_number (last_data_received[3:0]),

	// outputs
	.seven_seg_display (HEX0)
);

Hexadecimal_To_Seven_Segment Segment1 (
	// inputs
	.hex_number (last_data_received[7:4]),

	// outputs
	.seven_seg_display (HEX1)
);

endmodule 