puts ""
puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
puts ""
puts ""
puts "                          Program Memory Configuration Device"
puts ""
puts ""
puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
puts ""

#-------------------------------------------------------------------------------
set CFG_DIR [pwd]
#-------------------------------------------------------------------------------
#
#    Tool arguments
#
set TRG_BOARD       [lindex $argv 0]
set TRG_DEVICE      [lindex $argv 1]
set TRG_CFGMEM      [lindex $argv 2]
set TRG_CFGMEM_SIZE [lindex $argv 3]
set TRG_FILE        [lindex $argv 4]

puts "TRG_BOARD:       $TRG_BOARD"
puts "TRG_DEVICE:      $TRG_DEVICE"
puts "TRG_CFGMEM:      $TRG_CFGMEM"
puts "TRG_CFGMEM_SIZE: $TRG_CFGMEM_SIZE"
puts "TRG_FILE:        $TRG_FILE"

#-------------------------------------------------------------------------------
#
#    Create target bitstream
#
set TRG_BIN_FILE [file rootname $TRG_FILE].bin

puts "\n\nCreate 'bin' file for programming configuration memory..."
write_cfgmem -force -format bin -loadbit "up 0x0 $TRG_FILE" -size $TRG_CFGMEM_SIZE -interface SPIx4 $TRG_BIN_FILE

#-------------------------------------------------------------------------------
#
#    Open connection to target board
#
puts "\n\n"
open_hw
connect_hw_server
set hwTarget "localhost:3121/xilinx_tcf/${TRG_BOARD}"
open_hw_target $hwTarget

#-------------------------------------------------------------------------------
#
#    Settings
#
current_hw_device [get_hw_devices $TRG_DEVICE]

set_property PROGRAM.FILE $TRG_BIN_FILE [current_hw_device ]
create_hw_cfgmem -hw_device [current_hw_device] -mem_dev [lindex [get_cfgmem_parts ${TRG_CFGMEM}] 0]

set HW_CFGMEM [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $TRG_DEVICE] 0]]

set_property PROGRAM.ADDRESS_RANGE          {use_file}           $HW_CFGMEM
set_property PROGRAM.FILES                  [list $TRG_BIN_FILE] $HW_CFGMEM
set_property PROGRAM.PRM_FILE               {}                   $HW_CFGMEM
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none}          $HW_CFGMEM
set_property PROGRAM.BLANK_CHECK            0                    $HW_CFGMEM
set_property PROGRAM.ERASE                  1                    $HW_CFGMEM
set_property PROGRAM.CFG_PROGRAM            1                    $HW_CFGMEM
set_property PROGRAM.VERIFY                 1                    $HW_CFGMEM
set_property PROGRAM.CHECKSUM               0                    $HW_CFGMEM

#puts [report_property [current_hw_cfgmem]]

#-------------------------------------------------------------------------------
#
#    Load embedded programmer 
#
create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [current_hw_device]]
program_hw_devices [lindex [get_hw_devices xc7a200t_0] 0]

#-------------------------------------------------------------------------------
#
#    Program configuration memory
#
program_hw_cfgmem  -hw_cfgmem [current_hw_cfgmem]
puts "\n\n"
#-------------------------------------------------------------------------------
#
#    Close connection to target board
#
close_hw_target $hwTarget
close_hw


#open_hw_target
#INFO: [Labtoolstcl 44-466] Opening hw_target localhost:3121/xilinx_tcf/Digilent/210203A7C564A
#set_property PROGRAM.FILE {/opt/slon/xilinx/mike/xilinx-vivado-bullet/build/syn/xilinx_AC701/xilinx_AC701.runs/impl_1/slon5_test.bit} [get_hw_devices xc7a200t_0]
#current_hw_device [get_hw_devices xc7a200t_0]
#refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a200t_0] 0]
#INFO: [Labtools 27-1434] Device xc7a200t (JTAG device index = 0) is programmed with a design that has no supported debug core(s) in it.
#WARNING: [Labtools 27-3361] The debug hub core was not detected.
#Resolution:
#1. Make sure the clock connected to the debug hub (dbg_hub) core is a free running clock and is active.
#2. Make sure the BSCAN_SWITCH_USER_MASK device property in Vivado Hardware Manager reflects the user scan chain setting in the design and refresh the device.  To determine the user scan chain setting in the design, open the implemented design and use 'get_property C_USER_SCAN_CHAIN [get_debug_cores dbg_hub]'.
#For more details on setting the scan chain property, consult the Vivado Debug and Programming User Guide (UG908).
#create_hw_cfgmem -hw_device [lindex [get_hw_devices] 0] -mem_dev [lindex [get_cfgmem_parts {mt25ql256-spi-x1_x2_x4}] 0]
#
#set_property PROGRAM.ADDRESS_RANGE  {use_file} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a200t_0] 0]]
#set_property PROGRAM.FILES [list "/opt/slon/xilinx/mike/xilinx-vivado-bullet/build/syn/xilinx_AC701/xilinx_AC701.runs/impl_1/slon5_test.bin" ] [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a200t_0] 0]]
#set_property PROGRAM.PRM_FILE {} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a200t_0] 0]]
#set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a200t_0] 0]]
#set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a200t_0] 0]]
#set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a200t_0] 0]]
#set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a200t_0] 0]]
#set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a200t_0] 0]]
#set_property PROGRAM.CHECKSUM  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a200t_0] 0]]
#
#if {![string equal [get_property PROGRAM.HW_CFGMEM_TYPE  [lindex [get_hw_devices xc7a200t_0] 0]] \
#    [get_property MEM_TYPE [get_property CFGMEM_PART [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a200t_0] 0]]]]] } {
#    create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [ lindex [get_hw_devices xc7a200t_0] 0]]; \
#    program_hw_devices [lindex [get_hw_devices xc7a200t_0] 0];
#};
#
#
#program_hw_cfgmem -hw_cfgmem [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices xc7a200t_0] 0]]
#

