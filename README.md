# SlidePuzzle

A slider puzzle game run on a DE1-SoC FPGA development board using Verilog code.
The project is interfaced with a VGA adapter and a PS/2 keyboard.

The game that was created is a slider picture puzzle. 16 samples were taken from an image, all of equal size.
The samples were then randomly scrambled, with the bottom-rightmost sample replaced by a "free" space.
The user must then move the "free" space using the arrow keys to rearrange the image back into its original state.
Several features that were implemented were a start screen and win/lose screens.
