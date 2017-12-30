///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_io_ctrl.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module Instantaites the IDELAYCTRL primitive of the
//                  Virtex4 device which continously calibrates the IDELAY
//                  elements in the region in case of varying operating
//                  conditions. It takes a 200MHz clock as an input.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module mem_idelay_ctrl (
   input                  clk_200,
   input                  sys_rst200,
   output                 idelay_ctrl_rdy
                    );

IDELAYCTRL idelayctrl0 (
                        .RDY(idelay_ctrl_rdy),
                        .REFCLK(clk_200),
                        .RST(sys_rst200)
                        );


endmodule
