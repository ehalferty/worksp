################################################################################
##   ____  ____ 
##  /   /\/   / 
## /___/  \  /    Vendor: Xilinx 
## \   \   \/     Version : 1.3
##  \   \         Application : GTP Wizard 
##  /   /         Filename : simulate_mti.do
## /___/   /\    
## \   \  /  \ 
##  \___\/\___\ 
##
##
##***************************** Beginning of Script ***************************
        
		          
#Ensure the follwoing
#The library paths for UNISIMS_VER, SIMPRIMS_VER, XILINXCORELIB_VER,
#UNISIM, SIMPRIM, XILINXCORELIB are set correctly in the modelsim.ini file
#Variables LMC_HOME and XILINX are set 

set XILINX   $env(XILINX)
set INC_DIR  ../../example_design
set SRC_DIR  ../../src
set TB_DIR   ../../test_bench


vlib work
vmap work work

##PCIe Wrappers
vlog -work work	  $SRC_DIR/pci_express_wrapper.v; 
vlog -work work	  $SRC_DIR/pcie_top.v;
vlog -work work	  $SRC_DIR/pcie_mim_wrapper.v;
vlog -work work	  $SRC_DIR/pcie_gt_wrapper.v;
vlog -work work	  $SRC_DIR/bram_common.v;
vlog -work work	  $SRC_DIR/pcie_clocking.v;
vlog -work work	  $SRC_DIR/pcie_reset_logic.v;
vlog -work work	  $SRC_DIR/pcie_bar_decoder.v;
vlog -work work	  $SRC_DIR/pcie_cmm_decoder.v;
vlog -work work	  $SRC_DIR/pcie_blk_cf_mgmt.v;

##Example Design modules
##Completer

vlog +incdir+$INC_DIR  -work work  $INC_DIR/mem_ep_app_top.v;
vlog +incdir+$INC_DIR  -work work  $INC_DIR/completer_mem_block.v;
vlog +incdir+$INC_DIR  -work work  $INC_DIR/completer_mem_block_machine.v;
vlog +incdir+$INC_DIR  -work work  $INC_DIR/completer_mem_block_top.v;




##Other modules
vlog -work work   $XILINX/verilog/src/glbl.v;

##Test_bench files
vlog +incdir+$TB_DIR -work work  $TB_DIR/tb.v;
vlog +incdir+$TB_DIR -work work  $TB_DIR/pcie_top_ne.v;
vlog +incdir+$TB_DIR -work work  $TB_DIR/pcie_ne.v;


##Load Design
vsim -t 1ps -L UNISIMS_VER work.tb work.glbl 


##Load signals in wave window
view wave
do wave.do

##Run simulation
run 150 us
