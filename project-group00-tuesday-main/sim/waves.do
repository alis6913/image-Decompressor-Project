# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -uns UUT/UART_timer

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data

add wave -divider -height 10 {VGA signals}
add wave -bin UUT/VGA_unit/VGA_HSYNC_O
add wave -bin UUT/VGA_unit/VGA_VSYNC_O
add wave -uns UUT/VGA_unit/pixel_X_pos
add wave -uns UUT/VGA_unit/pixel_Y_pos
add wave -hex UUT/VGA_unit/VGA_red
add wave -hex UUT/VGA_unit/VGA_green
add wave -hex UUT/VGA_unit/VGA_blue

add wave -divider -height 10 {M1}
add wave UUT/M1_unit/M1_state
add wave -dec UUT/M1_unit/Product
add wave -dec UUT/M1_unit/Op0
add wave -dec UUT/M1_unit/Op1
add wave -dec UUT/M1_unit/X_counter
add wave -dec UUT/M1_unit/Y_Counter
add wave -dec UUT/M1_unit/Y_Register
add wave -dec UUT/M1_unit/V_Register
add wave -dec UUT/M1_unit/U_Register
add wave -hex UUT/M1_unit/V_Shift_Register
add wave -hex UUT/M1_unit/U_Shift_Register
add wave -hex UUT/M1_unit/V_buff
add wave -hex UUT/M1_unit/U_buff
add wave -hex UUT/M1_unit/r
add wave -hex UUT/M1_unit/g
add wave -hex UUT/M1_unit/b
add wave -dec UUT/M1_unit/R_Initial
add wave -dec UUT/M1_unit/G_Initial
add wave -dec UUT/M1_unit/B_Initial
