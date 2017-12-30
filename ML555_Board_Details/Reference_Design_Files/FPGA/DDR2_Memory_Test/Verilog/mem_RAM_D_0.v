///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_RAM_D_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : Contains the distributed RAM which stores IOB output data
//                  that is read from the memory.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_RAM_D_0 (
   output [`memory_width-1:0]   DPO,
   input                        A0,
   input                        A1,
   input                        A2,
   input                        A3,
   input [`memory_width-1:0]    D,
   input                        DPRA0,
   input                        DPRA1,
   input                        DPRA2,
   input                        DPRA3,
   input                        WCLK,
   input                        WE
                  );

   genvar RAM16_i;
   generate
      for(RAM16_i = 0; RAM16_i < `memory_width; RAM16_i = RAM16_i+1)
      begin:RAM16_inst
        RAM16X1D RAM16X1D0
                        (
                        .D        (D[RAM16_i]),
                        .WE       (WE),
                        .WCLK     (WCLK),
                        .A0       (A0),
                        .A1       (A1),
                        .A2       (A2),
                        .A3       (A3),
                        .DPRA0    (DPRA0),
                        .DPRA1    (DPRA1),
                        .DPRA2    (DPRA2),
                        .DPRA3    (DPRA3),
                        .SPO      (),
                        .DPO      (DPO[RAM16_i]));
      end // block: RAM16_inst
   endgenerate

endmodule
