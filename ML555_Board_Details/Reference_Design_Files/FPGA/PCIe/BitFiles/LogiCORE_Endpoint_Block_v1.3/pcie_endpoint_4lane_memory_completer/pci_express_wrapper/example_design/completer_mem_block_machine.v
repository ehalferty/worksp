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
//  /   /         Filename    : completer_mem_block_machine.v
// /___/   /\     Module      : completer_mem_block_machine
// \   \  /  \
//  \___\/\___\
//
//------------------------------------------------------------------------------
`timescale  1 ns / 10 ps

module completer_mem_block_machine (
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
  ram_write_address,
  ram_write_enables,
  ram_data_out,
  ram_read_address,
  ram_data_in,
  leds_out);

  parameter G_USER_WIDTH = 64;
  parameter G_TC_NUMBER = 0;
  parameter G_BAR0_MASK_WIDTH = 20;
  parameter G_READ_LATENCY = 1;  // only 1 or 2 are valid

  //enumerated states
  `define idle 6'b000000
  `define get_p_head4 6'b000001
  `define write_memory_1_special 6'b000010
  `define write_memory_n_special 6'b000011
  `define write_memory_p_special 6'b000100
  `define write_memory_1 6'b000101
  `define read_memory_1 6'b000110
  `define memr_cpl_head2 6'b000111
  `define memr_cpl_head1 6'b001000
  `define memr_cpl_head3 6'b001011
  `define ur_cpl_head1 6'b001111
  `define ur_cpl_head2 6'b010011
  `define ur_cpl_head3 6'b010100
  `define get_np_head1 6'b010101
  `define get_np_head2 6'b010110
  `define get_np_head3 6'b010111
  `define get_p_head1 6'b011000
  `define get_p_head2 6'b011001
  `define get_p_head3 6'b011010
  `define get_np_head4 6'b011011
  `define write_memory_n 6'b011100
  `define read_memory_n 6'b011101
  `define discard_p 6'b011110
  `define discard_np 6'b011111
  `define get_p_digest 6'b100010
  `define memrd_digest 6'b100101
  `define latency_wait 6'b100110

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
  reg [(G_USER_WIDTH/32)-1:0] tx_enable;
  output tx_header;
  reg tx_header;
  output tx_first;
  reg tx_first;
  output tx_last;
  reg tx_last;
  output tx_discard;
  wire tx_discard;
  output [G_USER_WIDTH-1:0] tx_data;
  reg [G_USER_WIDTH-1:0] tx_data;
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
  reg [1:0] rx_fifo_select;
  output rx_request;
  wire rx_request;
  input rx_request_end;
  input [(G_USER_WIDTH/32)-1:0] rx_valid;
  input rx_header;
  input rx_first;
  input rx_last;
  input rx_discard;
  input [G_USER_WIDTH-1:0] rx_data;
  output [(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32):0] ram_write_address;
  wire [(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32):0] ram_write_address;
  output [(G_USER_WIDTH/8)-1:0] ram_write_enables;
  wire [(G_USER_WIDTH/8)-1:0] ram_write_enables;
  output [G_USER_WIDTH-1:0] ram_data_out;
  wire [G_USER_WIDTH-1:0] ram_data_out;
  output [(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32):0] ram_read_address;
  wire [(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32):0] ram_read_address;
  input [G_USER_WIDTH-1:0] ram_data_in;
  output [7:0] leds_out;
  reg [7:0] leds_out;


  // Architecture Declarations
  wire mchead1;
  wire head1;
  wire head2;
  wire head3;
  reg cpl_with_data;
  reg cpl_unsuccessful;
  reg first_completion;
  reg store_header1;
  reg store_header2;
  reg store_header3;
  reg store_header4;
  reg [31:0] stored_header1;
  reg [31:0] stored_header2;
  reg [31:0] stored_header3;
  reg [31:0] stored_header4;
  wire [2:0] tc;
  wire [1:0] attr;
  wire [9:0] length;
  wire [15:0] requester_id;
  wire [7:0] tag;
  wire [3:0] first_byte_enables;
  wire [3:0] last_byte_enables;
  wire [63:0] long_address;
  reg [3:0] led_write_enables;
  reg [7:0] leds_out_int;
  reg init_length_count;
  reg update_length_count;
  reg init_transfer_count;
  reg inc_transfer_count;
  reg inc_transfer_count_by_1;
  reg [10:0] length_count;
  reg [9:0] transfer_count;
  wire [10:0] words_remaining;
  reg rcb_break;
  wire [11:0] byte_count;
  reg [11:0] byte_count_calc;
  wire [6:0] lower_address;
  wire [1:0] lower_address_modifier;
  reg load_ram_addr_counter;
  reg inc_ram_addr_counter;
  reg post_inc_ram_addr_counter;
  reg [(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32):0] ram_addr_counter;
  wire [(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32):0] next_ram_address;
  reg read_ram;
  reg [31:0] rx_data_delayed;
  reg rx_valid_delayed;
  reg rx_last_delayed;
  reg ram_valid;
  reg [31:0] ram_data_delayed;
  reg rx_request_en;
  reg reset_rx_request_en;
  reg [10:0] max_payload_div4;
  reg output_ram_start_address;
  reg store_first_ram_data;
  reg [31:0] first_ram_data_out_int;
  reg [63:0] ram_data_out_max_int;
  reg [7:0] ram_write_enables_max_int;
  reg [1:0] tx_enable_max;
  reg [63:0] tx_data_max;
  reg [(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32):0] ram_write_address_internal;
  reg [7:0] ram_write_enables_internal;
  reg [G_USER_WIDTH-1:0] ram_data_out_internal;
  reg [7:0] led_temp;
  wire [(G_USER_WIDTH/32)-1:0] tx_enable_early;
  reg tx_header_early;
  reg tx_first_early;
  reg tx_last_early;
  wire [G_USER_WIDTH-1:0] tx_data_early;
  
  reg rx_request_r;
  reg [(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32):0] starting_addr;
  reg [10:0] transfer_size;
  
  // calculate ending addr to determine boundary
  wire [(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32):0] ending_addr;

  // Declare current and next state signals
  reg [5:0] current_state;
  reg [5:0] next_state;
  reg request_available;
  
  reg rx_request_i = 1'b0;
  reg [4:0] count;
  reg read_ram_reg;
  reg [12:0] length_in_bytes;

