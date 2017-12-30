///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_phy_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     :
//
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_phy_0 (
   input                             CLK,
   input                             CLK90,
   input                             RESET0,
   input                             RESET90,
   input                             RESET_CAL_CLK,
   input [(`data_width*2)-1:0]       WDF_DATA,
   input [(`data_mask_width*2)-1:0]  MASK_DATA,
   input                             ctrl_wren,
   input                             ctrl_dqs_rst,
   input                             ctrl_dqs_en,
   input                             idelay_ctrl_rdy,
   input [`row_address-1  :0]        ctrl_address,
   input [`bank_address-1 :0]        ctrl_ba,
   input                             ctrl_ras_n,
   input                             ctrl_cas_n,
   input                             ctrl_we_n,
   input [`cs_width-1:0]             ctrl_cs_n,
   input [`odt_width-1:0]            ctrl_odt,
   input                             ctrl_rden,
   input                             ctrl_ref_flag,

   inout [`data_width-1:0]           DDR_DQ,
   inout [`data_strobe_width-1:0]    DDR_DQS,
   inout [`data_strobe_width-1:0]    DDR_DQS_L,

   output                            phy_init_wdf_rden,
   output                            dqs_rst,
   output                            dqs_en,
   output                            wr_en,
   output [`data_width-1:0]          wr_data_rise,
   output [`data_width-1:0]          wr_data_fall,

   output [`data_mask_width-1:0]     mask_data_rise,
   output [`data_mask_width-1:0]     mask_data_fall,
   output [`data_width-1:0]          rd_data_rise,
   output [`data_width-1:0]          rd_data_fall,
   
   output [`data_mask_width-1:0]     DDR_DM,

   output [`row_address-1  :0]       DDR_ADDRESS,
   output [`bank_address-1 :0]       DDR_BA,
   output                            DDR_RAS_L,
   output                            DDR_CAS_L,
   output                            DDR_WE_L,
   output [`cke_width-1:0]           DDR_CKE,
   output [`odt_width-1:0]           DDR_ODT,
   output [`cs_width-1:0]            ddr_cs_L,
   output                            phy_init_initialization_done,
   output [`data_strobe_width-1:0]   phy_calib_rden,
   output [`clk_width-1:0]           DDR2_CK,
   output [`clk_width-1:0]           DDR2_CK_N
   );

   wire                         phy_init_dqs_rst;
   wire                         phy_init_dqs_en;
   wire                         phy_init_wren;
   wire                         phy_init_rden;
   wire [`row_address-1:0]      phy_init_address;
   wire [`bank_address-1:0]     phy_init_ba;
   wire                         phy_init_ras_n;
   wire                         phy_init_cas_n;
   wire                         phy_init_we_n;
   wire [`cs_width-1:0]         phy_init_cs_n;
   wire [`cke_width-1:0]        phy_init_cke;
   wire [`odt_width-1:0]        phy_init_odt;
   wire                         phy_init_st1_read;
   wire                         phy_init_st2_read;
   wire                         phy_init_initialization_done_w;
   wire                         first_calib_done;
   wire                         second_calib_done;

   assign phy_init_initialization_done = phy_init_initialization_done_w;

   mem_phy_write_0  data_write_0
                   (
                     .CLK                          (CLK),
                     .CLK90                        (CLK90),
                     .RESET0                       (RESET0),
                     .RESET90                      (RESET90),
                     .WDF_DATA                     (WDF_DATA),
                     .MASK_DATA                    (MASK_DATA),
                     .ctrl_wren                    (ctrl_wren),
                     .ctrl_dqs_rst                 (ctrl_dqs_rst),
                     .ctrl_dqs_en                  (ctrl_dqs_en),
                     .dqs_rst                      (dqs_rst),
                     .dqs_en                       (dqs_en),

                     .phy_init_dqs_rst             (phy_init_dqs_rst),
                     .phy_init_dqs_en              (phy_init_dqs_en),
                     .phy_init_wren                (phy_init_wren),
                     .phy_init_initialization_done (phy_init_initialization_done_w),
                     .wr_en                        (wr_en),
                     .wr_data_rise                 (wr_data_rise),
                     .wr_data_fall                 (wr_data_fall),
                     .mask_data_rise               (mask_data_rise),
                     .mask_data_fall               (mask_data_fall)

                     );

   mem_phy_io_0 data_path_iobs_0(
                     .CLK                          (CLK),
                     .CLK90                        (CLK90),
                     .RESET0                       (RESET0),
                     .RESET90                      (RESET90),
                     .idelay_ctrl_rdy              (idelay_ctrl_rdy),

                     .phy_init_rden                (phy_init_rden),
                     .phy_init_initialization_done (phy_init_initialization_done_w),
                     .phy_init_st1_read            (phy_init_st1_read),
                     .phy_init_st2_read            (phy_init_st2_read),

                     .dqs_rst                      (dqs_rst),
                     .dqs_en                       (dqs_en),
                     .first_calib_done             (first_calib_done),
                     .second_calib_done            (second_calib_done),
                     .phy_calib_rden               (phy_calib_rden),
                     .ctrl_rden                    (ctrl_rden),

                     .wr_data_rise                 (wr_data_rise),
                     .wr_data_fall                 (wr_data_fall),
                     .wr_en                        (wr_en),
                     .rd_data_rise                 (rd_data_rise),
                     .rd_data_fall                 (rd_data_fall),
                     .mask_data_rise               (mask_data_rise),
                     .mask_data_fall               (mask_data_fall),
                     .DDR_DQ                       (DDR_DQ),
                     .DDR_DQS                      (DDR_DQS),
                     .DDR_DQS_L                    (DDR_DQS_L),
                     
                     .DDR_DM                       (DDR_DM),

                     .DDR2_CK                      (DDR2_CK),
                     .DDR2_CK_N                    (DDR2_CK_N)

                     );

   mem_phy_ctl_io_0 controller_iobs_0(
                     .clk                          (CLK),
                     .rst                          (RESET0),
                     .ctrl_address                 (ctrl_address),
                     .ctrl_ba                      (ctrl_ba),
                     .ctrl_ras_n                   (ctrl_ras_n),
                     .ctrl_cas_n                   (ctrl_cas_n),
                     .ctrl_we_n                    (ctrl_we_n),
                     .ctrl_cs_n                    (ctrl_cs_n),
                     .ctrl_odt                     (ctrl_odt),
                     .phy_init_address             (phy_init_address),
                     .phy_init_ba                  (phy_init_ba),
                     .phy_init_ras_n               (phy_init_ras_n),
                     .phy_init_cas_n               (phy_init_cas_n),
                     .phy_init_we_n                (phy_init_we_n),
                     .phy_init_cs_n                (phy_init_cs_n),
                     .phy_init_cke                 (phy_init_cke),
                     .phy_init_odt                 (phy_init_odt),
                     .phy_init_initialization_done (phy_init_initialization_done_w),

                     .DDR_ADDRESS                  (DDR_ADDRESS),
                     .DDR_BA                       (DDR_BA),
                     .DDR_RAS_L                    (DDR_RAS_L),
                     .DDR_CAS_L                    (DDR_CAS_L),
                     .DDR_WE_L                     (DDR_WE_L),
                     .DDR_CKE                      (DDR_CKE),
                     .DDR_ODT                      (DDR_ODT),
                     .DDR_CS_L                     (ddr_cs_L)
                   );

   mem_phy_init_0  phy_init_0(
                     .clk0                         (CLK),
                     .rst                          (RESET0),
                     .first_calib_done             (first_calib_done),
                     .second_calib_done            (second_calib_done),
                     .ctrl_ref_flag                (ctrl_ref_flag),
                     .phy_init_dqs_rst             (phy_init_dqs_rst),
                     .phy_init_odt                 (phy_init_odt),
                     .phy_init_wdf_rden            (phy_init_wdf_rden),
                     .phy_init_dqs_en              (phy_init_dqs_en),
                     .phy_init_wren                (phy_init_wren),
                     .phy_init_rden                (phy_init_rden),
                     .phy_init_address             (phy_init_address),
                     .phy_init_ba                  (phy_init_ba),
                     .phy_init_ras_n               (phy_init_ras_n),
                     .phy_init_cas_n               (phy_init_cas_n),
                     .phy_init_we_n                (phy_init_we_n),
                     .phy_init_cs_n                (phy_init_cs_n),
                     .phy_init_cke                 (phy_init_cke),
                     .phy_init_st1_read            (phy_init_st1_read),
                     .phy_init_st2_read            (phy_init_st2_read),
                     .phy_init_initialization_done (phy_init_initialization_done_w));


endmodule
