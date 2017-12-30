///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename:mem.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module is the top most module which interfaces with  
//                  the system and the memory.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module mem(
//MD inout  [71:0]  cntrl0_DDR2_DQ,
inout  [63:0]  cntrl0_DDR2_DQ,

output  [13:0]  cntrl0_DDR2_A,
output  [1:0]  cntrl0_DDR2_BA,
output  cntrl0_DDR2_RAS_N,
output  cntrl0_DDR2_CAS_N,
output  cntrl0_DDR2_WE_N,
output  cntrl0_DDR2_RESET_N,
output  [0:0]  cntrl0_DDR2_CS_N,
output  [0:0]  cntrl0_DDR2_ODT,
output  [0:0]  cntrl0_DDR2_CKE,
//MD output  [8:0]  cntrl0_DDR2_DM,
output  [7:0]  cntrl0_DDR2_DM,


input  SYS_CLK_P,
input  SYS_CLK_N,
input  CLK200_P,
input  CLK200_N,
input  SYS_RESET_IN,
output  cntrl0_ERROR,
output  cntrl0_ERROR_REG,
output  cntrl0_CALIBRATE,
//MD inout  [8:0]  cntrl0_DDR2_DQS,
//MD inout  [8:0]  cntrl0_DDR2_DQS_N,
inout  [7:0]  cntrl0_DDR2_DQS,
inout  [7:0]  cntrl0_DDR2_DQS_N,
output  [1:0]  cntrl0_DDR2_CK,
output  [1:0]  cntrl0_DDR2_CK_N
);


wire  sys_rst ;
wire  sys_rst90 ;
wire  sys_rst200 ;
wire  idelay_ctrl_rdy ;
wire  clk_0 ;
wire  clk_90 ;
wire  clk_200 ;
wire  cntrl0_phy_init_initialization_done ;
wire  cntrl0_WDF_ALMOST_FULL ;
wire  cntrl0_AF_ALMOST_FULL ;
wire  cntrl0_READ_DATA_VALID ;
wire  cntrl0_APP_WDF_WREN ;
wire  cntrl0_APP_AF_WREN ;
wire  [2:0]  cntrl0_BURST_LENGTH ;
wire  [35:0]  cntrl0_APP_AF_ADDR ;
//MD wire  [143:0]  cntrl0_READ_DATA_FIFO_OUT ;
//MD wire  [143:0]  cntrl0_APP_WDF_DATA ;
//MD wire  [17:0]  cntrl0_APP_MASK_DATA ;
wire  [127:0]  cntrl0_READ_DATA_FIFO_OUT ;
wire  [127:0]  cntrl0_APP_WDF_DATA ;
wire  [15:0]  cntrl0_APP_MASK_DATA ;



assign cntrl0_CALIBRATE = cntrl0_READ_DATA_VALID; //no inversion so LED on until data is being checked

mem_idelay_ctrl  mem_idelay_ctrl(
.sys_rst200(sys_rst200),
.idelay_ctrl_rdy(idelay_ctrl_rdy),
.clk_200(clk_200)
);

mem_infrastructure  mem_infrastructure(
.SYS_CLK_P(SYS_CLK_P),
.SYS_CLK_N(SYS_CLK_N),
.CLK200_P(CLK200_P),
.CLK200_N(CLK200_N),
.SYS_RESET_IN(SYS_RESET_IN),
.sys_rst(sys_rst),
.sys_rst90(sys_rst90),
.sys_rst200(sys_rst200),
.clk_0(clk_0),
.clk_90(clk_90),
.clk_200(clk_200)
);

mem_test_bench_0  mem_test_bench_0(
.ERROR(cntrl0_ERROR),
.ERROR_REG(cntrl0_ERROR_REG),
.sys_rst(sys_rst),
.clk_0(clk_0),
.phy_init_initialization_done(cntrl0_phy_init_initialization_done),
.WDF_ALMOST_FULL(cntrl0_WDF_ALMOST_FULL),
.AF_ALMOST_FULL(cntrl0_AF_ALMOST_FULL),
.READ_DATA_VALID(cntrl0_READ_DATA_VALID),
.APP_WDF_WREN(cntrl0_APP_WDF_WREN),
.APP_AF_WREN(cntrl0_APP_AF_WREN),
.BURST_LENGTH(cntrl0_BURST_LENGTH),
.APP_AF_ADDR(cntrl0_APP_AF_ADDR),
.READ_DATA_FIFO_OUT(cntrl0_READ_DATA_FIFO_OUT),
.APP_WDF_DATA(cntrl0_APP_WDF_DATA),
.APP_MASK_DATA(cntrl0_APP_MASK_DATA)
);

