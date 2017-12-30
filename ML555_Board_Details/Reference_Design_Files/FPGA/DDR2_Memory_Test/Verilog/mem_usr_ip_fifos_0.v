///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename:mem_usr_ip_fifos_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module instantiates the modules containing internal FIFOs
//                  to store the data and the address.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_usr_ip_fifos_0 (
   input                              clk0,
   input                              clk90,
   input                              rst,
   input                              rst90,

   //waf signals
   input [35:0]                       app_af_addr,
   input                              app_af_WrEn,
   input                              ctrl_af_RdEn,
   input                              phy_init_wdf_rden,
   output [35:0]                      af_addr,
   output                             af_Empty,
   output                             af_Almost_Full,

   //wdf signals
   input [(`dq_width*2)-1:0]          app_Wdf_data,
   input [(`dm_width*2)-1:0]          app_mask_data,

   input                              app_Wdf_WrEn,
   input                              ctrl_Wdf_RdEn,
   output [(`dq_width*2)-1:0]         Wdf_data,
   output [(`dm_width*2)-1:0]         mask_data,

   output                             Wdf_Almost_Full

                         );

   wire [`fifo16-1:0]        wr_df_almost_full_w;

   assign Wdf_Almost_Full   = wr_df_almost_full_w[0];

   mem_usr_ip_addr_fifo_0 rd_wr_addr_fifo_0 (
                         .clk0                     (clk0),
                         .rst                      (rst),
                         .app_af_addr              (app_af_addr),
                         .app_af_WrEn              (app_af_WrEn),
                         .ctrl_af_RdEn             (ctrl_af_RdEn),
                         .af_addr                  (af_addr),
                         .af_Empty                 (af_Empty),
                         .af_Almost_Full           (af_Almost_Full)
                         );

   
mem_usr_ip_wr_fifo_16 wr_data_fifo_160 (
                      .clk0                     (clk0),
                      .clk90                    (clk90),
                      .rst                      (rst),
                      .rst90                    (rst90),
                      .app_Wdf_data             (app_Wdf_data[31:0]),
                      .phy_init_wdf_rden        (phy_init_wdf_rden),
                      .app_mask_data            (app_mask_data[3:0]),
                      .app_Wdf_WrEn             (app_Wdf_WrEn),
                      .ctrl_Wdf_RdEn            (ctrl_Wdf_RdEn),
                      .Wdf_data                 (Wdf_data[31:0]),
                      .mask_data                (mask_data[3:0]),
                      .wr_df_almost_full        (wr_df_almost_full_w[0])
                      );


mem_usr_ip_wr_fifo_16 wr_data_fifo_161 (
                      .clk0                     (clk0),
                      .clk90                    (clk90),
                      .rst                      (rst),
                      .rst90                    (rst90),
                      .app_Wdf_data             (app_Wdf_data[63:32]),
                      .phy_init_wdf_rden        (phy_init_wdf_rden),
                      .app_mask_data            (app_mask_data[7:4]),
                      .app_Wdf_WrEn             (app_Wdf_WrEn),
                      .ctrl_Wdf_RdEn            (ctrl_Wdf_RdEn),
                      .Wdf_data                 (Wdf_data[63:32]),
                      .mask_data                (mask_data[7:4]),
                      .wr_df_almost_full        (wr_df_almost_full_w[1])
                      );


mem_usr_ip_wr_fifo_16 wr_data_fifo_162 (
                      .clk0                     (clk0),
                      .clk90                    (clk90),
                      .rst                      (rst),
                      .rst90                    (rst90),
                      .app_Wdf_data             (app_Wdf_data[95:64]),
                      .phy_init_wdf_rden        (phy_init_wdf_rden),
                      .app_mask_data            (app_mask_data[11:8]),
                      .app_Wdf_WrEn             (app_Wdf_WrEn),
                      .ctrl_Wdf_RdEn            (ctrl_Wdf_RdEn),
                      .Wdf_data                 (Wdf_data[95:64]),
                      .mask_data                (mask_data[11:8]),
                      .wr_df_almost_full        (wr_df_almost_full_w[2])
                      );


mem_usr_ip_wr_fifo_16 wr_data_fifo_163 (
                      .clk0                     (clk0),
                      .clk90                    (clk90),
                      .rst                      (rst),
                      .rst90                    (rst90),
                      .app_Wdf_data             (app_Wdf_data[127:96]),
                      .phy_init_wdf_rden        (phy_init_wdf_rden),
                      .app_mask_data            (app_mask_data[15:12]),
                      .app_Wdf_WrEn             (app_Wdf_WrEn),
                      .ctrl_Wdf_RdEn            (ctrl_Wdf_RdEn),
                      .Wdf_data                 (Wdf_data[127:96]),
                      .mask_data                (mask_data[15:12]),
                      .wr_df_almost_full        (wr_df_almost_full_w[3])
                      );

/* MD  
mem_usr_ip_wr_fifo_8 wr_data_fifo_84 (
                      .clk0                     (clk0),
                      .clk90                    (clk90),
                      .rst                      (rst),
                      .rst90                    (rst90),
                      .app_Wdf_data             (app_Wdf_data[143:128]),
                      .phy_init_wdf_rden        (phy_init_wdf_rden),
                      .app_mask_data            (app_mask_data[17:16]),
                      .app_Wdf_WrEn             (app_Wdf_WrEn),
                      .ctrl_Wdf_RdEn            (ctrl_Wdf_RdEn),
                      .Wdf_data                 (Wdf_data[143:128]),
                      .mask_data                (mask_data[17:16]),
                      .wr_df_almost_full        (wr_df_almost_full_w[4])
                      );

*/
endmodule
