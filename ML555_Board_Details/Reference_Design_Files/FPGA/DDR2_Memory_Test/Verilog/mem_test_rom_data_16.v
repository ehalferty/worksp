///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_test_rom_data_16.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description : This module contains the data generation logic for a 16 bit data.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module mem_test_rom_data_16 (
   input              clk0,
   input              rst,
   input              bkend_data_en,
   input              bkend_rd_data_valid,

   output reg [31:0]  app_Wdf_data,
   output reg [3:0]   app_mask_data,
   output [31:0]      app_compare_data,
   output reg         app_Wdf_WrEn
                          );

   reg [1:0]     wr_state;
   reg [1:0]     rd_state;
   reg [15:0]    wr_data_pattern ;
   reg [15:0]    wr_data_pattern_1 ;
   reg [15:0]    rd_data_pattern ;

   reg           app_Wdf_WrEn_r;
   reg           app_Wdf_WrEn_2r;
   reg           app_Wdf_WrEn_3r;
   reg           bkend_rd_data_valid_r;

   wire [31:0]   app_Wdf_data_r ;
   reg [31:0]    app_Wdf_data_1r ;
   reg [31:0]    app_Wdf_data_2r ;

   wire [3:0]    app_mask_data_r ;
   reg [3:0]     app_mask_data_1r ;
   reg [3:0]     app_mask_data_2r ;

   wire [15:0]   rd_rising_edge_data;
   wire [15:0]   rd_falling_edge_data;
   wire [1:0]    wr_data_mask_fall;
   wire [1:0]    wr_data_mask_rise;

   localparam wr_idle_first_data = 2'b00;
   localparam wr_second_data     = 2'b01;
   localparam wr_third_data      = 2'b10;
   localparam wr_fourth_data     = 2'b11;
   localparam rd_idle_first_data = 2'b00;
   localparam rd_second_data     = 2'b01;
   localparam rd_third_data      = 2'b10;
   localparam rd_fourth_data     = 2'b11;

   assign wr_data_mask_rise = 2'd0;
   assign wr_data_mask_fall = 2'd0;

   // DATA generation for WRITE DATA FIFOs & for READ DATA COMPARE

   // write data generation
   always @ (posedge clk0)
   begin
      if (rst)
      begin
         wr_data_pattern[15:0] <= 16'h0000;
         wr_data_pattern_1[15:0] <= 16'h0000;
         wr_state <= wr_idle_first_data;
      end
      else
      begin
         case (wr_state)
         wr_idle_first_data :  begin
                                  if (bkend_data_en == 1'b1)
                                  begin
                                     wr_data_pattern[15:0] <= 16'hFFFF;
                                     wr_data_pattern_1 <= 16'h0000;
                                     wr_state <= wr_second_data;
                                  end
                                  else
                                     wr_state <= wr_idle_first_data;
                               end

         wr_second_data     :  begin
                                  if (bkend_data_en == 1'b1)
                                  begin
                                     wr_data_pattern[15:0] <= 16'hAAAA;
                                     wr_data_pattern_1 <= 16'h5555;
                                     wr_state <= wr_third_data;
                                  end
                                  else
                                     wr_state <= wr_second_data;
                               end

         wr_third_data      :  begin
                                  if (bkend_data_en == 1'b1)
                                  begin
                                     wr_data_pattern[15:0] <= 16'h5555;
                                     wr_data_pattern_1 <= 16'hAAAA; //2222;//MD changed to 2222 from AAAA to see if any change
                                     wr_state <= wr_fourth_data;
                                  end
                                  else
                                     wr_state <= wr_third_data;
                               end
         wr_fourth_data     :  begin
                                  if (bkend_data_en == 1'b1)
                                  begin
                                     wr_data_pattern[15:0] <= 16'h9999;
                                     wr_data_pattern_1 <= 16'h6666;
                                     wr_state <= wr_idle_first_data;
                                  end
                                  else
                                     wr_state <= wr_fourth_data;
                               end
         endcase
      end
   end

   assign app_Wdf_data_r[31:0] = {wr_data_pattern, wr_data_pattern_1};

   assign app_mask_data_r[3:0] = {wr_data_mask_rise[1:0],wr_data_mask_fall[1:0]} ;

   always @ (posedge clk0)
   begin
      if (rst)
      begin
         app_Wdf_data_1r <= 32'h00000000;
         app_Wdf_data_2r <= 32'h00000000;
         app_Wdf_data    <= 32'h00000000;
      end
      else
      begin
         app_Wdf_data_1r <= app_Wdf_data_r ;
         app_Wdf_data_2r <= app_Wdf_data_1r;
         app_Wdf_data    <= app_Wdf_data_2r;
      end
   end

   always @ (posedge clk0)
   begin
      if (rst)
      begin
         app_mask_data_1r <= 4'h0;
         app_mask_data_2r <= 4'h0;
         app_mask_data    <= 4'h0;
      end
      else
      begin
         app_mask_data_1r <= app_mask_data_r ;
         app_mask_data_2r <= app_mask_data_1r;
         app_mask_data    <= app_mask_data_2r;
      end
   end

   always @ (posedge clk0)
   begin
      if (rst)
      begin
         app_Wdf_WrEn_r <= 1'b0;
         app_Wdf_WrEn_2r <= 1'b0;
         app_Wdf_WrEn_3r <= 1'b0;
         app_Wdf_WrEn <= 1'b0;
      end
      else
      begin
         app_Wdf_WrEn_r <= bkend_data_en;
         app_Wdf_WrEn_2r <= app_Wdf_WrEn_r;
         app_Wdf_WrEn_3r <= app_Wdf_WrEn_2r;
         app_Wdf_WrEn <= app_Wdf_WrEn_3r;
      end
   end

   always @ (posedge clk0)
   begin
      if (rst)
         bkend_rd_data_valid_r <= 1'b0;
      else
         bkend_rd_data_valid_r <= bkend_rd_data_valid;
   end

   // read comparison data generation
   always @ (posedge clk0)
   begin
      if (rst)
      begin
         rd_data_pattern[15:0] <= 16'h0000;
         rd_state <= rd_idle_first_data;
      end
      else
      begin
         case (rd_state)
         rd_idle_first_data :  begin
                                  if (bkend_rd_data_valid)
                                  begin
                                     rd_data_pattern[15:0] <= 16'hFFFF;
                                     rd_state <= rd_second_data;
                                  end
                                  else
                                     rd_state <= rd_idle_first_data;
                               end

         rd_second_data     :  begin
                                  rd_data_pattern[15:0] <= 16'hAAAA;
                                  rd_state <= rd_third_data;
                               end

         rd_third_data      :  begin
                                  if (bkend_rd_data_valid)
                                  begin
                                     rd_data_pattern[15:0] <= 16'h5555;
                                     rd_state <= rd_fourth_data;
                                  end
                                  else
                                     rd_state <= rd_third_data;
                               end
         rd_fourth_data     :  begin
                                  rd_data_pattern[15:0] <= 16'h9999;
                                  rd_state <= rd_idle_first_data;
                               end
         endcase
      end
   end

   assign rd_rising_edge_data[15:0]  = { rd_data_pattern[15:0]};
   assign rd_falling_edge_data[15:0] = { ~rd_data_pattern[15:0]};

   //data to the compare circuit during read
   assign app_compare_data[31:0] = (bkend_rd_data_valid_r) ? {rd_rising_edge_data[15:0], rd_falling_edge_data[15:0]} :
                                     32'h00000000;

endmodule