//------------------------------------------------------------------------------
//MODULE BODY
//------------------------------------------------------------------------------
  
  // rx_request logic -- rx_request needs to deassert immediately upon seeing
  // rx_request_end (asynchronously)
  assign rx_request = rx_request_i;
  
  always @(rx_request_end or  rx_request_r or count or request_available)
  begin
    if (rx_request_end == 1'b1 && rx_request_r == 1'b1) begin
        rx_request_i <= 1'b0;
    end
    else if (count == 2 && request_available == 1'b1) begin
        rx_request_i <= 1'b1;
    end    
    else begin
        rx_request_i <= rx_request_r;
    end
  end  
  
  always @(posedge clock)
  begin
    if (reset_n == 1'b0) begin
        count <= 0;
    end
    else if (count == 2 && rx_request_end == 1'b1 && request_available == 1'b0 ) 
        count <= 2;
    else if(rx_request_end) begin
        count <= count + 1;
    end
    else begin
        count <= 0;
    end
  end  
        
  
    always @(posedge clock )
    begin
      if (reset_n == 1'b0) begin
        request_available <= 0;
      end
      else if (rx_fifo_select == 2'b00 && rx_posted_available[G_TC_NUMBER] == 1'b1) begin
            request_available <= 1'b1;
      end
      else if (rx_fifo_select == 2'b01 && rx_non_posted_available[G_TC_NUMBER] == 1'b1) begin
           request_available <= 1'b1; 
      end
      else if (rx_fifo_select == 2'b10 && rx_completion_available[G_TC_NUMBER] == 1'b1) begin
           request_available <= 1'b1; 
      end
      else begin
           request_available <= 1'b0;     
      end
    end

  //------------------------------------------------------------------------------
  // STATE MACHINE
  //------------------------------------------------------------------------------

  always @(current_state,first_completion,long_address,ram_valid,rcb_break,rx_last,
  rx_non_posted_available,rx_posted_available,rx_valid,rx_valid_delayed,stored_header1,
  tc_status,tx_completion_ready,words_remaining,rx_last_delayed)
  begin
    case (current_state)
      `idle : begin
        if (rx_posted_available[G_TC_NUMBER] == 1'b1) begin
          next_state = `get_p_head1;
        end
        else if ((rx_non_posted_available[G_TC_NUMBER] == 1'b1)) begin
          next_state = `get_np_head1;
        end else begin
          next_state = `idle;
        end

      end
      `get_np_head1 : begin
        if (rx_valid != 0) begin
          if (G_USER_WIDTH == 64) begin
            next_state = `get_np_head3;
          end else begin
            next_state = `get_np_head2;
          end
        end else begin
          next_state = `get_np_head1;
        end

      end
      `get_np_head2 : begin
        if (rx_valid != 0) begin
          next_state = `get_np_head3;
        end else begin
          next_state = `get_np_head2;
        end

      end
      `get_np_head3 : begin
        if (stored_header1[26:24] == 3'b101) // Type 1 Request
          next_state = `ur_cpl_head1;
        else if (G_READ_LATENCY == 2) begin
          next_state = `latency_wait;
        end 
        else if (G_USER_WIDTH == 32 && rx_valid != 0 && stored_header1[30:24] == 7'b0100000) begin
          next_state = `get_np_head4;
        end
        else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000000 || stored_header1[30:24] == 7'b0100000) && (stored_header1[15] == 1'b1))) begin // Memory read
          next_state = `memrd_digest; 
        end
        else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000000 || stored_header1[30:24] == 7'b0100000))) begin // Memory read
          next_state = `memr_cpl_head1; 
        end
        else if ((rx_valid != 0 && (rx_last == 1'b1))) begin // some unsupported header
          next_state = `ur_cpl_head1;
        end
        else if (rx_valid != 0) begin
          next_state = `discard_np;
        end else begin
          next_state = `get_np_head3;
        end

      end
      `latency_wait : begin
         next_state = `memr_cpl_head1; // only supporting memr at this time
      end
      `get_np_head4 : begin
        if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000000 || stored_header1[30:24] == 7'b0100000) && (stored_header1[15] == 1'b1))) begin // Memory read
          next_state = `memrd_digest;
        end
        else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000000 || stored_header1[30:24] == 7'b0100000))) begin // Memory read
          next_state = `memr_cpl_head1; 
        end
        else if ((rx_valid != 0 && (rx_last == 1'b1))) begin // some unsupported header
          next_state = `ur_cpl_head1;
        end
        else if (rx_valid != 0) begin
          next_state = `discard_np;
        end else begin
          next_state = `get_np_head4;
        end

      end
      `get_p_head1 : begin
        if (rx_valid != 0) begin
          if (G_USER_WIDTH == 64) begin
            next_state = `get_p_head3;
          end else begin
            next_state = `get_p_head2;
          end
        end else begin
          next_state = `get_p_head1;
        end

      end
      `get_p_head2 : begin
        if (rx_valid != 0) begin
          next_state = `get_p_head3;
        end else begin
          next_state = `get_p_head2;
        end

      end
      `get_p_head3 : begin
        if ((G_USER_WIDTH == 32 && rx_valid != 0) && (stored_header1[30:24] == 7'b1100000)) begin
          next_state = `get_p_head4;                                                    // mem write 4DW header
        end
        else if ((G_USER_WIDTH == 32 && rx_valid != 0) && (stored_header1[30:24] == 7'b1000000)) begin
          next_state = `write_memory_1;                                                // mem write 3DW header
        end
        else if ((G_USER_WIDTH == 64 && rx_valid != 0) && (stored_header1[30:24] == 7'b1000000)) begin
          next_state = `write_memory_1_special;                                         // mem write 3DW header the 4th DW will be data
        end
        else if ((G_USER_WIDTH == 64 && rx_valid != 0) && (stored_header1[30:24] == 7'b1100000)) begin
          next_state = `write_memory_1;                                                 // mem write 4DW header
        end
        else if (((rx_valid != 0) && (rx_last == 1'b1))) begin
          next_state = `idle;
        end
        else if (rx_valid != 0) begin
          next_state = `discard_p;
        end else begin
          next_state = `get_p_head3;
        end

      end
      `get_p_head4 : begin
        if (rx_valid != 0) begin
          next_state = `write_memory_1;
        end else begin
          next_state = `get_p_head4;
        end

      end
      `write_memory_1_special : begin
        if (rx_last_delayed == 1'b1) begin
          if (long_address[2] == 1'b0) begin
            next_state = `idle;
          end else begin
            next_state = `write_memory_p_special;
          end
        end
        else if (rx_last == 1'b1 && rx_valid == 2) begin
          if (long_address[2] == 1'b0) begin
            next_state = `idle;
          end else begin
            next_state = `write_memory_p_special;
          end
        end
        else if (rx_last == 1'b1 && rx_valid == 3) begin
          if (long_address[2] == 1'b0) begin
            next_state = `write_memory_n_special;
          end else begin
            next_state = `write_memory_p_special;
          end
        end
        else if (rx_valid != 0) begin
          next_state = `write_memory_n_special;
        end else begin
          next_state = `write_memory_1_special;
        end

      end
      `write_memory_n_special : begin
        if (rx_last_delayed == 1'b1) begin
          if (long_address[2] == 1'b0) begin
            next_state = `idle;
          end else begin
            next_state = `write_memory_p_special;
          end
        end
        else if (rx_last == 1'b1 && rx_valid == 2) begin
          if (long_address[2] == 1'b0) begin
            next_state = `idle;
          end else begin
            next_state = `write_memory_p_special;
          end

        end
        else if (rx_last == 1'b1 && rx_valid == 3) begin
          if (long_address[2] == 1'b0) begin
            next_state = `write_memory_n_special;
          end else begin
            next_state = `write_memory_p_special;
          end
        end
        else if (rx_valid != 0) begin
          next_state = `write_memory_n_special;
        end else begin
          next_state = `write_memory_n_special;
        end

      end
      `write_memory_p_special : begin
        next_state = `idle;

      end
      `write_memory_1 : begin
        if ((G_USER_WIDTH == 32 && rx_valid != 0 && rx_last == 1'b1) ||
      (G_USER_WIDTH == 64 && rx_valid != 0 && rx_last == 1'b1 && long_address[2] == 1'b0) ||
      (G_USER_WIDTH == 64 && rx_valid == 2 && rx_last == 1'b1 && long_address[2] == 1'b1)) begin
          next_state = `idle;
        end
        else if (((rx_valid != 0 &&
      ((G_USER_WIDTH == 64 && words_remaining <= 10'b0000000010) ||
       (G_USER_WIDTH == 32 && words_remaining <= 10'b0000000001))) && (stored_header1[15] == 1'b1))) begin
          next_state = `get_p_digest;
        end
        else if ((rx_valid != 0 &&
      ((G_USER_WIDTH == 64 && words_remaining <= 10'b0000000010) ||
       (G_USER_WIDTH == 32 && words_remaining <= 10'b0000000001)))) begin
          next_state = `idle;
        end
        else if ((rx_valid != 0)) begin
          next_state = `write_memory_n;
        end else begin
          next_state = `write_memory_1;
        end

      end
      `write_memory_n : begin
        if (((rx_valid != 0 && ((G_USER_WIDTH == 64 && long_address[2] == 1'b0 && words_remaining <= 10'b0000000010) ||
       (G_USER_WIDTH == 32 && words_remaining <= 10'b0000000001))) || (rx_valid_delayed != 1'b0 && long_address[2] == 1'b1 && G_USER_WIDTH == 64 &&
        words_remaining < 10'b0000000010)) && (stored_header1[15] == 1'b1)) begin
          next_state = `get_p_digest;
        end
        else if (((rx_valid != 0 && ((G_USER_WIDTH == 64 && long_address[2] == 1'b0 && words_remaining <= 10'b0000000010) ||
       (G_USER_WIDTH == 32 && words_remaining <= 10'b0000000001))) || (rx_valid_delayed != 1'b0 && long_address[2] == 1'b1 && G_USER_WIDTH == 64 &&
        words_remaining < 10'b0000000010))) begin
          next_state = `idle;
        end else begin
          next_state = `write_memory_n;
        end

      end
      `get_p_digest : begin
        if (rx_valid != 0) begin
          next_state = `idle;
        end else begin
          next_state = `get_p_digest;
        end

      end
      `read_memory_1 : begin
        if (tx_completion_ready[0] == 1'b1 
            && words_remaining <= 10'b0000000001) begin
          next_state = `idle;
        end else if (tx_completion_ready[0] == 1'b1 
            && rcb_break == 1'b1) begin
          next_state = `memr_cpl_head1;
        end else if ((tx_completion_ready[0] == 1'b1 && ram_valid == 1'b1)) begin
          next_state = `read_memory_n;
        end else begin
          next_state = `read_memory_1;
        end
      end
      `memr_cpl_head2 : begin
        if (tx_completion_ready[0] == 1'b1) begin
          next_state = `memr_cpl_head3;
        end else begin
          next_state = `memr_cpl_head2;
        end
      end
      `memr_cpl_head1 : begin
        if (G_USER_WIDTH == 64 && tx_completion_ready[0] == 1'b1) begin
          next_state = `memr_cpl_head3;
        end
        else if ((tx_completion_ready[0] == 1'b1)) begin
          next_state = `memr_cpl_head2;
        end else begin
          next_state = `memr_cpl_head1;
        end
      end
      `memr_cpl_head3 : begin
        next_state = `read_memory_1;
      end
      `ur_cpl_head1 : begin
        if (G_USER_WIDTH == 64 && tx_completion_ready[0] == 1'b1) begin
          next_state = `ur_cpl_head3;
        end
        else if ((tx_completion_ready[0] == 1'b1)) begin
          next_state = `ur_cpl_head2;
        end else begin
          next_state = `ur_cpl_head1;
        end
      end
      `ur_cpl_head2 : begin
        if (tx_completion_ready[0] == 1'b1) begin
          next_state = `ur_cpl_head3;
        end else begin
          next_state = `ur_cpl_head2;
        end
      end
      `ur_cpl_head3 : begin
        if (tx_completion_ready[0] == 1'b1) begin
          next_state = `idle;
        end else begin
          next_state = `ur_cpl_head3;
        end
      
      end
      `read_memory_n : begin
        if (tx_completion_ready[0] == 1'b1 && ram_valid == 1'b1 && words_remaining <= 10'b0000000010) begin // was words_remaining <= 0
          next_state = `idle;
        end else if (tx_completion_ready[0] == 1'b1 && ram_valid == 1'b1 && rcb_break == 1'b1) begin
          next_state = `memr_cpl_head1;
        end else begin
          next_state = `read_memory_n;
        end

      end
      `discard_p : begin
        if (rx_last == 1'b1) begin
          next_state = `idle;
        end else begin
          next_state = `discard_p;
        end

      end
      `discard_np : begin
        if (rx_last == 1'b1 && rx_valid != 0) begin
          next_state = `ur_cpl_head1;
        end else begin
          next_state = `discard_np;
        end

      end
      `memrd_digest : begin
        if (rx_valid != 0) begin
          next_state = `memr_cpl_head1;
        end else begin
          next_state = `memrd_digest;
        end

      end
      default : begin
        next_state = `idle;

      end
    endcase

    // Interrupts
    if (tc_status == 8'b00000000) begin
      next_state = `idle;
    end

  end

  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      current_state <= `idle;

    end
    else begin
      current_state <= next_state;

    end
  end

  //------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------
  

  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      // Reset Values
      rx_fifo_select <= 2'b00;
      rx_request_r <= 1'b0;
      tx_first_early <= 1'b0;
      tx_header_early <= 1'b0;

    end
    else begin
      // Default Assignment To Internals
      rx_fifo_select <= 2'b00;
      rx_request_r <= 1'b0;
      tx_first_early <= 1'b0;
      tx_header_early <= 1'b0;

      // State Actions for internal signals only
      case (next_state)
        `get_p_head4 : begin
          rx_fifo_select <= 2'b00;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `write_memory_1_special : begin
          rx_fifo_select <= 2'b00;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `write_memory_n_special : begin
          rx_fifo_select <= 2'b00;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `write_memory_1 : begin
          rx_fifo_select <= 2'b00;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `read_memory_1 : begin
        end
        `read_memory_n : begin
        end
        `memr_cpl_head2 : begin
          tx_header_early <= 1'b1;
        end
        `memr_cpl_head1 : begin
          tx_header_early <= 1'b1;
          tx_first_early <= 1'b1;
        end
        `memr_cpl_head3 : begin
          tx_header_early <= 1'b1;
        end
        `ur_cpl_head1 : begin
          tx_first_early <= 1'b1;
          tx_header_early <= 1'b1;
        end
        `ur_cpl_head2 : begin
          tx_header_early <= 1'b1;
        end
        `ur_cpl_head3 : begin
          tx_header_early <= 1'b1;
        end
        `get_np_head1 : begin
          rx_fifo_select <= 2'b01;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `get_np_head2 : begin
          rx_fifo_select <= 2'b01;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `get_np_head3 : begin
          rx_fifo_select <= 2'b01;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `get_p_head1 : begin
          rx_fifo_select <= 2'b00;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `get_p_head2 : begin
          rx_fifo_select <= 2'b00;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `get_p_head3 : begin
          rx_fifo_select <= 2'b00;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `get_np_head4 : begin
          rx_fifo_select <= 2'b01;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `write_memory_n : begin
          rx_fifo_select <= 2'b00;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        //`read_memory_n : begin
        //end
        `discard_p : begin
          rx_fifo_select <= 2'b00;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `discard_np : begin
          rx_fifo_select <= 2'b01;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `get_p_digest : begin
          rx_fifo_select <= 2'b00;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        `memrd_digest : begin
          rx_fifo_select <= 2'b01;
          rx_request_r <= rx_request_en & (~ rx_request_end);
        end
        default : begin

        end
      endcase

    end
  end

  // Logic to gate off request after rx_request_end flag comes out from core.
  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      rx_request_en <= 1'b1;

    end
    else begin
      if (tc_status[7:0] == 8'b00000000) begin
        rx_request_en <= 1'b1;
      end else begin
        if (reset_rx_request_en == 1'b1) begin
          rx_request_en <= 1'b1;
        end
        else if (rx_request_end == 1'b1) begin
          rx_request_en <= 1'b0;
        end
      end

    end
  end

  assign rx_tc_select = G_TC_NUMBER;

  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      first_completion <= 1'b0;

    end
    else begin
      // Transition Actions for internal signals only
      case (current_state)

        `memr_cpl_head3 : begin
          if (tx_completion_ready[0] == 1'b1 && words_remaining <= 10'b0000000000) begin
          end
          else if ((tx_completion_ready[0] == 1'b1)) begin
            first_completion <= 1'b0;
          end

        end
        `get_np_head3 : begin
          if (G_USER_WIDTH == 32 && rx_valid != 0 && stored_header1[30:24] == 7'b0100000) begin
            first_completion <= 1'b1;
          end
          else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b1000010))) begin // IO write
            first_completion <= 1'b1;
          end
          else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000010) && (stored_header1[15] == 1'b1))) begin // IO read
            first_completion <= 1'b1;
          end
          else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000010))) begin // IO read
            first_completion <= 1'b1;
          end
          else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000000 || stored_header1[30:24] == 7'b0100000) && (stored_header1[15] == 1'b1))) begin // Memory read
            first_completion <= 1'b1;
          end
          else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000000 || stored_header1[30:24] == 7'b0100000))) begin // Memory read
            first_completion <= 1'b1;
          end
          else if ((rx_valid != 0 && (rx_last == 1'b1))) begin // some unsupported header
            first_completion <= 1'b1;
          end
          else if (rx_valid != 0) begin
            first_completion <= 1'b1;
          end

        end
        default : begin


        end
      endcase

    end
  end

  //------------------------------------------------------------------------------
  // STORE PARTS OF THE RX PACKET
  //------------------------------------------------------------------------------
  // The first 3 header words are stored as the request packet header is read out of the core
  // The 4th header word is only present in 64bit addressed request headers. It's not actually used currently.
  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      stored_header1 <= {32{1'b0}};
      stored_header2 <= {32{1'b0}};
      stored_header3 <= {32{1'b0}};
      stored_header4 <= {32{1'b0}};

    end
    else begin
      if (store_header1 == 1'b1) begin
        stored_header1 <= rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32];
      end
      if (store_header2 == 1'b1) begin
        stored_header2 <= rx_data[31:0];
      end
      if (store_header3 == 1'b1) begin
        stored_header3 <= rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32];
      end
      if (store_header4 == 1'b1) begin
        stored_header4 <= rx_data[31:0];
      end

    end
  end

  // Pull various fields out of the stored header words for use elsewhere
  assign tc = stored_header1[22:20];
  assign attr = stored_header1[13:12];
  assign length = (cpl_unsuccessful == 1'b0) ? stored_header1[9:0] : 10'b0000000000;
  assign requester_id = stored_header2[31:16];
  assign tag = stored_header2[15:8];
  assign last_byte_enables = stored_header2[7:4];
  assign first_byte_enables = stored_header2[3:0];
  assign long_address = (stored_header1[29] == 1'b1) ? {stored_header3 , stored_header4} : {32'b00000000000000000000000000000000 , stored_header3};               // 64bit and 32bit addressing header formats

  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      rx_valid_delayed <= 1'b0;
      rx_last_delayed <= 1'b0;
      rx_data_delayed <= {32{1'b0}};

    end
    else begin
      if (G_USER_WIDTH == 64) begin  // These signals are delayed in 64bit mode to cope with non 64bit-aligned transfers
        if (rx_valid != 0) begin
          rx_valid_delayed <= rx_valid[0];
          rx_last_delayed <= rx_last;
          rx_data_delayed <= rx_data[31:0];  // These serve writes
        end
      end

    end
  end

  // save first_ram_data_out_int so that it can be written at the end when we've got time
  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      first_ram_data_out_int <= {32{1'b0}};

    end
    else begin
      if (store_first_ram_data == 1'b1) begin
        first_ram_data_out_int <= rx_data_delayed;
      end

    end
  end

  //------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------

  always @(current_state,first_byte_enables,first_completion,last_byte_enables,long_address,
  ram_valid,rcb_break,rx_data,rx_data_delayed,rx_last,rx_last_delayed,rx_valid,rx_valid_delayed,
  stored_header1,tx_completion_ready,words_remaining,first_ram_data_out_int,length_count,read_ram_reg)
  begin
    // Default Assignment
    tx_enable_max = {2{1'b0}};
    // Default Assignment To Internals
    cpl_unsuccessful = 1'b0;
    cpl_with_data = 1'b0;
    inc_ram_addr_counter = 1'b0;
    inc_transfer_count = 1'b0;
    inc_transfer_count_by_1 = 1'b0;
    init_length_count = 1'b0;
    init_transfer_count = 1'b0;
    led_write_enables = {4{1'b0}};
    load_ram_addr_counter = 1'b0;
    post_inc_ram_addr_counter = 1'b0;
    ram_data_out_max_int = {64{1'b0}};
    ram_write_enables_max_int = {8{1'b0}};
    read_ram = 1'b0;
    reset_rx_request_en = 1'b0;
    store_header1 = 1'b0;
    store_header2 = 1'b0;
    store_header3 = 1'b0;
    store_header4 = 1'b0;
    update_length_count = 1'b0;
    store_first_ram_data = 1'b0;
    output_ram_start_address = 1'b0;
    
    tx_last_early <= 1'b0;

    // Combined Actions
    case (current_state)
      `idle : begin
        reset_rx_request_en = 1'b1;

    // always 64 bit and 3DW header when in this state
      end
      `write_memory_1_special : begin
        if (rx_last_delayed == 1'b1) begin      // 1 DW data tagged to 3rd DW of the header
          if (long_address[2] == 1'b0) begin
            ram_data_out_max_int[63:32] = rx_data_delayed;
            ram_write_enables_max_int[7:4] = first_byte_enables;
            ram_data_out_max_int[31:0] = 32'b00000000000000000000000000000000;
            ram_write_enables_max_int[3:0] = 4'b0000;
          end else begin
            ram_data_out_max_int[63:32] = 32'b00000000000000000000000000000000;   // do the write in write_memory_p_special
            ram_write_enables_max_int[7:4] = 4'b0000;
            ram_data_out_max_int[31:0] = 32'b00000000000000000000000000000000;
            ram_write_enables_max_int[3:0] = 4'b0000;
          end
        end
        else if (rx_last == 1'b1 && rx_valid == 2) begin   // 1 DW + the one we got before
          if (long_address[2] == 1'b0) begin               // even
            ram_data_out_max_int[63:32] = rx_data_delayed;
            ram_write_enables_max_int[7:4] = first_byte_enables;
            ram_data_out_max_int[31:0] = rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32];
            ram_write_enables_max_int[3:0] = last_byte_enables;
          end else begin                                   // write this DW now write delayed at the end
            ram_data_out_max_int[63:32] = rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32];
            ram_write_enables_max_int[7:4] = last_byte_enables;
            ram_data_out_max_int[31:0] = 32'b00000000000000000000000000000000;
            ram_write_enables_max_int[3:0] = 4'b0000;
          end
        end
        else if (rx_last == 1'b1 && rx_valid == 3) begin
          if (long_address[2] == 1'b0) begin               // finish rx_data(31..0)-> rx_delayed data.. next cycle
            ram_data_out_max_int[63:32] = rx_data_delayed;
            ram_write_enables_max_int[7:4] = first_byte_enables;
            ram_data_out_max_int[31:0] = rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32];
            ram_write_enables_max_int[3:0] = 4'b1111;
          end else begin
            ram_data_out_max_int[63:0] = rx_data;
            ram_write_enables_max_int[7:4] = 4'b1111;
            ram_write_enables_max_int[3:0] = last_byte_enables;
            inc_ram_addr_counter = 1'b1;
          end
        end
        else if (rx_valid != 0) begin                      // assumption that rx_valid(0) = 1  ie 2 DW and not the last
          if (long_address[2] == 1'b0) begin
            ram_data_out_max_int[63:32] = rx_data_delayed;
            ram_write_enables_max_int[7:4] = 4'b1111;
            ram_data_out_max_int[31:0] = rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32];
            ram_write_enables_max_int[3:0] = 4'b1111;
          end else begin
            ram_data_out_max_int[G_USER_WIDTH-1:0] = rx_data;
            ram_write_enables_max_int[7:4] = 4'b1111;
            ram_write_enables_max_int[3:0] = 4'b1111;
            inc_ram_addr_counter = 1'b1;
          end
        end
        if ((rx_valid != 0 || rx_last_delayed == 1'b1) && long_address[2] == 1'b1) begin
          inc_ram_addr_counter = 1'b1;
        end else begin
          inc_ram_addr_counter = 1'b0;
        end
        inc_transfer_count = rx_valid[0];
        store_first_ram_data = 1'b1; // store the first DW of the data so it can be written later.

      end
      `write_memory_n_special : begin
        if (rx_last_delayed == 1'b1) begin                 // rx_last delayed will only be present if we did not jump
          ram_data_out_max_int[63:32] = rx_data_delayed;
          ram_write_enables_max_int[7:4] = last_byte_enables;
          ram_data_out_max_int[31:0] = 32'b00000000000000000000000000000000;
          ram_write_enables_max_int[3:0] = 4'b0000;
        end
        else if (rx_last == 1'b1 && rx_valid == 2) begin
          if (long_address[2] == 1'b0) begin
            ram_data_out_max_int[63:32] = rx_data_delayed;
            ram_write_enables_max_int[7:4] = 4'b1111;
            ram_data_out_max_int[31:0] = rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32];
            ram_write_enables_max_int[3:0] = last_byte_enables;
          end else begin
            ram_data_out_max_int[63:32] = rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32];
            ram_write_enables_max_int[7:4] = last_byte_enables;
            ram_data_out_max_int[31:0] = 32'b00000000000000000000000000000000;
            ram_write_enables_max_int[3:0] = 4'b0000;
          end
        end
        else if (rx_last == 1'b1 && rx_valid == 3) begin
          if (long_address[2] == 1'b0) begin               // finish rx_data(31..0)-> rx_delayed data.. next cycle
            ram_data_out_max_int[63:32] = rx_data_delayed;
            ram_write_enables_max_int[7:4] = 4'b1111;
            ram_data_out_max_int[31:0] = rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32];
            ram_write_enables_max_int[3:0] = 4'b1111;
          end else begin
            ram_data_out_max_int[G_USER_WIDTH-1:0] = rx_data;
            ram_write_enables_max_int[7:4] = 4'b1111;
            ram_write_enables_max_int[3:0] = last_byte_enables;
          end
        end
        else if (rx_valid != 0) begin                   // assumption that rx_valid(0) = 1   ie 2 DW and not the last
          if (long_address[2] == 1'b0) begin
            ram_data_out_max_int[63:32] = rx_data_delayed;
            ram_write_enables_max_int[7:4] = 4'b1111;
            ram_data_out_max_int[31:0] = rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32];
            ram_write_enables_max_int[3:0] = 4'b1111;
          end else begin
            ram_data_out_max_int[G_USER_WIDTH-1:0] = rx_data;
            ram_write_enables_max_int[7:4] = 4'b1111;
            ram_write_enables_max_int[3:0] = 4'b1111;
          end
        end
        inc_transfer_count = rx_valid[0];
        if (rx_valid != 0 || rx_last_delayed == 1'b1) begin
          inc_ram_addr_counter = 1'b1;
        end else begin
          inc_ram_addr_counter = 1'b0;
        end

      end
      `write_memory_p_special : begin
        ram_data_out_max_int[31:0] = first_ram_data_out_int;
        ram_write_enables_max_int[3:0] = first_byte_enables;
        ram_write_enables_max_int[7:4] = 4'b0000;
        output_ram_start_address = 1'b1;

      end
      `write_memory_1 : begin
        if (G_USER_WIDTH == 64) begin
          if (long_address[2] == 1'b1) begin
            if (rx_valid != 0) begin
              ram_write_enables_max_int[3:0] = first_byte_enables;
            end else begin
              ram_write_enables_max_int[3:0] = 4'b0000;
            end
            ram_data_out_max_int = {rx_data_delayed , rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32]};
          end else begin
            if (rx_valid != 0) begin
              ram_write_enables_max_int[7:4] = first_byte_enables;
            end else begin
              ram_write_enables_max_int[7:4] = 4'b0000;
            end
            if (rx_valid[0] == 1'b1) begin
              if (rx_last == 1'b1) begin
                ram_write_enables_max_int[3:0] = last_byte_enables;
              end else begin
                ram_write_enables_max_int[3:0] = 4'b1111;
              end
            end else begin
              ram_write_enables_max_int[3:0] = 4'b0000;
            end
            ram_data_out_max_int[G_USER_WIDTH-1:0] = rx_data;
          end
        end else begin
          if (rx_valid[0] == 1'b1) begin
            ram_write_enables_max_int[3:0] = first_byte_enables;
          end else begin
            ram_write_enables_max_int[3:0] = 4'b0000;
          end
          ram_data_out_max_int[G_USER_WIDTH-1:0] = rx_data;
        end
        post_inc_ram_addr_counter = rx_valid[0];
        inc_transfer_count = rx_valid[0];

      end
      `read_memory_1 : begin
            if (tx_completion_ready[0] == 1'b1 &&  
               ((words_remaining == 10'b0000000001 && length_count[0] == 1'b0) ||  // evens
                (words_remaining == 10'b0000000001 && length_count == 1)       ||  // 1 DW
                (words_remaining == 10'b0000000010 && length_count[0] == 1'b1) ||  // odds
                rcb_break == 1'b1))
                 tx_last_early <= 1'b1;

        if (G_USER_WIDTH == 64) begin
          if (words_remaining <= 1 || (rcb_break == 1'b1 && long_address[2] == 1'b1 && first_completion == 1'b1)) begin
            tx_enable_max[1] = ram_valid & tx_completion_ready[0];
            read_ram = 1'b0;
          end else begin
            tx_enable_max[1:0] = {(ram_valid & tx_completion_ready[0]) , (ram_valid & tx_completion_ready[0])};
            read_ram = 1'b1;
          end
        end else begin
          if (words_remaining <= 1) begin
            read_ram = 1'b0;
          end else begin
            read_ram = 1'b1;
          end
          
          tx_enable_max[0] = ram_valid & tx_completion_ready[0];
        end
        inc_transfer_count = ram_valid & tx_completion_ready[0];
        cpl_with_data = 1'b1;
        
        if (G_READ_LATENCY == 1)
          inc_ram_addr_counter = ram_valid & tx_completion_ready[0] & ~ (rcb_break & long_address[2] & first_completion);
        else
          inc_ram_addr_counter = read_ram_reg & tx_completion_ready[0] & ~ (rcb_break & long_address[2] & first_completion);

      end
      `memr_cpl_head2 : begin
        tx_enable_max[0] = tx_completion_ready[0];
        cpl_with_data = 1'b1;
      end
      `latency_wait : begin
        read_ram = 1'b1;
      end
      `memr_cpl_head1 : begin
        if (G_USER_WIDTH == 64) begin
          tx_enable_max[1:0] = {tx_completion_ready[0] , tx_completion_ready[0]};
        end else begin
          tx_enable_max[0] = tx_completion_ready[0];
        end
        cpl_with_data = 1'b1;
        read_ram = 1'b1;
        inc_transfer_count = ram_valid & tx_completion_ready[0];
        
          if (G_READ_LATENCY == 1)
            inc_ram_addr_counter = ram_valid;
          else
            inc_ram_addr_counter = read_ram_reg;
      end
      `memr_cpl_head3 : begin
            if (tx_completion_ready[0] == 1'b1 && 
               ((words_remaining == 10'b0000000001 && length_count[0] == 1'b0) ||  // evens
                (words_remaining == 10'b0000000001 && length_count == 1)       ||  // 1 DW
                (words_remaining == 10'b0000000010 && length_count[0] == 1'b1) ||  // odds
                rcb_break == 1'b1))
                 tx_last_early <= 1'b1;
        
        if (G_USER_WIDTH == 64) begin
          tx_enable_max = {tx_completion_ready[0], tx_completion_ready[0]};
        end else begin
          tx_enable_max[0] = tx_completion_ready[0];
        end
        cpl_with_data = 1'b1;
        update_length_count = 1'b1;
        inc_transfer_count = ram_valid & tx_completion_ready[0];
        
        if (words_remaining <= 1 || (rcb_break == 1'b1 && long_address[2] == 1'b1 && first_completion == 1'b1)) begin
           read_ram = 1'b0;
        end else begin
           read_ram = 1'b1;
        end
           
          if (G_READ_LATENCY == 1)
            inc_ram_addr_counter = ram_valid;
          else
            inc_ram_addr_counter = read_ram_reg;
      end
      `ur_cpl_head1 : begin
        if (G_USER_WIDTH == 64) begin
          tx_enable_max[1:0] = {tx_completion_ready[0] , tx_completion_ready[0]};
        end else begin
          tx_enable_max[0] = tx_completion_ready[0];
        end
        cpl_unsuccessful = 1'b1;
      end
      `ur_cpl_head2 : begin
        tx_enable_max[0] = tx_completion_ready[0];
        cpl_unsuccessful = 1'b1;
      end
      `ur_cpl_head3 : begin
           tx_last_early <= 1'b1;
        
        tx_enable_max[0] = tx_completion_ready[0];
        cpl_unsuccessful = 1'b1;

      end
      `get_np_head1 : begin
        if (G_USER_WIDTH == 64) begin
          if (rx_valid != 0) begin
            store_header1 = 1'b1;
            store_header2 = 1'b1;
            init_length_count = 1'b1;
            init_transfer_count = 1'b1;
          end
        end else begin
          if (rx_valid != 0) begin
            store_header1 = 1'b1;
            init_length_count = 1'b1;
            init_transfer_count = 1'b1;
          end
        end

      end
      `get_np_head2 : begin
        if (rx_valid != 0) begin
          store_header2 = 1'b1;
        end

      end
      `get_np_head3 : begin
        if (rx_valid != 0) begin
          store_header3 = 1'b1;
        end

        if (G_USER_WIDTH == 32 && rx_valid != 0 && stored_header1[30:24] == 7'b0100000) begin
          load_ram_addr_counter = 1'b1;
        end
        else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b1000010))) begin // IO write
          load_ram_addr_counter = 1'b1;
        end
        else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000010) && (stored_header1[15] == 1'b1))) begin // IO read
          load_ram_addr_counter = 1'b1;
        end
        else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000010))) begin // IO read
          load_ram_addr_counter = 1'b1;
        end
        else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000000 || stored_header1[30:24] == 7'b0100000) && (stored_header1[15] == 1'b1))) begin // Memory read
          load_ram_addr_counter = 1'b1;
          load_ram_addr_counter = 1'b1;
        end
        else if ((rx_valid != 0 && (stored_header1[30:24] == 7'b0000000 || stored_header1[30:24] == 7'b0100000))) begin // Memory read
          load_ram_addr_counter = 1'b1;
          load_ram_addr_counter = 1'b1;
        end
        else if ((rx_valid != 0 && (rx_last == 1'b1))) begin // some unsupported header
          load_ram_addr_counter = 1'b1;
        end
        else if (rx_valid != 0) begin
          load_ram_addr_counter = 1'b1;
        end

      end
      `get_p_head1 : begin
        if (G_USER_WIDTH == 64) begin
          if (rx_valid != 0) begin
            store_header1 = 1'b1;
            store_header2 = 1'b1;
            init_length_count = 1'b1;
            init_transfer_count = 1'b1;
          end
        end else begin
          if (rx_valid != 0) begin
            store_header1 = 1'b1;
            init_length_count = 1'b1;
            init_transfer_count = 1'b1;
          end
        end

      end
      `get_p_head2 : begin
        if (rx_valid != 0) begin
          store_header2 = 1'b1;
        end

      end
      `get_p_head3 : begin
        if (rx_valid != 0) begin
          store_header3 = 1'b1;
        end

        if (G_USER_WIDTH == 32 && rx_valid != 0 && stored_header1[30:24] == 7'b1100000) begin
          load_ram_addr_counter = 1'b1;
        end
        else if (((G_USER_WIDTH == 32 && rx_valid != 0 && stored_header1[30:24] == 7'b1000000) ||
      (G_USER_WIDTH == 64 && rx_valid == 3 && stored_header1[30:24] == 7'b1100000) ||
      (G_USER_WIDTH == 64 && rx_valid != 0 && stored_header1[30:24] == 7'b1000000))) begin
          load_ram_addr_counter = 1'b1;
        end

      end
      `get_np_head4 : begin
        if ((rx_valid != 0) && (stored_header1[30:24] == 7'b1000010)) begin // IO write
        end
        else if (((rx_valid != 0) && (stored_header1[30:24] == 7'b0000010) && (stored_header1[15] == 1'b1))) begin // IO read
        end
        else if (((rx_valid != 0) && (stored_header1[30:24] == 7'b0000010))) begin // IO read
        end
        else if (((rx_valid != 0) && (stored_header1[30:24] == 7'b0000000 || stored_header1[30:24] == 7'b0100000) && (stored_header1[15] == 1'b1))) begin // Memory read
          load_ram_addr_counter = 1'b1;
        end
        else if (((rx_valid != 0) && (stored_header1[30:24] == 7'b0000000 || stored_header1[30:24] == 7'b0100000))) begin // Memory read
          load_ram_addr_counter = 1'b1;
        end

      end
      `write_memory_n : begin
        if (G_USER_WIDTH == 64) begin
          if (long_address[2] == 1'b1) begin
            if ((rx_last == 1'b1 && rx_valid[0] == 1'b0) || rx_last_delayed == 1'b1) begin
              if (rx_valid != 0) begin
                ram_write_enables_max_int[3:0] = last_byte_enables;
                if (rx_valid_delayed == 1'b1) begin
                  ram_write_enables_max_int[7:4] = 4'b1111;
                end else begin
                  ram_write_enables_max_int[7:4] = 4'b0000;
                end
              end else begin
                ram_write_enables_max_int[3:0] = 4'b0000;
                if (rx_valid_delayed == 1'b1) begin
                  ram_write_enables_max_int[7:4] = last_byte_enables;
                end else begin
                  ram_write_enables_max_int[7:4] = 4'b0000;
                end
              end
            end else begin
              if (rx_valid != 0) begin
                ram_write_enables_max_int[3:0] = 4'b1111;
              end else begin
                ram_write_enables_max_int[3:0] = 4'b0000;
              end
              if (rx_valid_delayed == 1'b1) begin
                ram_write_enables_max_int[7:4] = 4'b1111;
              end else begin
                ram_write_enables_max_int[7:4] = 4'b0000;
              end
            end
            ram_data_out_max_int = {rx_data_delayed , rx_data[G_USER_WIDTH-1:G_USER_WIDTH-32]};
          end else begin
            if (rx_last == 1'b1) begin
              if (rx_valid[0] == 1'b1) begin
                ram_write_enables_max_int[3:0] = last_byte_enables;
                if (rx_valid != 0) begin
                  ram_write_enables_max_int[7:4] = 4'b1111;
                end else begin
                  ram_write_enables_max_int[7:4] = 4'b0000;
                end
              end else begin
                ram_write_enables_max_int[3:0] = 4'b0000;
                if (rx_valid != 0) begin
                  ram_write_enables_max_int[7:4] = last_byte_enables;
                end else begin
                  ram_write_enables_max_int[7:4] = 4'b0000;
                end
              end
            end else begin
              if (rx_valid != 0) begin
                ram_write_enables_max_int[7:4] = 4'b1111;
              end else begin
                ram_write_enables_max_int[7:4] = 4'b0000;
              end
              if (rx_valid[0] == 1'b1) begin
                ram_write_enables_max_int[3:0] = 4'b1111;
              end else begin
                ram_write_enables_max_int[3:0] = 4'b0000;
              end
            end
            ram_data_out_max_int[G_USER_WIDTH-1:0] = rx_data;
          end
        end else begin
          if (rx_last == 1'b1) begin
            if (rx_valid[0] == 1'b1) begin
              ram_write_enables_max_int[3:0] = last_byte_enables;
            end else begin
              ram_write_enables_max_int[3:0] = 4'b0000;
            end
          end else begin
            if (rx_valid[0] == 1'b1) begin
              ram_write_enables_max_int[3:0] = 4'b1111;
            end else begin
              ram_write_enables_max_int[3:0] = 4'b0000;
            end
          end
          ram_data_out_max_int[G_USER_WIDTH-1:0] = rx_data;
        end
        post_inc_ram_addr_counter = rx_valid[0];
        inc_transfer_count = rx_valid[0];
      end
      `read_memory_n : begin
            if (tx_completion_ready[0] == 1'b1 && 
               ((words_remaining == 10'b0000000001 && length_count[0] == 1'b0) ||  // evens
                (words_remaining == 10'b0000000001 && length_count == 1)       ||  // 1 DW
                (words_remaining == 10'b0000000010 && length_count[0] == 1'b1) ||  // odds
                rcb_break == 1'b1))
                 tx_last_early <= 1'b1;
      
        if (G_USER_WIDTH == 64) begin
          if (words_remaining <= 2 || (rcb_break == 1'b1 && long_address[2] == 1'b1 && first_completion == 1'b1)) begin
            tx_enable_max[1] = ram_valid & tx_completion_ready[0];
            read_ram = 1'b0;
            
            if (words_remaining[0] == 1'b0) begin // even number left, both positions enabled
              tx_enable_max[0] = ram_valid & tx_completion_ready[0];
            end
          end else begin
            tx_enable_max[1:0] = {(ram_valid & tx_completion_ready[0]) , (ram_valid & tx_completion_ready[0])};
            read_ram = 1'b1;
          end
        end else begin
          tx_enable_max[0] = ram_valid & tx_completion_ready[0];
          if (words_remaining <= 2)
             read_ram = 1'b0;
          else
             read_ram = 1'b1;
        end
        inc_transfer_count = ram_valid & tx_completion_ready[0];
        cpl_with_data = 1'b1;
        
        if (G_READ_LATENCY == 1)
          inc_ram_addr_counter = ram_valid & tx_completion_ready[0] & ~ (rcb_break & long_address[2] & first_completion);
        else
          inc_ram_addr_counter = read_ram_reg & tx_completion_ready[0] & ~ (rcb_break & long_address[2] & first_completion);

      end
      default : begin

      end
    endcase

  end

  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      ram_addr_counter <= {(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32)+1{1'b0}};

    end
    else begin
      if (tc_status[7:0] == 8'b00000000) begin
        ram_addr_counter <= {(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32)+1{1'b0}};
      end else begin
        if (load_ram_addr_counter == 1'b1) begin // RAM address counter - gets loaded at the start and then increments through the transfer
          if (G_USER_WIDTH == 64) begin // If RAM is 64bit wide, then use 1 less least sig address bit from the request header
            ram_addr_counter <= rx_data[G_BAR0_MASK_WIDTH + (G_USER_WIDTH-32) - 1:((G_USER_WIDTH-32)+1+(G_USER_WIDTH/32))];
          end else begin
            ram_addr_counter <= rx_data[G_BAR0_MASK_WIDTH - 1:(1+(G_USER_WIDTH/32))];
          end
        end
        else if (inc_ram_addr_counter == 1'b1 || post_inc_ram_addr_counter == 1'b1) begin // reads have to pre increment the address counter, writes postincrement
          ram_addr_counter <= next_ram_address;                                  // this is because of the extra clock latency when reading from the RAM
        end
      end

    end
  end

  //------------------------------------------------------------------------------
  // REGISTER THE OUTPUT TO THE RAMS
  //------------------------------------------------------------------------------
  always @(posedge clock or negedge reset_n)
  begin : vhdl2v_32
  integer loopvar;
    if (reset_n == 1'b0) begin
      ram_write_enables_internal <= {8{1'b0}};
      ram_write_address_internal <= {(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32)+1{1'b0}};
      ram_data_out_internal <= {G_USER_WIDTH{1'b0}};

    end
    else begin
      if (G_USER_WIDTH == 64) begin
        for (loopvar = 0; loopvar <= 3; loopvar = loopvar + 1) begin
          ram_write_enables_internal[loopvar] <= ram_write_enables_max_int[3-loopvar];
        end
        for (loopvar = 4; loopvar <= 7; loopvar = loopvar + 1) begin
          ram_write_enables_internal[loopvar] <= ram_write_enables_max_int[11-loopvar];
        end
      end else begin
        for (loopvar = 0; loopvar <= 3; loopvar = loopvar + 1) begin
          ram_write_enables_internal[loopvar] <= ram_write_enables_max_int[3-loopvar];
        end
      end

      // mux between current and next ram read address
      // so we can either hold or quickly increment the read address
      // depending on wait state control signals
      if (output_ram_start_address == 1'b1) begin
        ram_write_address_internal <= long_address[(G_BAR0_MASK_WIDTH-2)-(G_USER_WIDTH/32)+3:3];
      end
      else if (inc_ram_addr_counter == 1'b1) begin
        ram_write_address_internal <= next_ram_address;
      end else begin
        ram_write_address_internal <= ram_addr_counter;
      end

      ram_data_out_internal <= ram_data_out_max_int[G_USER_WIDTH-1:0];
    end
  end

  assign ram_data_out = ram_data_out_internal;
  assign ram_write_enables = ram_write_enables_internal[(G_USER_WIDTH/8)-1:0];
  assign ram_write_address = ram_write_address_internal;

  assign next_ram_address = ram_addr_counter + 1; // Calculate next ram address value
  assign ram_read_address = (inc_ram_addr_counter == 1'b1) ? next_ram_address : ram_addr_counter; // mux between current and next ram read address
                                                                                              // so we can either hold or quickly increment the read address
                                                                                              // depending on wait state control signals
  
  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      ram_valid <= 1'b0;
      read_ram_reg <= 1'b0;

    end
    else begin
      if (tc_status[7:0] == 8'b00000000) begin
        ram_valid <= 1'b0;
        read_ram_reg <= 1'b0;
      end else begin
        if (G_READ_LATENCY == 1)
           ram_valid <= read_ram;  // hook for longer latency RAMs
        else begin
           read_ram_reg <= read_ram; 
           ram_valid <= read_ram_reg;  // for latency = 2
        end
      end

    end
  end

  //------------------------------------------------------------------------------
  // CREATE THE IO REGISTER - NOW OBSOLETE
  //------------------------------------------------------------------------------
  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      leds_out_int <= {8{1'b1}};

    end
    else begin
      // The LEDs can get written from any of the byte lanes, depending on which byte enables are active
      if (led_write_enables[3] == 1'b1) begin
        leds_out_int <= ~ rx_data[(G_USER_WIDTH-32)+7:(G_USER_WIDTH-32)];  // the ls byte enable has priority.
      end
      else if (led_write_enables[2] == 1'b1) begin
        leds_out_int <= ~ rx_data[(G_USER_WIDTH-32)+15:(G_USER_WIDTH-32)+8];
      end
      else if (led_write_enables[1] == 1'b1) begin
        leds_out_int <= ~ rx_data[(G_USER_WIDTH-32)+23:(G_USER_WIDTH-32)+16];
      end
      else if (led_write_enables[0] == 1'b1) begin
        leds_out_int <= ~ rx_data[(G_USER_WIDTH-32)+31:(G_USER_WIDTH-32)+24];
      end

    end
  end

  //------------------------------------------------------------------------------
  // FORMAT THE COMPLETION PACKET
  //------------------------------------------------------------------------------

  // These signals are delayed in 64bit mode to cope with non 64bit-aligned transfers
  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      ram_data_delayed <= {32{1'b0}};

    end
    else begin
      if (G_USER_WIDTH == 64) begin
        ram_data_delayed <= ram_data_in[31:0];
      end else begin
        ram_data_delayed <= {32{1'b0}};
      end

    end
  end

  assign mchead1 = (current_state == `memr_cpl_head1) ? 1'b1 : 1'b0;
  assign head1 = (current_state == `ur_cpl_head1) ? 1'b1 : 1'b0;
  assign head2 = (current_state ==  `memr_cpl_head2 || current_state == `ur_cpl_head2) ? 1'b1 : 1'b0;
  assign head3 = (current_state ==  `memr_cpl_head3 || current_state == `ur_cpl_head3) ? 1'b1 : 1'b0;

  // This process generates the packet headers for the completions we send back to the requester
  always @(mchead1, head1, head2, head3, cpl_with_data, tc, attr, length, transfer_size, completer_id, cpl_unsuccessful, byte_count,
          requester_id, tag, lower_address, stored_header1, leds_out_int, ram_data_in, long_address, first_completion, ram_data_delayed)
  begin
    tx_data_max = {64{1'b0}};
    if (mchead1 == 1'b1) begin
      if (G_USER_WIDTH == 64) begin
        tx_data_max[63:0] = {1'b0 , cpl_with_data , 7'b0010100 , tc , 6'b000000 , attr , 2'b00 , transfer_size[9:0] , completer_id , 2'b00 , cpl_unsuccessful , 1'b0 , byte_count};
      end else begin
        tx_data_max[31:0] = {1'b0 , cpl_with_data , 7'b0010100 , tc , 6'b000000 , attr , 2'b00 , transfer_size[9:0]};
      end
    end
    else if (head1 == 1'b1) begin
      if (G_USER_WIDTH == 64) begin
        tx_data_max[63:0] = {1'b0 , cpl_with_data , 7'b0010100 , tc , 6'b000000 , attr , 2'b00 , length[9:0] , completer_id , 2'b00 , cpl_unsuccessful , 1'b0 , byte_count};
      end else begin
        tx_data_max[31:0] = {1'b0 , cpl_with_data , 7'b0010100 , tc , 6'b000000 , attr , 2'b00 , length[9:0]};
      end
    end
    else if (head2 == 1'b1) begin
      tx_data_max[31:0] = {completer_id , 2'b00 , cpl_unsuccessful , 1'b0 , byte_count};
    end
    else if (head3 == 1'b1) begin
      if (G_USER_WIDTH == 64) begin
        // stuff data into 3rd header
         if (long_address[2] == 1'b1 && first_completion == 1'b1) // 2nd half of 64-bit RAM data
           tx_data_max[63:0] = {requester_id , tag , 1'b0 , lower_address , ram_data_in[G_USER_WIDTH-32-1:0]};
         else
           tx_data_max[63:0] = {requester_id , tag , 1'b0 , lower_address , ram_data_in[G_USER_WIDTH-1:G_USER_WIDTH-32]};
      end else begin
        tx_data_max[31:0] = {requester_id , tag , 1'b0 , lower_address};
      end
    end else begin
      if (stored_header1[25] == 1'b1) begin
        if (G_USER_WIDTH == 64) begin
          tx_data_max[63:0] = {~ leds_out_int , ~ leds_out_int , ~ leds_out_int , ~ leds_out_int ,
                                   ~ leds_out_int , ~ leds_out_int , ~ leds_out_int , ~ leds_out_int};
        end else begin
          tx_data_max[31:0] = {~ leds_out_int , ~ leds_out_int , ~ leds_out_int , ~ leds_out_int};
        end
      end else begin
        if (G_USER_WIDTH == 64) begin
          if (long_address[2] == 1'b1) begin
            tx_data_max = ram_data_in;
          end else begin
            tx_data_max = {ram_data_delayed , ram_data_in[G_USER_WIDTH-1:G_USER_WIDTH-32]};
          end
        end else begin
          tx_data_max[G_USER_WIDTH-1:0] = ram_data_in;
        end
      end
    end
  end

  // -----------------------------------------------------------------------------
  // PRECALCULATE THE LENGTH OF TRANSFER
  // -----------------------------------------------------------------------------
  
  // hold starting address to calculate boundary condition
  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
       starting_addr <= {10{1'b1}};
    end else begin
        if (load_ram_addr_counter == 1'b1) begin 
          if (G_USER_WIDTH == 64) begin // If RAM is 64bit wide, then use 1 less least sig address bit from the request header
            starting_addr <= rx_data[G_BAR0_MASK_WIDTH + (G_USER_WIDTH-32) - 1:((G_USER_WIDTH-32)+1+(G_USER_WIDTH/32))];
          end else begin
            starting_addr <= rx_data[G_BAR0_MASK_WIDTH - 1:(1+(G_USER_WIDTH/32))];
          end
        end else if (update_length_count == 1'b1) begin
            starting_addr <= starting_addr + transfer_size; // last starting address + previous transfer size
        end
    end
  end

  assign ending_addr = (length_count > max_payload_div4) ? starting_addr + max_payload_div4 : starting_addr + length_count;

  
 
  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      transfer_size <= {11{1'b0}};
    end else begin
    // On first completion if , if breaking up completion to fit within max payload size,
    // just need to make sure we end on a valid boundary
    if (G_USER_WIDTH == 64 && long_address[2] == 1'b1 && first_completion == 1'b1 &&
       length_count > max_payload_div4)  begin  // && we can't finish the transfer within the max payload size,
      transfer_size <= max_payload_div4; // then we need to limit the transfer size here
    end
    // On continuing completions, if breaking up completion to fit within max payload size,
    // just need to make sure we end on a valid boundary
    else if (G_USER_WIDTH == 64 && (long_address[2] == 1'b0 || first_completion == 1'b0) &&
       length_count > max_payload_div4) begin // we can't finish the transfer within the max payload size,
      transfer_size <= max_payload_div4;  // then we need to break the transfer here
    end
    else if (G_USER_WIDTH == 32 &&
          length_count > max_payload_div4) begin // we can't finish the transfer within the max payload size,
      transfer_size <= max_payload_div4;    // then we need to break the transfer here
    end else begin
      transfer_size <= length_count;
    end
    end // clocked portion
  end // always block


  //------------------------------------------------------------------------------
  // TRACK WHERE WE ARE IN THE COMPLETION AND BREAK AT RCB
  //------------------------------------------------------------------------------

  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      length_count <= {11{1'b0}};
      transfer_count <= {10{1'b0}};

    end
    else begin
      if (tc_status[7:0] == 8'b00000000) begin
        length_count <= {11{1'b0}};
        transfer_count <= {10{1'b0}};
      end else begin
        if (init_length_count == 1'b1) begin  // the position of the length field varies, depending on whether packet has 3 or 4 header words
          if (G_USER_WIDTH == 64) begin
            length_count[9:0] <= rx_data[(G_USER_WIDTH-32)+9:(G_USER_WIDTH-32)]; // load length count from header field 
            length_count[10] <= ~(| rx_data[(G_USER_WIDTH-32)+9:(G_USER_WIDTH-32)]); // if all 0, then length=4096 bytes
          end else begin
            length_count[9:0] <= rx_data[9:0];     // load length count from header field
            length_count[10] <= ~(| rx_data[9:0]); // if all 0, then length=4096 bytes
          end
        end
        else if (update_length_count == 1'b1) begin
          length_count <= words_remaining;  // and do calculation to update it at the end of each completion. Read requests can be served using
        end                             // multiple completion packets.

        if (init_transfer_count == 1'b1) begin   // initialise transfer count at start of each transfer
          transfer_count <= {10{1'b0}};
        end
        else if (inc_transfer_count == 1'b1) begin // then increment through the transfer
          if (G_USER_WIDTH == 64) begin
            // inc by 2 if RAM is 64bits wide (unless only 1 word remaining) or first DW
            if (words_remaining <= 1 || (rcb_break == 1'b1 && long_address[2] == 1'b1 && first_completion == 1'b1)
             || (next_state == `read_memory_1)) begin
              transfer_count <= transfer_count + 1;
            end else begin
              transfer_count <= transfer_count + 2;
            end
          end else begin
            transfer_count <= transfer_count + 1;    // else inc by 1 if 32bits wide
          end
        end
        else if (inc_transfer_count_by_1 == 1'b1) begin
          transfer_count <= transfer_count + 1;
        end
      end

    end
  end

  
    assign words_remaining = (length_count > max_payload_div4) ? max_payload_div4 - transfer_count : length_count - transfer_count;

  // Generate lower address field for completion header
  assign lower_address = ((cpl_with_data == 1'b0 || (stored_header1[30] != 1'b0 || stored_header1[28:24] != 5'b00000) || first_completion == 1'b0)) ? 7'b0000000 : {long_address[6:2] , lower_address_modifier};
  assign lower_address_modifier = (first_byte_enables[0] == 1'b1) ? 2'b00 : (first_byte_enables[1] == 1'b1) ?  2'b01 : (first_byte_enables[2] == 1'b1) ?  2'b10 : (first_byte_enables[3] == 1'b1) ?  2'b11 : 2'b00;

  // Generate byte count field for completion header
    always @(length_count, max_payload_div4)
    begin : vhdl2v_38
      if (length_count > max_payload_div4)
        length_in_bytes = {max_payload_div4[10:0], 2'b00};
      else
        length_in_bytes = {length_count[10:0] , 2'b00};
    end // always

always @(length_count, length_in_bytes, first_byte_enables, last_byte_enables, first_completion)
begin
    if (length_count == 11'b00000000000) begin
      byte_count_calc = length_in_bytes;
    end
    else if (length_count == 11'b00000000001) begin
      if (first_byte_enables[3] == 1'b1) begin
        if (first_byte_enables[0] == 1'b1) begin
          byte_count_calc = length_in_bytes;
        end
        else if (first_byte_enables[1] == 1'b1) begin
          byte_count_calc = length_in_bytes - 1;
        end
        else if (first_byte_enables[2] == 1'b1) begin
          byte_count_calc = length_in_bytes - 2;
        end else begin
          byte_count_calc = length_in_bytes - 3;
        end
      end
      else if (first_byte_enables[2] == 1'b1) begin
        if (first_byte_enables[0] == 1'b1) begin
          byte_count_calc = length_in_bytes - 1;
        end
        else if (first_byte_enables[1] == 1'b1) begin
          byte_count_calc = length_in_bytes - 2;
        end else begin
          byte_count_calc = length_in_bytes - 3;
        end
      end
      else if (first_byte_enables[1] == 1'b1) begin
        if (first_byte_enables[0] == 1'b1) begin
          byte_count_calc = length_in_bytes - 2;
        end else begin
          byte_count_calc = length_in_bytes - 3;
        end
      end else begin
        byte_count_calc = length_in_bytes - 3;
      end
    end else begin
      if (last_byte_enables[3] == 1'b1) begin
        if (first_byte_enables[0] == 1'b1 || first_completion == 1'b0) begin
          byte_count_calc = length_in_bytes;
        end
        else if (first_byte_enables[1] == 1'b1) begin
          byte_count_calc = length_in_bytes - 1;
        end
        else if (first_byte_enables[2] == 1'b1) begin
          byte_count_calc = length_in_bytes - 2;
        end else begin
          byte_count_calc = length_in_bytes - 3;
        end
      end
      else if (last_byte_enables[2] == 1'b1) begin
        if (first_byte_enables[0] == 1'b1 || first_completion == 1'b0) begin
          byte_count_calc = length_in_bytes - 1;
        end
        else if (first_byte_enables[1] == 1'b1) begin
          byte_count_calc = length_in_bytes - 2;
        end
        else if (first_byte_enables[2] == 1'b1) begin
          byte_count_calc = length_in_bytes - 3;
        end else begin
          byte_count_calc = length_in_bytes - 4;
        end
      end
      else if (last_byte_enables[1] == 1'b1) begin
        if (first_byte_enables[0] == 1'b1 || first_completion == 1'b0) begin
          byte_count_calc = length_in_bytes - 2;
        end
        else if (first_byte_enables[1] == 1'b1) begin
          byte_count_calc = length_in_bytes - 3;
        end
        else if (first_byte_enables[2] == 1'b1) begin
          byte_count_calc = length_in_bytes - 4;
        end else begin
          byte_count_calc = length_in_bytes - 5;
        end
      end else begin
        if (first_byte_enables[0] == 1'b1 || first_completion == 1'b0) begin
          byte_count_calc = length_in_bytes - 3;
        end
        else if (first_byte_enables[1] == 1'b1) begin
          byte_count_calc = length_in_bytes - 4;
        end
        else if (first_byte_enables[2] == 1'b1) begin
          byte_count_calc = length_in_bytes - 5;
        end else begin
          byte_count_calc = length_in_bytes - 6;
        end
      end
    end
  end

  assign byte_count = ((cpl_with_data == 1'b0 || (stored_header1[30] != 1'b0 || stored_header1[28:24] != 5'b00000))) ? 13'b000000000000 : byte_count_calc;

  // Decode and register maxp
  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      max_payload_div4 <= {11{1'b0}};
    end
    else begin
      case (maxp)
        3'b000 : begin          max_payload_div4 <= (128/4);
        end
        3'b001 : begin          max_payload_div4 <= (256/4);
        end
        3'b010 : begin          max_payload_div4 <= (512/4);
        end
        3'b011 : begin          max_payload_div4 <= (1024/4);
        end
        3'b100 : begin          max_payload_div4 <= (2048/4);
        end
        3'b101 : begin          max_payload_div4 <= (4096/4);
        end
        default : begin          max_payload_div4 <= (128/4); // play it safe if software does something stupid
        end
      endcase
    end
  end

    always @(max_payload_div4 , length_count) begin
      if (length_count > max_payload_div4) begin
         $display("** WARNING: This Endpoint Completer Reference Design cannot return multiple completions.");
         $display("** WARNING: The requested completion is being capped at Max Payload size.");
      end
        rcb_break = 1'b0;
    end



  //------------------------------------------------------------------------------
  // HANG THE LEDS OFF MEMORY ADDRESS 0
  //------------------------------------------------------------------------------
  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      led_temp <= {8{1'b0}};
      leds_out <= {8{1'b0}};

    end
    else begin
      if (|(ram_write_address_internal) == 1'b0 && ram_write_enables_internal[(G_USER_WIDTH/8)-4] == 1'b1) begin
        led_temp <= ram_data_out_internal[G_USER_WIDTH-25:G_USER_WIDTH-32];
      end
      leds_out <= led_temp;

    end
  end

  //------------------------------------------------------------------------------
  // REGSITER THE TX USER INTERFACE
  //------------------------------------------------------------------------------

  assign tx_tc_select = G_TC_NUMBER;
  assign tx_fifo_select = 2'b10;
  assign tx_complete = 1'b0;
  assign tx_discard = 1'b0;

  assign tx_enable_early = tx_enable_max[(G_USER_WIDTH/32)-1:0];
  assign tx_data_early = tx_data_max[G_USER_WIDTH-1:0];

  always @(posedge clock or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      tx_enable <= {(G_USER_WIDTH/32){1'b0}};
      tx_header <= 1'b0;
      tx_first <= 1'b0;
      tx_last <= 1'b0;
      tx_data <= {G_USER_WIDTH{1'b0}};

    end
    else begin
      if (tx_completion_ready[G_TC_NUMBER] == 1'b1) begin
        tx_enable <= tx_enable_early;
        tx_header <= tx_header_early;
        tx_first <= tx_first_early;
        tx_last <= tx_last_early && (ram_valid || cpl_unsuccessful);
        tx_data <= tx_data_early;
      end

    end
  end

  //undefine enumerated states
  `undef idle
  `undef get_p_head4
  `undef write_memory_1_special
  `undef write_memory_n_special
  `undef write_memory_p_special
  `undef write_memory_1
  `undef read_memory_1
  `undef memr_cpl_head2
  `undef memr_cpl_head1
  `undef memr_cpl_head3
  `undef ur_cpl_head1
  `undef ur_cpl_head2
  `undef ur_cpl_head3
  `undef get_np_head1
  `undef get_np_head2
  `undef get_np_head3
  `undef get_p_head1
  `undef get_p_head2
  `undef get_p_head3
  `undef get_np_head4
  `undef write_memory_n
  `undef read_memory_n
  `undef discard_p
  `undef discard_np
  `undef setup_ram_addr
  `undef misaligned_preread
  `undef get_p_digest
  `undef memrd_digest

endmodule

