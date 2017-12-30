///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_phy_write_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module splits the user data into the rise data
//                  and the fall data.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_phy_write_0 (
   input                             CLK,
   input                             CLK90,
   input                             RESET0,
   input                             RESET90,
   input [(`dq_width*2)-1:0]         WDF_DATA,
   input [(`dm_width*2)-1:0]         MASK_DATA,
   input                             ctrl_wren,
   input                             ctrl_dqs_rst,
   input                             ctrl_dqs_en,
   input                             phy_init_dqs_rst,
   input                             phy_init_dqs_en,
   input                             phy_init_wren,
   input                             phy_init_initialization_done,

   output                            dqs_rst,
   output                            dqs_en,
   output                            wr_en,
   output [`dq_width-1:0]            wr_data_rise,
   output [`dq_width-1:0]            wr_data_fall,
   output [`data_mask_width-1:0]     mask_data_rise,
   output [`data_mask_width-1:0]     mask_data_fall

                     );

   reg                    wr_en_clk270_r1;

   reg                    wr_en_clk90_r3;

   reg                    dqs_rst_r1;
   reg                    dqs_rst_r2;

   reg                    dqs_en_r1;
   reg                    dqs_en_r2;
   reg                    dqs_en_r3;

   wire   [3:0]           CAS_LATENCY_VALUE;
   wire   [3:0]           ADDITIVE_LATENCY_VALUE;
   wire                   REGISTERED_VALUE;
   wire                   ECC_VALUE;

   reg [11:3]              dqs_en_stages_r;
   reg [11:3]              dqs_rst_stages_r;
   reg [11:3]              wr_en_stages_r;

   wire [14:0] load_mode_reg;

   wire [14:0] ext_mode_reg;

   reg phy_init_initialization_done_270;
   reg phy_init_initialization_done_90;

   assign  dqs_rst = dqs_rst_r2;
   assign  dqs_en  = dqs_en_r3;
   assign  wr_en   = wr_en_clk90_r3;

   assign    load_mode_reg        = `load_mode_register;
   assign    ext_mode_reg         = `ext_load_mode_register;

   assign    REGISTERED_VALUE       = `registered;
   assign    CAS_LATENCY_VALUE      = {1'd0,load_mode_reg[6:4]};
   assign    ADDITIVE_LATENCY_VALUE = {1'd0, ext_mode_reg[5:3]};
   assign    ECC_VALUE              = `ecc_enable;

   always @(posedge CLK)
   begin
      if(RESET0)
      begin
         dqs_en_stages_r  <= 9'd0;
         dqs_rst_stages_r <= 9'd0;
         wr_en_stages_r   <= 9'd0;
      end
      else
      begin
         dqs_en_stages_r[3] <= ctrl_dqs_en | phy_init_dqs_en;
         dqs_en_stages_r[4] <= dqs_en_stages_r[3];
         dqs_en_stages_r[5] <= dqs_en_stages_r[4];
         dqs_en_stages_r[6] <= dqs_en_stages_r[5];
         dqs_en_stages_r[7] <= dqs_en_stages_r[6];
         dqs_en_stages_r[8] <= dqs_en_stages_r[7];
         dqs_en_stages_r[9] <= dqs_en_stages_r[8];
         dqs_en_stages_r[10] <= dqs_en_stages_r[9];
         dqs_en_stages_r[11] <= dqs_en_stages_r[10];
         dqs_rst_stages_r[3] <= ctrl_dqs_rst | phy_init_dqs_rst;
         dqs_rst_stages_r[4] <= dqs_rst_stages_r[3];
         dqs_rst_stages_r[5] <= dqs_rst_stages_r[4];
         dqs_rst_stages_r[6] <= dqs_rst_stages_r[5];
         dqs_rst_stages_r[7] <= dqs_rst_stages_r[6];
         dqs_rst_stages_r[8] <= dqs_rst_stages_r[7];
         dqs_rst_stages_r[9] <= dqs_rst_stages_r[8];
         dqs_rst_stages_r[10] <= dqs_rst_stages_r[9];
         dqs_rst_stages_r[11] <= dqs_rst_stages_r[10];
         wr_en_stages_r[3] <= ctrl_wren | phy_init_wren;
         wr_en_stages_r[4] <= wr_en_stages_r[3];
         wr_en_stages_r[5] <= wr_en_stages_r[4];
         wr_en_stages_r[6] <= wr_en_stages_r[5];
         wr_en_stages_r[7] <= wr_en_stages_r[6];
         wr_en_stages_r[8] <= wr_en_stages_r[7];
         wr_en_stages_r[9] <= wr_en_stages_r[8];
         wr_en_stages_r[10] <= wr_en_stages_r[9];
         wr_en_stages_r[11] <= wr_en_stages_r[10];
      end // else: !if(RESET0)
   end // always@ (posedge CLK)

   always @ (negedge CLK90)
   begin
      if (RESET0 == 1'b1)
      begin
         wr_en_clk270_r1 <= 1'b0;
         dqs_rst_r1      <= 1'b0;
         dqs_en_r1       <= 1'b0;
	 phy_init_initialization_done_270 <= 1'b0;
      end
      else
      begin
         wr_en_clk270_r1  <= wr_en_stages_r[ADDITIVE_LATENCY_VALUE + CAS_LATENCY_VALUE  + REGISTERED_VALUE  + ECC_VALUE];
         dqs_rst_r1       <= dqs_rst_stages_r[ADDITIVE_LATENCY_VALUE + CAS_LATENCY_VALUE  + REGISTERED_VALUE  + ECC_VALUE];
         dqs_en_r1        <= ~dqs_en_stages_r[ADDITIVE_LATENCY_VALUE + CAS_LATENCY_VALUE  + REGISTERED_VALUE  + ECC_VALUE];
         phy_init_initialization_done_270 <= phy_init_initialization_done;
      end // else: !if(RESET0 == 1'b1)
   end // always @ (negedge CLK90)

   always @ (negedge CLK)
   begin
      if (RESET0 == 1'b1)
      begin
         dqs_rst_r2        <= 1'b0;
         dqs_en_r2         <= 1'b0;
         dqs_en_r3         <= 1'b0;
      end
      else
      begin
         dqs_rst_r2        <= dqs_rst_r1;
         dqs_en_r2         <= dqs_en_r1;
         dqs_en_r3         <= dqs_en_r2;
      end // else: !if(RESET0 == 1'b1)
   end // always @ (negedge CLK)

   always @ (posedge CLK90)
   begin
      if (RESET90 == 1'b1)
      begin
         wr_en_clk90_r3      <= 1'b0;
         phy_init_initialization_done_90 <= 1'b0;
      end
      else
      begin
         wr_en_clk90_r3      <= wr_en_clk270_r1;
	 phy_init_initialization_done_90 <= phy_init_initialization_done_270;
      end // else: !if(RESET90 == 1'b1)
   end // always @ (posedge CLK90)

   assign wr_data_rise = WDF_DATA[(`dq_width*2)-1:`dq_width];
   assign wr_data_fall = WDF_DATA[`dq_width-1:0];

   assign mask_data_rise = ((wr_en_clk90_r3 == 1'b0) | (~phy_init_initialization_done_90)) ? `dm_width'b0 : MASK_DATA[(`dm_width*2)-1:`dm_width];
   assign mask_data_fall = ((wr_en_clk90_r3 == 1'b0) | (~phy_init_initialization_done_90)) ? `dm_width'b0 : MASK_DATA[`dm_width-1:0];

//   assign mask_data_rise = MASK_DATA[(`dm_width*2)-1:`dm_width];
//   assign mask_data_fall = MASK_DATA[`dm_width-1:0];

endmodule // mem_phy_write
