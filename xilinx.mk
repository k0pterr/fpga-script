#------------------------------------------------------------------------------
#
#     Xilinx-oriented designs build script
#
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#
#     General settings
#
CFG_NAME           := $(notdir $(CURDIR))
				   
SCRIPT_DIR         := $(REF_DIR)/script
IP_LIB_DIR         := $(REF_DIR)/ip/xilinx
BIN_DIR            := $(REF_DIR)/bin
BUILD_DIR          := $(REF_DIR)/build

PLATFORM_BUILD_DIR := $(abspath $(BUILD_DIR)/syn/$(CFG_NAME))
PLATFORM_FSIM_DIR  := $(abspath $(BUILD_DIR)/sim/$(CFG_NAME)/func)
SIM_WLIB_DIR       := $(PLATFORM_FSIM_DIR)/$(SIM_WLIB_NAME)
OUT_IP_DIR         := $(PLATFORM_BUILD_DIR)/.ip

SIM_HANDOFF        := handoff.do

#-------------------------------------------------------------------------------
#
#     Tool scripts
#
IP_BLD_SCRIPT     := xilinx_ip_bld.tcl
PRJ_GEN_SCRIPT    := xilinx_prj_gen.tcl
OUT_GEN_SCRIPT    := xilinx_prj_build.tcl
DEV_PGM_SCRIPT    := xilinx_dev_pgm.tcl
CFGMEM_PGM_SCRIPT := xilinx_cfgmem_pgm.tcl

#-------------------------------------------------------------------------------
#
#     Toolchain shells
#
ifeq ($(OS),Windows_NT)
 detected_OS := Windows
else
 detected_OS := $(shell sh -c 'uname -s 2>/dev/null || echo not')
endif

#-------------------------------------------------------------------------------
ifeq ($(detected_OS),Windows)
 fixPath = $(subst /,\,$1)
 SHELL_DIR := D:/CAD/Xilinx/SDx/2016.3/Vivado/bin
else
 fixPath = $1
 SHELL_DIR := $(XILINX_VIVADO)/bin
endif

#-------------------------------------------------------------------------------
PRJ_SHELL  := vivado
PGM_SHELL  := vivado
SIM_SHELL  := vsim

#-------------------------------------------------------------------------------
#
#     Direcrory paths tweaking
#
IP_LIB_DIR          := $(abspath $(IP_LIB_DIR))
SRC_DIR             := $(abspath $(SRC_DIR))
LIB_DIR             := $(abspath $(LIB_DIR))
PLATFORM_BUILD_DIR  := $(call fixPath,$(PLATFORM_BUILD_DIR))
OUT_IP_DIR          := $(call fixPath,$(OUT_IP_DIR))
BIN_DIR             := $(call fixPath,$(abspath $(BIN_DIR)))
SCRIPT_DIR          := $(call fixPath,$(abspath $(SCRIPT_DIR)))

#-------------------------------------------------------------------------------
#
#     Synthesizer shell command-lines
#
PRJ_FILE_CMD_LINE   := -mode batch -journal $(PLATFORM_BUILD_DIR)/$(CFG_NAME)-prj.jou -log $(PLATFORM_BUILD_DIR)/$(CFG_NAME)-prj.log -source $(SCRIPT_DIR)/$(PRJ_GEN_SCRIPT) -notrace
OUT_FILE_CMD_LINE   := -mode batch -journal $(PLATFORM_BUILD_DIR)/$(CFG_NAME)-out.jou -log $(PLATFORM_BUILD_DIR)/$(CFG_NAME)-out.log -source $(SCRIPT_DIR)/$(OUT_GEN_SCRIPT) -notrace
DEV_PGM_CMD_LINE    := -mode batch -journal $(PLATFORM_BUILD_DIR)/$(CFG_NAME)-pgm.jou -log $(PLATFORM_BUILD_DIR)/$(CFG_NAME)-pgm.log -source $(SCRIPT_DIR)/$(DEV_PGM_SCRIPT) -notrace
CFGMEM_PGM_CMD_LINE := -mode batch -journal $(PLATFORM_BUILD_DIR)/$(CFG_NAME)-pgm.jou -log $(PLATFORM_BUILD_DIR)/$(CFG_NAME)-pgm.log -source $(SCRIPT_DIR)/$(CFGMEM_PGM_SCRIPT) -notrace

