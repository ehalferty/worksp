///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_phy_dq_iob.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module places the data in the IOBs.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module mem_phy_dq_iob (
   input        CLK,
   input        CLK90,
   input        RESET,
   input        DATA_DLYINC,
   input        DATA_DLYCE,
   input        DATA_DLYRST,
   input        WRITE_DATA_RISE,
   input        WRITE_DATA_FALL,
   input        CTRL_WREN,
   input        DQS,
   inout        DDR_DQ,
   output       READ_DATA_RISE,
   output       READ_DATA_FALL

                    );

   wire         dq_in;
   wire         dq_out;
   wire         write_en_L;
   wire         write_en_L_r1;
   wire         vcc;
   wire         gnd;

   wire         data_rise;
   wire         data_fall;

   assign vcc        = 1'b1;
   assign gnd        = 1'b0;

   assign write_en_L = ~CTRL_WREN;

   defparam oddr_dq.SRTYPE = "SYNC";
   defparam oddr_dq.DDR_CLK_EDGE = "SAME_EDGE";

   ODDR oddr_dq (
                 .Q   (dq_out),
                 .C   (CLK90),
                 .CE  (vcc),
                 .D1  (WRITE_DATA_RISE),
                 .D2  (WRITE_DATA_FALL),
                 .R   (gnd),
                 .S   (gnd)
                 );

   FDCE tri_state_dq (
                      .D    (write_en_L),
                      .CLR  (RESET),
                      .C    (CLK90),
                      .Q    (write_en_L_r1),
                      .CE   (vcc)
                      );

   IOBUF  iobuf_dq (
                    .I   (dq_out),
                    .T   (write_en_L_r1),
                    .IO  (DDR_DQ),
                    .O  (dq_in)
                    );

   defparam iserdes_dq.BITSLIP_ENABLE = "FALSE";
   defparam iserdes_dq.DATA_RATE = "DDR";
   defparam iserdes_dq.DATA_WIDTH = 4;
   defparam iserdes_dq.INTERFACE_TYPE = "MEMORY";
   defparam iserdes_dq.IOBDELAY = "IFD";
   defparam iserdes_dq.IOBDELAY_TYPE = "VARIABLE";
   defparam iserdes_dq.IOBDELAY_VALUE = 5;
   defparam iserdes_dq.NUM_CE = 2;
   defparam iserdes_dq.SERDES_MODE = "MASTER";

   ISERDES iserdes_dq (
                       .O            (),
                       .Q1           (data_fall),
                       .Q2           (data_rise),
                       .Q3           (),
                       .Q4           (),
                       .Q5           (),
                       .Q6           (),
                       .SHIFTOUT1    (),
                       .SHIFTOUT2    (),
                       .BITSLIP      (),
                       .CE1          (1'd1),
                       .CE2          (1'd1),
                       .CLK          (DQS),
                       .CLKDIV       (CLK90),
                       .D            (dq_in),
                       .DLYCE        (DATA_DLYCE),
                       .DLYINC       (DATA_DLYINC),
                       .DLYRST       (DATA_DLYRST),
                       .OCLK         (CLK90),
                       .REV          (gnd),
                       .SHIFTIN1     (),
                       .SHIFTIN2     (),
                       .SR           (RESET)
                       );

   assign READ_DATA_RISE = data_rise;
   assign READ_DATA_FALL = data_fall;

endmodule
