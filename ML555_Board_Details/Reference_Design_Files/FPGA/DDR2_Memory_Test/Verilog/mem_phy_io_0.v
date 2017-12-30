///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_phy_io_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description : This module instantiates data, data strobe and the data mask iobs.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_phy_io_0 (
   input                           CLK,
   input                           CLK90,
   input                           RESET0,
   input                           RESET90,
   input                           dqs_rst,
   input                           dqs_en,
   input                           ctrl_rden,
   input                           idelay_ctrl_rdy,
   input                           phy_init_rden,
   input                           phy_init_initialization_done,
   input                           phy_init_st1_read,
   input                           phy_init_st2_read,

   output                          first_calib_done,
   output                          second_calib_done,
   output [`data_strobe_width-1:0] phy_calib_rden,

   input [`data_width-1:0]         wr_data_rise,
   input [`data_width-1:0]         wr_data_fall,
   input          wr_en,
   output [`data_width-1:0]        rd_data_rise,
   output [`data_width-1:0]        rd_data_fall,
   input [`data_mask_width-1:0]    mask_data_rise,
   input [`data_mask_width-1:0]    mask_data_fall,

   inout [`data_width-1:0]         DDR_DQ,
   inout [`data_strobe_width-1:0]  DDR_DQS,
   inout [`data_strobe_width-1:0]  DDR_DQS_L,
   
   output [`data_mask_width-1:0]   DDR_DM,

   output [`clk_width-1:0]         DDR2_CK,
   output [`clk_width-1:0]         DDR2_CK_N
                     );

   wire [`data_strobe_width-1:0] dqs_idelay_inc;
   wire [`data_strobe_width-1:0] dqs_idelay_ce;
   wire [`data_strobe_width-1:0] dqs_idelay_rst;
   wire [`data_width-1:0]        dq_idelay_inc;
   wire [`data_width-1:0]        dq_idelay_ce;
   wire [`data_width-1:0]        dq_idelay_rst;
   wire [`data_strobe_width-1:0] dqs_delayed;

   wire [`clk_width-1:0]         DDR2_CK_q;


   wire       vcc;
   wire       gnd;

   assign vcc         = 1'b1;
   assign gnd         = 1'b0;


   mem_phy_calib_0 phy_calib_0 (
                       .reset90                      (RESET90),
                       .phy_init_rden                (phy_init_rden),
                       .phy_init_st1_read            (phy_init_st1_read),
                       .phy_init_st2_read            (phy_init_st2_read),
                       .ctrl_rden                    (ctrl_rden),
                       .clk90                        (CLK90),
                       .clk0                         (CLK),
                       .reset0                       (RESET0),
                       .idelay_ctrl_rdy              (idelay_ctrl_rdy),
                       .first_calib_done             (first_calib_done),
                       .second_calib_done            (second_calib_done),
                       .phy_calib_rden               (phy_calib_rden),
                       .capture_data                 ({rd_data_rise, rd_data_fall}),
                       .phy_calib_dq_dlyinc          (dq_idelay_inc),
                       .phy_calib_dq_dlyce           (dq_idelay_ce),
                       .phy_calib_dq_dlyrst          (dq_idelay_rst),
                       .phy_calib_dqs_dlyinc         (dqs_idelay_inc),
                       .phy_calib_dqs_dlyce          (dqs_idelay_ce),
                       .phy_calib_dqs_dlyrst         (dqs_idelay_rst));

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// MEMORY CLOCKS GENERATION
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   genvar CLK_i;
   generate for(CLK_i = 0; CLK_i < `clk_width; CLK_i = CLK_i+1)
   begin: mem_clk_loop

    //  defparam oddr_clkCLK_i.SRTYPE = "SYNC";
   //   defparam oddr_clkCLK_i.DDR_CLK_EDGE = "OPPOSITE_EDGE";

            ODDR #(.SRTYPE("SYNC"),.DDR_CLK_EDGE("OPPOSITE_EDGE"))
        oddr_clkCLK_i (
                      .Q   (DDR2_CK_q[CLK_i]),
                      .C   (CLK),
                      .CE  (vcc),
                      .D1  (gnd),
                      .D2  (vcc),
                      .R   (gnd),
                      .S   (gnd)
                      );



      OBUFDS OBUFDSCLK_i
              (
               .I   (DDR2_CK_q[CLK_i]),
               .O   (DDR2_CK[CLK_i]),
               .OB  (DDR2_CK_N[CLK_i])
               );
   end // block : mem_clk_loop
   endgenerate


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DQS instances
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   genvar dqs_i;
   generate
      for(dqs_i= 0; dqs_i < `data_strobe_width; dqs_i = dqs_i+1)
        begin:dqs_inst
              mem_phy_dqs_iob dqs(
                          .CLK           (CLK),
                          .CLK90         (CLK90),
                          .RESET         (RESET0),
                          .DLYINC        (dqs_idelay_inc[dqs_i]),
                          .DLYCE         (dqs_idelay_ce[dqs_i]),
                          .DLYRST        (dqs_idelay_rst[dqs_i]),
                          .CTRL_DQS_RST  (dqs_rst),
                          .CTRL_DQS_EN   (dqs_en),
                          .DDR_DQS       (DDR_DQS[dqs_i]),
                          .DDR_DQS_L     (DDR_DQS_L[dqs_i]),
                          .DQS_RISE      (dqs_delayed[dqs_i])
                    );

        end // block: dqs_inst
   endgenerate

 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// DM instances
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   genvar dm_i;
   generate
      for(dm_i = 0; dm_i < `data_mask_width; dm_i = dm_i+1)
        begin:dm_inst
           mem_phy_dm_iob dm(
                          .CLK90           (CLK90),
                          .MASK_DATA_RISE  (mask_data_rise[dm_i]),
                          .MASK_DATA_FALL  (mask_data_fall[dm_i]),
                          .DDR_DM          (DDR_DM[dm_i])
                      );

        end // block: dm_inst
   endgenerate


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//DQ_IOB4 instances
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   genvar dq_i;
   generate
      for(dq_i= 0; dq_i < `data_width; dq_i = dq_i+1)
        begin:dq_inst
           mem_phy_dq_iob dq(
                          .CLK              (CLK),
                          .CLK90            (CLK90),
                          .DQS              (dqs_delayed[dq_i/8]),
                          .RESET            (RESET90),
                          .DATA_DLYINC      (dq_idelay_inc[dq_i]),
                          .DATA_DLYCE       (dq_idelay_ce[dq_i]),
                          .DATA_DLYRST      (dq_idelay_rst[dq_i]),
                          .WRITE_DATA_RISE  (wr_data_rise[dq_i]),
                          .WRITE_DATA_FALL  (wr_data_fall[dq_i]),
                          .CTRL_WREN        (wr_en),
                          .DDR_DQ           (DDR_DQ[dq_i]),
                          .READ_DATA_RISE   (rd_data_rise[dq_i]),
                          .READ_DATA_FALL   (rd_data_fall[dq_i])
                       );
        end // block: dq_inst
   endgenerate

endmodule
