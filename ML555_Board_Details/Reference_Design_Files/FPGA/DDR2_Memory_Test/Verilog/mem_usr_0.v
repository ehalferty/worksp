///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_usr_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module interfaces with the user. The user should
//                  provide the data and various commands.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_usr_0 (
   input                              CLK,
   input                              clk90,
   input                              RESET,
   input                              RESET90,

   input [`data_width-1:0]            READ_DATA_RISE,
   input [`data_width-1:0]            READ_DATA_FALL,
   input [`data_strobe_width-1:0]     CTRL_RDEN,
   input                              phy_init_wdf_rden,
   output                             READ_DATA_VALID,
   output [(`data_width*2)-1:0]       READ_DATA_FIFO_OUT,

   input [35:0]                       APP_AF_ADDR,
   input                              APP_AF_WREN,
   input                              CTRL_AF_RDEN,
   output [35:0]                      AF_ADDR,
   output                             AF_EMPTY,
   output                             AF_ALMOST_FULL,
   input [(`data_width*2)-1:0]        APP_WDF_DATA,
   input [(`data_mask_width*2)-1:0]   APP_MASK_DATA,

   input                              APP_WDF_WREN,
   input                              CTRL_WDF_RDEN,
   output [(`data_width*2)-1:0]       WDF_DATA,
   output [(`data_mask_width*2)-1:0]  MASK_DATA,

   output                             WDF_ALMOST_FULL

                       );

   wire [`data_width-1:0]  read_data_fifo_rise_i;
   wire [`data_width-1:0]  read_data_fifo_fall_i;

   assign READ_DATA_FIFO_OUT  =  {read_data_fifo_rise_i ,  read_data_fifo_fall_i};

   mem_usr_rd_0 rd_data_0 (
                                 .CLK                   (clk90),
                                 .RESET                 (RESET90),
                                 .CTRL_RDEN             (CTRL_RDEN),
                                 .READ_DATA_RISE        (READ_DATA_RISE),
                                 .READ_DATA_FALL        (READ_DATA_FALL),
                                 .READ_DATA_FIFO_RISE   (read_data_fifo_rise_i),
                                 .READ_DATA_FIFO_FALL   (read_data_fifo_fall_i),
                                 .READ_DATA_VALID       (READ_DATA_VALID)
                               );

   mem_usr_ip_fifos_0 backend_fifos_0 (
                                 .clk0                  (CLK),
                                 .clk90                 (clk90),
                                 .rst                   (RESET),
                                 .rst90                 (RESET90),
                                 .app_af_addr           (APP_AF_ADDR),
                                 .app_af_WrEn           (APP_AF_WREN),
                                 .ctrl_af_RdEn          (CTRL_AF_RDEN),
                                 .phy_init_wdf_rden     (phy_init_wdf_rden),
                                 .af_addr               (AF_ADDR),
                                 .af_Empty              (AF_EMPTY),
                                 .af_Almost_Full        (AF_ALMOST_FULL),
                                 .app_Wdf_data          (APP_WDF_DATA),
                                 .app_mask_data         (APP_MASK_DATA),
                                 .app_Wdf_WrEn          (APP_WDF_WREN),
                                 .ctrl_Wdf_RdEn         (CTRL_WDF_RDEN),
                                 .Wdf_data              (WDF_DATA),
                                 .mask_data             (MASK_DATA),
                                 .Wdf_Almost_Full       (WDF_ALMOST_FULL)
                                 );


endmodule
