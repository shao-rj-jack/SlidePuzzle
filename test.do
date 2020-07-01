vlib work

vlog gameLogic.v
vlog gameLogic_control.v
vlog gameLogic_datapath.v
vlog vga_display/basicDisplay.v
vlog vga_display/sprite0rom.v
vlog vga_display/sprite1rom.v
vlog vga_adapter/vga_adapter.v
vlog vga_adapter/vga_address_translator.v
vlog vga_adapter/vga_controller.v
vlog vga_adapter/vga_pll.v
vlog Counter.v
vlog rand8bit.v
vlog ram16x4.v
vlog keyboard_decoder/Altera_UP_PS2_Command_Out.v
vlog keyboard_decoder/Altera_UP_PS2_Data_In.v
vlog keyboard_decoder/Hexadecimal_To_Seven_Segment.v
vlog keyboard_decoder/keyboard_decoder.v
vlog keyboard_decoder/PS2_Controller.v

vsim -L altera_mf_ver gameLogic

log {/*}

add wave {/*}

# set up clock
force {CLOCK_50} 0 {0ns} , 1 {10ns} -r 20ns

force {KEY[0]} 1
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1

run 100ns

force {KEY[0]} 0

run 100000ns

force {KEY[0]} 1

run 200000ns