#---
define ip_bld_cmd
 $(SHELL_DIR)/$(PRJ_SHELL)\
  -mode batch\
  -journal $(PLATFORM_BUILD_DIR)/$(CFG_NAME)-ip-$(patsubst %.tcl,%,$(notdir $(1))).jou\
  -log     $(PLATFORM_BUILD_DIR)/$(CFG_NAME)-ip-$(patsubst %.tcl,%,$(notdir $(1))).log\
  -source  $(SCRIPT_DIR)/$(IP_BLD_SCRIPT)\
  -notrace
endef

#-------------------------------------------------------------------------------
#
#     Target names
#
PRJ_FILE_NAME    := $(CFG_NAME)
OUT_FILE_NAME    := $(TOP_NAME)
TARGET_FILE_NAME := $(CFG_NAME)

#-------------------------------------------------------------------------------
#
#     File paths tweaking
#
INC            := $(abspath $(INC)) 
SRC            := $(abspath $(SRC)) 
CFG_IP         := $(abspath $(addprefix $(CFG_IP_DIR)/, $(CFG_IP))) 

SRC_DEPS       := $(call fixPath, $(SRC)) $(call fixPath, $(INC)) $(call fixPath, $(SDC))
PRJ_FILE       := $(call fixPath, $(abspath $(PLATFORM_BUILD_DIR)/$(PRJ_FILE_NAME).xpr)) 
OUT_FILE       := $(call fixPath, $(abspath $(PLATFORM_BUILD_DIR)/$(CFG_NAME).runs/impl_1/$(OUT_FILE_NAME).bit))
TRG_FILE       := $(call fixPath, $(abspath $(BIN_DIR)/$(TARGET_FILE_NAME).bit))

#-------------------------------------------------------------------------------
#
#     Build scripts dependencies
#
CMD_DEPS            := $(SCRIPT_DIR)/xilinx.mk makefile
CMD_DEPS_PRJ        := $(SCRIPT_DIR)/xilinx_prj_gen.tcl $(SCRIPT_DIR)/cfg_header_gen.tcl $(PRJ_DEPS)
CMD_DEPS_BLD        := $(SCRIPT_DIR)/xilinx_prj_build.tcl
CMD_DEPS_PRG        := $(SCRIPT_DIR)/xilinx_dev_pgm.tcl
CMD_DEPS_PRG_CFGMEM := $(SCRIPT_DIR)/xilinx_cfgmem_pgm.tcl

ifneq ($(wildcard cfg_params.tcl),)
 CMD_DEPS_PRJ := $(CMD_DEPS_PRJ) cfg_params.tcl
endif

ifneq ($(wildcard prologue.tcl),)
 CMD_DEPS_PRJ := $(CMD_DEPS_PRJ) prologue.tcl
endif

ifneq ($(wildcard epilogue.tcl),)
 CMD_DEPS_PRJ := $(CMD_DEPS_PRJ) epilogue.tcl
endif

ifneq ($(wildcard settings.tcl),)
 CMD_DEPS_PRJ := $(CMD_DEPS_PRJ) settings.tcl
endif

#-------------------------------------------------------------------------------
#
#     IP cores dependencies
#
OUT_IP     := $(foreach ip_src, $(notdir $(CFG_IP)), $(OUT_IP_DIR)/$(ip_src)/)
OUT_IP     := $(abspath $(OUT_IP)) 

#--------------------------------------------------------------------------------
#
#    Main targets
#
.PHONY: all dev_pgm cfgmem_pgm clean clean_all print-% test qs_vlog qs_gui qs_sim

all:    build_prj

build_prj:  $(TRG_FILE)

create_prj: $(PRJ_FILE)

