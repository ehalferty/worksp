///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_phy_dm_iob.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module places the data mask signals into the IOBs.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module mem_phy_dm_iob (
   input        CLK90,
   input        MASK_DATA_RISE,
   input        MASK_DATA_FALL,

   output       DDR_DM

                    );

   wire         vcc;
   wire         gnd;

   wire         dm_out;

   assign vcc        = 1'b1;
   assign gnd        = 1'b0;

   defparam oddr_dm.SRTYPE = "SYNC";
   defparam oddr_dm.DDR_CLK_EDGE = "SAME_EDGE";

   ODDR oddr_dm (
                  .Q   (dm_out),
                  .C   (CLK90),
                  .CE  (vcc),
                  .D1  (MASK_DATA_RISE),
                  .D2  (MASK_DATA_FALL),
                  .R   (gnd),
                  .S   (gnd)
                  );

   OBUF obuf_dm (
                  .I   (dm_out),
                  .O   (DDR_DM)
                  );

endmodule
