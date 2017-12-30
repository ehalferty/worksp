///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_usr_rd_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : The delay between the read data with respect to the command
//                  issued is calculted in terms of no. of clocks. This data is
//                  then stored into the FIFOs and then read back and given as
//                  the ouput for comparison.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_usr_rd_0 (
   input                           CLK,
   input                           RESET,
   input [`data_width-1:0]         READ_DATA_RISE,
   input [`data_width-1:0]         READ_DATA_FALL,
   input [`data_strobe_width-1:0]  CTRL_RDEN,
   output                          READ_DATA_VALID,
   output [`data_width-1:0]        READ_DATA_FIFO_RISE,
   output [`data_width-1:0]        READ_DATA_FIFO_FALL

                     );

   wire [`data_strobe_width-1:0]  READ_EN_DELAYED_RISE;
   wire [`data_strobe_width-1:0]  READ_EN_DELAYED_FALL;

   reg fifo_read_enable_r;
   reg fifo_read_enable_2r;
   reg fifo_read_enable_3r;
   reg fifo_read_enable_4r;

   wire  [`data_strobe_width-1:0] rd_data_valid;

   assign READ_DATA_VALID = rd_data_valid[0];

   always @ (posedge CLK)
   begin
      if (RESET == 1'b1)
        begin
          fifo_read_enable_r  <= 1'b0;
          fifo_read_enable_2r <= 1'b0;
          fifo_read_enable_3r <= 1'b0;
          fifo_read_enable_4r <= 1'b0;
          end
      else
      begin
          fifo_read_enable_r  <= CTRL_RDEN[0];
          fifo_read_enable_2r <= fifo_read_enable_r;
          fifo_read_enable_3r <= fifo_read_enable_2r;
          fifo_read_enable_4r <= fifo_read_enable_3r;
      end
   end

   genvar fifo_i;
   generate
      for(fifo_i= 0; fifo_i < `data_strobe_width; fifo_i = fifo_i+1)
      begin:fifo_inst
          mem_usr_rd_fifo_0 rd_data_fifo_0
                   (
                         .CLK                   (CLK),
                         .RESET                 (RESET),
                         .FIFO_RD_EN            (fifo_read_enable_4r),
                         .READ_EN_DELAYED_RISE  (CTRL_RDEN[fifo_i]),
                         .READ_EN_DELAYED_FALL  (CTRL_RDEN[fifo_i]),
                         .READ_DATA_RISE        (READ_DATA_RISE[((fifo_i*(`memory_width))+(`memory_width-1)):fifo_i*(`memory_width)]),
                         .READ_DATA_FALL        (READ_DATA_FALL[((fifo_i*(`memory_width))+(`memory_width-1)):fifo_i*(`memory_width)]),
                         .READ_DATA_FIFO_RISE   (READ_DATA_FIFO_RISE[((fifo_i*(`memory_width))+(`memory_width-1)):fifo_i*(`memory_width)]),
                         .READ_DATA_FIFO_FALL   (READ_DATA_FIFO_FALL[((fifo_i*(`memory_width))+(`memory_width-1)):fifo_i*(`memory_width)]),
                         .READ_DATA_VALID       (rd_data_valid[fifo_i])
                        );

      end // block: fifo_inst
   endgenerate

endmodule
