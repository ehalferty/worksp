################################################################################
##   ____  ____ 
##  /   /\/   / 
## /___/  \  /    Vendor: Xilinx 
## \   \   \/     Version : 1.1
##  \   \         Application : PCIe  
##  /   /         Filename : simulate_ncsim.sh
## /___/   /\    
## \   \  /  \ 
##  \___\/\___\ 
##
##
##***************************** Beginning of Script ***************************
#!/bin/sh
        
#Ensure the follwoing
#The library paths for UNISIMS_VER, SIMPRIMS_VER, XILINXCORELIB_VER,
#UNISIM, SIMPRIM, XILINXCORELIB are set correctly in the cds.lib and hdl.var files.
#Variables LMC_HOME and XILINX are set 
#Define the mapping for the work library in cds.lib file. DEFINE work ./work

mkdir work
##PCIe Wrappers
ncvlog -work work ../../src/pci_express_wrapper.v; 
ncvlog -work work ../../src/pcie_top.v;
ncvlog -work work ../../src/pcie_mim_wrapper.v;
ncvlog -work work ../../src/pcie_gt_wrapper.v;
ncvlog -work work ../../src/bram_common.v;
ncvlog -work work ../../src/pcie_clocking.v;
ncvlog -work work ../../src/pcie_reset_logic.v;
ncvlog -work work ../../src/pcie_bar_decoder.v;
ncvlog -work work ../../src/pcie_cmm_decoder.v;
ncvlog -work work ../../src/pcie_blk_cf_mgmt.v;
##Example Design modules
##Completer

ncvlog -INCDIR "../../example_design" -work work ../../example_design/mem_ep_app_top.v;
ncvlog -INCDIR "../../example_design" -work work ../../example_design/completer_mem_block.v;
ncvlog -INCDIR "../../example_design" -work work ../../example_design/completer_mem_block_machine.v;
ncvlog -INCDIR "../../example_design" -work work ../../example_design/completer_mem_block_top.v;




##Other modules
ncvlog -work work $XILINX/verilog/src/glbl.v;

##Test_bench files
ncvlog -INCDIR "../../test_bench" -work work  ../../test_bench/tb.v;
ncvlog -INCDIR "../../test_bench" -work work  ../../test_bench/pcie_top_ne.v;
ncvlog -INCDIR "../../test_bench" -work work  ../../test_bench/pcie_ne.v;

ncelab -TIMESCALE 10ps/10ps -LOADPLI1 swiftpli:swift_boot -ACCESS +rw work.tb work.glbl 

ncsim work.tb