build_ip:   $(OUT_IP)

#--------------------------------------------------------------------------------
#
#    Main targets rules
#
dev_pgm: $(TRG_FILE) $(CMD_DEPS_PRG)
	rm -rf $(PLATFORM_BUILD_DIR)\$(CFG_NAME)-pgm*
	$(SHELL_DIR)/$(PGM_SHELL) $(DEV_PGM_CMD_LINE) -tclargs $(TRG_BOARD) $(TRG_DEVICE) $(TRG_FILE)
	rm -rf .Xil

#---------------------------------------------------------------------
cfgmem_pgm: $(TRG_FILE) $(CMD_DEPS_PRG_CFGMEM)
	rm -rf $(PLATFORM_BUILD_DIR)\$(CFG_NAME)-pgm*
	$(SHELL_DIR)/$(PGM_SHELL) $(CFGMEM_PGM_CMD_LINE) -tclargs $(TRG_BOARD) $(TRG_DEVICE) $(TRG_CFGMEM) $(TRG_CFGMEM_SIZE) $(TRG_FILE)
	rm -rf .Xil webtalk*

#---------------------------------------------------------------------
clean:
	rm -rf $(PLATFORM_BUILD_DIR) $(TRG_FILE) $(CFG_DIR)/.Xil $(CFG_DIR)/*jou $(CFG_DIR)/*log
#---------------------------------------------------------------------
clean_all:
	rm -rf $(BUILD_DIR) $(BIN_DIR)
#---------------------------------------------------------------------
$(TRG_FILE): $(OUT_FILE)
	mkdir --parents $(BIN_DIR)
	cp $(OUT_FILE) $(TRG_FILE)
	rm -rf .Xil
#---------------------------------------------------------------------
$(OUT_FILE): $(SRC_DEPS) $(PRJ_FILE) $(CMD_DEPS) $(CMD_DEPS_BLD) $(CMD_DEPS_PRJ)
	rm -rf $(PLATFORM_BUILD_DIR)\$(CFG_NAME)-out*
	$(SHELL_DIR)/$(PRJ_SHELL) $(OUT_FILE_CMD_LINE) -tclargs $(PLATFORM_BUILD_DIR) $(PRJ_FILE_NAME)
#---------------------------------------------------------------------
$(OUT_IP_DIR)/simlib:
	mkdir --parents $(OUT_IP_DIR)
	cd $(OUT_IP_DIR); vlib simlib
#---------------------------------------------------------------------

print-%:
	@echo $* = $($*)

test:
	@echo test $(TARGET_FILE_NAME)	

#---------------------------
$(PRJ_FILE): $(CMD_DEPS) $(CMD_DEPS_PRJ) $(OUT_IP) | $(PLATFORM_BUILD_DIR)
	$(SHELL_DIR)/$(PRJ_SHELL) $(PRJ_FILE_CMD_LINE) -tclargs $(SCRIPT_DIR) $(SRC_DIR) $(PLATFORM_BUILD_DIR) $(TOP_NAME) $(TARGET_FILE_NAME) $(DEVICE) $(LIB_DIR) $(SRC) $(SDC) $(OUT_IP)

.SECONDEXPANSION:
PERCENT = %
$(OUT_IP): % : $$(filter $$(PERCENT)$$(notdir $$*), $$(CFG_IP)).tcl | $(OUT_IP_DIR)/simlib
	@echo Generate IP cores
	$(call ip_bld_cmd, $^ ) -tclargs $(SCRIPT_DIR) $^ $@ $(DEVICE) $(IP_LIB_DIR)
	cd $(OUT_IP_DIR); $(SIM_SHELL) -c -do "set IP_LIB_DIR $(IP_LIB_DIR)" -do $<

#---------------------------
$(PLATFORM_BUILD_DIR):
	mkdir -p $(PLATFORM_BUILD_DIR)	

#--------------------------------------------------------------------------------
#
#   Simulator support
#
IP_SIMLIB_NAME := ip_simlib
SRC_SIM        += $(XILINX_VIVADO)/data/verilog/src/glbl.v

ifneq ($(strip $(CFG_IP) ),)
MAP_IP_SIMLIB_CMD := vmap $(IP_SIMLIB_NAME) $(OUT_IP_DIR)/simlib;
VOPT_FLAGS += -L $(IP_SIMLIB_NAME)
endif

VOPT_FLAGS += glbl

$(PLATFORM_FSIM_DIR):
	@echo Create sim dir
	mkdir -p $(PLATFORM_FSIM_DIR)	
	
#---------------------------------------------------------------------
$(SIM_WLIB_DIR): $(CMD_DEPS) $(OUT_IP) | $(PLATFORM_FSIM_DIR)
	@echo Create work library $(SIM_WLIB_DIR)
	@if [ -e  $(SIM_WLIB_DIR) ]; then rm -rf $(SIM_WLIB_DIR); fi;
	@if [ -e  $(PLATFORM_FSIM_DIR)/modelsim.ini ]; then rm $(PLATFORM_FSIM_DIR)/modelsim.ini; fi;
	@vlib $(SIM_WLIB_DIR)
	@cd $(PLATFORM_FSIM_DIR); vmap -c; vmap $(SIM_WLIB_NAME) $(SIM_WLIB_DIR); $(MAP_IP_SIMLIB_CMD) cd $(CURDIR)

#---------------------------------------------------------------------
$(SIM_HANDOFF): | $(PLATFORM_FSIM_DIR)
	@echo Create handoff file
	@echo set CFG_DIR {$(CFG_DIR)}                                               >  $(PLATFORM_FSIM_DIR)/$(SIM_HANDOFF)
	@echo set SCRIPT_DIR {$(SCRIPT_DIR)}                                         >> $(PLATFORM_FSIM_DIR)/$(SIM_HANDOFF)
	@echo set SRC_DIR {$(SRC_DIR)}                                               >> $(PLATFORM_FSIM_DIR)/$(SIM_HANDOFF)
	@echo set TOP_NAME {$(TOP_NAME)}                                             >> $(PLATFORM_FSIM_DIR)/$(SIM_HANDOFF)
	@echo set TBENCH_NAME {$(TBENCH_NAME)}                                       >> $(PLATFORM_FSIM_DIR)/$(SIM_HANDOFF)
	@echo set WLIB_NAME {$(SIM_WLIB_NAME)}                                       >> $(PLATFORM_FSIM_DIR)/$(SIM_HANDOFF)
	@echo set Src          [list $(foreach f, $(SRC_SIM), {$(abspath $f)})]      >> $(PLATFORM_FSIM_DIR)/$(SIM_HANDOFF)
	@echo set SIM_INC_DIRS [list $(foreach d, $(SIM_INC_DIRS), {$(abspath $d)})] >> $(PLATFORM_FSIM_DIR)/$(SIM_HANDOFF)
	@echo set VLOG_FLAGS   [list $(foreach f, $(VLOG_FLAGS), {$f})]              >> $(PLATFORM_FSIM_DIR)/$(SIM_HANDOFF)
	@echo set VOPT_FLAGS   [list $(foreach f, $(VOPT_FLAGS), {$f})]              >> $(PLATFORM_FSIM_DIR)/$(SIM_HANDOFF)

#---------------------------------------------------------------------
qs_vlog: $(SIM_HANDOFF) $(SIM_WLIB_DIR) $(OUT_IP)
	@echo Questa Sim compile
	cd $(PLATFORM_FSIM_DIR) && vsim -c -do $(SCRIPT_DIR)/qs_compile.tcl
	
#---------------------------------------------------------------------
qs_gui:
	@echo Questa Sim GUI
	cd $(PLATFORM_FSIM_DIR) && $(MENTOR)/questa.sh -gui -do $(SCRIPT_DIR)/questa_sim.tcl
	
#---------------------------------------------------------------------
qs_sim:
	@echo Questa Sim simulate in console mode
#-------------------------------------------------------------------------------
	
