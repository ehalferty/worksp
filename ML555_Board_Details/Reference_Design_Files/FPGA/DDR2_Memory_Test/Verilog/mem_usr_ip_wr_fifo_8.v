///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename:mem_usr_ip_wr_fifo_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description    : This module instantiates the block RAM based FIFO to store
//                 the user interface data into it and read after a specified
//                 amount in already written. The reading starts when the almost
//                 full signal is generated whose offset is programmable.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module mem_usr_ip_wr_fifo_8 (
   input          clk0,
   input          clk90,
   input          rst,
   input          rst90,

   //wdf signals
   input [15:0]   app_Wdf_data,
   input [1:0]    app_mask_data,
   output [15:0]  Wdf_data,
   output [1:0]   mask_data,
   input          app_Wdf_WrEn,
   input          ctrl_Wdf_RdEn,
   input          phy_init_wdf_rden,
   output         wr_df_almost_full

                         );

   reg         ctrl_Wdf_RdEn_270;
   reg         phy_init_wdf_rden_270;
   reg         ctrl_Wdf_RdEn_90;

   reg         init_wren;
   reg [31:0]  init_data;
   reg [2:0]   init_count;
   reg         init_flag;

   wire [31:0] fifo_data_out;
   wire [3:0]  fifo_mask_out;
   wire [31:0] fifo_data_in  = {{16{1'b0}}, app_Wdf_data};
   wire [3:0]  fifo_mask_in  = {{2{1'b0}}, app_mask_data};

   assign Wdf_data   = fifo_data_out[15:0];
   assign mask_data  = fifo_mask_out[1:0];

   always @(negedge clk90)
   begin
      if(rst90)begin
           ctrl_Wdf_RdEn_270 <= 1'd0;
           phy_init_wdf_rden_270 <= 1'd0;
      end else begin
           ctrl_Wdf_RdEn_270 <= ctrl_Wdf_RdEn;
           phy_init_wdf_rden_270 <= phy_init_wdf_rden;
      end
   end

   always @(posedge clk90)
   begin
      if(rst90)
         ctrl_Wdf_RdEn_90 <= 1'd0;
      else
         ctrl_Wdf_RdEn_90 <= ctrl_Wdf_RdEn_270 | phy_init_wdf_rden_270;
   end

   always @(posedge clk0)
   begin
      if(rst) begin
         init_count <= 3'd0;
         init_wren <= 1'd0;
         init_data <= 32'd0;
         init_flag <= 1'd0;
      end else begin
         case(init_count)
            3'd0: begin
                     if(init_flag)begin
                        init_count <= 3'd0;
                        init_wren <= 1'd0;
                        init_data <= 32'h0000_0000;
                     end else begin
                        init_count <= 3'd1;
                        init_wren <= 1'd1;
                        init_data <= 32'hffff_ffff;
                     end
                  end
            3'd1: begin
                     init_count <= 3'd2;
                     init_wren <= 1'd1;
                     init_data <= 32'h0000_0000;
                  end
            3'd2: begin
                     init_count <= 3'd3;
                     init_wren <= 1'd1;
                     init_data <= 32'hffff_ffff;
                  end
            3'd3: begin
                     init_count <= 3'd4;
                     init_wren <= 1'd1;
                     init_data <= 32'h0000_0000;
                  end
            3'd4: begin
                     init_count <= 3'd5;
                     init_wren <= 1'd1;
                     init_data <= 32'h5555_5555;
                  end
            3'd5: begin
                     init_count <= 3'd6;
                     init_wren <= 1'd1;
                     init_data <= 32'h6666_6666;
                  end
            3'd6: begin
                     init_count <= 3'd7;
                     init_wren <= 1'd1;
                     init_data <= 32'h9999_9999;
                  end
            3'd7: begin
                     init_wren <= 1'd1;
                     init_data <= 32'h0000_0000;
                     init_flag <= 1'd1;
                     init_count <= 3'd0;
                  end
         endcase // case(init_count)
      end // else: !if(rst)
   end // always@ (clk0)

   defparam Wdf_1.ALMOST_FULL_OFFSET = 12'h00F;
   defparam Wdf_1.ALMOST_EMPTY_OFFSET = 12'h007;
   defparam Wdf_1.DATA_WIDTH = 36;
   defparam Wdf_1.DO_REG = 1;
   defparam Wdf_1.EN_SYN = "FALSE";
   defparam Wdf_1.FIRST_WORD_FALL_THROUGH = "FALSE";

   FIFO36  Wdf_1(
              .ALMOSTEMPTY         (),
              .ALMOSTFULL          (wr_df_almost_full),
              .DI                  (fifo_data_in[31:0] | init_data),
              .DIP                 (fifo_mask_in[3:0]),
              .EMPTY               (),
              .FULL                (),
              .RDCOUNT             (),
              .RDERR               (),
              .WRCOUNT             (),
              .WRERR               (),
              .DO                  (fifo_data_out[31:0]),
              .DOP                 (fifo_mask_out[3:0]),
              .RDCLK               (clk90),
              .RDEN                (ctrl_Wdf_RdEn_90),
              .RST                 (rst90),
              .WRCLK               (clk0),
              .WREN                (app_Wdf_WrEn | init_wren)
             );

endmodule

