///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_phy_calib_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module does the claibration after initialization.
//
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_phy_calib_0 (
   input                                clk90,
   input                                reset90,
   input                                clk0,
   input                                reset0,
   input                                ctrl_rden,
   input                                idelay_ctrl_rdy,
   input [(`data_width*2)-1:0]          capture_data,
   input                                phy_init_rden,
   input                                phy_init_st1_read,
   input                                phy_init_st2_read,

   output reg [`data_strobe_width-1:0]  phy_calib_rden,
   output reg                           first_calib_done,
   output reg                           second_calib_done,
   output reg [`data_width-1:0]         phy_calib_dq_dlyinc,
   output reg [`data_width-1:0]         phy_calib_dq_dlyce,
   output reg [`data_width-1:0]         phy_calib_dq_dlyrst,
   output reg [`data_strobe_width-1:0]  phy_calib_dqs_dlyinc,
   output reg [`data_strobe_width-1:0]  phy_calib_dqs_dlyce,
   output reg [`data_strobe_width-1:0]  phy_calib_dqs_dlyrst);

   reg [3:0]                         state_r;
   reg                               data_detect_r;
   reg [5:0]                         window_count_r;
   reg [4:0]                         tap_count_r;
   reg [5:0]                         tap_inc_count_r;
   reg                               window_sel_done_r;
   reg [5:0]                         start_window_r;
   reg                               add_dq_delay_r;

   reg                               phy_init_rden_270_r;
   reg                               ctrl_rden_270_r;
   reg                               first_calib_done_90_r;
   reg                               second_calib_done_90_r;

   reg                               stg2_read_r1;
   reg                               stg2_read_r2;

   reg                               stg1_read_r1;
   reg                               stg1_read_r2;

   reg [4:0]                         read_en_r;
   reg [(`data_strobe_width*2)-1 :0] read_en_stg_r;

   reg [`data_strobe_width-1:0]      dqs_count_r;
   reg [`data_strobe_width-1:0]      rden_count_r;
   reg [(`data_width*2)-1:0]         capture_data_r;
   reg [(`data_width*2)-1:0]         capture_data_r1;
   reg                               dq_calib_done_r;
   reg                               dq_calib_begin_r;

   reg [3:0]                         dq_state_r;
   reg [1:0]                         dq_inc_count_r;
   reg [1:0]                         dq_dec_count_r;
   reg [2:0]                         dq_count_r;
   reg                               previous_value_r;

   reg                               data_match;
   reg                               data_check_r;

   wire                              read_en_r1_edge;
   wire                              read_en_r2_edge;
   wire                              read_en_r3_edge;
   wire                              read_en_r4_edge;

   reg [14:0]                         rd_en_stages_r;
   wire [14:0]                       load_mode_reg;
   wire [14:0]                       ext_mode_reg;

   localparam             IDLE              = 4'h0;
   localparam             CHECK             = 4'h1;
   localparam             INC               = 4'h2;
   localparam             WAIT0             = 4'h3;
   localparam             WAIT1             = 4'h4;
   localparam             WAIT2             = 4'h5;
   localparam             WINDOW_CHECK      = 4'h6;
   localparam             SELECT            = 4'h7;
   localparam             DQS_DQ_INC        =  4'h8;
   localparam             FINAL_INC         = 4'h9;
   localparam             FINAL_CHECK       = 4'hA;
   localparam             WINDOW_CHECK_WAIT = 4'hB;
   localparam             DQ_CALIB          = 4'hC;
   localparam             INC_WAIT0         = 4'hD;
   localparam             INC_WAIT1         = 4'hE;
   localparam             INC_WAIT2         = 4'hF;

   localparam             DQ_IDLE           = 4'h0;
   localparam             DQ_DQ_CHECK       = 4'h1;
   localparam             DQ_DQ_DEC         = 4'h2;
   localparam             DQ_DQ_INC         = 4'h3;
   localparam             DQ_DQ_WAIT0       = 4'h4;
   localparam             DQ_DQ_WAIT1       = 4'h5;
   localparam             DQ_DQ_WAIT2       = 4'h6;
   localparam             DQ_DQ_SELECT      = 4'h7;
   localparam             DQ_DQ_CALIB_DONE0 = 4'h8;
   localparam             DQ_DQ_CALIB_DONE1 = 4'h9;

   assign    load_mode_reg          = `load_mode_register;
   assign    ext_mode_reg           = `ext_load_mode_register;
   assign    REGISTERED_VALUE       = `registered;
   assign    CAS_LATENCY_VALUE      = load_mode_reg[6:4];
   assign    ADDITIVE_LATENCY_VALUE = ext_mode_reg[5:3];
   assign    ECC_VALUE              = `ecc_enable;

   // SM for the first stage of calibration. In the first stage of calibration the taps for DQS are incremented
   // until there is valid data. Once there is a data match the sm will increase the taps to find out the window
   // for valid data.During the calibration the SM will look at bit 0 of the DQS byte.
   // Once the calibration is done for the DQS, then the DQ calibration will be done by the next state machine.

   always @(posedge clk90)
   begin
      if(reset90 || ~idelay_ctrl_rdy)begin
        state_r <= IDLE;
         data_detect_r <= 1'd0; // will go high when there is a data match.
         phy_calib_dqs_dlyinc <= `data_strobe_width'd0;
         phy_calib_dqs_dlyce <= `data_strobe_width'd0;
         phy_calib_dqs_dlyrst <= {`data_strobe_width{1'b1}};
         window_count_r <= 6'd0;
         tap_count_r <= 5'd0;
         first_calib_done_90_r <= 1'd0; // flag to indicate the first stage of calibration is done.
         tap_inc_count_r <= 6'd0; // counter to count the taps during clock0 calibration.
         window_sel_done_r <= 1'd0; // flag for clock0 calibration
         dqs_count_r <= `data_strobe_width'd0; // count for dqs
         capture_data_r <= `data_width*2'd0;
         capture_data_r1 <= `data_width*2'd0;
         start_window_r <= 6'd0; // register to keep track of the start of the window.
         dq_calib_begin_r <= 1'd0; // flag to the dq calib state machine.
         add_dq_delay_r <= 1'd0;
         data_check_r <= 1'd0;
         previous_value_r <= 1'd0;

      end  else begin // if (reset90 || ~idelay_ctrl_rdy)
         capture_data_r <= capture_data;
         capture_data_r1 <= capture_data_r;
         data_check_r <= ((capture_data_r1[dqs_count_r*`memory_width] == capture_data_r1[(dqs_count_r*`memory_width) + `data_width] )
                         && ((capture_data_r1[dqs_count_r*`memory_width] ^ capture_data_r[dqs_count_r*`memory_width])
                         && (capture_data_r1[(dqs_count_r*`memory_width) + `data_width] ^ capture_data_r[(dqs_count_r*`memory_width) + `data_width]))
                         && (capture_data_r1[dqs_count_r*`memory_width] == previous_value_r));
        case(state_r)
           IDLE: if(stg1_read_r2) state_r <= CHECK;
	  
           CHECK: begin // The condition checks for data match. Also checks for rise and fall counter not going over 64.
                        // once the window is 16, we stop incrementing (inc_counter <= 4'd15)
                     if(data_check_r && (~(&tap_inc_count_r)) && (window_count_r < `data_window)) begin
                        data_detect_r <= 1'd1;
                        state_r <= INC;
                        window_count_r <= window_count_r + 1'd1;
                     end
                     else begin // if data_detect went high or rise,fall count has reached 64 without match
                        if((data_detect_r) || (&tap_inc_count_r))begin
                              state_r <= WINDOW_CHECK;
                              tap_count_r <= 5'd1;
                        end else
                          state_r <= INC;
                     end // else: !if((capture_data_r[dqs_count_r*`memory_width] == capture_data_r[(dqs_count_r*`memory_width) + `data_width] )...
                  end // case: CHECK
	  
           INC: begin
                   phy_calib_dqs_dlyce[dqs_count_r] <= 1'd1;
                   phy_calib_dqs_dlyinc[dqs_count_r] <= 1'd1;
                   state_r <= WAIT0;
                   tap_inc_count_r <= tap_inc_count_r + 1'd1;
                end  // case: INC
	  
           WAIT0: begin
                     state_r <= WAIT1;
                     add_dq_delay_r <= 1'd0;
                     phy_calib_dqs_dlyce[dqs_count_r] <= 1'd0;
                     phy_calib_dqs_dlyinc[dqs_count_r] <= 1'd0;
                     phy_calib_dqs_dlyrst[dqs_count_r] <= 1'd0;
                  end  // case: WAIT0
	  
           WAIT1: state_r <= WAIT2;
	  
           WAIT2: begin
                     if(window_sel_done_r ) // IF both clock0 and clock180 windows are found.
                         state_r <= FINAL_INC;
                     else begin
                         state_r <= CHECK;
                         previous_value_r <= capture_data_r[dqs_count_r*`memory_width];
                     end
                  end  // case: WAIT2
	  
           WINDOW_CHECK: begin
                            tap_count_r <= tap_count_r -1;
                            phy_calib_dqs_dlyrst[dqs_count_r] <= 1'd1; // reset90 all the taps to 0
                            data_detect_r <= 1'd0;
                            start_window_r <= tap_inc_count_r - window_count_r;
                            if(window_count_r < (`data_window -1))
                              begin
                                 add_dq_delay_r <= 1'd1;
                                 if(tap_count_r > 5'd0) begin
                                    state_r <= WINDOW_CHECK;
                                 end else begin
                                    state_r <= WAIT0;
                                    window_count_r <= 6'd0;
                                    tap_inc_count_r <= 6'd0;
                                 end // else: !if(tap_count_r == 5'd1)
                            end else begin
                                   window_sel_done_r <= 1'd1;
                                   state_r <= WINDOW_CHECK_WAIT;
                            end // else: !if(window_count_r < 5'd8)
                         end // case: WINDOW_CHECK
	  
           WINDOW_CHECK_WAIT: begin
                                 state_r <= SELECT; // wait state for dqs_rst
                                 phy_calib_dqs_dlyrst[dqs_count_r] <= 1'd0;
                              end  // case: WINDOW_CHECK_WAIT
	  
           SELECT: begin
                      state_r <= DQS_DQ_INC;
                      if(window_count_r > `data_window)
                        tap_inc_count_r <= window_count_r/2;
                      else
                        tap_inc_count_r <= window_count_r -8; // loading the counter with the tap value that needs to incremented from the start of the window.
                   end // case: SELECT
	  
           DQS_DQ_INC: begin
                          if(start_window_r > 6'd0)begin // increment until the start of window.
                             phy_calib_dqs_dlyce[dqs_count_r] <= 1'd1;
                             phy_calib_dqs_dlyinc[dqs_count_r] <= 1'd1;
                             start_window_r <= start_window_r - 1'b1;
                             state_r <= INC_WAIT0;
                          end else begin // once incremented do the individual dq calibration in the SM below.
                             if(dq_calib_done_r)
                               state_r <= FINAL_INC;
                             else
                               dq_calib_begin_r <= 1'd1;
                          end // else: !if(start_window_r > 6'd0)
                       end // case: INC
	  
           INC_WAIT0: begin
                         state_r <= INC_WAIT1;
                         phy_calib_dqs_dlyce[dqs_count_r] <= 1'd0;
                         phy_calib_dqs_dlyinc[dqs_count_r] <= 1'd0;
                      end  // case: INC_WAIT0
	  
           INC_WAIT1: state_r <= INC_WAIT2;
	  
           INC_WAIT2: state_r <= DQS_DQ_INC;
	  
           FINAL_INC: begin
                         dq_calib_begin_r <= 1'd0;
		       
                         if(tap_inc_count_r > 6'd0) // increment until the middle of the window.
                           begin
                              phy_calib_dqs_dlyce[dqs_count_r] <= 1'd1;
                              phy_calib_dqs_dlyinc[dqs_count_r] <= 1'd1;
                              tap_inc_count_r <= tap_inc_count_r - 1'd1;
                              state_r <= WAIT0;
                           end else begin
                              state_r <= FINAL_CHECK;
                              dqs_count_r <= dqs_count_r + 1'b1; // increment the dqs counter
                           end
                        end // case: FINAL_INC
	  
           FINAL_CHECK: begin
                           if(dqs_count_r >= (`data_strobe_width)) begin // if all the dqs has been calibrated then end the first calibration.
                              first_calib_done_90_r <= 1'd1;
                           end
                           else begin // reset90 all the counters and start on the next dqs.
                                 window_count_r <= 4'd0;
                                 tap_inc_count_r <= 6'd0;
                                 window_sel_done_r <= 1'd0;
                                 state_r <= WAIT0;
                           end // else: !if(dqs_count_r >= `data_strobe_width)
                        end // case: FINAL_CHECK
	  
        endcase // case(state_r)

      end // else: !if(reset90 || ~idelay_ctrl_rdy)

   end // always@ (posedge clk90)

   // This state machine does the DQ calibration. After the DQS calibration is done, the dq calibration
   // will be done.  The DQ bits start with a tap setting of 5. The taps will be incremented or decremented
   // to fine tune the individual DQ window.

   always @(posedge clk90)
   begin
      if(reset90 || ~idelay_ctrl_rdy)begin
         dq_state_r <= DQ_IDLE;
         dq_calib_done_r <= 1'd0;
         dq_inc_count_r <= 2'd0;
         dq_dec_count_r <= 2'd0;
         dq_count_r <= 3'd1; // starts with a default of 1 because the first dq is calibrated in the dqs calibration
         phy_calib_dq_dlyinc <= `data_width'd0;
         phy_calib_dq_dlyce <= `data_width'd0;
         phy_calib_dq_dlyrst <= {`data_width{1'b1}};
      end // if (reset90 || ~idelay_ctrl_rdy)
      else begin

      phy_calib_dq_dlyrst <= `data_width'd0;

        case(dq_state_r)

           DQ_IDLE: begin
          
                       phy_calib_dq_dlyinc[(dqs_count_r*`memory_width) + 0] <= add_dq_delay_r;
                       phy_calib_dq_dlyce[(dqs_count_r*`memory_width) + 0] <= add_dq_delay_r;
                       phy_calib_dq_dlyinc[(dqs_count_r*`memory_width) + 1] <= add_dq_delay_r;
                       phy_calib_dq_dlyce[(dqs_count_r*`memory_width) + 1] <= add_dq_delay_r;
                       phy_calib_dq_dlyinc[(dqs_count_r*`memory_width) + 2] <= add_dq_delay_r;
                       phy_calib_dq_dlyce[(dqs_count_r*`memory_width) + 2] <= add_dq_delay_r;
                       phy_calib_dq_dlyinc[(dqs_count_r*`memory_width) + 3] <= add_dq_delay_r;
                       phy_calib_dq_dlyce[(dqs_count_r*`memory_width) + 3] <= add_dq_delay_r;
                       phy_calib_dq_dlyinc[(dqs_count_r*`memory_width) + 4] <= add_dq_delay_r;
                       phy_calib_dq_dlyce[(dqs_count_r*`memory_width) + 4] <= add_dq_delay_r;
                       phy_calib_dq_dlyinc[(dqs_count_r*`memory_width) + 5] <= add_dq_delay_r;
                       phy_calib_dq_dlyce[(dqs_count_r*`memory_width) + 5] <= add_dq_delay_r;
                       phy_calib_dq_dlyinc[(dqs_count_r*`memory_width) + 6] <= add_dq_delay_r;
                       phy_calib_dq_dlyce[(dqs_count_r*`memory_width) + 6] <= add_dq_delay_r;
                       phy_calib_dq_dlyinc[(dqs_count_r*`memory_width) + 7] <= add_dq_delay_r;
                       phy_calib_dq_dlyce[(dqs_count_r*`memory_width) + 7] <= add_dq_delay_r;
                       if(dq_calib_begin_r) dq_state_r <= DQ_DQ_CHECK;
                    end  // case: DQ_IDLE
          
           DQ_DQ_CHECK: begin
                           if((capture_data_r[(dqs_count_r*`memory_width) + dq_count_r] == capture_data_r[((dqs_count_r*`memory_width) + `data_width)+dq_count_r] ))begin
                                if(dq_dec_count_r > 2'd0) // if no data match to start with increment to find the window. If there was a decrement and
                                  dq_state_r <= DQ_DQ_SELECT; // data does not match now then the end of the window has been foune.
                                else
                                  dq_state_r <= DQ_DQ_INC;
                           end else begin
                              if((dq_inc_count_r == 2'd0)) // if there is a data match to start with decrement the window. If there was an increment
                                                             // and then a data match (dq_inc_counter_r will be > 0 in case of previous increment). the
                                  dq_state_r <= DQ_DQ_DEC;   // window for the DQ has been found.
                                else
                                  dq_state_r <= DQ_DQ_SELECT;
                           end // else: !if((capture_data_r[(dqs_count_r*`memory_width) + dq_count_r] == capture_data_r[((dqs_count_r*`memory_width) + `data_width)+dq_count_r] ))
                        end // case: DQ_DQ_CHECK
          
           DQ_DQ_DEC: begin
                         phy_calib_dq_dlyce[(dqs_count_r*`memory_width) + dq_count_r] <= 1'd1;
                         dq_state_r <= DQ_DQ_WAIT0;
                         dq_dec_count_r <= dq_dec_count_r + 1'd1;
                      end  // case: DQ_DQ_DEC
          
           DQ_DQ_INC: begin
                         phy_calib_dq_dlyce[(dqs_count_r*`memory_width) + dq_count_r] <= 1'd1;
                         phy_calib_dq_dlyinc[(dqs_count_r*`memory_width) + dq_count_r] <= 1'd1;
                         dq_state_r <= DQ_DQ_WAIT0;
                         dq_inc_count_r <= dq_inc_count_r + 1'd1;
                      end  // case: DQ_DQ_INC
          
           DQ_DQ_WAIT1: dq_state_r <= DQ_DQ_WAIT2;
          
           DQ_DQ_WAIT0: begin
                           dq_state_r <= DQ_DQ_WAIT1;
                           phy_calib_dq_dlyinc[(dqs_count_r*`memory_width) + dq_count_r] <= 1'd0;
                           phy_calib_dq_dlyce[(dqs_count_r*`memory_width) + dq_count_r] <= 1'd0;
                        end  // case: DQ_DQ_WAIT0
          
           DQ_DQ_WAIT2: begin
                           if(&dq_dec_count_r || &dq_inc_count_r)
                             dq_state_r <= DQ_DQ_SELECT;
                           else
                             dq_state_r <= DQ_DQ_CHECK;
                        end  // case: DQ_DQ_WAIT2
          
           DQ_DQ_SELECT: begin
                            if(&dq_count_r) begin // if all the dq bits are calibrated
                               dq_state_r <= DQ_DQ_CALIB_DONE0;
                               dq_count_r <= 3'd1;
                               dq_calib_done_r <= 1'd1;
                               dq_dec_count_r <= 2'd0;
                               dq_inc_count_r <= 2'd0;
                            end else begin
                               dq_state_r <= DQ_DQ_CHECK;
                               dq_count_r <= dq_count_r + 1'd1;
                            end
                         end // case: DQ_DQ_SELECT
          
           DQ_DQ_CALIB_DONE0: begin
                                 dq_state_r <= DQ_DQ_CALIB_DONE1;
                                 dq_calib_done_r <= 1'd1;
                              end // case: DQ_DQ_CALIB_DONE0
          
           DQ_DQ_CALIB_DONE1: begin
                                 dq_state_r <= DQ_IDLE;
                                 dq_calib_done_r <= 1'd0;
                              end  // case: DQ_DQ_CALIB_DONE1
          
        endcase // case(dq_state_r)

      end // else: !if(reset90 || ~idelay_ctrl_rdy)
   end // always@ (posedge clk90)

   always @(negedge clk90)
   begin
      if(reset90) begin
         ctrl_rden_270_r <= 1'd0;
         phy_init_rden_270_r <= 1'd0;
      end else begin
         ctrl_rden_270_r <= ctrl_rden;
         phy_init_rden_270_r <= phy_init_rden;
      end
   end

   always @(posedge clk90)
   begin
      if(reset90)
      begin
        read_en_r <= 5'd0;
        rd_en_stages_r <= 15'd0;
        end
      else
      begin
         read_en_r[0] <= rd_en_stages_r[ADDITIVE_LATENCY_VALUE + ECC_VALUE + REGISTERED_VALUE+5];
         read_en_r[1] <= read_en_r[0];
         read_en_r[2] <= read_en_r[1];
         read_en_r[3] <= read_en_r[2];
         read_en_r[4] <= read_en_r[3];
         rd_en_stages_r[0] <= ctrl_rden_270_r | phy_init_rden_270_r;
         rd_en_stages_r[1] <= rd_en_stages_r[0];
         rd_en_stages_r[2] <= rd_en_stages_r[1];
         rd_en_stages_r[3] <= rd_en_stages_r[2];
         rd_en_stages_r[4] <= rd_en_stages_r[3];
         rd_en_stages_r[5] <= rd_en_stages_r[4];
         rd_en_stages_r[6] <= rd_en_stages_r[5];
         rd_en_stages_r[7] <= rd_en_stages_r[6];
         rd_en_stages_r[8] <= rd_en_stages_r[7];
         rd_en_stages_r[9] <= rd_en_stages_r[8];
         rd_en_stages_r[10] <= rd_en_stages_r[9];
         rd_en_stages_r[11] <= rd_en_stages_r[10];
         rd_en_stages_r[12] <= rd_en_stages_r[11];
         rd_en_stages_r[13] <= rd_en_stages_r[12];
         rd_en_stages_r[14] <= rd_en_stages_r[13];

      end
   end

   //readen calibration

   always @(posedge clk90)
   begin
      if(reset90)
      begin
         stg2_read_r2 <= 1'd0;
         stg1_read_r2 <= 1'd0;
      end
      else
      begin
         stg2_read_r2 <= stg2_read_r1;
         stg1_read_r2 <= stg1_read_r1;
      end
   end // always@ (posedge clk90)

   always @(negedge clk90)
   begin
      if(reset90)
      begin
         stg2_read_r1 <= 1'd0;
         stg1_read_r1 <= 1'd0;
      end
      else
      begin
         stg2_read_r1 <= phy_init_st2_read;
         stg1_read_r1 <= phy_init_st1_read;
      end
   end // always@ (posedge clk90)

   assign read_en_r1_edge = read_en_r[0] & ~read_en_r[1];
   assign read_en_r2_edge = read_en_r[1] & ~read_en_r[2];
   assign read_en_r3_edge = read_en_r[2] & ~read_en_r[3];
   assign read_en_r4_edge = read_en_r[3] & ~read_en_r[4];

   always @(posedge clk90)
   begin
      if(reset90)
        data_match <= 1'b0;
      else
        data_match <= ( (capture_data_r[(rden_count_r*`memory_width)] == 1) &&
                             (capture_data_r[(rden_count_r*`memory_width+1)] == 0)&&
                             (capture_data_r[(rden_count_r*`memory_width+2)] == 1)&&
                             (capture_data_r[(rden_count_r*`memory_width+3)] == 0)&&
                             (capture_data[(rden_count_r*`memory_width)] == 0) &&
                             (capture_data[(rden_count_r*`memory_width+1)] == 1)&&
                             (capture_data[(rden_count_r*`memory_width+2)] == 1)&&
                             (capture_data[(rden_count_r*`memory_width+3)] == 0)&&
                             (capture_data_r[(rden_count_r*`memory_width)+`data_width ] == 1) &&
                             (capture_data_r[(rden_count_r*`memory_width+1)+ `data_width] == 0)&&
                             (capture_data_r[(rden_count_r*`memory_width+2)+ `data_width] == 1)&&
                             (capture_data_r[(rden_count_r*`memory_width+3)+ `data_width] == 0)&&
                             (capture_data[(rden_count_r*`memory_width)+`data_width ] == 0) &&
                             (capture_data[(rden_count_r*`memory_width+1)+ `data_width] == 1)&&
                             (capture_data[(rden_count_r*`memory_width+2)+ `data_width] == 1)&&
                             (capture_data[(rden_count_r*`memory_width+3)+ `data_width] == 0));
   end // always @ (posedge clk90)

   always @(posedge clk90)
   begin
      if(reset90)
      begin
         read_en_stg_r <= 2*`data_strobe_width'd0;
         second_calib_done_90_r <= 1'd0;
         rden_count_r <= `data_strobe_width'd0;
      end
      else
      begin
         if(rden_count_r ==  (`data_strobe_width))
            second_calib_done_90_r <= 1'd1;

         case({second_calib_done_90_r,data_match, read_en_r1_edge, read_en_r2_edge, read_en_r3_edge, read_en_r4_edge})
            6'b011000: begin
               read_en_stg_r[((rden_count_r*2) + 1)] <= 1'b0;
               read_en_stg_r[(rden_count_r*2)] <= 1'b0;
               rden_count_r <= rden_count_r + 1'd1;
            end
            6'b010100: begin
               read_en_stg_r[((rden_count_r*2) + 1)] <= 1'b0;
               read_en_stg_r[(rden_count_r*2)] <= 1'b1;
                rden_count_r <= rden_count_r + 1'd1;
            end
            6'b010010: begin
               read_en_stg_r[((rden_count_r*2) + 1)] <= 1'b1;
               read_en_stg_r[(rden_count_r*2)] <= 1'b0;
               rden_count_r <= rden_count_r + 1'd1;
            end
            6'b010001: begin
               read_en_stg_r[((rden_count_r*2) + 1)] <= 1'b1;
               read_en_stg_r[(rden_count_r*2)] <= 1'b1;
               rden_count_r <= rden_count_r + 1'd1;
            end
         endcase // case({data_match, read_en_r1_edge, read_en_r2_edge, read_en_r3_edge, read_en_r4_edge})

      end // else: !if(reset90)
   end // always@ (posedge clk90)

   always @(posedge clk0)
   begin
      if(reset0)
      begin
         first_calib_done <= 1'd0;
         second_calib_done <= 1'd0;
      end
      else
      begin
         first_calib_done <= first_calib_done_90_r;
         second_calib_done <= second_calib_done_90_r;
      end
   end

   genvar rd_en;
   generate for(rd_en= 0; rd_en < `data_strobe_width; rd_en = rd_en+1)
   begin: rd_en_inst
   always @(posedge clk90)
   begin
      if(reset90)
      begin
         phy_calib_rden[rd_en] <= 1'd0;
      end
      else
      begin
            case({stg2_read_r2,read_en_stg_r[((rd_en*2)+1):(rd_en*2)]})
              3'b000: phy_calib_rden[rd_en]  <= rd_en_stages_r[ADDITIVE_LATENCY_VALUE + ECC_VALUE + REGISTERED_VALUE+3];
              3'b001: phy_calib_rden[rd_en]  <= rd_en_stages_r[ADDITIVE_LATENCY_VALUE + ECC_VALUE + REGISTERED_VALUE+4];
              3'b010: phy_calib_rden[rd_en]  <= rd_en_stages_r[ADDITIVE_LATENCY_VALUE + ECC_VALUE + REGISTERED_VALUE+5];
              3'b011: phy_calib_rden[rd_en]  <= rd_en_stages_r[ADDITIVE_LATENCY_VALUE + ECC_VALUE + REGISTERED_VALUE+6];
            endcase // case({stg2_read_r2,read_en_stg_r[1:0]})
     end // else: !if(reset90)
    end // always@ (posedge clk90)
   end
   endgenerate

endmodule // phy_calib


