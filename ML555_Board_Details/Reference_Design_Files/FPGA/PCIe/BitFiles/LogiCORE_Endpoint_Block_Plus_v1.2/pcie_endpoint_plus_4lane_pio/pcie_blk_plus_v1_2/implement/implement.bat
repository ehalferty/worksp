rem Clean up the results directory
rmdir /S /Q results
mkdir results

echo 'Synthesizing verilog example design with XST';
xst -ifn xst.scr
move xilinx_pci_exp_4_lane_ep.ngc .\results\pcie_blk_plus_v1_2_top.ngc

cd results

echo 'Running ngdbuild'
  ngdbuild -verbose -uc ..\..\example_design\xilinx_pci_exp_blk_plus_4_lane_ep-XC5VLX50T-FF1136-1.ucf pcie_blk_plus_v1_2_top.ngc -sd ..\..\..\

echo 'Running map'
map -timing -ol high -pr b -o mapped.ncd pcie_blk_plus_v1_2_top.ngd mapped.pcf

echo 'Running par'
par -ol high -w mapped.ncd routed.ncd mapped.pcf

echo 'Running trce'
trce -u -v 100 routed.ncd mapped.pcf

echo 'Running design through netgen'
  netgen -sim -ofmt verilog -ne -w -tm xilinx_pci_exp_4_lane_ep -sdf_path ..\..\implement\results routed.ncd

echo 'Running design through bitgen'
bitgen -w routed.ncd
