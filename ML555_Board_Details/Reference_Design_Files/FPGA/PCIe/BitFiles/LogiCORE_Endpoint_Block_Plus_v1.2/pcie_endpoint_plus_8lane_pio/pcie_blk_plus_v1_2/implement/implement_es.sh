#!/bin/sh

# Clean up the results directory
rm -rf results
mkdir results

cp xdlmod.pl results/.

#Synthesize the Verilog Wrapper Files
echo 'Synthesizing verilog example design with XST';
xst -ifn xst.scr
mv xilinx_pci_exp_8_lane_ep.ngc ./results/pcie_blk_plus_v1_2_top.ngc

cd results

echo 'Running ngdbuild'
ngdbuild \
  -verbose \
  -uc ../../example_design/xilinx_pci_exp_blk_plus_8_lane_ep-XC5VLX50T-FF1136-1_ES_ML555.ucf \
  pcie_blk_plus_v1_2_top.ngc \
  -sd ../../../

echo 'Running map'
map \
  -timing \
  -ol high \
  -pr b \
  -o mapped.ncd \
  pcie_blk_plus_v1_2_top.ngd \
  mapped.pcf

echo 'Running XDL'
xdl -ncd2xdl mapped.ncd mapped.xdl

echo 'Running Perl Script'
xilperl xdlmod.pl mapped.xdl

echo 'Running XDL'
xdl -xdl2ncd modified_mapped.xdl modified_mapped.ncd

echo 'Running par'
par \
  -ol high \
  -w modified_mapped.ncd \
  routed.ncd \
  mapped.pcf

echo 'Running trce'
trce \
  -u \
  -v 100 \
  routed.ncd \
  mapped.pcf


echo 'Running design through netgen'
netgen  \
  -sim  \
  -ofmt verilog \
  -ne \
  -w \
  -tm xilinx_pci_exp_8_lane_ep \
  -sdf_path ../../implement/results \
  routed.ncd

echo 'Running design through bitgen'
bitgen \
  -w routed.ncd
