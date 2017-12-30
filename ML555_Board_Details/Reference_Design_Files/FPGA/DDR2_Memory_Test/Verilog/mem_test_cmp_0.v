///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_test_cmp_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module generates the error signal in case of bit errors.
//                  It compares the read data with expected data value.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_test_cmp_0 (
   input                      CLK,
   input                      RESET,
   input                      READ_DATA_VALID,
   input [(`dq_width*2)-1:0]  APP_COMPARE_DATA,
   input [(`dq_width*2)-1:0]  READ_DATA_FIFO_OUT,

   output reg                 ERROR,
   output wire                ERROR_REG
                    );

   reg                      valid;
   reg [`dm_width-1:0]      byte_err_rising;
   reg [`dm_width-1:0]      byte_err_falling;

   wire [`dm_width-1:0]     byte_err_rising_w;
   wire [`dm_width-1:0]     byte_err_falling_w;

   reg                      valid_1;
   reg [(`dq_width*2)-1:0]  read_data_r;
   reg [(`dq_width*2)-1:0]  read_data_r2;
   reg [(`dq_width*2)-1:0]  write_data_r2;

   wire [`dq_width-1:0]     data_pattern_falling;
   wire [`dq_width-1:0]     data_pattern_rising;
   wire [`dq_width-1:0]     data_falling;
   wire [`dq_width-1:0]     data_rising;
   reg                      falling_error;
   reg                      rising_error;

   wire                     byte_err_rising_a;
   wire                     byte_err_falling_a;

   assign data_falling         = read_data_r2[`dq_width-1:0];
   assign data_rising          = read_data_r2[(`dq_width*2)-1:`dq_width];

   assign data_pattern_falling = write_data_r2[`dq_width-1:0];
   assign data_pattern_rising  = write_data_r2[(`dq_width*2)-1:`dq_width];

    assign byte_err_falling_w[0] =   ((valid_1 == 1'b1) && (data_falling[7:0] != data_pattern_falling[7:0]))? 1'b1 : 1'b0;

 assign byte_err_falling_w[1] =   ((valid_1 == 1'b1) && (data_falling[15:8] != data_pattern_falling[15:8]))? 1'b1 : 1'b0;

 assign byte_err_falling_w[2] =   ((valid_1 == 1'b1) && (data_falling[23:16] != data_pattern_falling[23:16]))? 1'b1 : 1'b0;

 assign byte_err_falling_w[3] =   ((valid_1 == 1'b1) && (data_falling[31:24] != data_pattern_falling[31:24]))? 1'b1 : 1'b0;

 assign byte_err_falling_w[4] =   ((valid_1 == 1'b1) && (data_falling[39:32] != data_pattern_falling[39:32]))? 1'b1 : 1'b0;

 assign byte_err_falling_w[5] =   ((valid_1 == 1'b1) && (data_falling[47:40] != data_pattern_falling[47:40]))? 1'b1 : 1'b0;

 assign byte_err_falling_w[6] =   ((valid_1 == 1'b1) && (data_falling[55:48] != data_pattern_falling[55:48]))? 1'b1 : 1'b0;

 assign byte_err_falling_w[7] =   ((valid_1 == 1'b1) && (data_falling[63:56] != data_pattern_falling[63:56]))? 1'b1 : 1'b0;

 //MDassign byte_err_falling_w[8] =   ((valid_1 == 1'b1) && (data_falling[71:64] != data_pattern_falling[71:64]))? 1'b1 : 1'b0;

    assign byte_err_rising_w[0] =   ((valid_1 == 1'b1) && (data_rising[7:0] != data_pattern_rising[7:0]))? 1'b1 : 1'b0;

 assign byte_err_rising_w[1] =   ((valid_1 == 1'b1) && (data_rising[15:8] != data_pattern_rising[15:8]))? 1'b1 : 1'b0;

 assign byte_err_rising_w[2] =   ((valid_1 == 1'b1) && (data_rising[23:16] != data_pattern_rising[23:16]))? 1'b1 : 1'b0;

 assign byte_err_rising_w[3] =   ((valid_1 == 1'b1) && (data_rising[31:24] != data_pattern_rising[31:24]))? 1'b1 : 1'b0;

 assign byte_err_rising_w[4] =   ((valid_1 == 1'b1) && (data_rising[39:32] != data_pattern_rising[39:32]))? 1'b1 : 1'b0;

 assign byte_err_rising_w[5] =   ((valid_1 == 1'b1) && (data_rising[47:40] != data_pattern_rising[47:40]))? 1'b1 : 1'b0;

 assign byte_err_rising_w[6] =   ((valid_1 == 1'b1) && (data_rising[55:48] != data_pattern_rising[55:48]))? 1'b1 : 1'b0;

 assign byte_err_rising_w[7] =   ((valid_1 == 1'b1) && (data_rising[63:56] != data_pattern_rising[63:56]))? 1'b1 : 1'b0;

 //MDassign byte_err_rising_w[8] =   ((valid_1 == 1'b1) && (data_rising[71:64] != data_pattern_rising[71:64]))? 1'b1 : 1'b0;


   assign byte_err_rising_a  = |byte_err_rising[`dq_width/8-1:0];
   assign byte_err_falling_a = |byte_err_falling[`dq_width/8-1:0];

   always @ (posedge CLK)
   begin
      byte_err_rising[`dm_width-1:0]  <= byte_err_falling_w[`dm_width-1:0];
      byte_err_falling[`dm_width-1:0] <= byte_err_rising_w[`dm_width-1:0];
   end

   always @ (posedge CLK)
   begin
      if (RESET == 1'b1)
      begin
         rising_error  <= 1'b0;
         falling_error <= 1'b0;
         ERROR         <= 1'b0;
      end
      else
      begin
         rising_error  <= byte_err_rising_a;
         falling_error <= byte_err_falling_a;
         ERROR         <= rising_error || falling_error;
      end
   end

   always @ (posedge CLK)
   begin
      if (RESET == 1'b1)
         read_data_r <= `dq_width*2'd0;
      else
         read_data_r <= READ_DATA_FIFO_OUT;
   end

   always @ (posedge CLK)
   begin
      if (RESET == 1'b1)
      begin
         read_data_r2 <= `dq_width*2'd0;
         write_data_r2 <= `dq_width*2'd0;
      end
      else
      begin
         read_data_r2 <= read_data_r;
         write_data_r2 <= APP_COMPARE_DATA;
      end
   end

   always @ (posedge CLK)
   begin
      if (RESET == 1'b1)
      begin
         valid   <= 1'b0;
         valid_1 <= 1'b0;
      end
      else
      begin
         valid   <= READ_DATA_VALID;
         valid_1 <= valid;
      end
   end

   always @ (posedge CLK)
   begin
      if (ERROR)
         $display ("ERROR at time %t" , $time);
   end

//MD chipscope files



reg [15:0] error_count;
wire       matts_error_notify;
always @ (posedge ERROR or posedge RESET)
begin
  if(RESET)
  begin
    error_count <= 16'h00;
  end
  else
  if(ERROR)
  begin
    error_count <= error_count + 1'b1;
  end
  else
  begin
    error_count <= error_count;
  end
end
assign matts_error_notify = (error_count != 16'h00);

assign ERROR_REG = ~matts_error_notify;

//endmodule

  //-----------------------------------------------------------------
  //
  //  ICON core wire declarations
  //
  //-----------------------------------------------------------------
  wire [35:0] control0;


  //-----------------------------------------------------------------
  //
  //  ICON core instance
  //
  //-----------------------------------------------------------------
  small_icon i_small_icon
    (
      .control0(control0)
    );


//-----------------------------------------------------------------
  //
  //  ILA Core wire declarations
  //
  //-----------------------------------------------------------------

  wire [15:0] trig0;

  assign trig0 = {byte_err_falling_w[7:0], byte_err_rising_w[7:0]};


  //-----------------------------------------------------------------
  //
  //  ILA core instance
  //
  //-----------------------------------------------------------------
  small_ila i_small_ila
    (
      .control(control0),
      .clk(CLK),
      .trig0(trig0)
    );


endmodule

//-------------------------------------------------------------------
//
//  ICON core module declaration
//
//-------------------------------------------------------------------
module small_icon 
  (
      control0
  );
  output [35:0] control0;
endmodule



//-------------------------------------------------------------------
//
//  ILA core module declaration
//
//-------------------------------------------------------------------
module small_ila
  (
    control,
    clk,
    trig0
  );
  input [35:0] control;
  input clk;
  input [15:0] trig0;
endmodule







