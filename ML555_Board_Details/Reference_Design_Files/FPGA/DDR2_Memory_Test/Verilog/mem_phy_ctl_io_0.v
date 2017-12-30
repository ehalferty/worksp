///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_phy_ctl_io_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module puts the memory control signals like address,
//                  bank address, row address strobe, column address strobe,
//                  write enable and clock enable in the IOBs.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_phy_ctl_io_0 (
   input                      clk,
   input                      rst,
   input[`row_address-1:0]    ctrl_address,
   input[`bank_address-1:0]   ctrl_ba,
   input                      ctrl_ras_n,
   input                      ctrl_cas_n,
   input                      ctrl_we_n,
   input [`cs_width-1:0]      ctrl_cs_n,
   input [`odt_width-1:0]     ctrl_odt,
   input [`row_address-1:0]   phy_init_address,
   input [`bank_address-1:0]  phy_init_ba,
   input                      phy_init_ras_n,
   input                      phy_init_cas_n,
   input                      phy_init_we_n,
   input [`cs_width-1:0]      phy_init_cs_n,
   input [`cke_width-1:0]     phy_init_cke,
   input [`odt_width-1:0]     phy_init_odt,
   input                      phy_init_initialization_done,

   output [`row_address-1:0]  DDR_ADDRESS,
   output [`bank_address-1:0] DDR_BA,
   output                     DDR_RAS_L,
   output                     DDR_CAS_L,
   output                     DDR_WE_L,
   output [`cke_width-1:0]    DDR_CKE,
   output [`odt_width-1:0]    DDR_ODT,
   output [`cs_width-1:0]     DDR_CS_L

                      );

   reg                        ras_n_r;
   reg                        cas_n_r;
   reg                        we_n_r;
   reg [`cs_width-1:0]        cs_n_r;
   reg [`row_address-1:0]     address_r;
   reg [`bank_address-1:0]    ba_r;
   reg [`odt_width-1:0]       odt_r;

   // synthesis attribute iob of ras_n_r is true;
   // synthesis attribute iob of cas_n_r is true;
   // synthesis attribute iob of we_n_r is true;
   // synthesis attribute iob of cs_n_r is true;
   // synthesis attribute iob of address_r is true;
   // synthesis attribute iob of ba_r is true;

   always @(posedge clk)
   begin
      if(rst)begin
        ras_n_r   <= 1'd1;
        cas_n_r   <= 1'd1;
        we_n_r    <= 1'd1;
        cs_n_r    <= `cs_width'd0;
        address_r <= `row_address'd0;
        ba_r      <= `bank_address'd0;
        odt_r     <= `odt_width'd0;
      end
      else begin
        if(phy_init_initialization_done)begin
           ras_n_r   <= ctrl_ras_n;
           cas_n_r   <= ctrl_cas_n;
           we_n_r    <= ctrl_we_n;
           cs_n_r    <= ctrl_cs_n;
           address_r <= ctrl_address;
           ba_r      <= ctrl_ba;
           odt_r     <= ctrl_odt;
        end else begin
           ras_n_r   <= phy_init_ras_n;
           cas_n_r   <= phy_init_cas_n;
           we_n_r    <= phy_init_we_n;
           cs_n_r    <= phy_init_cs_n;
           address_r <= phy_init_address;
           ba_r      <= phy_init_ba;
           odt_r     <= phy_init_odt;
        end // else: !if(phy_init_initialization_done)
      end // else: !if(rst)
   end // always@ (posedge clk)

   OBUF r0(
           .I  (ras_n_r),
           .O  (DDR_RAS_L)
          );

   OBUF r1(
           .I  (cas_n_r),
           .O  (DDR_CAS_L)
          );

   OBUF r2(
           .I  (we_n_r),
           .O  (DDR_WE_L)
          );

   genvar cke_i;
   generate for(cke_i = 0; cke_i < `cke_width; cke_i = cke_i+1)
   begin: cke_inst
             OBUF OBUF_ckecke_i
             (
             .I  (phy_init_cke[cke_i]),
             .O  (DDR_CKE[cke_i])
             );
   end // block: cke_inst
   endgenerate

   genvar cs_i;
   generate for(cs_i = 0; cs_i < `cs_width; cs_i = cs_i+1)
   begin: cs_inst
             OBUF OBUF_cscs_i
                  (
                  .I  (cs_n_r[cs_i]),
                  .O  (DDR_CS_L[cs_i])
                  );
   end // block: cs_inst
   endgenerate

   genvar odt_i;
   generate for(odt_i = 0; odt_i < `odt_width; odt_i = odt_i+1)
   begin: odt_inst
             OBUF OBUF_odtodt_i
                   (
                   .I  (odt_r[odt_i]),
                   .O  (DDR_ODT[odt_i])
                   );
   end // block: odt_inst
   endgenerate

   genvar addr_i;
   generate for(addr_i = 0; addr_i < `row_address; addr_i = addr_i+1)
   begin: addr_inst
             OBUF OBUF_addraddr_i
                   (
                   .I  (address_r[addr_i]),
                   .O  (DDR_ADDRESS[addr_i])
                   );
   end // block: addr_inst
   endgenerate

   genvar ba_i;
   generate for(ba_i = 0; ba_i < `bank_address; ba_i = ba_i+1)
   begin: ba_inst
             OBUF OBUF_baba_i
                   (
                   .I  (ba_r[ba_i]),
                   .O  (DDR_BA[ba_i])
                   );
   end // block: ba_inst
   endgenerate

endmodule
