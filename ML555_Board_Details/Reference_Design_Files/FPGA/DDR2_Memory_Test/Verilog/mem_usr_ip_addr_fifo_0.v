///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_usr_ip_add_fifo_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module instantiates the block RAM based FIFO to store
//                  the user address and the command information.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_usr_ip_addr_fifo_0 (
   input          clk0,
   input          rst,
   input [35:0]   app_af_addr,
   input          app_af_WrEn,
   input          ctrl_af_RdEn,

   output [35:0]  af_addr,
   output         af_Empty,
   output         af_Almost_Full
                      );

   wire [35:0]    fifo_input_write_addr;
   wire [35:0]    fifo_output_write_addr;

   reg [35:0]     compare_value_r ;
   reg [35:0]     app_af_addr_r   ;
   reg [35:0]     fifo_input_addr_r;
   reg            af_en_r;
   reg            af_en_2r;
   wire           compare_result_row;
   wire           compare_result_bank;

   // [35] -- row conflict;
   // [34] -- bank conflict;
   // [33:32]  -- command to controller
   // [31:0]   --- address

   assign fifo_input_write_addr[35:0] = {compare_result_row, compare_result_bank, app_af_addr_r[33:0]};
   assign af_addr[35:0]               = fifo_output_write_addr;

   assign compare_result_row          = (compare_value_r[`row_address + `column_address:`column_address+1]
                                         == fifo_input_write_addr[`row_address + `column_address:`column_address+1]) ? 1'b0: 1'b1;

   assign compare_result_bank         = (compare_value_r[`bank_range_end:`bank_range_start]
                                         == fifo_input_write_addr[`bank_range_end:`bank_range_start]) ? 1'b0: 1'b1;

   always @(posedge clk0)
   begin
      if(rst)
        begin
           compare_value_r         <= 36'd0;
           app_af_addr_r[35:0]    <= 36'd0;
           fifo_input_addr_r[35:0] <= 36'd0;
           af_en_r              <= 1'b0;
           af_en_2r             <= 1'b0;
        end
      else
        begin
           if(af_en_r)
             compare_value_r<= fifo_input_write_addr;
           app_af_addr_r[35:0]    <= app_af_addr[35:0];
           fifo_input_addr_r[35:0] <= fifo_input_write_addr[35:0];
           af_en_r              <= app_af_WrEn;
           af_en_2r             <= af_en_r;
      end
   end

   defparam af_fifo16.ALMOST_FULL_OFFSET = 12'h00F;
   defparam af_fifo16.ALMOST_EMPTY_OFFSET = 12'h007;
   defparam af_fifo16.DATA_WIDTH = 36;
   defparam af_fifo16.DO_REG = 1;
   defparam af_fifo16.EN_SYN = "FALSE";
   defparam af_fifo16.FIRST_WORD_FALL_THROUGH = "TRUE";

   FIFO36  af_fifo16(
              .ALMOSTEMPTY         (),
              .ALMOSTFULL          (af_Almost_Full),
              .DO                  (fifo_output_write_addr[31:0]),
              .DOP                 (fifo_output_write_addr[35:32]),
              .EMPTY               (af_Empty),
              .FULL                (),
              .RDCOUNT             (),
              .RDERR               (),
              .WRCOUNT             (),
              .WRERR               (),
              .DI                  (fifo_input_addr_r[31:0]),
              .DIP                 (fifo_input_addr_r[35:32]),
              .RDCLK               (clk0),
              .RDEN                (ctrl_af_RdEn),
              .RST                 (rst),
              .WRCLK               (clk0),
              .WREN                (af_en_2r)
             );

endmodule
