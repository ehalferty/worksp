///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_test_bench_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module is the synthesizable test bench for the memory
//                  interface. This Test bench is to compare the write and the
//                  read data and generate an error flag.
///////////////////////////////////////////////////////////////////////////////

`define idle  3'b000
`define write 3'b001
`define read  3'b010

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_test_bench_0 (
   input                              clk_0,
   input                              sys_rst,
   input                              WDF_ALMOST_FULL,
   input                              AF_ALMOST_FULL,
   input [2:0]                        BURST_LENGTH,
   input                              READ_DATA_VALID,
   input [(`dq_width*2)-1:0]          READ_DATA_FIFO_OUT,
   input                              phy_init_initialization_done,

   output [35:0]                      APP_AF_ADDR,
   output                             APP_AF_WREN,
   output [(`dq_width*2)-1:0]         APP_WDF_DATA,
   output [(`dm_width*2)-1:0]         APP_MASK_DATA,
   output                             APP_WDF_WREN,
   output                             ERROR,
   output                             ERROR_REG
                   );

   reg [2:0]     state;
   reg [2:0]     burst_count;
   reg           write_data_en;
   reg           write_addr_en;
   reg [3:0]     state_cnt;

   wire [(`dq_width*2)-1:0]   app_cmp_data;
   wire [2:0]                 burst_len;

   assign burst_len = BURST_LENGTH;

// State Machine for writing to WRITE DATA & ADDRESS FIFOs
// state machine changed for low FIFO threshold values
   always @ (posedge clk_0)
   begin
      if (sys_rst == 1'b1)   // State Machine in IDLE state
      begin
         write_data_en <= 1'b0;
         write_addr_en <= 1'b0;
         state[2:0]     <= `idle;
         state_cnt <= 4'b0000;

      end
      else
      begin

         case (state[2:0])
         3'b000: begin // idle
                    write_data_en <= 1'b0;
                    write_addr_en <= 1'b0;
                    if (WDF_ALMOST_FULL == 1'b0 && AF_ALMOST_FULL == 1'b0 && phy_init_initialization_done)
                    begin
                       state[2:0]       <= `write;
                       burst_count[2:0] <=  burst_len; // Burst length divided by 2
                    end
                    else
                    begin
                        state[2:0]       <= `idle;
                        burst_count[2:0] <= 3'b000;
                    end
                 end // case: 3'b000

         3'b001: begin // write
                    if (WDF_ALMOST_FULL == 1'b0 && AF_ALMOST_FULL == 1'b0)
                    begin
                       if(state_cnt == 4'd8)
                       begin
                          state <= `read;
                          state_cnt <= 4'd0;
                          write_data_en    <= 1'b1;
                       end
                       else
                       begin
                          state[2:0]       <= `write;
                          write_data_en    <= 1'b1;
                       end

                       if (burst_count[2:0] != 3'b000)
                          burst_count[2:0] <= burst_count[2:0] - 1'b1;
                       else
                          burst_count[2:0] <=  burst_len - 1'b1;

                       if (burst_count[2:0] == 3'b001)
                       begin
                          write_addr_en  <= 1'b1;
                          state_cnt <= state_cnt + 1'b1;
                       end
                       else
                          write_addr_en  <= 1'b0;
                    end
                    else
                    begin
                       write_addr_en    <= 1'b0;
                       write_data_en    <= 1'b0;
                    end
                 end // case: 3'b001

         3'b010: begin // read
                    if ( AF_ALMOST_FULL == 1'b0)
                    begin
                       if(state_cnt == 4'd8)
                       begin
                          write_addr_en  <= 1'b0;
                          if (WDF_ALMOST_FULL == 1'b0)
                          begin
                             state_cnt <= 4'd0;
                             state <= `write;
                          end
                       end
                       else
                       begin
                          state[2:0]       <= `read;
                          write_addr_en  <= 1'b1;
                          write_data_en    <= 1'b0;
                          state_cnt <= state_cnt + 1;
                       end // else: !if(state_cnt == 4'd7)
                    end
                 // Modified to fix the dead lock condition
                    else
                    begin
                       if(state_cnt == 4'd8)
                       begin
                          state[2:0]       <= `idle;
                          write_addr_en    <= 1'b0;
                          write_data_en    <= 1'b0;
                          state_cnt        <= 4'd0;
                       end
                       else
                       begin
                          state[2:0]       <= `read; // it will remain in read state till it completes 8 reads
                          write_addr_en    <= 1'b0;
                          write_data_en    <= 1'b0;
                          state_cnt        <= state_cnt; // state count will retain
                       end
                    end
                 end // case: 3'b001

         default: begin
                     write_data_en <= 1'b0;
                     write_addr_en <= 1'b0;
                     state[2:0]    <= `idle;
                  end
         endcase
      end
   end

   mem_test_cmp_0 cmp_rd_data_00 (
                             .CLK                  (clk_0),
                             .RESET                (sys_rst),
                             .READ_DATA_VALID      (READ_DATA_VALID),
                             .APP_COMPARE_DATA     (app_cmp_data),
                             .READ_DATA_FIFO_OUT   (READ_DATA_FIFO_OUT),
                             .ERROR                (ERROR),
                             .ERROR_REG            (ERROR_REG)
                             );

   mem_test_rom_0 backend_rom_00 (
                             .clk0                 (clk_0),
                             .rst                  (sys_rst),
                             .bkend_data_en        (write_data_en),
                             .bkend_wraddr_en      (write_addr_en),
                             .bkend_rd_data_valid  (READ_DATA_VALID),
                             .app_af_addr          (APP_AF_ADDR),
                             .app_af_WrEn          (APP_AF_WREN),
                             .app_Wdf_data         (APP_WDF_DATA),
                             .app_mask_data        (APP_MASK_DATA),
                             .app_compare_data     (app_cmp_data),
                             .app_Wdf_WrEn         (APP_WDF_WREN)
                             );

endmodule
