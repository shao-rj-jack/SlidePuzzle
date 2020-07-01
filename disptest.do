vlib work

vlog vga_display/basicDisplay.v
vlog Counter.v
vlog vga_adapter/vga_adapter.v
vlog vga_adapter/vga_address_translator.v
vlog vga_adapter/vga_controller.v
vlog vga_adapter/vga_pll.v
vlog vga_display/sprite1rom.v
vlog vga_display/sprite0rom.v
vlog vga_display/sprite2rom.v

vsim -L altera_mf_ver basicDisplay

log {/*}

add wave {/*}

# set up clock
force {clk} 0 {0ns} , 1 {10ns} -r 20ns

force {address[0]} 0
force {address[1]} 0
force {address[2]} 0
force {address[3]} 0

force {sprite_sel[0]} 0
force {sprite_sel[1]} 0
force {sprite_sel[2]} 0

force {ID[0]} 0
force {ID[1]} 0
force {ID[2]} 0
force {ID[3]} 0

force {load_sprite} 0
force {plot} 0
force {resetn} 0

run 20ns

force {resetn} 1
force {plot} 1

run 20ns

force {plot} 0

run 11000ns

force {plot} 1

run 20ns

force {plot} 0

run 11000ns

force {load_sprite} 1

run 20ns

force {load_sprite} 0

run 500000ns