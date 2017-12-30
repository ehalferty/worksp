///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_usr_rd_fifo_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module instantiates the distributed RAM which stores the
//                  read data from the memory.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_usr_rd_fifo_0 (
   input                       CLK,
   input                       RESET,
   input                       FIFO_RD_EN,
   input                       READ_EN_DELAYED_RISE,
   input                       READ_EN_DELAYED_FALL,
   input [`memory_width-1:0]   READ_DATA_RISE,
   input [`memory_width-1:0]   READ_DATA_FALL,

   output                      READ_DATA_VALID,
   output [`memory_width-1:0]  READ_DATA_FIFO_RISE,
   output [`memory_width-1:0]  READ_DATA_FIFO_FALL

                     );

   reg [`memory_width*2-1:0]  fifos_data_out1;
   reg [3:0]                  fifo_rd_addr;
   reg [3:0]                  rise0_wr_addr;
   reg [3:0]                  fall0_wr_addr;
   reg                        fifo_read_en;
   reg                        fifo_rd_en_r1;
   reg                        fifo_rd_en_r2;
   reg [`memory_width-1:0]    rise_fifo_data;
   reg [`memory_width-1:0]    fall_fifo_data;

   wire [`memory_width-1:0]   rise_fifo_out;
   wire [`memory_width-1:0]   fall_fifo_out;

   assign READ_DATA_VALID                         = fifo_rd_en_r2;
   assign READ_DATA_FIFO_FALL[`memory_width-1:0]  =  fifos_data_out1[`memory_width-1:0];
   assign READ_DATA_FIFO_RISE[`memory_width-1:0]  =  fifos_data_out1[`memory_width*2-1 : `memory_width];

// Read Pointer and fifo data output sequencing

// Read Enable generation for fifos based on write enable

   always @ (posedge CLK)
   begin
        if (RESET == 1'b1)
          begin
            fifo_read_en             <= 1'b0;
            fifo_rd_en_r1          <= 1'b0;
            fifo_rd_en_r2          <= 1'b0;
          end
        else
          begin
            fifo_read_en             <= FIFO_RD_EN ;
            fifo_rd_en_r1          <= fifo_read_en;
            fifo_rd_en_r2          <= fifo_rd_en_r1;
          end
   end

   // Write Pointer increment for FIFOs

   always @ (posedge CLK)
   begin
     if (RESET == 1'b1)
       rise0_wr_addr[3:0] <= 4'h0;
     else if (READ_EN_DELAYED_RISE == 1'b1)
       rise0_wr_addr[3:0] <= rise0_wr_addr[3:0] + 1'b1;
   end

   always @ (posedge CLK)
   begin
     if (RESET == 1'b1)
       fall0_wr_addr[3:0] <= 4'h0;
     else if (READ_EN_DELAYED_FALL == 1'b1)
       fall0_wr_addr[3:0] <= fall0_wr_addr[3:0] + 1'b1;
   end

///////////////////////////////// FIFO Data Output Sequencing //////////////////////////////////////////////////////

   always @ (posedge CLK)
   begin
     if (RESET == 1'b1)
       begin
         rise_fifo_data[`memory_width-1:0] <= `memory_width'd0;
         fall_fifo_data[`memory_width-1:0] <= `memory_width'd0;
         fifo_rd_addr[3:0]   <= 4'h0;
       end
     else if (fifo_read_en == 1'b1)
       begin
         rise_fifo_data[`memory_width-1:0] <= rise_fifo_out[`memory_width-1:0];
         fall_fifo_data[`memory_width-1:0] <= fall_fifo_out[`memory_width-1:0];
         fifo_rd_addr[3:0]                 <= fifo_rd_addr[3:0] + 1'b1;
       end
   end

   always @ (posedge CLK)
   begin
     if (RESET == 1'b1)
       fifos_data_out1[`memory_width*2-1:0] <= 16'h0000;
     else if (fifo_rd_en_r1 == 1'b1)
       begin
           fifos_data_out1[`memory_width*2-1:0] <= {rise_fifo_data[`memory_width-1:0],fall_fifo_data[`memory_width-1:0]};
       end
   end

//*************************************************************************************************************************
// Distributed RAM 4 bit wide FIFO instantiations (2 FIFOs per strobe, rising edge data fifo and falling edge data fifo)
//*************************************************************************************************************************
// FIFOs associated with DQS(0)

   mem_RAM_D_0 ram_rise0
           (
             .DPO          (rise_fifo_out[`memory_width-1:0]),
             .A0           (rise0_wr_addr[0]),
             .A1           (rise0_wr_addr[1]),
             .A2           (rise0_wr_addr[2]),
             .A3           (rise0_wr_addr[3]),
             .D            (READ_DATA_RISE[`memory_width-1:0]),
             .DPRA0        (fifo_rd_addr[0]),
             .DPRA1        (fifo_rd_addr[1]),
             .DPRA2        (fifo_rd_addr[2]),
             .DPRA3        (fifo_rd_addr[3]),
             .WCLK         (CLK),
             .WE           (READ_EN_DELAYED_RISE)
            );

   mem_RAM_D_0 ram_fall0
           (
             .DPO          (fall_fifo_out[`memory_width-1:0]),
             .A0           (fall0_wr_addr[0]),
             .A1           (fall0_wr_addr[1]),
             .A2           (fall0_wr_addr[2]),
             .A3           (fall0_wr_addr[3]),
             .D            (READ_DATA_FALL[`memory_width-1:0]),
             .DPRA0        (fifo_rd_addr[0]),
             .DPRA1        (fifo_rd_addr[1]),
             .DPRA2        (fifo_rd_addr[2]),
             .DPRA3        (fifo_rd_addr[3]),
             .WCLK         (CLK),
             .WE           (READ_EN_DELAYED_FALL)
            );

endmodule
