///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2005 Xilinx, Inc.
// This design is confidential and proprietary of Xilinx, All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_phy_init_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description     : This module is the intialization control logic of the memory
//                  interface. All commands are issued from here acoording to the
//                  burst, CAS Latency and the user commands.
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "../rtl/mem_parameters_0.v"

module mem_phy_init_0 (

   input                       clk0,
   input                       rst,
   input                       first_calib_done,
   input                       second_calib_done,
   input                       ctrl_ref_flag,


   output reg                  phy_init_wdf_rden,
   output                      phy_init_dqs_rst,
   output                      phy_init_dqs_en,
   output                      phy_init_wren,
   output                      phy_init_rden,
   output [`row_address-1:0]   phy_init_address,
   output [`bank_address-1:0]  phy_init_ba,
   output                      phy_init_ras_n,
   output                      phy_init_cas_n,
   output                      phy_init_we_n,
   output [`cs_width-1:0]      phy_init_cs_n,
   output [`cke_width-1:0]     phy_init_cke,
   output [`odt_width-1:0]     phy_init_odt,
   output                      phy_init_st1_read,
   output                      phy_init_st2_read,
   output                      phy_init_initialization_done

                      );

   // internal signals
   reg [3:0]                init_count_r;
   reg                      init_memory_r;
   reg [7:0]                count_200_cycle_r;
   reg [4:0]                init_next_state;
   reg [4:0]                init_state_r;
   reg [4:0]                init_state_r1;
   reg [4:0]                init_state_r2;
   reg [`row_address -1:0]  ddr2_address_init_r;
   reg [`bank_address-1:0]  ddr2_ba_r;
   reg [2:0]                cas_count_r;
   reg [3:0]                cas_check_count_r;
   reg [2:0]                wrburst_cnt_r;
   reg [2:0]                read_burst_cnt_r;
   reg [2:0]                rdburst_cnt_r;
   reg                      ddr2_ras_r1;
   reg                      ddr2_cas_r1;
   reg                      ddr2_we_r1;
   reg                      ddr2_ras_r;
   reg                      ddr2_cas_r;
   reg                      ddr2_we_r;
   reg                      dqs_reset;
   reg                      dqs_en;
   reg [`cs_width-1:0]      ddr2_cs_r1;
   reg [`cke_width-1:0]     ddr2_cke_r;
   reg [1:0]                chip_cnt_r;
   reg                      count_200cycle_done_r;
   wire [2:0]               burst_cnt;
   reg                      ctrl_write_en;
   reg                      ctrl_read_en;
   wire [3:0]               CAS_LATENCY_VALUE;
   wire [2:0]               BURST_LENGTH_VALUE;
   wire [3:0]               ADDITIVE_LATENCY_VALUE;
   wire                     ODT_ENABLE;
   wire                     REGISTERED_VALUE;
   reg  [4:0]               cke_200us_cnt_r;
   reg                      done_200us_r;
   reg                      initalization_done_r;
   wire [14:0]              load_mode_reg;
   wire [14:0]              ext_mode_reg;
   reg [2:0]                ctrl_wren_cnt_r;
   reg [3:0]                odt_cnt_r;
   reg [3:0]                odt_en_cnt_r;
   reg [`odt_width-1 :0 ]   odt_en;

   reg                      wdf_rden_r;
   reg                      wdf_rden_r1;
   reg                      wdf_rden_r2;
   reg                      wdf_rden_r3;
   reg                      wdf_rden_r4;
   reg                      wdf_rden_r5;
   reg                      wdf_rden_r6;
   reg                      wdf_rden_r7;
   reg                      wdf_rden_r8;
   reg                      wdf_rden_r9;

   reg [5:0]                count6;

   localparam  cntnext   =  6'b101011;

   localparam  INIT_ACTIVE              =     5'h00;
   localparam  INIT_DUMMY_ACTIVE        =     5'h01;
   localparam  INIT_PRECHARGE           =     5'h02;
   localparam  INIT_LOAD_MODE           =     5'h03;
   localparam  INIT_AUTO_REFRESH        =     5'h04;
   localparam  INIT_FIRST_WRITE         =     5'h05;
   localparam  INIT_PATTERN_WRITE       =     5'h06;
   localparam  INIT_FIRST_READ          =     5'h07;
   localparam  INIT_PATTERN_READ        =     5'h08;
   localparam  INIT_COUNT_200           =     5'h09;
   localparam  INIT_DEEP_MEMORY_ST      =     5'h0A;
   localparam  INIT_MODE_REGISTER_WAIT  =     5'h0B;
   localparam  INIT_PRECHARGE_WAIT      =     5'h0C;
   localparam  INIT_AUTO_REFRESH_WAIT   =     5'h0D;
   localparam  INIT_COUNT_200_WAIT      =     5'h0E;
   localparam  INIT_DUMMY_ACTIVE_WAIT   =     5'h0F;
   localparam  INIT_ACTIVE_WAIT         =     5'h10;
   localparam  INIT_PATTERN_WRITE_READ  =     5'h11;
   localparam  INIT_PATTERN_READ_WAIT   =     5'h12;
   localparam  INIT_FIRST_WRITE_READ    =     5'h13;
   localparam  INIT_FIRST_READ_WAIT     =     5'h14;
   localparam  INIT_IDLE                =     5'h15;

   assign    phy_init_st1_read      = (init_state_r2  == INIT_FIRST_READ) || (init_state_r2 == INIT_FIRST_READ_WAIT);
   assign    phy_init_st2_read      = ((init_state_r2  == INIT_PATTERN_READ) || (init_state_r2  == INIT_PATTERN_READ_WAIT));
   assign    REGISTERED_VALUE       = `registered;
   assign    CAS_LATENCY_VALUE      = {1'd0, load_mode_reg[6:4]};
   assign    BURST_LENGTH_VALUE     = load_mode_reg[2:0];
   assign    ADDITIVE_LATENCY_VALUE = {1'd0, ext_mode_reg[5:3]};
   assign    ODT_ENABLE             = ext_mode_reg[2] | ext_mode_reg[6];
   assign    load_mode_reg          = `load_mode_register;
   assign    ext_mode_reg           = `ext_load_mode_register;
   assign    phy_init_initialization_done =  initalization_done_r;

   assign    burst_cnt           = (BURST_LENGTH_VALUE == 3'b010) ? 3'b010 :
                                (BURST_LENGTH_VALUE == 3'b011) ? 3'b100 : 3'b000;

   //to initialize memory
   always @ (posedge clk0)
   begin
      if ((rst)|| (init_state_r == INIT_DEEP_MEMORY_ST))
           init_memory_r <= 1'b1;
      else if (init_count_r == 4'hE)
           init_memory_r <= 1'b0;
   end

   always @(posedge clk0)
   begin
      if(rst)
         count6 <= 6'b000000;
      else begin
         case (init_state_r)

            INIT_PRECHARGE_WAIT, INIT_MODE_REGISTER_WAIT, INIT_AUTO_REFRESH_WAIT,
            INIT_ACTIVE_WAIT, INIT_PATTERN_WRITE_READ, INIT_PATTERN_READ_WAIT,
            INIT_DUMMY_ACTIVE_WAIT, INIT_FIRST_READ_WAIT, INIT_FIRST_WRITE_READ :
            begin
               count6 <= count6 + 1;
            end

            default:
                 count6 <= 6'b000000;
         endcase
      end
   end

   //200us counter for cke
   always @ (posedge clk0)
   begin
      if (rst )
         `ifdef simulation
             cke_200us_cnt_r <= 5'b00001;
          //   cke_200us_cnt_r <= 5'b11111;
         `else
             cke_200us_cnt_r <= 5'b11011;
         `endif
      else if (ctrl_ref_flag)
        cke_200us_cnt_r  <=  cke_200us_cnt_r - 1;
   end

   // refresh detect in 266 MHz clock
   always @ (posedge clk0)
   begin
      if (rst)
         done_200us_r <= 1'b0;
      else  if (done_200us_r == 1'b0)
         done_200us_r <= (cke_200us_cnt_r == 5'b00000);
   end

   // 200 clocks counter - count value : C8
   // required for initialization
   always @ (posedge clk0)
   begin
      if (rst)
         count_200_cycle_r <= 8'h00;
      else if (init_state_r == INIT_COUNT_200)
         count_200_cycle_r <= 8'hC8;
      else if (count_200_cycle_r >8'h00)
         count_200_cycle_r <= count_200_cycle_r - 1;
   end

   always @ (posedge clk0)
   begin
      if (rst)
         count_200cycle_done_r<= 1'b0;
      else if (init_memory_r && (count_200_cycle_r == 8'h00))
         count_200cycle_done_r<= 1'b1;
      else
         count_200cycle_done_r<= 1'b0;
   end

   always @ (posedge clk0)
   begin
      if ((rst)|| (init_state_r == INIT_DEEP_MEMORY_ST)) 
           init_count_r <= 4'd0;
      else if (init_memory_r ) begin 
//MD this is change 2 for the loop of LMR
//         if ((init_state_r == INIT_IDLE || init_state_r == INIT_LOAD_MODE) && init_count_r == 4'hC)
//           begin
//             init_count_r <= 4'h0;
//           end
         if (init_state_r == INIT_LOAD_MODE || init_state_r == INIT_PRECHARGE || init_state_r == INIT_AUTO_REFRESH ||
             init_state_r == INIT_COUNT_200 || init_state_r == INIT_DEEP_MEMORY_ST) begin
            init_count_r <= init_count_r + 1'b1;
         end else if(init_count_r == 4'hF )
            init_count_r <= 4'd0;
      end
   end // always @ (posedge clk0)

   always @ (posedge clk0 )
   begin
      if (rst)
           chip_cnt_r <= 2'd0;
      else if ( init_state_r == INIT_DEEP_MEMORY_ST)
         chip_cnt_r <= chip_cnt_r + 2'd1;
   end

   // write burst count
   always @ (posedge clk0)
   begin
      if (rst)
         wrburst_cnt_r <= 3'd0;
      else if (init_state_r == INIT_PATTERN_WRITE || init_state_r == INIT_FIRST_WRITE )
         wrburst_cnt_r <= burst_cnt;
      else if (wrburst_cnt_r > 3'd0)
         wrburst_cnt_r <= wrburst_cnt_r - 1'b1;
   end

   // read burst count for state machine
   always @ (posedge clk0)
   begin
      if (rst)
         read_burst_cnt_r <= 3'd0;
      else if (init_state_r == INIT_PATTERN_READ || init_state_r == INIT_FIRST_READ)
         read_burst_cnt_r <= burst_cnt;
      else if (read_burst_cnt_r > 3'd0)
         read_burst_cnt_r <= read_burst_cnt_r - 1'b1;
   end

   // count to generate write enable to the data path
   always @ (posedge clk0)
   begin
      if (rst)
         ctrl_wren_cnt_r <= 3'd0;
      else if ((init_state_r1 == INIT_FIRST_WRITE)  || (init_state_r1 == INIT_PATTERN_WRITE))
         ctrl_wren_cnt_r <= burst_cnt;
      else if (ctrl_wren_cnt_r > 3'd0)
         ctrl_wren_cnt_r <= ctrl_wren_cnt_r -1'b1;
   end

   //write enable to data path
   always @ (*)
   begin
      if (ctrl_wren_cnt_r != 3'd0)
         ctrl_write_en <= 1'b1;
      else
         ctrl_write_en <= 1'b0;
   end

   assign phy_init_wren = ctrl_write_en;

   // DQS enable to data path
   always @ (*)
   begin
      if ((init_state_r == INIT_PATTERN_WRITE) || (init_state_r == INIT_FIRST_WRITE))
         dqs_reset <= 1'b1;
      else
         dqs_reset <= 1'b0;
   end

   assign phy_init_dqs_rst = dqs_reset;

   always @ (*)
   begin
      if ((init_state_r == INIT_PATTERN_WRITE) || (init_state_r == INIT_FIRST_WRITE) || (wrburst_cnt_r != 3'b000))
         dqs_en <= 1'b1;
      else
         dqs_en <= 1'b0;
   end

   assign phy_init_dqs_en = dqs_en;

   // cas count
   always @ (posedge clk0)
   begin
      if (rst)
         cas_count_r <= 3'd0;
      else if (init_state_r == INIT_PATTERN_READ)
         cas_count_r <= CAS_LATENCY_VALUE + `registered;
      else if (cas_count_r > 3'd0)
         cas_count_r <= cas_count_r - 1;
   end

   always @ (posedge clk0)
   begin
      if (rst)
         cas_check_count_r <= 4'd0;
      else if ((init_state_r1 == INIT_PATTERN_READ) )
         cas_check_count_r <= (CAS_LATENCY_VALUE - 1);
      else if (cas_check_count_r > 4'd0)
         cas_check_count_r <= cas_check_count_r - 1'b1;
   end

   always @ (posedge clk0)
   begin
      if (rst)
         rdburst_cnt_r <= 3'd0;
      else if ((cas_check_count_r == 4'b0010))
         rdburst_cnt_r <= burst_cnt;
      else if (rdburst_cnt_r > 3'd0)
         rdburst_cnt_r <= rdburst_cnt_r - 1'b1;
   end // always @ (posedge clk0)

   //read enable to data path
   always @ (*)
   begin
      if ((rdburst_cnt_r == 3'd0)) begin
         ctrl_read_en <= 1'b0;
      end else begin
         ctrl_read_en <= 1'b1;
      end
   end

   always @(posedge clk0)
   begin
      if(rst)
         wdf_rden_r <= 1'd0;
      else if ((init_state_r == INIT_FIRST_WRITE) || (init_state_r == INIT_PATTERN_WRITE))
         wdf_rden_r <= 1'd1;
      else
         wdf_rden_r <= 1'd0;
   end

   always @(posedge clk0)
   begin
      if(rst) begin
         wdf_rden_r1 <= 1'd0;
         wdf_rden_r2 <= 1'd0;
         wdf_rden_r3 <= 1'd0;
         wdf_rden_r4 <= 1'd0;
         wdf_rden_r5 <= 1'd0;
         wdf_rden_r6 <= 1'd0;
         wdf_rden_r7 <= 1'd0;
         wdf_rden_r8 <= 1'd0;
         wdf_rden_r9 <= 1'd0;
      end
      else begin
         wdf_rden_r1 <= wdf_rden_r;
         wdf_rden_r2 <= wdf_rden_r1;
         wdf_rden_r3 <= wdf_rden_r2;
         wdf_rden_r4 <= wdf_rden_r3;
         wdf_rden_r5 <= wdf_rden_r4;
         wdf_rden_r6 <= wdf_rden_r5;
         wdf_rden_r7 <= wdf_rden_r6;
         wdf_rden_r8 <= wdf_rden_r7;
         wdf_rden_r9 <= wdf_rden_r8;
      end // else: !if(rst)
   end // always@ (posedge clk0)

   always @(posedge clk0)
   begin
      if(rst) begin
         phy_init_wdf_rden<= 1'd0;
      end else begin
          case(ADDITIVE_LATENCY_VALUE  + CAS_LATENCY_VALUE + REGISTERED_VALUE)
             4'b0011:phy_init_wdf_rden<= wdf_rden_r | wdf_rden_r1 | wdf_rden_r2 | wdf_rden_r3;
             4'b0100:phy_init_wdf_rden<= wdf_rden_r1 | wdf_rden_r2 | wdf_rden_r3 | wdf_rden_r4;
             4'b0101:phy_init_wdf_rden<= wdf_rden_r2 | wdf_rden_r3 | wdf_rden_r4 | wdf_rden_r5;
             4'b0110:phy_init_wdf_rden<= wdf_rden_r3 | wdf_rden_r4 | wdf_rden_r5 | wdf_rden_r6;
             4'b0111:phy_init_wdf_rden<= wdf_rden_r4 | wdf_rden_r5 | wdf_rden_r6 | wdf_rden_r7;
             4'b1000:phy_init_wdf_rden<= wdf_rden_r5 | wdf_rden_r6 | wdf_rden_r7 | wdf_rden_r8;
             4'b1001:phy_init_wdf_rden<= wdf_rden_r6 | wdf_rden_r7 | wdf_rden_r8 | wdf_rden_r9;
          endcase // case(ADDITIVE_LATENCY_VALUE  + CAS_LATENCY_VALUE + REGISTERED_VALUE)
      end // else: !if(rst)
   end // always@ (posedge clk0)

   assign phy_init_rden  = ctrl_read_en;

   always @ (posedge clk0)
   begin
     if (rst || init_memory_r)
        initalization_done_r <= 1'd0;
     else if((second_calib_done) && ((init_state_r == INIT_PRECHARGE_WAIT) && (count6 == cntnext)))
        initalization_done_r <= 1'd1;
   end

   always @ (posedge clk0)
   begin
      if (rst) begin
         init_state_r <= INIT_IDLE;
         init_state_r1 <= INIT_IDLE;
         init_state_r2 <= INIT_IDLE;
      end else begin
         init_state_r <= init_next_state;
         init_state_r1 <= init_state_r;
         init_state_r2 <= init_state_r1;
         end
   end

   // init state machine
   always @ (*)
   begin

       init_next_state = init_state_r;

      case (init_state_r)
         INIT_IDLE : begin
                        if (init_memory_r && done_200us_r == 1'b1) begin
                           case (init_count_r ) // synthesis parallel_case full_case
                              4'h0    : init_next_state = INIT_COUNT_200;
                              4'h1    : if (count_200cycle_done_r) init_next_state = INIT_PRECHARGE;
                              4'h2    : init_next_state = INIT_LOAD_MODE; //emr(2)
                              4'h3    : init_next_state = INIT_LOAD_MODE; //emr(3);
                              4'h4    : init_next_state = INIT_LOAD_MODE; //emr;
                              4'h5    : init_next_state = INIT_LOAD_MODE; //lmr;
                              4'h6    : init_next_state = INIT_PRECHARGE;
                              4'h7    : init_next_state = INIT_AUTO_REFRESH;
                              4'h8    : init_next_state = INIT_AUTO_REFRESH;
                              4'h9    : init_next_state = INIT_LOAD_MODE;
                              4'hA    : init_next_state = INIT_LOAD_MODE;
                              4'hB    : init_next_state = INIT_LOAD_MODE;

   // INIT_COUNT_200 state has been removed since it already waiting for 200 clock cycles

//MD put this for a LMR loop????  this is change 1
//removed
/*
                              4'hC    : begin
                                           if( (chip_cnt_r < `cs_width-1))
                                              init_next_state = INIT_IDLE;
                                           else  if (count_200cycle_done_r)
                                              init_next_state = INIT_IDLE; //  init_next_state = INIT_DUMMY_READ_CYCLES;
                                           else
                                              init_next_state = INIT_IDLE;
                                        end
*/
/*  MD changed to keep load mode register in a loop for debug
*/ //this is now back in and above is commented out
                              4'hC    : begin
                                           if( (chip_cnt_r < `cs_width-1))
                                              init_next_state = INIT_DEEP_MEMORY_ST;
                                           else  if (count_200cycle_done_r)
                                              init_next_state = INIT_DUMMY_ACTIVE; //  init_next_state = INIT_DUMMY_READ_CYCLES;
                                           else
                                              init_next_state = INIT_IDLE;
                                        end


                              4'hD    : if (second_calib_done) init_next_state = INIT_PRECHARGE;
                              4'hE    : begin
                                           if (second_calib_done)
                                              init_next_state = INIT_IDLE;
                                        end

/*                            4'hC    : init_next_state = INIT_COUNT_200;
                              4'hD    : begin
                                           if( (chip_cnt_r < `cs_width-1))
                                              init_next_state = INIT_DEEP_MEMORY_ST;
                                           else  if (count_200cycle_done_r)
                                              init_next_state = INIT_DUMMY_ACTIVE; //  init_next_state = INIT_DUMMY_READ_CYCLES;
                                           else
                                              init_next_state = INIT_IDLE;
                                        end
                              4'hE    : if (second_calib_done) init_next_state = INIT_PRECHARGE;
                              4'hF    : begin
                                           if (second_calib_done)
                                              init_next_state = INIT_IDLE;
                                        end
*/
                              default : init_next_state = INIT_IDLE;

                           endcase // case(init_count)

                        end
         end // case: IDLE
         INIT_DEEP_MEMORY_ST       : init_next_state = INIT_IDLE;
         INIT_COUNT_200            : init_next_state = INIT_COUNT_200_WAIT;
         INIT_COUNT_200_WAIT       : if (count_200cycle_done_r) init_next_state = INIT_IDLE;
         INIT_DUMMY_ACTIVE         : init_next_state = INIT_DUMMY_ACTIVE_WAIT;
         INIT_DUMMY_ACTIVE_WAIT    : if (count6 == cntnext) init_next_state = INIT_FIRST_WRITE;
         INIT_FIRST_READ_WAIT      : begin
                                        if((first_calib_done)) begin
                                           if(count6 == cntnext)
                                              init_next_state = INIT_PATTERN_WRITE ;
                                        end else
                                           init_next_state = INIT_FIRST_READ;
                                        end
          INIT_FIRST_WRITE          : init_next_state = INIT_FIRST_WRITE_READ;

         INIT_FIRST_WRITE_READ     : if (count6 == cntnext) init_next_state = INIT_FIRST_READ;
         INIT_FIRST_READ           : init_next_state = INIT_FIRST_READ_WAIT;
         INIT_PRECHARGE            : init_next_state = INIT_PRECHARGE_WAIT;
         INIT_PRECHARGE_WAIT       : if (count6 == cntnext) init_next_state = INIT_IDLE;
         INIT_LOAD_MODE            : init_next_state = INIT_MODE_REGISTER_WAIT;
         INIT_MODE_REGISTER_WAIT   : if (count6 == cntnext) init_next_state = INIT_IDLE;
         INIT_AUTO_REFRESH         : init_next_state = INIT_AUTO_REFRESH_WAIT;
         INIT_AUTO_REFRESH_WAIT    : if (count6 == cntnext) init_next_state = INIT_IDLE;
         INIT_ACTIVE               : init_next_state = INIT_ACTIVE_WAIT;
         INIT_ACTIVE_WAIT          : if (count6 == cntnext) init_next_state = INIT_IDLE;
         INIT_PATTERN_WRITE        : init_next_state = INIT_PATTERN_WRITE_READ;
         INIT_PATTERN_WRITE_READ   : if (count6 == cntnext) init_next_state = INIT_PATTERN_READ;
         INIT_PATTERN_READ         : init_next_state = INIT_PATTERN_READ_WAIT;
         INIT_PATTERN_READ_WAIT    : begin
                                        if((second_calib_done))begin
                                           if (count6 == cntnext)
                                              init_next_state = INIT_PRECHARGE;
                                        end else if (count6 == cntnext)
                                           init_next_state = INIT_PATTERN_READ;
                                        end

      endcase // case(state)
   end // always @ (...

   // commands to the memory
   always @ (posedge clk0)
   begin
      if (rst)
         ddr2_ras_r <= 1'b1;
      else if (init_state_r < INIT_FIRST_WRITE)
         ddr2_ras_r <= 1'b0;
    else ddr2_ras_r <= 1'b1;
   end

   // commands to the memory
   always @ (posedge clk0)
   begin
      if (rst)
         ddr2_cas_r <= 1'b1;
       else if ((init_state_r > INIT_PRECHARGE) && (init_state_r < INIT_COUNT_200))
         ddr2_cas_r <= 1'b0;
      else
         ddr2_cas_r <= 1'b1;
   end // always @ (posedge clk0)

   // commands to the memory
   always @ (posedge clk0)
   begin
      if (rst)
         ddr2_we_r <= 1'b1;
      else if (init_state_r == INIT_PATTERN_WRITE || init_state_r == INIT_FIRST_WRITE
                   || init_state_r == INIT_LOAD_MODE || init_state_r == INIT_PRECHARGE)
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

   // address during init
   always @ (posedge clk0)
   begin
      if (rst)
         ddr2_address_init_r <= `row_address'h0000;
      else begin
         if (init_state_r1 == INIT_PRECHARGE) begin
            ddr2_address_init_r <= `row_address'h0400;                       //A10 = 1 for precharge all
         end else if ( init_state_r1 == INIT_LOAD_MODE && init_count_r == 4'h5) begin
            ddr2_address_init_r <= ext_mode_reg;                             // A0 == 0 for DLL enable
         end else if ( init_state_r1 == INIT_LOAD_MODE && init_count_r == 4'h6) begin
            ddr2_address_init_r <= (`row_address'h0100 | load_mode_reg);     // A8 == 1 for DLL reset
         end else if (init_state_r1 == INIT_LOAD_MODE && init_count_r ==4'hA) begin
            ddr2_address_init_r <= load_mode_reg;                            // Write recovery = 4; cas_latency = 4; burst length = 4
         end else if (init_state_r1 == INIT_LOAD_MODE && init_count_r ==4'hB) begin
            ddr2_address_init_r <= (`row_address'h0380 | ext_mode_reg);      // OCD DEFAULT
         end else if (init_state_r1 == INIT_LOAD_MODE && init_count_r ==4'hC) begin
            ddr2_address_init_r <= (`row_address'h0000 | ext_mode_reg);      // OCD EXIT
         end else if(init_state_r1 == INIT_DUMMY_ACTIVE)
            ddr2_address_init_r <= `row_address'h0000;
         else
            ddr2_address_init_r <= `row_address'h0000;
      end
   end // always @ (posedge clk0)

   always @ (posedge clk0)
   begin
      if (rst) begin
         ddr2_ba_r[`bank_address-1:0] <= `bank_address'h0;
      end else if (init_memory_r == 1'b1 && init_state_r1 == INIT_LOAD_MODE ) begin
         if (init_count_r == 4'h3) begin
            ddr2_ba_r[`bank_address-1:0] <= `bank_address'h2; //emr2
         end else if (init_count_r == 4'h4) begin
            ddr2_ba_r[`bank_address-1:0] <= `bank_address'h3; //emr3
         end else if (init_count_r == 4'h5 || init_count_r == 4'hB || init_count_r == 4'hC) begin
            ddr2_ba_r[`bank_address-1:0] <= `bank_address'h1; //emr
         end else 
	    ddr2_ba_r[`bank_address-1:0] <= `bank_address'h0;
      end else if (init_state_r1 < INIT_AUTO_REFRESH) begin
            ddr2_ba_r[`bank_address-1:0] <= `bank_address'h0;
         end else
            ddr2_ba_r[`bank_address-1:0] <= ddr2_ba_r[`bank_address-1:0];
   end // always @ (posedge clk0)

   always @ (posedge clk0)
   begin
      if (rst) begin
         ddr2_cs_r1[`cs_width-1:0] <= `cs_width'hF;
      end else if (init_memory_r == 1'b1 ) begin
         if (chip_cnt_r == 2'h0) begin
            ddr2_cs_r1[`cs_width-1:0] <= `cs_width'hE;
         end else if (chip_cnt_r == 2'h1) begin
            ddr2_cs_r1[`cs_width-1:0] <= `cs_width'hD;
         end else if (chip_cnt_r == 2'h2) begin
            ddr2_cs_r1[`cs_width-1:0] <= `cs_width'hB;
         end else if (chip_cnt_r == 2'h3) begin
            ddr2_cs_r1[`cs_width-1:0] <= `cs_width'h7;
         end else
            ddr2_cs_r1[`cs_width-1:0] <= `cs_width'hF;
      end
   end // always @ (posedge clk0)

   always @ (posedge clk0)
   begin
      if (rst) begin
         ddr2_cke_r<= `cke_width'h0;
      end else begin
         if(done_200us_r == 1'b1)
            ddr2_cke_r<= `cke_width'hF;
      end
   end

   // odt

   always @ (posedge clk0)
   begin
      if (rst)
        odt_en_cnt_r <= 4'b0000;
      else if((((init_state_r == INIT_FIRST_WRITE) || (init_state_r == INIT_PATTERN_WRITE))&& ODT_ENABLE) && (odt_en_cnt_r < 2'd2))
        odt_en_cnt_r <= ((ADDITIVE_LATENCY_VALUE + CAS_LATENCY_VALUE )-2);
      else if((((init_state_r1 == INIT_FIRST_READ) || (init_state_r1 == INIT_PATTERN_READ))&& ODT_ENABLE)&& (odt_en_cnt_r < 2'd2))
        odt_en_cnt_r <= ((ADDITIVE_LATENCY_VALUE + CAS_LATENCY_VALUE )-1);
      else if(odt_en_cnt_r != 4'b0000)
        odt_en_cnt_r <= odt_en_cnt_r - 1'b1;
       else
        odt_en_cnt_r <= 4'b0000;
   end

   always @ (posedge clk0)
   begin
      if (rst)
        odt_cnt_r <= 4'b0000;
      else if(((init_state_r == INIT_FIRST_WRITE) || (init_state_r == INIT_PATTERN_WRITE)) )
        odt_cnt_r <= ((ADDITIVE_LATENCY_VALUE + CAS_LATENCY_VALUE + burst_cnt));
      else if(((init_state_r == INIT_FIRST_READ) || (init_state_r == INIT_PATTERN_READ)))
        odt_cnt_r <= ((ADDITIVE_LATENCY_VALUE + CAS_LATENCY_VALUE + burst_cnt+1));
      else if(odt_cnt_r != 4'b0000)
        odt_cnt_r <= odt_cnt_r - 1'b1;
      else
        odt_cnt_r <= 4'b0000;
   end

   always @ (posedge clk0)
   begin
      if (rst)
        odt_en  <= `cs_width'h0;
      else if((odt_en_cnt_r == 4'b0010))
        odt_en  <= `cs_width'hF;
      else if (odt_cnt_r == 4'b0011)
        odt_en <= `cs_width'h0;
   end

   assign phy_init_address[`row_address-1:0]  = ddr2_address_init_r[`row_address-1:0];
   assign phy_init_ba [`bank_address-1:0]     = ddr2_ba_r[`bank_address-1:0];
   assign phy_init_ras_n = ddr2_ras_r1;
   assign phy_init_cas_n = ddr2_cas_r1;
   assign phy_init_we_n  = ddr2_we_r1;
   assign phy_init_cs_n = 2'd0;
   assign phy_init_odt = odt_en;

   assign phy_init_cke  = ddr2_cke_r;

endmodule

