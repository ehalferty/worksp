///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_top_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     :
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_top_0(
   input                             clk_0,
   input                             clk_90,
   input                             clk_200,
   input                             sys_rst,
   input                             sys_rst90,
   input                             idelay_ctrl_rdy,
   input [35:0]                      APP_AF_ADDR,
   input                             APP_AF_WREN,
   input [(`data_width*2)-1:0]       APP_WDF_DATA,
   input [(`data_mask_width*2)-1:0]  APP_MASK_DATA,
   input                             APP_WDF_WREN,

   inout [`data_width-1:0]           DDR2_DQ,
   inout [`data_strobe_width-1:0]    DDR2_DQS,
   inout [`data_strobe_width-1:0]    DDR2_DQS_N,

   output                            DDR2_RAS_N,
   output                            DDR2_CAS_N,
   output                            DDR2_WE_N,
   output [`odt_width-1:0]           DDR2_ODT,
   output [`cke_width-1:0]           DDR2_CKE,
   output [`cs_width-1:0]            DDR2_CS_N,
   
   output [`data_mask_width-1:0]     DDR2_DM,

   
   output                            DDR2_RESET_N,

   output [`bank_address-1:0]        DDR2_BA,
   output [`row_address-1:0]         DDR2_A,
   output                            phy_init_initialization_done,
   output                            WDF_ALMOST_FULL,
   output                            AF_ALMOST_FULL,
   output [2:0]                      BURST_LENGTH,
   output                            READ_DATA_VALID,
   output [(`data_width*2)-1:0]      READ_DATA_FIFO_OUT,
   output [`clk_width-1:0]           DDR2_CK,
   output [`clk_width-1:0]           DDR2_CK_N
   );

   wire [(`data_width*2)-1:0]        wr_df_data;
   wire [(`data_mask_width*2)-1:0]   mask_df_data;
   wire [`data_width-1:0]            rd_data_rise;
   wire [`data_width-1:0]            rd_data_fall;

   wire          af_empty_w;

   wire [35:0]   af_addr;
   wire          ctrl_af_rden;
   wire          ctrl_wr_df_rden;
   wire          ctrl_dqs_enable;
   wire          ctrl_dqs_reset;
   wire          ctrl_wr_en;
   wire          ctrl_rden;

   wire wr_en;
   wire dqs_rst;
   wire dqs_en;

   wire [`data_width-1:0]         wr_data_rise;
   wire [`data_width-1:0]         wr_data_fall;
   wire [`data_mask_width-1:0]    mask_data_fall;
   wire [`data_mask_width-1:0]    mask_data_rise;
   wire [`row_address-1:0]        ctrl_address;
   wire [`bank_address-1:0]       ctrl_ba;
   wire                           ctrl_ras_n;
   wire                           ctrl_cas_n;
   wire                           ctrl_we_n;
   wire [`cs_width-1:0]           ctrl_cs_n;
   wire [`odt_width-1:0]          ctrl_odt;
   wire [`data_strobe_width-1:0]  phy_calib_rden;

   wire ctrl_ref_flag;

   wire phy_init_initialization_done_w;
   wire phy_init_wdf_rden;

   
   assign    DDR2_RESET_N = ~sys_rst;

   assign phy_init_initialization_done = phy_init_initialization_done_w;

   mem_phy_0    phy_0
                   (/*AUTO-INST*/

                      .CLK                           (clk_0),
                      .CLK90                         (clk_90),

                      .rd_data_rise                  (rd_data_rise),
                      .rd_data_fall                  (rd_data_fall),
                      .phy_init_wdf_rden             (phy_init_wdf_rden),
                      .DDR_DQ                        (DDR2_DQ),
                      .DDR_DQS                       (DDR2_DQS),
                      .DDR_DQS_L                     (DDR2_DQS_N),
                      
                      .DDR_DM                        (DDR2_DM),

                      .DDR2_CK                       (DDR2_CK),
                      .DDR2_CK_N                     (DDR2_CK_N),

                      .idelay_ctrl_rdy               (idelay_ctrl_rdy),
                      .ctrl_address                  (ctrl_address),
                      .ctrl_ba                       (ctrl_ba),
                      .ctrl_ras_n                    (ctrl_ras_n),
                      .ctrl_cas_n                    (ctrl_cas_n),
                      .ctrl_we_n                     (ctrl_we_n),
                      .ctrl_cs_n                     (ctrl_cs_n),
                      .ctrl_odt                      (ctrl_odt),
                      .DDR_ADDRESS                   (DDR2_A),
                      .DDR_BA                        (DDR2_BA),
                      .DDR_RAS_L                     (DDR2_RAS_N),
                      .DDR_CAS_L                     (DDR2_CAS_N),
                      .DDR_WE_L                      (DDR2_WE_N),
                      .DDR_CKE                       (DDR2_CKE),
                      .DDR_ODT                       (DDR2_ODT),
                      .ddr_cs_L                      (DDR2_CS_N),
                      .ctrl_rden                     (ctrl_rden),
                      .phy_calib_rden                (phy_calib_rden),
                      .phy_init_initialization_done  (phy_init_initialization_done_w),

                      .RESET0                        (sys_rst),
                      .RESET90                       (sys_rst90),
                      .RESET_CAL_CLK                 (sys_rst),
                      .WDF_DATA                      (wr_df_data),
                      .MASK_DATA                     (mask_df_data),
                      .ctrl_wren                     (ctrl_wr_en),
                      .ctrl_dqs_rst                  (ctrl_dqs_reset),
                      .ctrl_dqs_en                   (ctrl_dqs_enable),
                      .dqs_rst                       (dqs_rst),
                      .dqs_en                        (dqs_en),
                      .wr_en                         (wr_en),
                      .ctrl_ref_flag                 (ctrl_ref_flag),
                      .wr_data_rise                  (wr_data_rise),
                      .wr_data_fall                  (wr_data_fall),
                      .mask_data_rise                (mask_data_rise),
                      .mask_data_fall                (mask_data_fall)

                        );

    mem_usr_0   user_interface_0 (
                      .CLK                           (clk_0),
                      .clk90                         (clk_90),
                      .RESET                         (sys_rst),
                      .RESET90                       (sys_rst90),
                      .phy_init_wdf_rden             (phy_init_wdf_rden),
                      .READ_DATA_RISE                (rd_data_rise),
                      .READ_DATA_FALL                (rd_data_fall),
                      .CTRL_RDEN                     (phy_calib_rden),
                      .READ_DATA_FIFO_OUT            (READ_DATA_FIFO_OUT),
                      .READ_DATA_VALID               (READ_DATA_VALID),
                      .AF_EMPTY                      (af_empty_w),
                      .AF_ALMOST_FULL                (AF_ALMOST_FULL),
                      .APP_AF_ADDR                   (APP_AF_ADDR),
                      .APP_AF_WREN                   (APP_AF_WREN),
                      .CTRL_AF_RDEN                  (ctrl_af_rden),
                      .AF_ADDR                       (af_addr),
                      .APP_WDF_DATA                  (APP_WDF_DATA),
                      .APP_MASK_DATA                 (APP_MASK_DATA),
                      .APP_WDF_WREN                  (APP_WDF_WREN),
                      .CTRL_WDF_RDEN                 (ctrl_wr_df_rden),
                      .WDF_DATA                      (wr_df_data),
                      .MASK_DATA                     (mask_df_data),
                      .WDF_ALMOST_FULL               (WDF_ALMOST_FULL)
                                   );

     mem_ctrl_0    ctrl_0 (
                      .clk0                          (clk_0),
                      .rst                           (sys_rst),
                      .burst_length                  (BURST_LENGTH),
                      .af_addr                       (af_addr),
                      .af_empty                      (af_empty_w),
                      .phy_init_initialization_done  (phy_init_initialization_done_w),
                      .ctrl_af_rden                  (ctrl_af_rden),
                      .ctrl_wdf_rden                 (ctrl_wr_df_rden),
                      .ctrl_dqs_rst                  (ctrl_dqs_reset),
                      .ctrl_dqs_en                   (ctrl_dqs_enable),
                      .ctrl_wren                     (ctrl_wr_en),
                      .ctrl_rden                     (ctrl_rden),
                      .ctrl_address                  (ctrl_address),
                      .ctrl_ba                       (ctrl_ba),
                      .ctrl_ras_n                    (ctrl_ras_n),
                      .ctrl_cas_n                    (ctrl_cas_n),
                      .ctrl_we_n                     (ctrl_we_n),
                      .ctrl_cs_n                     (ctrl_cs_n),
                      .ctrl_odt                      (ctrl_odt),
                      .ctrl_ref_flag                 (ctrl_ref_flag)
                                       );

endmodule


