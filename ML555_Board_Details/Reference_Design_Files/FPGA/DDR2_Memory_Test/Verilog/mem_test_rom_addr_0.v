///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_test_rom_addr_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : The address for the memory and the various user commands can be
//                  given through this module. It instantiates the block RAM which
//                  stores all the information in particular sequence. The data
//                  stored should be in a sequence starting from LSB:
//                  column address, row address, bank address, chip address, commands,
//                  and the row conflict information.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module mem_test_rom_addr_0 (
   input              clk0,
   input              rst,
   input              bkend_wraddr_en,

   //Write address fifo signals
   output reg [35:0]  app_af_addr,
   output reg         app_af_WrEn
                   );

   wire [8:0]     wr_rd_addr;
   wire           wr_rd_addr_en;

   reg [5:0]      wr_addr_count;
   reg            bkend_wraddr_en_reg;
   reg            bkend_wraddr_en_3r;

   wire           gnd;
   wire [35:0]    addr_out;
   wire [15:0]    ramb36_addra;
   reg  [15:0]    fixed_bits;

   assign gnd              = 1'b0;

   //ADDRESS generation for Write and Read Address FIFOs

   //ROM with address patterns
   //512x36 mode is used with addresses 0-127 for storing write addresses and
   //addresses (128-511) for storing read addresses

   //INIP_OO: read 1
   //INIP_OO: write 0

   RAMB36 wr_rd_addr_lookup (
                    .CASCADEOUTLATA   (),
                    .CASCADEOUTLATB   (),
                    .CASCADEOUTREGA   (),
                    .CASCADEOUTREGB   (),
                    .DOA              (addr_out[31:0]),
                    .DOB              (),
                    .DOPA             (addr_out[35:32]),
                    .DOPB             (),
                    .ADDRA            (ramb36_addra),
                    .ADDRB            (16'h0000),
                    .CASCADEINLATA    (),
                    .CASCADEINLATB    (),
                    .CASCADEINREGA    (),
                    .CASCADEINREGB    (),
                    .CLKA             (clk0),
                    .CLKB             (clk0),
                    .DIA              (32'b0),
                    .DIB              (32'b0),
                    .DIPA             (4'b0),
                    .DIPB             (4'b0),
                    .ENA              (1'b1),
                    .ENB              (1'b1),
                    .REGCEA           (),
                    .REGCEB           (),
                    .SSRA             (1'b0),
                    .SSRB             ( 1'b0 ),
                    .WEA              (4'b0000),
                    .WEB              (4'b0000)
                    );

     defparam

             wr_rd_addr_lookup.INIT_00  = 256'h0003C154_0003C198_0003C088_0003C0EC_00023154_00023198_00023088_000230EC,
             wr_rd_addr_lookup.INIT_01  = 256'h00023154_00023198_00023088_000230EC_0003C154_0003C198_0003C088_0003C0EC,
             wr_rd_addr_lookup.INIT_02  = 256'h0083C154_0083C198_0083C088_0083C0EC_00823154_00823198_00823088_008230EC,
             wr_rd_addr_lookup.INIT_03  = 256'h0083C154_0083C198_0083C088_0083C0EC_00823154_00823198_00823088_008230EC,
             wr_rd_addr_lookup.INIT_04  = 256'h0043C154_0043C198_0043C088_0043C0EC_00423154_00423198_00423088_004230EC,
             wr_rd_addr_lookup.INIT_05  = 256'h0043C154_0043C198_0043C088_0043C0EC_00423154_00423198_00423088_004230EC,
             wr_rd_addr_lookup.INIT_06  = 256'h00C3C154_00C3C198_00C3C088_00C3C0EC_00C23154_00C23198_00C23088_00C230EC,
             wr_rd_addr_lookup.INIT_07  = 256'h00C3C154_00C3C198_00C3C088_00C3C0EC_00C23154_00C23198_00C23088_00C230EC,

             wr_rd_addr_lookup.INITP_00 = 256'h11111111_00000000_11111111_00000000_11111111_00000000_11111111_00000000;

   defparam wr_rd_addr_lookup.READ_WIDTH_A = 36;
   defparam wr_rd_addr_lookup.READ_WIDTH_B = 36;

   assign ramb36_addra = {fixed_bits[15:14], wr_rd_addr, 5'b00000};

   always @ (posedge clk0)
   begin
      if (rst) begin
        fixed_bits <= 16'hFFFF;
      end else begin
        fixed_bits <= 16'h0000;
      end
   end

   assign wr_rd_addr_en = (bkend_wraddr_en == 1'b1);

   //register backend enables
   always @ (posedge clk0)
   begin
      if (rst)
      begin
         bkend_wraddr_en_reg <= 1'b0;
         bkend_wraddr_en_3r  <= 1'b0;
      end
      else
      begin
         bkend_wraddr_en_reg <= bkend_wraddr_en;
         bkend_wraddr_en_3r  <= bkend_wraddr_en_reg;
      end
   end

   // Fifo enables
   always @ (posedge clk0)
   begin
      if (rst)
      begin
         app_af_WrEn <= 1'b0;
      end
      else
      begin
         app_af_WrEn <= bkend_wraddr_en_3r;
      end
   end

   // FIFO addresses
   always @ (posedge clk0)
   begin
      if (rst)
      begin
         app_af_addr <= 36'h00000;
      end
      else if (bkend_wraddr_en_3r) begin
         app_af_addr <= addr_out;
      end
      else begin
         app_af_addr <= 36'h00000;
      end
   end

   // address input for ROM
   always @ (posedge clk0)
   begin
      if (rst) begin
          wr_addr_count[5:0] <= 6'b111111;
      end else if (bkend_wraddr_en) begin
          wr_addr_count[5:0] <= wr_addr_count[5:0] + 1;
      end else begin
          wr_addr_count[5:0] <= wr_addr_count[5:0];
      end
   end

   assign wr_rd_addr[8:0] = (bkend_wraddr_en_reg) ? {fixed_bits[13:11],wr_addr_count[5:0]} :
                            9'b000000000;

endmodule

