#*******************************************************************************
#*******************************************************************************

puts ""
puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
puts ""
puts ""
puts "                                     Program Device"
puts ""
puts ""
puts "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
puts ""


#-----------------------------------
set DEBUG_INFO 1


#-----------------------------------
set TRG_BOARD       [lindex $argv 0]
set TRG_DEVICE      [lindex $argv 1]
set TRG_FILE        [lindex $argv 2]

#-----------------------------------
set CFG_DIR [pwd]

#-----------------------------------
open_hw
connect_hw_server
set hwTarget "localhost:3121/xilinx_tcf/${TRG_BOARD}"

#-----------------------------------
#--- TEST-1 (begin)
set TEST_1 0
puts "hwTarget: $hwTarget"
if {$TEST_1 == 1} {
       puts "\n**************** \[XILINX_DEV_PGM:DEBUG\] TEST-1 (begin)"
       set hwTargets [get_hw_targets ]
       puts "---- hw targets:"
       set idx 0
       foreach trg $hwTargets {
        incr idx
        puts "trg $idx: $trg" 
       }
       puts "**************** \[XILINX_DEV_PGM:DEBUG\] TEST-1 (end)\n"
}
#--- TEST-1 (end)
#-----------------------------------

open_hw_target $hwTarget

#-----------------------------------
#--- TEST (begin)
set TEST_2 0
if {$TEST_2 == 1} {
       puts "\n**************** \[XILINX_DEV_PGM:DEBUG\] TEST-2 (begin)"
       set hwDevices [get_hw_devices ]
       puts "---- hw devices (hw target: $hwTarget)"
       set idx 0
       foreach dev $hwDevices {
        incr idx
        puts "dev $idx: $dev" 
       }
       puts "**************** \[XILINX_DEV_PGM:DEBUG\] TEST-2 (end)\n"
}
#--- TEST-2 (end)
#-----------------------------------

current_hw_device $TRG_DEVICE
refresh_hw_device -update_hw_probes false [current_hw_device ]
set_property PROBES.FILE {} [current_hw_device ]
set_property PROGRAM.FILE $TRG_FILE [current_hw_device ]
program_hw_devices [current_hw_device ]
refresh_hw_device [current_hw_device ]
close_hw_target $hwTarget

close_hw


#-----------------------------------
if {$DEBUG_INFO == 1} {
        puts "\[XILINX_DEV_PGM:DEBUG\] TRG_BOARD:  $TRG_BOARD"
        puts "\[XILINX_DEV_PGM:DEBUG\] TRG_DEVICE: $TRG_DEVICE"
        puts "\[XILINX_DEV_PGM:DEBUG\] TRG_FILE:   $TRG_FILE"
}