mem_top_0  mem_top_0(
.DDR2_DQ(cntrl0_DDR2_DQ),
.DDR2_A(cntrl0_DDR2_A),
.DDR2_BA(cntrl0_DDR2_BA),
.DDR2_RAS_N(cntrl0_DDR2_RAS_N),
.DDR2_CAS_N(cntrl0_DDR2_CAS_N),
.DDR2_WE_N(cntrl0_DDR2_WE_N),
.DDR2_RESET_N(cntrl0_DDR2_RESET_N),
.DDR2_CS_N(cntrl0_DDR2_CS_N),
.DDR2_ODT(cntrl0_DDR2_ODT),
.DDR2_CKE(cntrl0_DDR2_CKE),
.DDR2_DM(cntrl0_DDR2_DM),
.sys_rst(sys_rst),
.sys_rst90(sys_rst90),
.idelay_ctrl_rdy(idelay_ctrl_rdy),
.clk_0(clk_0),
.clk_90(clk_90),
.clk_200(clk_200),
.phy_init_initialization_done(cntrl0_phy_init_initialization_done),
.WDF_ALMOST_FULL(cntrl0_WDF_ALMOST_FULL),
.AF_ALMOST_FULL(cntrl0_AF_ALMOST_FULL),
.READ_DATA_VALID(cntrl0_READ_DATA_VALID),
.APP_WDF_WREN(cntrl0_APP_WDF_WREN),
.APP_AF_WREN(cntrl0_APP_AF_WREN),
.BURST_LENGTH(cntrl0_BURST_LENGTH),
.APP_AF_ADDR(cntrl0_APP_AF_ADDR),
.READ_DATA_FIFO_OUT(cntrl0_READ_DATA_FIFO_OUT),
.APP_WDF_DATA(cntrl0_APP_WDF_DATA),
.APP_MASK_DATA(cntrl0_APP_MASK_DATA),
.DDR2_DQS(cntrl0_DDR2_DQS),
.DDR2_DQS_N(cntrl0_DDR2_DQS_N),
.DDR2_CK(cntrl0_DDR2_CK),
.DDR2_CK_N(cntrl0_DDR2_CK_N)
);

endmodule 

/*
  //-----------------------------------------------------------------
  //
  //  ICON core wire declarations
  //
  //-----------------------------------------------------------------
  wire [35:0] control0;
  wire [35:0] control1;
  //-----------------------------------------------------------------
  //
  //  ILA Core wire declarations
  //
  //-----------------------------------------------------------------
  wire [31:0] data;
  wire [7:0] trig0;
  //-----------------------------------------------------------------
  //
  //  VIO Core wire declarations
  //
  //-----------------------------------------------------------------
  wire [1:0] async_in;
  wire [3:0] async_out;
  wire [1:0] sync_in;

assign data = {//cntrl0_READ_DATA_FIFO_OUT[15:0],   //
                     cntrl0_APP_WDF_DATA[7:0],   //
                      cntrl0_APP_AF_ADDR[9:0],   //
                      cntrl0_APP_AF_WREN,   //1
                     cntrl0_APP_WDF_WREN};  //1


assign trig0 = {cntrl0_READ_DATA_VALID,
                 cntrl0_AF_ALMOST_FULL,
                cntrl0_WDF_ALMOST_FULL,
                   cntrl0_APP_WDF_WREN,
                    cntrl0_APP_AF_WREN};


assign async_in = {SYS_RESET_IN,cntrl0_phy_init_initialization_done};


assign sync_in = {cntrl0_ERROR,idelay_ctrl_rdy};


  //-----------------------------------------------------------------
  //
  //  ICON core instance
  //
  //-----------------------------------------------------------------
  ddr2_icon i_ddr2_icon
    (
      .control0(control0),
      .control1(control1)
    );






  //-----------------------------------------------------------------
  //
  //  ILA core instance
  //
  //-----------------------------------------------------------------
  ila i_ila
    (
      .control(control0),
      .clk(clk_0),
      .data(data),
      .trig0(trig0)
    );




  //-----------------------------------------------------------------
  //
  //  VIO core instance
  //
  //-----------------------------------------------------------------
  vio i_vio
    (
      .control(control1),
      .clk(clk_0),
      .async_in(async_in),
      .async_out(async_out),
      .sync_in(sync_in)
    );




endmodule

//-------------------------------------------------------------------
//
//  ICON core module declaration
//
//-------------------------------------------------------------------
module ddr2_icon 
  (
      control0,
      control1
  );
  output [35:0] control0;
  output [35:0] control1;
endmodule




//-------------------------------------------------------------------
//
//  ILA core module declaration
//
//-------------------------------------------------------------------
module ila
  (
    control,
    clk,
    data,
    trig0
  );
  input [35:0] control;
  input clk;
  input [31:0] data;
  input [7:0] trig0;
endmodule



//-------------------------------------------------------------------
//
//  VIO core module declaration
//
//-------------------------------------------------------------------
module vio
  (
    control,
    clk,
    async_in,
    async_out,
    sync_in
  );
  input  [35:0] control;
  input  clk;
  input  [1:0] async_in;
  output [3:0] async_out;
  input  [1:0] sync_in;
endmodule

*/