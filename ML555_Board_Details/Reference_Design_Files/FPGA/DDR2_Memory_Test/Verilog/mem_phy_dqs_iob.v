///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_phy_dqs_iob.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module places the data stobes in the IOBs.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module mem_phy_dqs_iob (
   input        CLK,
   input        CLK90,
   input        RESET,
   input        DLYINC,
   input        DLYCE,
   input        DLYRST,
   input        CTRL_DQS_RST,
   input        CTRL_DQS_EN,
   inout        DDR_DQS,
   inout        DDR_DQS_L,
   output       DQS_RISE
                    );

   wire         dqs_in;
   wire         dqs_out;
   wire         dqs_delayed;
   wire         dqs_delayed_o;
   wire         ctrl_dqs_en_r1;
   wire         vcc;
   wire         gnd;
   wire         clk180;
   reg          data1;

   assign vcc         = 1'b1;
   assign gnd         = 1'b0;
   assign clk180      = ~CLK;

   // synthesis attribute max_fanout of data1 is 1

   always @ (posedge clk180)
   begin
     if (CTRL_DQS_RST == 1'b1)
       data1 <= 1'b0;
     else
       data1 <= 1'b1;
   end

   assign DQS_RISE = dqs_delayed_o;

   defparam idelay_dqs.IOBDELAY_TYPE = "VARIABLE";
   defparam idelay_dqs.IOBDELAY_VALUE = 0;

   IDELAY idelay_dqs (
                      .O   (dqs_delayed),
                      .I   (dqs_in),
                      .C   (CLK90),
                      .CE  (DLYCE),
                      .INC (DLYINC),
                      .RST (DLYRST)
                      );

    BUFIO bufio1 (
                  .I  (dqs_delayed),
                  .O  (dqs_delayed_o)
                 );

   defparam oddr_dqs.SRTYPE = "SYNC";
   defparam oddr_dqs.DDR_CLK_EDGE = "OPPOSITE_EDGE";

   ODDR oddr_dqs (
                  .Q   (dqs_out),
                  .C   (clk180),
                  .CE  (vcc),
                  .D1  (data1),
                  .D2  (gnd),
                  .R   (gnd),
                  .S   (gnd)
                  );

   //defparam tri_state_dqs.IOB = "TRUE";
   FD tri_state_dqs (
                     .D  (CTRL_DQS_EN),
                     .Q  (ctrl_dqs_en_r1),
                     .C  (clk180)
                     );

   IOBUFDS iobuf_dqs (
                      .O    (dqs_in),
                      .IO   (DDR_DQS),
                      .IOB  (DDR_DQS_L),
                      .I    (dqs_out),
                      .T    (ctrl_dqs_en_r1)
                      );

endmodule
