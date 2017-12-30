///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_ctrl_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module is the main control logic of the memory interface.
//                  All commands are issued from here acoording to the burst,
//                  CAS Latency and the user commands.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_ctrl_0 (
   input                        clk0,
   input                        rst,
   input [35:0]                 af_addr,
   input                        af_empty,
   input                        phy_init_initialization_done,

   output                       ctrl_ref_flag,
   output                       ctrl_af_rden,
   output reg                   ctrl_wdf_rden,
   output                       ctrl_dqs_rst,
   output                       ctrl_dqs_en,

   output                       ctrl_wren,
   output                       ctrl_rden,
   output [`row_address-1:0]    ctrl_address,
   output [`bank_address-1:0]   ctrl_ba,
   output                       ctrl_ras_n,
   output                       ctrl_cas_n,
   output                       ctrl_we_n,
   output [`cs_width-1:0]       ctrl_cs_n,
   output [`odt_width-1:0]      ctrl_odt,
   output [2:0]                 burst_length

                      );

   wire                                 ref_flag;
   reg                                  auto_ref_r;
   reg [4:0]                            next_state;
   reg [4:0]                            state_r;
   reg [4:0]                            state_r1;
   reg [4:0]                            state_r2;
   reg [`row_address -1:0]              row_addr_r ;
   reg [`row_address -1:0]              ddr2_address_r;
   reg [`bank_address-1:0]              ddr2_ba_r;

   // counters for ddr2 controller
   reg [2:0]                            rp_count_r;
   reg [5:0]                            rfc_count_r;
   reg [2:0]                            rcd_count_r;
   reg [3:0]                            ras_count_r;
   reg [3:0]                            wr_to_rd_count_r;
   reg [3:0]                            rd_to_wr_count_r;
   reg [3:0]                            rtp_count_r;
   reg [3:0]                            wtp_count_r;

   reg [11:0]                           refi_count_r;
   reg [2:0]                            cas_count_r;
   reg [3:0]                            cas_check_count_r;
   reg [2:0]                            wrburst_cnt_r;
   reg [2:0]                            read_burst_cnt_r;
   reg [2:0]                            ctrl_wren_cnt_r;
   reg [2:0]                            rdburst_cnt_r;
   reg [35:0]                           af_addr_r ;
   reg [35:0]                           af_addr_r1 ;
   wire                                 af_rden;
   reg                                  ddr2_ras_r1;
   reg                                  ddr2_cas_r1;
   reg                                  ddr2_we_r1;
   reg                                  ddr2_ras_r;
   reg                                  ddr2_cas_r;
   reg                                  ddr2_we_r;
   reg [`cs_width-1:0]                  ddr2_cs_r2;
   reg [`cs_width-1:0]                  ddr2_cs_r1;
   reg [`cs_width-1:0]                  ddr2_cs_r;
   reg [2:0]                            auto_cnt_r;
   wire [2:0]                           burst_cnt;
   reg                                  ctrl_write_en;
   reg                                  ctrl_read_en;
   reg [3:0]                            odt_cnt_r;
   reg [3:0]                            odt_en_cnt_r;
   reg [`odt_width-1 :0 ]               odt_en;
   wire                                 conflict_detect;
   wire [14:0]                          load_mode_reg;
   wire [14:0]                          ext_mode_reg;
   reg                                  WR;
   reg                                  RD;
   reg                                  WR_r;
   reg                                  RD_r;
   wire [1:0]                           command_address;
   wire [3:0]                           zeroes;
   reg                                  burst_write;
   reg                                  burst_read;
   reg                                  burst_write_r;
   reg                                  burst_read_r;
   reg                                  burst_read_r1;
   reg                                  burst_read_r2;
   reg [`bank_address+`row_address :0]  bank_00_r;
   reg [`bank_address+`row_address :0]  bank_01_r;
   reg [`bank_address+`row_address :0]  bank_10_r;
   reg [`bank_address+`row_address :0]  bank_11_r;
   reg [`bank_address-1:0]              active_bank_r;
   reg                                  no_precharge_r;
   reg                                  no_precharge_wait_r;
   reg                                  bank_hit0;
   reg                                  bank_hit1;
   reg                                  bank_hit2;
   reg                                  bank_hit3;
   reg                                  bank_hit0_r;
   reg                                  bank_hit1_r;
   reg                                  bank_hit2_r;
   reg                                  bank_hit3_r;
   reg                                  bank_hit_r;
   reg                                  bank_conf_r;
   reg                                  phy_init_initialization_done_r;
   wire                                 reg_val;
   wire [3:0]                           cas_lat;
   wire [2:0]                           brst_lnth;
   wire [3:0]                           add_lat;
   wire                                 ecc_val;

   reg                                  wdf_rden_r;
   reg                                  wdf_rden_r2;
   reg                                  wdf_rden_r3;
   reg                                  wdf_rden_r4;
   reg                                  dqs_en;
   reg                                  dqs_reset;

   reg                                  ctrl_wdf_read_en;
   reg                                  ctrl_wdf_read_en_r1;
   reg                                  ctrl_wdf_read_en_r2;
   reg                                  ctrl_wdf_read_en_r3;
   reg                                  ctrl_wdf_read_en_r4;
   reg                                  ctrl_wdf_read_en_r5;
   reg                                  ctrl_wdf_read_en_r6;

   localparam  IDLE                =     5'h00;
   localparam  PRECHARGE           =     5'h01;
   localparam  PRECHARGE_WAIT      =     5'h02;
   localparam  AUTO_REFRESH        =     5'h03;
   localparam  AUTO_REFRESH_WAIT   =     5'h04;
   localparam  ACTIVE              =     5'h05;
   localparam  ACTIVE_WAIT         =     5'h06;
   localparam  BURST_READ          =     5'h07;
   localparam  READ_WAIT           =     5'h08;
   localparam  BURST_WRITE         =     5'h09;
   localparam  WRITE_WAIT          =     5'h0A;
   localparam  COMMAND_WAIT        =     5'h0B;
   localparam  WRITE_BANK_CONF     =     5'h0C;
   localparam  READ_BANK_CONF      =     5'h0D;
   localparam  COMMAND_WAIT_CONF   =     5'h0E;
   localparam  PRECHARGE_WAIT1     =     5'h0F;

   assign    reg_val     = `registered;
   assign    cas_lat     = {1'd0, load_mode_reg[6:4]};
   assign    brst_lnth   = load_mode_reg[2:0];
   assign    add_lat     = {1'd0, ext_mode_reg[5:3]};
   assign    odt_enable  = ext_mode_reg[2] | ext_mode_reg[6];
   assign    ecc_val     = `ecc_enable;

   assign    burst_length     = burst_cnt;
   assign    command_address  = af_addr[33:32];
   assign    zeroes           = 4'b0000;
   assign    load_mode_reg    = `load_mode_register;
   assign    ext_mode_reg     = `ext_load_mode_register;

   // fifo control signals

   assign ctrl_af_rden = af_rden;

   assign conflict_detect = |af_addr[35:34] & ~af_empty;

   //commands

   always @(*)
   begin
      WR = 1'b0;
      RD = 1'b0;
      bank_hit0 = bank_hit0_r;
      bank_hit1 = bank_hit1_r;
      bank_hit2 = bank_hit2_r;
      bank_hit3 = bank_hit3_r;

      if(~af_empty)
      begin
         case(command_address)
            2'b00: WR  = 1'b1;
            2'b01: RD  = 1'b1;
         endcase // case(af_addr[31:29])

         bank_hit0 = (bank_00_r[`row_address+`bank_address:`row_address] == {1'b1, af_addr[`bank_range_end:`bank_range_start]}) ;
         bank_hit1 = (bank_01_r[`row_address+`bank_address:`row_address] == {1'b1, af_addr[`bank_range_end:`bank_range_start]}) ;
         bank_hit2 = (bank_10_r[`row_address+`bank_address:`row_address] == {1'b1, af_addr[`bank_range_end:`bank_range_start]}) ;
         bank_hit3 = (bank_11_r[`row_address+`bank_address:`row_address] == {1'b1, af_addr[`bank_range_end:`bank_range_start]});

      end // if (ctrl_init_done & ~af_empty)
   end // always @ (af_addr)

   // register address outputs
   always @ (posedge clk0)
   begin
      if (rst) begin
         WR_r <= 1'b0;
         RD_r <= 1'b0;
      end else begin
         WR_r <= WR;
         RD_r <= RD;
      end
   end

   // register address outputs
   always @ (posedge clk0)
   begin
      if (rst) begin
         af_addr_r          <= 36'h00000;
         af_addr_r1         <= 36'h00000;
      end else begin   // holding the A10 bit to zero during reads and writes
         af_addr_r <= {af_addr[35:11],1'd0,af_addr[9:0]};
         af_addr_r1 <= af_addr_r;
      end
   end

   always @(posedge clk0)
   begin
      if (rst) begin
         bank_conf_r <= 1'd0;
         bank_hit0_r <= 1'd0;
         bank_hit1_r <= 1'd0;
         bank_hit2_r <= 1'd0;
         bank_hit3_r <= 1'd0;
         bank_hit_r  <= 1'd0;
         no_precharge_r <= 1'd0;
         no_precharge_wait_r <= 1'd0;
      end
      else
      begin
         bank_hit_r <= bank_hit0 | bank_hit1 | bank_hit2 | bank_hit3;
         bank_hit0_r <= bank_hit0;
         bank_hit1_r <= bank_hit1;
         bank_hit2_r <= bank_hit2;
         bank_hit3_r <= bank_hit3;

         no_precharge_r <= 1'd0;
         no_precharge_wait_r <= 1'd0;
         bank_conf_r <= conflict_detect; // if no bank hit it becomes a conflict

         casex({conflict_detect,bank_hit0,bank_hit1,bank_hit2,bank_hit3}) // detect bank conf
             5'b11000:bank_conf_r <= (bank_00_r[`row_address-1'b1:0] !=  af_addr[`row_range_end:`row_range_start]);// if bank hit and the row is not open then conflict
             5'b10100:bank_conf_r <= (bank_01_r[`row_address-1'b1:0] !=  af_addr[`row_range_end:`row_range_start]);
             5'b10010:bank_conf_r <= (bank_10_r[`row_address-1'b1:0] !=  af_addr[`row_range_end:`row_range_start]);
             5'b10001:bank_conf_r <= (bank_11_r[`row_address-1'b1:0] !=  af_addr[`row_range_end:`row_range_start]);
             5'b10000:begin
                             no_precharge_r <= ~bank_11_r[`row_address+`bank_address]; // flag to tell there is no need for precharge
                             no_precharge_wait_r <= bank_11_r[`row_address+`bank_address]; // flag to tell there is no need for precharge wait
                          end
             5'b0xxxx: no_precharge_r <= ~conflict_detect;

         endcase

         if (((state_r1 == ACTIVE_WAIT)) && (active_bank_r[`bank_address-1:0] == af_addr_r[`bank_range_end:`bank_range_start]))
            bank_conf_r <= 1'd0;
      end // else: !if(rst)
   end // always@ (posedge clk0)

   always @ (posedge clk0)
   begin
      if ((rst) || (state_r1 == AUTO_REFRESH)) begin
          bank_00_r <= 20'h00000;
          bank_01_r <= 20'h00000;
          bank_10_r <= 20'h00000;
          bank_11_r <= 20'h00000;
          active_bank_r   <= `bank_address'd0;
      end else begin
         if(state_r == ACTIVE)
         begin
            bank_00_r[`bank_address+`row_address-1'b1:0] <= af_addr_r[`bank_range_end:`row_range_start]; // 00 is always going to have the latest bank and row.
            bank_00_r[`bank_address+`row_address] <= 1'b1; // This indicates the bank was activated

            if(bank_hit1_r)
                 bank_01_r <= bank_00_r;
            else if (bank_hit2_r)
            begin
                 bank_01_r <= bank_00_r;
                 bank_10_r <= bank_01_r;
            end
            else if(~bank_hit0_r) // if no bank hit or bank3 hit.
            begin
                 bank_01_r <= bank_00_r;
                 bank_10_r <= bank_01_r;
                 bank_11_r <= bank_10_r;
            end
         end

         if(state_r1 == ACTIVE) // stored to see which banks was activated
            active_bank_r <= af_addr_r1[`bank_range_end:`bank_range_start];

      end // else: !if(rst)
   end // always @ (posedge clk266)

   // rp count
   always @ (posedge clk0)
   begin
      if (rst)
         rp_count_r <= 3'd0;
      else if ((state_r == PRECHARGE) )
         rp_count_r <= `rp_count_value;
      else if (rp_count_r > 3'd0)
         rp_count_r <= rp_count_r - 1'b1;
   end

   // rfc count
   always @ ( posedge clk0)
   begin
      if (rst)
          rfc_count_r <= 6'd0;
      else if ((state_r == AUTO_REFRESH) )
          rfc_count_r <= `rfc_count_value;
      else if (rfc_count_r > 6'd0)
          rfc_count_r <= rfc_count_r - 1'b1;
   end

   // rcd count - 20ns
   always @ ( posedge clk0)
   begin
      if (rst)
          rcd_count_r <= 3'd0;
      else if (state_r == ACTIVE  )
          rcd_count_r <= `rcd_count_value - add_lat;
      else if (rcd_count_r != 3'd0)
          rcd_count_r <= rcd_count_r - 1'b1;
   end

   // ras count - active to precharge
   always @ ( posedge clk0)
   begin
      if (rst)
          ras_count_r <= 4'd0;
      else if ((state_r == ACTIVE) )
          ras_count_r <= `ras_count_value;
      else if (ras_count_r > 4'd0)
          ras_count_r <= ras_count_r - 1'b1;
   end

   //AL+BL/2+TRTP-2
   // rtp count - read to precharge
   always @ ( posedge clk0)
   begin
      if (rst)
          rtp_count_r <= 4'd0;
      else if (state_r == BURST_READ )
          rtp_count_r <= (`trtp_count_value + burst_cnt + add_lat -2'd3) ;
      else if(rtp_count_r > 4'd0)
          rtp_count_r <= rtp_count_r - 1'b1;
   end

   // WL+BL/2+TWR
   // wtp count - write to precharge
   always @ ( posedge clk0)
   begin
      if (rst)
          wtp_count_r <= 4'd0;
      else if (state_r == BURST_WRITE )
          wtp_count_r <= (`twr_count_value + burst_cnt + cas_lat + add_lat -2'd2)  ;
      else if (wtp_count_r > 4'd0)
          wtp_count_r <= wtp_count_r - 1'd1;
   end

   // write to read counter
   // write to read includes : write latency + burst time + tWTR

   always @ (posedge clk0)
   begin
      if (rst)
          wr_to_rd_count_r <= 4'd0;
      else if (state_r == BURST_WRITE  )
          wr_to_rd_count_r <= (`twtr_count_value + burst_cnt + add_lat + cas_lat);
      else if (wr_to_rd_count_r >  4'd0)
          wr_to_rd_count_r <= wr_to_rd_count_r - 1'd1;
   end

   // read to write counter
   always @ (posedge clk0)
   begin
      if (rst)
         rd_to_wr_count_r<= 4'd0;
      else if ((state_r == BURST_READ)  )
         rd_to_wr_count_r <= ( add_lat + `registered + burst_cnt + 2);
      else if (rd_to_wr_count_r >4'd0)
         rd_to_wr_count_r <= rd_to_wr_count_r - 1'd1;
   end

   // auto refresh interval counter in refresh_clk domain
   always @ (posedge clk0)
   begin
      if (rst)
         refi_count_r <= 12'd0;
      else if (refi_count_r == `max_ref_cnt )
         refi_count_r <= 12'd0;
      else
         refi_count_r <= refi_count_r + 1'd1;
   end

   assign ref_flag = ((refi_count_r == `max_ref_cnt)) ? 1'b1 : 1'b0;

   assign ctrl_ref_flag = (refi_count_r == `max_ref_cnt);

   //refresh flag detect
   //auto_ref high indicates auto_refresh requirement
   //auto_ref is held high until auto refresh command is issued.
   always @(posedge clk0)
   begin
      if (rst)
         auto_ref_r <= 1'b0;
      else if (ref_flag && phy_init_initialization_done)
          auto_ref_r <= 1'b1;
      else if (state_r == AUTO_REFRESH)
          auto_ref_r <= 1'b0;
   end

   assign burst_cnt    = (brst_lnth == 3'b010) ? 3'b010 :
                         (brst_lnth == 3'b011) ? 3'b100 : 3'b000;

   always @ (posedge clk0 )
   begin
      if (rst || (state_r == PRECHARGE ))
         auto_cnt_r <= 3'd0;
      else if ( state_r ==AUTO_REFRESH)
         auto_cnt_r <= auto_cnt_r + 1'b1;
   end

   // write burst count
   always @ (posedge clk0)
   begin
      if (rst)
          wrburst_cnt_r<= 3'd0;
      else if (state_r == BURST_WRITE )
          wrburst_cnt_r <= burst_cnt;
      else if (wrburst_cnt_r > 3'd0)
          wrburst_cnt_r <= wrburst_cnt_r - 1'd1;
   end

   // read burst count for state machine
   always @ (posedge clk0)
   begin
      if (rst)
          read_burst_cnt_r<= 3'd0;
      else if (state_r == BURST_READ)
          read_burst_cnt_r<= burst_cnt;
      else if (read_burst_cnt_r > 3'd0)
          read_burst_cnt_r<= read_burst_cnt_r - 1'd1;
   end

   // count to generate write enable to the data path
   always @ (posedge clk0)
   begin
      if (rst)
          ctrl_wren_cnt_r <= 3'd0;
      else if (wdf_rden_r)
          ctrl_wren_cnt_r <= burst_cnt;
      else if (ctrl_wren_cnt_r > 3'd0)
          ctrl_wren_cnt_r <= ctrl_wren_cnt_r  -1'd1;
   end

   //write enable to data path
   always @ (*)
   begin
      if (ctrl_wren_cnt_r  != 3'd0)
         ctrl_write_en <= 1'b1;
      else
        ctrl_write_en <= 1'b0;
   end

   assign ctrl_wren = ctrl_write_en;

   always @ (*)
   begin
      if (((state_r == BURST_WRITE) && ~burst_write_r))
        dqs_reset <= 1'b1;
      else
        dqs_reset <= 1'b0;
   end

   assign ctrl_dqs_rst = dqs_reset;

   always @ (*)
   begin
      if ((state_r == BURST_WRITE) || (wrburst_cnt_r != 3'd0))
         dqs_en <= 1'b1;
      else
         dqs_en <= 1'b0;
   end

   assign ctrl_dqs_en = dqs_en;

   // cas count
   always @ (posedge clk0)
   begin
      if (rst)
         cas_count_r<= 3'd0;
      else if (((state_r == BURST_READ) && ~burst_read_r) )
         cas_count_r  <= cas_lat + `registered;
      else if (cas_count_r != 3'd0)
         cas_count_r <= cas_count_r - 1'b1;
   end

   always @ (posedge clk0)
   begin
      if (rst)
          cas_check_count_r <= 4'd0;
      else if ((state_r1 == BURST_READ) && ~burst_read_r1)
             cas_check_count_r <= (cas_lat - 1'b1);
      else if (cas_check_count_r > 4'd0)
          cas_check_count_r <= cas_check_count_r - 1'd1;
      else
        cas_check_count_r <= 4'd1;
   end

   always @ (posedge clk0)
   begin
      if (rst)
         rdburst_cnt_r  <= 3'd0;
      else if((state_r2 == BURST_READ) && burst_read_r2) begin
         if(burst_cnt[2])
           rdburst_cnt_r <= (({burst_cnt[2:0],1'b0})-(3'd7 - cas_lat));
         else
           rdburst_cnt_r<= (({burst_cnt[2:0],1'b0}) -(3'd5 - cas_lat));
      end else if ((cas_check_count_r == 4'b0010))
         rdburst_cnt_r <= burst_cnt;
      else if (rdburst_cnt_r > 3'd0)
         rdburst_cnt_r <= rdburst_cnt_r - 1'b1;
   end // always @ (posedge clk0)

   //read enable to data path
   always @ (rdburst_cnt_r)
   begin
      if ((rdburst_cnt_r == 3'd0)) begin
         ctrl_read_en <= 1'b0;
      end else begin
         ctrl_read_en <= 1'b1;
      end
   end

   assign ctrl_rden = ctrl_read_en;

   assign af_rden = (state_r ==BURST_WRITE || state_r ==BURST_READ);

   // write data fifo read enable
   always @ (posedge clk0)
   begin
      if (rst)
          wdf_rden_r  <= 1'b0;
      else if ((state_r ==BURST_WRITE))  // place holder for burst_write
          wdf_rden_r  <= 1'b1;
      else
        wdf_rden_r  <= 1'b0;
   end

   always @ (posedge clk0)
   begin
      if (rst)
      begin
         wdf_rden_r2 <= 1'b0;
         wdf_rden_r3 <= 1'b0;
         wdf_rden_r4 <= 1'b0;
      end
      else
      begin
         wdf_rden_r2 <= wdf_rden_r;
         wdf_rden_r3 <= wdf_rden_r2;
         wdf_rden_r4 <= wdf_rden_r3;
      end // else: !if(rst)
   end // always @ (posedge clk0)

   // Read enable to the data fifo
   always @ (*)
   begin
      if (burst_cnt == 3'b010) begin
          ctrl_wdf_read_en<= (wdf_rden_r | wdf_rden_r2) ;
      end else if (burst_cnt == 3'b100)
          ctrl_wdf_read_en<= (wdf_rden_r | wdf_rden_r2 | wdf_rden_r3 | wdf_rden_r4) ;
      else ctrl_wdf_read_en<= 1'b0;

   end

   always @(posedge clk0)
   begin
      if (rst) begin
         ctrl_wdf_rden <= 1'b0;
         ctrl_wdf_read_en_r1<= 1'b0;
         ctrl_wdf_read_en_r2<= 1'b0;
         ctrl_wdf_read_en_r3<= 1'b0;
         ctrl_wdf_read_en_r4<= 1'b0;
         ctrl_wdf_read_en_r5<= 1'b0;
         ctrl_wdf_read_en_r6<= 1'b0;
      end else begin
         ctrl_wdf_read_en_r1<= ctrl_wdf_read_en;
         ctrl_wdf_read_en_r2<= ctrl_wdf_read_en_r1;
         ctrl_wdf_read_en_r3<= ctrl_wdf_read_en_r2;
         ctrl_wdf_read_en_r4<= ctrl_wdf_read_en_r3;
         ctrl_wdf_read_en_r5<= ctrl_wdf_read_en_r4;
         ctrl_wdf_read_en_r6<= ctrl_wdf_read_en_r5;

      case(add_lat + cas_lat + reg_val)
         4'b0011: ctrl_wdf_rden  <= ctrl_wdf_read_en;
         4'b0100: ctrl_wdf_rden  <= ctrl_wdf_read_en_r1;
         4'b0101: ctrl_wdf_rden  <= ctrl_wdf_read_en_r2;
         4'b0110: ctrl_wdf_rden  <= ctrl_wdf_read_en_r3;
         4'b0111: ctrl_wdf_rden  <= ctrl_wdf_read_en_r4;
         4'b1000: ctrl_wdf_rden  <= ctrl_wdf_read_en_r5;
         4'b1001: ctrl_wdf_rden  <= ctrl_wdf_read_en_r6;
      default: ctrl_wdf_rden  <= 1'b0;
      endcase // case(ADDITIVE_LATENCY_VALUE + CAS_LATENCY_VALUE )
      end // else: !if(rst)
   end // always @ (posedge clk0)

   always @ (posedge clk0)
   begin
      if (rst ) begin
         phy_init_initialization_done_r <= 1'd0;
      end else begin
         phy_init_initialization_done_r <= phy_init_initialization_done;
      end
   end

   always @ (posedge clk0)
   begin
      if (rst) begin
          state_r <= IDLE;
      end else begin
         if(phy_init_initialization_done_r)
            state_r <= next_state;
      end
   end

   // main control state machine
   always @ (*)
   begin
      next_state = state_r;
      burst_read = 1'd0;
      burst_write = 1'd0;

      case (state_r)

         IDLE               : begin
                                 if(auto_ref_r)
                                    next_state = PRECHARGE;
                                 else if ((WR_r  || RD_r  ))
                                    next_state = ACTIVE;
                              end  // case: IDLE

         PRECHARGE          : begin
                                 if(auto_ref_r)
                                    next_state = PRECHARGE_WAIT1;
                                 else if (no_precharge_wait_r) // when precharging an LRU bank, do not have to go to wait state
                                    next_state = ACTIVE;
                                 else
                                    next_state = PRECHARGE_WAIT;
                              end  // case: PRECHARGE

         PRECHARGE_WAIT     : begin
                                 if (rp_count_r == 3'b000) begin
                                    if (auto_ref_r ) begin
                                       next_state = PRECHARGE; // precharge again to close all the banks
                                    end else  begin
                                       next_state = ACTIVE;
                                    end
                                 end
                              end // case: PRECHARGE_WAIT

         PRECHARGE_WAIT1    : if(rp_count_r == 3'b000) next_state = AUTO_REFRESH;

         AUTO_REFRESH       : next_state = AUTO_REFRESH_WAIT;

         AUTO_REFRESH_WAIT  : if(rfc_count_r == 3'd0) next_state = ACTIVE;

         ACTIVE             : next_state = ACTIVE_WAIT;

         ACTIVE_WAIT        : if(rcd_count_r == 3'd0) next_state = COMMAND_WAIT;

         COMMAND_WAIT       : begin
                                 if(auto_ref_r) begin
                                    if(ras_count_r == 4'd0)
                                        next_state = PRECHARGE;
                                 end else if (conflict_detect)
                                          next_state = COMMAND_WAIT_CONF;
                                 else if (WR)
                                   next_state = BURST_WRITE;
                                 else if(RD)
                                   next_state = BURST_READ;
                              end  // case: COMMAND_WAIT

         BURST_WRITE        : next_state = WRITE_WAIT;

         WRITE_WAIT         : begin
                                 if ((conflict_detect)|| auto_ref_r)  begin
                                    next_state = WRITE_BANK_CONF;
                                 end else if ((WR) && (wrburst_cnt_r < 3'b010)) begin
                                    next_state = BURST_WRITE;
                                 end else if ((WR) && (wrburst_cnt_r == 3'b010)) begin
                                    next_state = BURST_WRITE;
                                    burst_write = 1'd1;
                                 end else if ((wrburst_cnt_r <= 3'b010) && (wr_to_rd_count_r <= 4'd1))begin
                                    next_state = COMMAND_WAIT;
                                 end
                              end // case: WRITE_WAIT

         BURST_READ         : next_state = READ_WAIT;

         READ_WAIT          : begin
                                 if ((conflict_detect) || auto_ref_r) begin
                                      next_state = READ_BANK_CONF;
                                 end else if ((RD) && (read_burst_cnt_r == 3'b010)) begin
                                    next_state = BURST_READ;
                                    burst_read = 1'd1;
                                 end else if ((RD) && (read_burst_cnt_r < 3'b010)) begin
                                    next_state = BURST_READ;
                                 end else if ((read_burst_cnt_r <= 3'b010) && (rd_to_wr_count_r <= 4'd1))  begin
                                    next_state = COMMAND_WAIT;
                                 end
                              end // case: READ_WAIT

         WRITE_BANK_CONF    : begin
                                 if(auto_ref_r) begin
                                   if((wtp_count_r == 4'd0) && (ras_count_r == 4'b0000))
                                      next_state = PRECHARGE;
                                 end else if(bank_conf_r)begin
                                   if(no_precharge_r)
                                     next_state = ACTIVE;
                                   else if ((wtp_count_r == 4'b0000) && (ras_count_r == 4'b0000))
                                     next_state = PRECHARGE;
                                 end else if ((WR) && (wrburst_cnt_r < 3'b010)) begin
                                     next_state = BURST_WRITE;
                                 end else if ((WR) && (wrburst_cnt_r == 3'b010)) begin
                                     next_state = BURST_WRITE;
                                     burst_write = 1'd1;
                                 end else if ((wrburst_cnt_r <= 3'b010) && (wr_to_rd_count_r <= 4'd1))begin
                                     next_state = COMMAND_WAIT;
                                 end
                              end // case: BANK_WRITE_CONF

         READ_BANK_CONF     : begin
                                 if(auto_ref_r) begin
                                   if((rtp_count_r == 4'd0) && (ras_count_r == 4'b0000))
                                      next_state = PRECHARGE;
                                 end else if(bank_conf_r)begin
                                    if(no_precharge_r)
                                      next_state = ACTIVE;
                                    else if ((rtp_count_r == 4'b0000) && (ras_count_r == 4'b0000))
                                      next_state = PRECHARGE;
                                 end else if ((RD) && (read_burst_cnt_r == 3'b010)) begin
                                      next_state = BURST_READ;
                                      burst_read = 1'd1;
                                 end else if ((RD) && (read_burst_cnt_r < 3'b010)) begin
                                      next_state = BURST_READ;
                                 end else if ((read_burst_cnt_r <= 3'b010) && (rd_to_wr_count_r <= 4'd1))  begin
                                      next_state = COMMAND_WAIT;
                                 end
                              end // case: READ_BANK_CONF

         COMMAND_WAIT_CONF  : begin
                                 if(bank_conf_r) begin
                                   if(no_precharge_r)
                                      next_state = ACTIVE;
                                   else if(ras_count_r == 4'd0)
                                      next_state = PRECHARGE;
                                 end  else if (WR)
                                   next_state = BURST_WRITE;
                                 else if(RD)
                                   next_state = BURST_READ;
                                 else
                                    next_state = COMMAND_WAIT;
                              end  // case: COMMAND_WAIT_CONF

      endcase // case(state)
   end // always @ (...

   //register command outputs
   always @ (posedge clk0)
   begin
      if (rst) begin
         state_r1 <= 5'b00000;
         state_r2 <= 5'b00000;
         burst_read_r <= 1'd0;
         burst_write_r <= 1'd0;
         burst_read_r1 <= 1'd0;
         burst_read_r2 <= 1'd0;
      end else begin
         state_r1 <= state_r;
         state_r2 <= state_r1;
         burst_read_r <= burst_read;
         burst_write_r <= burst_write;
         burst_read_r1 <= burst_read_r;
         burst_read_r2 <= burst_read_r1;
      end
   end

   // commands to the memory
   always @ (posedge clk0)
   begin
      if (rst)
         ddr2_ras_r <= 1'b1;
      else if (state_r == AUTO_REFRESH || state_r == ACTIVE || state_r == PRECHARGE)
         ddr2_ras_r <= 1'b0;
      else ddr2_ras_r <= 1'b1;
   end

   // commands to the memory
   always @ (posedge clk0)
   begin
      if (rst)
         ddr2_cas_r <= 1'b1;
      else if (state_r == BURST_WRITE || state_r == BURST_READ || state_r == AUTO_REFRESH)
         ddr2_cas_r <= 1'b0;
      else
         ddr2_cas_r <= 1'b1;
   end // always @ (posedge clk0)

   // commands to the memory
   always @ (posedge clk0)
   begin
      if (rst)
         ddr2_we_r <= 1'b1;
      else if (state_r == BURST_WRITE || state_r == PRECHARGE )
         ddr2_we_r <= 1'b0;
      else ddr2_we_r <= 1'b1;
   end

   //register commands to the memory
   always @ (posedge clk0)
   begin
      if (rst) begin
         ddr2_ras_r1 <= 1'b1;
         ddr2_cas_r1 <= 1'b1;
         ddr2_we_r1 <= 1'b1;
      end else begin
         ddr2_ras_r1  <= ddr2_ras_r;
         ddr2_cas_r1  <= ddr2_cas_r;
         ddr2_we_r1   <= ddr2_we_r;
      end
   end

   always @ (posedge clk0)
   begin
      if (rst) begin
         row_addr_r[`row_address-1:0] <= `row_address'h0000;
      end else
         row_addr_r[`row_address-1:0] <= af_addr[`row_range_end:`row_range_start];
   end

   // chip enable generation logic

   always @(posedge clk0)
   begin
      if (rst)  begin
         ddr2_cs_r[`cs_width-1 : 0] <=  `cs_width'hF;
      end else begin
         if (af_addr_r[`cs_range_end:`cs_range_start]  ==  `chip_address'h0) begin
            ddr2_cs_r[`cs_width-1 : 0] <= `cs_width'hE;
         end  else if (af_addr_r[`cs_range_end:`cs_range_start] == `chip_address'h1) begin
            ddr2_cs_r[`cs_width-1 : 0] <= `cs_width'hD;
         end else if (af_addr_r[`cs_range_end:`cs_range_start] == `chip_address'h2) begin
            ddr2_cs_r[`cs_width-1 : 0] <= `cs_width'hB;
         end else if (af_addr_r[`cs_range_end:`cs_range_start] == `chip_address'h3) begin
            ddr2_cs_r[`cs_width-1 : 0] <= `cs_width'h7;
         end else
           ddr2_cs_r[`cs_width-1 : 0] <= `cs_width'hF;
      end // else: !if(rst)
   end // always@ (posedge clk0)

   always @ (posedge clk0)
   begin
      if (rst) begin
         ddr2_address_r <= `row_address'h0000;
      end else if ((state_r1 == ACTIVE)) begin // if (init_memory)
         ddr2_address_r <= row_addr_r;
      end else if (state_r1 == BURST_WRITE || state_r1 == BURST_READ) begin
         ddr2_address_r <= {zeroes[(`row_address - (`column_address+1))-1:0 ], af_addr_r1[`col_range_end:`col_range_start]};
      end else if ((state_r1 == PRECHARGE) && (state_r != ACTIVE) && auto_ref_r) begin
           ddr2_address_r <= `row_address'h0400;
      end else ddr2_address_r <= `row_address'h0000;
   end // always @ (posedge clk0)

   always @ (posedge clk0)
   begin
      if (rst) begin
         ddr2_ba_r[`bank_address-1:0] <= `bank_address'h0;
      end else if (state_r1 == PRECHARGE) begin
          if(bank_conf_r && ~bank_hit_r)
              ddr2_ba_r[`bank_address-1:0] <= bank_11_r[`bank_address+`row_address-1'b1:`row_address];
          else
              ddr2_ba_r[`bank_address-1:0] <= af_addr_r1[`bank_range_end:`bank_range_start];
      end else if((state_r1 == BURST_WRITE) || (state_r1 == BURST_READ) || (state_r1 == ACTIVE))
              ddr2_ba_r[`bank_address-1:0] <= af_addr_r1[`bank_range_end:`bank_range_start];
   end // always @ (posedge clk0)

   always @ (posedge clk0)
   begin
      if (rst) begin
         ddr2_cs_r1[`cs_width-1:0] <= `cs_width'hF;
      end else if ((state_r1 == AUTO_REFRESH )) begin
         if (auto_cnt_r == 3'h1) begin
            ddr2_cs_r1[`cs_width-1:0] <= `cs_width'hE;
         end else if (auto_cnt_r == 3'h2) begin
            ddr2_cs_r1[`cs_width-1:0] <= `cs_width'hD;
         end else if (auto_cnt_r == 3'h3) begin
            ddr2_cs_r1[`cs_width-1:0] <= `cs_width'hB;
         end else if (auto_cnt_r == 3'h4) begin
            ddr2_cs_r1[`cs_width-1:0] <= `cs_width'h7;
         end else
           ddr2_cs_r1[`cs_width-1:0] <= `cs_width'hF;
      end else if ((state_r1 == ACTIVE )||(state_r1 == PRECHARGE_WAIT ))  begin
         ddr2_cs_r1[`cs_width-1:0] <= ddr2_cs_r[`cs_width-1:0];
      end else
         ddr2_cs_r1[`cs_width-1:0] <= ddr2_cs_r1[`cs_width-1:0];
   end // always @ (posedge clk0)

   // odt

   always @ (posedge clk0)
   begin
      if (rst)
        odt_en_cnt_r <= 4'b0000;
      else if(((state_r == BURST_WRITE) && ~burst_write_r)&& odt_enable)
        odt_en_cnt_r <= ((add_lat + cas_lat  )-2);
      else if(((state_r == BURST_READ) && ~burst_read_r)&& odt_enable)
        odt_en_cnt_r <= ((add_lat + cas_lat )-1);
      else if(odt_en_cnt_r != 4'b0000)
        odt_en_cnt_r <= odt_en_cnt_r - 1'b1;
      else
        odt_en_cnt_r <= 4'b0000;
   end

   always @ (posedge clk0)
   begin
      if (rst)
        odt_cnt_r <= 4'b0000;
      else if((state_r == BURST_WRITE) )
        odt_cnt_r <= ((add_lat + cas_lat + burst_cnt));
      else if((state_r == BURST_READ) )
        odt_cnt_r <= ((add_lat + cas_lat + burst_cnt+1));
      else if(odt_cnt_r != 4'b0000)
        odt_cnt_r <= odt_cnt_r - 1'b1;
      else
        odt_cnt_r <= 4'b0000;
   end

   always @ (posedge clk0)
   begin
      if (rst)
        odt_en  <= `cs_width'h0;
      else if((odt_en_cnt_r == 4'b0001))
        odt_en  <= `cs_width'hF;
      else if (odt_cnt_r == 4'b0010)
        odt_en  <= `cs_width'h0;
   end

   always @ (posedge clk0)
   begin
      if (rst)
         ddr2_cs_r2  <= `cs_width'h0;
      else
         ddr2_cs_r2  <= ddr2_cs_r1;
   end

   assign ctrl_address[`row_address-1:0]  = ddr2_address_r[`row_address-1:0];
   assign ctrl_ba [`bank_address-1:0]     = ddr2_ba_r[`bank_address-1:0];
   assign ctrl_ras_n = ddr2_ras_r1;
   assign ctrl_cas_n = ddr2_cas_r1;
   assign ctrl_we_n  = ddr2_we_r1;
   assign ctrl_odt  = odt_en;
   assign ctrl_cs_n = 2'd0;

endmodule


 

