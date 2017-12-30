#!/bin/sh

#
# PCI Express Endpoint NC Verilog Run Script
#

rm -rf INCA* work

mkdir work

ncvlog    -WORK work -define NCV \
          -define BOARDx08 \
          -define SIMULATION \
          -file board_rtl_x08_ncv.f \
          -define SIM_USERTB \
          -incdir ../ -incdir ../tests -incdir ../dsport 

ncelab -loadpli1  swiftpli:swift_boot -access +rwc -timescale 1ns/1ps \
work.boardx08 work.glbl

ncsim work.boardx08
