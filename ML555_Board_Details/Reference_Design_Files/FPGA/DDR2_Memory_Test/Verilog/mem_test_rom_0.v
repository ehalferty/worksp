///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_test_rom_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module instantiates the addr_gen and the data_gen
//                  modules. It takes the user data stored in internal FIFOs
//                  and gives the data that is to be compared with the read data.
///////////////////////////////////////////////////////////////////////////////

`define wr_idle_first_data 2'b00
`define wr_second_data     2'b01
`define wr_third_data      2'b10
`define wr_fourth_data     2'b11
`define rd_idle_first_data 2'b00
`define rd_second_data     2'b01
`define rd_third_data      2'b10
`define rd_fourth_data     2'b11

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_test_rom_0 (
   input                        clk0,
   input                        rst,

   // enables signals from state machine
   input                        bkend_data_en,
   input                        bkend_wraddr_en,
   input                        bkend_rd_data_valid,

   //Write address fifo signals
   output [35:0]                app_af_addr,
   output                       app_af_WrEn,

   //Write data fifo signals
   output [(`dq_width*2)-1:0]   app_Wdf_data,
   output [(`dm_width*2)-1:0]   app_mask_data,
   output [(`dq_width*2)-1:0]   app_compare_data, // data for the backend compare logic
   output                       app_Wdf_WrEn
                    );

wire [`fifo16-1:0]          app_Wdf_WrEn_w;

wire [31:0]app_Wdf_data3;
wire [31:0]app_Wdf_data2;
wire [31:0]app_Wdf_data1;
wire [31:0]app_Wdf_data0;
wire [15:0]app_Wdf_data4;

wire [3:0]app_mask_data3;
wire [3:0]app_mask_data2;
wire [3:0]app_mask_data1;
wire [3:0]app_mask_data0;
wire [1:0]app_mask_data4;

wire [31:0]app_compare_data3;
wire [31:0]app_compare_data2;
wire [31:0]app_compare_data1;
wire [31:0]app_compare_data0;
wire [15:0]app_compare_data4;

/* MD
assign app_Wdf_data = {app_Wdf_data4[15:8], app_Wdf_data3[31:16],app_Wdf_data2[31:16],app_Wdf_data1[31:16],app_Wdf_data0[31:16] ,
                              app_Wdf_data4[7:0], app_Wdf_data3[15:0],app_Wdf_data2[15:0],app_Wdf_data1[15:0],app_Wdf_data0[15:0]};

assign app_mask_data ={app_mask_data4[1], app_mask_data3[3:2],app_mask_data2[3:2],app_mask_data1[3:2],app_mask_data0[3:2] ,
                                app_mask_data4[0], app_mask_data3[1:0],app_mask_data2[1:0],app_mask_data1[1:0],app_mask_data0[1:0]};

assign app_compare_data = {app_compare_data4[15:8], app_compare_data3[31:16],app_compare_data2[31:16],app_compare_data1[31:16],app_compare_data0[31:16] ,
                              app_compare_data4[7:0], app_compare_data3[15:0],app_compare_data2[15:0],app_compare_data1[15:0],app_compare_data0[15:0]};

*/

assign app_Wdf_data = {app_Wdf_data3[31:16],app_Wdf_data2[31:16],app_Wdf_data1[31:16],app_Wdf_data0[31:16] ,
                              app_Wdf_data3[15:0],app_Wdf_data2[15:0],app_Wdf_data1[15:0],app_Wdf_data0[15:0]};

assign app_mask_data ={app_mask_data3[3:2],app_mask_data2[3:2],app_mask_data1[3:2],app_mask_data0[3:2] ,
                                app_mask_data3[1:0],app_mask_data2[1:0],app_mask_data1[1:0],app_mask_data0[1:0]};

assign app_compare_data = {app_compare_data3[31:16],app_compare_data2[31:16],app_compare_data1[31:16],app_compare_data0[31:16] ,
                              app_compare_data3[15:0],app_compare_data2[15:0],app_compare_data1[15:0],app_compare_data0[15:0]};



assign app_Wdf_WrEn = app_Wdf_WrEn_w[`fifo16-1];

mem_test_rom_addr_0 addr_gen_0(
                      .clk0                     (clk0),
                      .rst                      (rst),
                      .bkend_wraddr_en          (bkend_wraddr_en),
                      .app_af_addr              (app_af_addr),
                      .app_af_WrEn              (app_af_WrEn)
                    );


mem_test_rom_data_16 data_gen_16_0(
                      .clk0                     (clk0),
                      .rst                      (rst),
                      .bkend_data_en            (bkend_data_en),
                      .bkend_rd_data_valid      (bkend_rd_data_valid),
                      .app_Wdf_data             (app_Wdf_data0[31:0]),
                      .app_mask_data            (app_mask_data0[3:0]),
                      .app_compare_data         (app_compare_data0[31:0]),
                      .app_Wdf_WrEn             (app_Wdf_WrEn_w[0])
                    );



mem_test_rom_data_16 data_gen_16_1(
                      .clk0                     (clk0),
                      .rst                      (rst),
                      .bkend_data_en            (bkend_data_en),
                      .bkend_rd_data_valid      (bkend_rd_data_valid),
                      .app_Wdf_data             (app_Wdf_data1[31:0]),
                      .app_mask_data            (app_mask_data1[3:0]),
                      .app_compare_data         (app_compare_data1[31:0]),
                      .app_Wdf_WrEn             (app_Wdf_WrEn_w[1])
                    );



mem_test_rom_data_16 data_gen_16_2(
                      .clk0                     (clk0),
                      .rst                      (rst),
                      .bkend_data_en            (bkend_data_en),
                      .bkend_rd_data_valid      (bkend_rd_data_valid),
                      .app_Wdf_data             (app_Wdf_data2[31:0]),
                      .app_mask_data            (app_mask_data2[3:0]),
                      .app_compare_data         (app_compare_data2[31:0]),
                      .app_Wdf_WrEn             (app_Wdf_WrEn_w[2])
                    );



mem_test_rom_data_16 data_gen_16_3(
                      .clk0                     (clk0),
                      .rst                      (rst),
                      .bkend_data_en            (bkend_data_en),
                      .bkend_rd_data_valid      (bkend_rd_data_valid),
                      .app_Wdf_data             (app_Wdf_data3[31:0]),
                      .app_mask_data            (app_mask_data3[3:0]),
                      .app_compare_data         (app_compare_data3[31:0]),
                      .app_Wdf_WrEn             (app_Wdf_WrEn_w[3])
                    );

/* MD

mem_test_rom_data_8 data_gen_8_4(
                      .clk0                     (clk0),
                      .rst                      (rst),
                      .bkend_data_en            (bkend_data_en),
                      .bkend_rd_data_valid      (bkend_rd_data_valid),
                      .app_Wdf_data             (app_Wdf_data4[15:0]),
                      .app_mask_data            (app_mask_data4[1:0]),
                      .app_compare_data         (app_compare_data4[15:0]),
                      .app_Wdf_WrEn             (app_Wdf_WrEn_w[4])
                    );

*/
endmodule
