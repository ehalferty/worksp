//------------------------------------------------------------------------------
//
// Copyright (C) 2006, Xilinx, Inc. All Rights Reserved.
//
// This file is owned and controlled by Xilinx and must be used solely
// for design, simulation, implementation and creation of design files
// limited to Xilinx devices or technologies. Use with non-Xilinx
// devices or technologies is expressly prohibited and immediately
// terminates your license.
//
// Xilinx products are not intended for use in life support
// appliances, devices, or systems. Use in such applications is
// expressly prohibited.
//
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor      : Xilinx
// \   \   \/     Version     : 1.2
//  \   \         Application : Example Completer design for PCI Express
//  /   /         Filename    : completer_mem_block_top.v
// /___/   /\     Module      : completer_mem_block_top
// \   \  /  \
//  \___\/\___\
//
//------------------------------------------------------------------------------
`timescale  1 ns / 10 ps

module completer_mem_block_top 
(
  clock,
  reset_n,
  completer_id,
  maxp,
  tc_status,
  tx_posted_ready,
  tx_non_posted_ready,
  tx_completion_ready,
  tx_config_ready,
  tx_tc_select,
  tx_fifo_select,
  tx_enable,
  tx_header,
  tx_first,
  tx_last,
  tx_discard,
  tx_data,
  tx_complete,
  rx_posted_available,
  rx_non_posted_available,
  rx_completion_available,
  rx_config_available,
  rx_posted_partial,
  rx_non_posted_partial,
  rx_completion_partial,
  rx_config_partial,
  rx_tc_select,
  rx_fifo_select,
  rx_request,
  rx_request_end,
  rx_valid,
  rx_header,
  rx_first,
  rx_last,
  rx_discard,
  rx_data,
  leds_out,
  mem_debug);

  parameter G_USER_WIDTH = 64;
  parameter G_TC_NUMBER = 0;
  parameter G_BAR0_MASK_WIDTH = 20;
  parameter G_RAM_READ_LATENCY = 1; // only 1 or 2 supported

  input clock;
  input reset_n;
  input [15:0] completer_id;
  input [2:0] maxp;
  input [7:0] tc_status;
  input [7:0] tx_posted_ready;
  input [7:0] tx_non_posted_ready;
  input [7:0] tx_completion_ready;
  input tx_config_ready;
  output [2:0] tx_tc_select;
  wire [2:0] tx_tc_select;
  output [1:0] tx_fifo_select;
  wire [1:0] tx_fifo_select;
  output [(G_USER_WIDTH/32)-1:0] tx_enable;
  wire [(G_USER_WIDTH/32)-1:0] tx_enable;
  output tx_header;
  wire tx_header;
  output tx_first;
  wire tx_first;
  output tx_last;
  wire tx_last;
  
  output tx_discard;
  wire tx_discard;
  output [G_USER_WIDTH-1:0] tx_data;
  wire [G_USER_WIDTH-1:0] tx_data;
  output tx_complete;
  wire tx_complete;
  input [7:0] rx_posted_available;
  input [7:0] rx_non_posted_available;
  input [7:0] rx_completion_available;
  input rx_config_available;
  input [7:0] rx_posted_partial;
  input [7:0] rx_non_posted_partial;
  input [7:0] rx_completion_partial;
  input rx_config_partial;
  output [2:0] rx_tc_select;
  wire [2:0] rx_tc_select;
  output [1:0] rx_fifo_select;
  wire [1:0] rx_fifo_select;
  output rx_request;
  wire rx_request;
  input rx_request_end;
  input [(G_USER_WIDTH/32)-1:0] rx_valid;
  input rx_header;
  input rx_first;
  input rx_last;
  input rx_discard;
  input [G_USER_WIDTH-1:0] rx_data;
  output [7:0] leds_out;
  wire [7:0] leds_out;
  output [31:0] mem_debug;
  wire [31:0] mem_debug;


  // Internal signal declarations
  wire logic1;
  wire [G_USER_WIDTH-1:0] ram_data_in;
  wire [G_USER_WIDTH-1:0] ram_data_out;
  wire [(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32):0] ram_read_address;
  wire [(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32):0] ram_write_address;
  wire [(G_USER_WIDTH/8)-1:0] ram_write_enables;

  wire [G_USER_WIDTH - 1:0] ram_data_in_x;
  reg [G_USER_WIDTH - 1:0] ram_data_in_reg;
  
  reg [7:0] rx_posted_available_r1;
  reg [7:0] rx_posted_available_r2;
  reg [7:0] rx_posted_partial_r1;
  reg [7:0] rx_posted_partial_r2;

//------------------------------------------------------------------------------
//MODULE BODY
//------------------------------------------------------------------------------
  assign logic1 = 1'b1;
  assign mem_debug = {32{1'b0}};

  // Instance port mappings.
  completer_mem_block_machine #(
    .G_READ_LATENCY          (G_RAM_READ_LATENCY),
    .G_TC_NUMBER             (G_TC_NUMBER),
    .G_USER_WIDTH            (G_USER_WIDTH),
    .G_BAR0_MASK_WIDTH       (G_BAR0_MASK_WIDTH))
  I0(
    .clock                   (clock),
    .reset_n                 (reset_n),

    .completer_id            (completer_id),
    .maxp                    (maxp),

    .tc_status               (tc_status),
    .tx_posted_ready         (tx_posted_ready),
    .tx_non_posted_ready     (tx_non_posted_ready),
    .tx_completion_ready     (tx_completion_ready),
    .tx_config_ready         (tx_config_ready),
    .tx_tc_select            (tx_tc_select),
    .tx_fifo_select          (tx_fifo_select),
    .tx_enable               (tx_enable),
    .tx_header               (tx_header),
    .tx_first                (tx_first),
    .tx_last                 (tx_last),
    .tx_discard              (tx_discard),
    .tx_data                 (tx_data),
    .tx_complete             (tx_complete),

    .rx_posted_available     (rx_posted_available),
    .rx_non_posted_available (rx_non_posted_available),
    .rx_completion_available (rx_completion_available),
    .rx_config_available     (rx_config_available),
    .rx_posted_partial       (rx_posted_partial),
    .rx_non_posted_partial   (rx_non_posted_partial),
    .rx_completion_partial   (rx_completion_partial),
    .rx_config_partial       (rx_config_partial),

    .rx_tc_select            (rx_tc_select),
    .rx_fifo_select          (rx_fifo_select),
    .rx_request              (rx_request),
    .rx_request_end          (rx_request_end),
    .rx_valid                (rx_valid),
    .rx_header               (rx_header),
    .rx_first                (rx_first),
    .rx_last                 (rx_last),
    .rx_discard              (rx_discard),
    .rx_data                 (rx_data),

    .ram_write_address       (ram_write_address),
    .ram_write_enables       (ram_write_enables),
    .ram_data_out            (ram_data_out),
    .ram_read_address        (ram_read_address),
    .ram_data_in             (ram_data_in),
    .leds_out                (leds_out));
  
  
      completer_mem_block #(
        .G_RAM_READ_LATENCY      (G_RAM_READ_LATENCY),  // only 1 or 2 is supported
        .G_RAM_DEPTH             (2),  // only 1 or 2 is supported
        .G_RAM_SIZE              (16)  // only 16 is supported
        )
      mem (
        .write_clock             (clock),
        .write_clock_en          (logic1), // not used currently
        .read_clock              (clock),
        .read_clock_en           (logic1), // not used currently
        // RAM interface
        .write_a                 (ram_write_address[15:0]),
        .write_we                (ram_write_enables),
        .write_d                 (ram_data_out),
        .read_a                  (ram_read_address[15:0]),
        .read_d                  (ram_data_in_x));
  

  // if the memory completer gets unitialised data from the RAM the packets will contain X's
  // so for simulations need to remove U's
  integer index;
  always @(ram_data_in_x or reset_n)
    begin
    for(index=0;index<G_USER_WIDTH;index=index+1)
      begin
      ram_data_in_reg[index] <= 1'b0;
      end

    if (reset_n == 1'b1)
      begin
      for(index=0;index<G_USER_WIDTH;index=index+1)
        begin
        if (ram_data_in_x[index] == 1)
          begin
          ram_data_in_reg[index] <= 1'b1;
          end
        else
          begin
          ram_data_in_reg[index] <= 1'b0;
          end
        end
      end 
    end

  assign ram_data_in = ram_data_in_reg;

endmodule
