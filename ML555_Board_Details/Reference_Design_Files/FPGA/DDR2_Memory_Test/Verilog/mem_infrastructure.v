///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_infrastructure.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     :
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module mem_infrastructure(

   
   input                     SYS_CLK_N,
   input                     SYS_CLK_P,
   input                     CLK200_N,
   input                     CLK200_P,
   input                     SYS_RESET_IN,

   output                    clk_0,
   output                    clk_90,
   output                    clk_200,



   
   output reg                sys_rst,
   output reg                sys_rst90,
   output reg                sys_rst200

                      );


   wire       clk0_bufg_in;
   wire       clk90_bufg_in;
   wire       clk0_bufg_out;
   wire       clk90_bufg_out;
   wire       clk0_bufg1_out;
   wire       REF_CLK200_IN;
   wire       SYS_CLK_IN;
   wire       SYS_RESET;
   wire       dcm_lock;

   reg        sys_rst_0;
   reg        sys_rst_1;
   reg        sys_rst_2;

   reg        sys_rst90_0;
   reg        sys_rst90_1;
   reg        sys_rst90_2;

   reg        sys_rst_200_0;
   reg        sys_rst_200_1;
   reg        sys_rst_200_2;



   assign clk_0         = clk0_bufg_out;
   assign clk_90        = clk90_bufg_out;
	


   assign clk_200       = clk0_bufg1_out;
   assign SYS_RESET   = ~SYS_RESET_IN;

   IBUFGDS_LVPECL_25  lvds_sys_clk_input (
                                          .I   (SYS_CLK_P),
                                          .IB  (SYS_CLK_N),
                                          .O   (SYS_CLK_IN)
                                          );

   IBUFGDS_LVPECL_25 lvpecl_clk200_in (
                                       .O   (REF_CLK200_IN),
                                       .I   (CLK200_P),
                                       .IB  (CLK200_N)
                                       );
 
   defparam DCM_BASE0.DLL_FREQUENCY_MODE = "HIGH";
   defparam DCM_BASE0.DUTY_CYCLE_CORRECTION = "TRUE";
   defparam DCM_BASE0.CLKDV_DIVIDE = 16.0;
   defparam DCM_BASE0.CLKFX_MULTIPLY = 2;
   defparam DCM_BASE0.CLKFX_DIVIDE = 8;
   defparam DCM_BASE0.FACTORY_JF = 16'hF0F0;

   DCM_BASE DCM_BASE0 (
                       .CLK0      (clk0_bufg_in),
                       .CLK180    (),
                       .CLK270    (),
                       .CLK2X     (),
                       .CLK2X180  (),
                       .CLK90     (clk90_bufg_in),
                       .CLKDV     (),
                       .CLKFX     (),
                       .CLKFX180  (),
                       .LOCKED    (dcm_lock),
                       .CLKFB     (clk0_bufg_out),
                       .CLKIN     (SYS_CLK_IN),
                       .RST       (SYS_RESET)
                       );





   BUFG dcm_clk0 (
                  .O  (clk0_bufg_out),
                  .I  (clk0_bufg_in)
                  );

   BUFG dcm_clk90 (
                   .O  (clk90_bufg_out),
                   .I  (clk90_bufg_in)
                   );

   BUFG dcm1_clk0 (
                   .O  (clk0_bufg1_out),
                   .I  (REF_CLK200_IN)
                   );


   always @ (posedge clk_0)
   begin
      if ( (dcm_lock == 1'b0))
      begin
         sys_rst_0 <= 1'b1;
         sys_rst_1 <= 1'b1;
         sys_rst_2 <= 1'b1;
         sys_rst   <= 1'b1;
      end
      else
      begin
         sys_rst_0 <= 1'b0;
         sys_rst_1 <= sys_rst_0;
         sys_rst_2 <= sys_rst_1;
         sys_rst   <= sys_rst_2;
      end
   end

   always @ (posedge clk_90)
   begin
      if ( (dcm_lock == 1'b0))
      begin
         sys_rst90_0 <= 1'b1;
         sys_rst90_1 <= 1'b1;
         sys_rst90_2 <= 1'b1;
         sys_rst90   <= 1'b1;
      end
      else
      begin
         sys_rst90_0 <= 1'b0;
         sys_rst90_1 <= sys_rst90_0;
         sys_rst90_2 <= sys_rst90_1;
         sys_rst90   <= sys_rst90_2;
      end
   end

   always @ (posedge clk_200)
   begin
      if ((dcm_lock == 1'b0))
      begin
         sys_rst_200_0 <= 1'b1;
         sys_rst_200_1 <= 1'b1;
         sys_rst_200_2 <= 1'b1;
         sys_rst200    <= 1'b1;
      end
      else
      begin
         sys_rst_200_0 <= 1'b0;
         sys_rst_200_1 <= sys_rst_200_0;
         sys_rst_200_2 <= sys_rst_200_1;
         sys_rst200    <= sys_rst_200_2;
      end
   end


endmodule



