#-------------------------------------------------------------------------------
proc cfg_header_gen {SCRIPT_DIR CFG_DIR} {
#-----------------------------------
    set DEBUG_INFO 0
    
    #-----------------------------------
    set CFG_PARAMS_FILE ${CFG_DIR}/cfg_params.tcl
    
    #-----------------------------------
    set prjDefFile [open [set fileName "$CFG_DIR/cfg_params_generated.svh"] w];
    set guardName  [string toupper [set name "cfg_params_generated_svh"]];
    
    puts $prjDefFile [format "//--------------------------------------------------------------"];
    puts $prjDefFile [format "// This file is automatically generated. Do not edit this file"];
    puts $prjDefFile [format "//--------------------------------------------------------------"];
    puts $prjDefFile [format "`ifndef %s"  $guardName];
    puts $prjDefFile [format "`define %s\n"  $guardName];
    
    #-----------------------------------
    puts $prjDefFile [format "//--- automatically define section\n"];
    puts $prjDefFile [format "// synopsys translate_off"];
    puts $prjDefFile [format "`define SIMULATOR"];
    puts $prjDefFile [format "// synopsys translate_on"];
    puts $prjDefFile [format ""];
    puts $prjDefFile [format "`define CFG_NAME_[string toupper [file tail $CFG_DIR]]"];
    puts $prjDefFile [format ""];
    if {[file exists $CFG_PARAMS_FILE] == 1} {
        puts $prjDefFile [format "//--- user defined section\n"];

        source $CFG_PARAMS_FILE
        
        if { [info exists config_params] } {
            foreach i ${config_params} {
                set name  [lindex ${i} 0]
                set value [lindex ${i} 1]

                puts $prjDefFile [format "`define ${name} %[expr 28 - [string length ${name}]]s"  ${value}];
            }
        }
    }
    #-----------------------------------
    
    puts $prjDefFile [format "\n`endif //%s"  $guardName];
    
    close $prjDefFile;
    
    #-----------------------------------
    if {$DEBUG_INFO == 1} {
        puts "\[CFG_HEADER_GEN:DEBUG\] CFG_DIR: $CFG_DIR"
    }
}
#-------------------------------------------------------------------------------

