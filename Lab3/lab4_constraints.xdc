## Clock signal - 100 MHz
## This sets the clock frequency to 100 MHz (10 ns period)
## Helps guide placement and routing to meet timing
create_clock -period 20.000 -name sys_clk_pin [get_ports Clk]

## Assign clock to physical pin E3 on Nexys A7 board
set_property PACKAGE_PIN E3 [get_ports Clk]
set_property IOSTANDARD LVCMOS33 [get_ports Clk]

## Reset signal - Center button
set_property PACKAGE_PIN N17 [get_ports Reset]
set_property IOSTANDARD LVCMOS33 [get_ports Reset]

## IMPORTANT: Input/Output delay constraints
## These tell Vivado how much time signals take to arrive/leave
set_input_delay -clock sys_clk_pin -min 0.000 [get_ports Reset]
set_input_delay -clock sys_clk_pin -max 2.000 [get_ports Reset]

## Output constraints for PC_out and Data_out
## These prevent Vivado from optimizing away your outputs
set_output_delay -clock sys_clk_pin -min 0.000 [get_ports PC_out*]
set_output_delay -clock sys_clk_pin -max 2.000 [get_ports PC_out*]
set_output_delay -clock sys_clk_pin -min 0.000 [get_ports Data_out*]
set_output_delay -clock sys_clk_pin -max 2.000 [get_ports Data_out*]

## Disable timing checks on reset (asynchronous)
## Uncomment this line if you have timing issues with reset
# set_false_path -from [get_ports rst]

## Keep these signals from being optimized away during implementation
## This ensures PC_out and Data_out remain in the design
set_property KEEP_HIERARCHY TRUE [get_cells *]


##############################################################################
## LAB 5 - Uncomment these when you add the seven-segment display
##############################################################################

## Seven-segment display enable signals (anodes)
#set_property PACKAGE_PIN J17 [get_ports {en_out[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {en_out[0]}]
#set_property PACKAGE_PIN J18 [get_ports {en_out[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {en_out[1]}]
#set_property PACKAGE_PIN T9 [get_ports {en_out[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {en_out[2]}]
#set_property PACKAGE_PIN J14 [get_ports {en_out[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {en_out[3]}]
#set_property PACKAGE_PIN P14 [get_ports {en_out[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {en_out[4]}]
#set_property PACKAGE_PIN T14 [get_ports {en_out[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {en_out[5]}]
#set_property PACKAGE_PIN K2 [get_ports {en_out[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {en_out[6]}]
#set_property PACKAGE_PIN U13 [get_ports {en_out[7]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {en_out[7]}]

## Seven-segment display segments (cathodes)
#set_property PACKAGE_PIN T10 [get_ports {out7[6]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {out7[6]}]
#set_property PACKAGE_PIN R10 [get_ports {out7[5]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {out7[5]}]
#set_property PACKAGE_PIN K16 [get_ports {out7[4]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {out7[4]}]
#set_property PACKAGE_PIN K13 [get_ports {out7[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {out7[3]}]
#set_property PACKAGE_PIN P15 [get_ports {out7[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {out7[2]}]
#set_property PACKAGE_PIN T11 [get_ports {out7[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {out7[1]}]
#set_property PACKAGE_PIN L18 [get_ports {out7[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {out7[0]}]
