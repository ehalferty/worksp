//--------------------------------------------------------------------------------
//--
//-- This file is owned and controlled by Xilinx and must be used solely
//-- for design, simulation, implementation and creation of design files
//-- limited to Xilinx devices or technologies. Use with non-Xilinx
//-- devices or technologies is expressly prohibited and immediately
//-- terminates your license.
//--
//-- Xilinx products are not intended for use in life support
//-- appliances, devices, or systems. Use in such applications is
//-- expressly prohibited.
//--
//--            **************************************
//--            ** Copyright (C) 2005, Xilinx, Inc. **
//--            ** All Rights Reserved.             **
//--            **************************************
//--
//--------------------------------------------------------------------------------
//-- Filename: PIO_EP_MEM_ACCESS.v
//--
//-- Description: Endpoint Memory Access Unit. This module provides access functions
//--              to the Endpoint memory aperture.
//--
//--              Read Access: Module returns data for the specifed address and
//--              byte enables selected. 
//-- 
//--              Write Access: Module accepts data, byte enables and updates
//--              data when write enable is asserted. Modules signals write busy 
//--              when data write is in progress. 
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`define TCQ 1

`define PIO_MEM_ACCESS_WR_RST     3'b000
`define PIO_MEM_ACCESS_WR_WAIT    3'b001
`define PIO_MEM_ACCESS_WR_READ    3'b010
`define PIO_MEM_ACCESS_WR_WRITE   3'b100



module PIO_EP_MEM_ACCESS (

                     clk,
                     rst_n,

                     // Read Access

                     rd_addr_i,     // I [10:0]
                     rd_be_i,       // I [3:0]
                     rd_data_o,     // O [31:0]
                     rd_data0_en,   // I
                     rd_data1_en,   // I
                     rd_data2_en,   // I
                     rd_data3_en,   // I

                     // Write Access

                     wr_addr_i,     // I [10:0]
                     wr_be_i,       // I [7:0]
                     wr_data_i,     // I [31:0]
                     wr_en_i,       // I
                     wr_busy_o      // O

                     );

    input            clk;
    input            rst_n;

    /*
     *  Read Port
     */

    input  [10:0]    rd_addr_i;
    input  [3:0]     rd_be_i;
    output [31:0]    rd_data_o;
    input            rd_data0_en;
    input            rd_data1_en;
    input            rd_data2_en;
    input            rd_data3_en;

    /*
     *  Write Port
     */

    input  [10:0]    wr_addr_i;
    input  [7:0]     wr_be_i;
    input  [31:0]    wr_data_i;
    input            wr_en_i;
    output           wr_busy_o;

    wire   [31:0]     rd_data_o;

    reg   [31:0]      rd_data_raw_o;

    wire  [31:0]     rd_data0_o, rd_data1_o, rd_data2_o, rd_data3_o;

    wire             wr_busy_o;
    reg              write_en;
    reg   [31:0]     post_wr_data;
    reg   [31:0]     w_pre_wr_data;

    reg   [2:0]      wr_mem_state;

    reg   [31:0]     pre_wr_data;
    wire  [31:0]     w_pre_wr_data0;
    wire  [31:0]     w_pre_wr_data1;
    wire  [31:0]     w_pre_wr_data2;
    wire  [31:0]     w_pre_wr_data3;

    reg   [31:0]     pre_wr_data0_q, pre_wr_data1_q, pre_wr_data2_q, pre_wr_data3_q;

    reg   [31:0]     DW0, DW1, DW2;

    /**
     ** Memory Write Process
     **/

    /*
     *  Extract current data bytes. These need to be swizzled
     *  BRAM storage format :
     *    data[31:0] = { byte[3], byte[2], byte[1], byte[0] (lowest addr) }
     */

    wire  [7:0]      w_pre_wr_data_b3 = pre_wr_data[31:24];
    wire  [7:0]      w_pre_wr_data_b2 = pre_wr_data[23:16];
    wire  [7:0]      w_pre_wr_data_b1 = pre_wr_data[15:08];
    wire  [7:0]      w_pre_wr_data_b0 = pre_wr_data[07:00];

    /*
     *  Extract new data bytes from payload
     *  TLP Payload format :
     *    data[31:0] = { byte[0] (lowest addr), byte[2], byte[1], byte[3] }  
     */

    wire  [7:0]      w_wr_data_b3 = wr_data_i[07:00];
    wire  [7:0]      w_wr_data_b2 = wr_data_i[15:08];
    wire  [7:0]      w_wr_data_b1 = wr_data_i[23:16];
    wire  [7:0]      w_wr_data_b0 = wr_data_i[31:24];


    always @(posedge clk or negedge rst_n) begin

        if ( !rst_n ) begin

          pre_wr_data <= 32'b0;
          post_wr_data <= 32'b0;
          pre_wr_data <= 32'b0;
          write_en   <= 1'b0;
          pre_wr_data0_q <= 32'b0;
          pre_wr_data1_q <= 32'b0;
          pre_wr_data2_q <= 32'b0;
          pre_wr_data3_q <= 32'b0;

          wr_mem_state <= `PIO_MEM_ACCESS_WR_RST;

        end else begin

          case ( wr_mem_state )

            `PIO_MEM_ACCESS_WR_RST : begin

              if (wr_en_i) begin // read state

                wr_mem_state <= `PIO_MEM_ACCESS_WR_WAIT; //Pipelining happens in RAM's internal output reg.

              end else begin

                write_en <= 1'b0;

                wr_mem_state <= `PIO_MEM_ACCESS_WR_RST;

              end

            end

            `PIO_MEM_ACCESS_WR_WAIT : begin

              /*
               * Pipeline B port data before processing. Virtex 5 Block RAMs have internal
                 output register enabled.
               */

              //pre_wr_data0_q <= w_pre_wr_data0;
             // pre_wr_data1_q <= w_pre_wr_data1;
             // pre_wr_data2_q <= w_pre_wr_data2;
             // pre_wr_data3_q <= w_pre_wr_data3;

              write_en <= 1'b0;

              wr_mem_state <= `PIO_MEM_ACCESS_WR_READ ;

            end

            `PIO_MEM_ACCESS_WR_READ : begin

                /*
                 * Now save the selected BRAM B port data out
                 */

                pre_wr_data <= w_pre_wr_data; 
                write_en <= 1'b0;

                wr_mem_state <= `PIO_MEM_ACCESS_WR_WRITE;

            end

            `PIO_MEM_ACCESS_WR_WRITE : begin

              /*
               * Merge new enabled data and write target BlockRAM location
               */

              post_wr_data <= {{wr_be_i[3] ? w_wr_data_b3 : w_pre_wr_data_b3},
                               {wr_be_i[2] ? w_wr_data_b2 : w_pre_wr_data_b2},
                               {wr_be_i[1] ? w_wr_data_b1 : w_pre_wr_data_b1},
                               {wr_be_i[0] ? w_wr_data_b0 : w_pre_wr_data_b0}};
              write_en     <= 1'b1;

              wr_mem_state <= `PIO_MEM_ACCESS_WR_RST;

            end

          endcase

        end

    end

    /*
     * Write controller busy 
     */

    assign wr_busy_o = wr_en_i | (wr_mem_state != `PIO_MEM_ACCESS_WR_RST);

    /*
     *  Select BlockRAM output based on higher 2 address bits
     */

    always @* // (wr_addr_i or pre_wr_data0_q or pre_wr_data1_q or pre_wr_data2_q or pre_wr_data3_q) begin
     begin
      case ({wr_addr_i[10:9]}) /* synthesis full_case */ /* synthesis parallel_case */

        2'b00 : w_pre_wr_data = w_pre_wr_data0;
        2'b01 : w_pre_wr_data = w_pre_wr_data1;  
        2'b10 : w_pre_wr_data = w_pre_wr_data2;
        2'b11 : w_pre_wr_data = w_pre_wr_data3; 

      endcase

    end

    /*
     *  Memory Read Controller
     */


    always @(rd_addr_i or rd_data0_o or rd_data1_o or rd_data2_o or rd_data3_o) 
      begin

      case ({rd_addr_i[10:9]}) /* synthesis full_case */ /* synthesis parallel_case */

        2'b00 : rd_data_raw_o = rd_data0_o;
        2'b01 : rd_data_raw_o = rd_data1_o;  
        2'b10 : rd_data_raw_o = rd_data2_o;
        2'b11 : rd_data_raw_o = rd_data3_o;  

      endcase

    end

   /* Handle Read byte enables */

    assign rd_data_o = {{rd_be_i[0] ? rd_data_raw_o[07:00] : 8'h0},
                        {rd_be_i[1] ? rd_data_raw_o[15:08] : 8'h0},
                        {rd_be_i[2] ? rd_data_raw_o[23:16] : 8'h0}, 
                        {rd_be_i[3] ? rd_data_raw_o[31:24] : 8'h0}};

    EP_MEM EP_MEM    (

                      .clk_i(clk),

                      .a_rd_a_i_0(rd_addr_i[8:0]),              // I [8:0]
                      .a_rd_en_i_0(rd_data0_en),                // I [1:0]
                      .a_rd_d_o_0(rd_data0_o),                  // O [31:0]

                      .b_wr_a_i_0(wr_addr_i[8:0]),              // I [8:0]
                      .b_wr_d_i_0(post_wr_data),                // I [31:0]
                      .b_wr_en_i_0({write_en & (wr_addr_i[10:9] == 2'b00)}), // I
                      .b_rd_d_o_0(w_pre_wr_data0[31:0]),        // O [31:0]
                      .b_rd_en_i_0({wr_addr_i[10:9] == 2'b00}), // I
                  
                      .a_rd_a_i_1(rd_addr_i[8:0]),              // I [8:0]
                      .a_rd_en_i_1(rd_data1_en),                // I [1:0]
                      .a_rd_d_o_1(rd_data1_o),                  // O [31:0]
    
                      .b_wr_a_i_1(wr_addr_i[8:0]),              // [8:0]
                      .b_wr_d_i_1(post_wr_data),                // [31:0]
                      .b_wr_en_i_1({write_en & (wr_addr_i[10:9] == 2'b01)}), // I
                      .b_rd_d_o_1(w_pre_wr_data1[31:0]),        // [31:0]
                      .b_rd_en_i_1({wr_addr_i[10:9] == 2'b01}), // I

                      .a_rd_a_i_2(rd_addr_i[8:0]),              // I [8:0]
                      .a_rd_en_i_2(rd_data2_en),                // I [1:0]
                      .a_rd_d_o_2(rd_data2_o),                  // O [31:0]
    
                      .b_wr_a_i_2(wr_addr_i[8:0]),              // I [8:0]
                      .b_wr_d_i_2(post_wr_data),                // I [31:0]
                      .b_wr_en_i_2({write_en & (wr_addr_i[10:9] == 2'b10)}), // I
                      .b_rd_d_o_2(w_pre_wr_data2[31:0]),        // I [31:0]
                      .b_rd_en_i_2({wr_addr_i[10:9] == 2'b10}), // I

                      .a_rd_a_i_3(rd_addr_i[8:0]),              // [8:0]
                      .a_rd_en_i_3(rd_data3_en),                // [1:0]
                      .a_rd_d_o_3(rd_data3_o),                  // O [31:0]
    
                      .b_wr_a_i_3(wr_addr_i[8:0]),              // I [8:0]
                      .b_wr_d_i_3(post_wr_data),                // I [31:0]
                      .b_wr_en_i_3({write_en & (wr_addr_i[10:9] == 2'b11)}), // I
                      .b_rd_d_o_3(w_pre_wr_data3[31:0]),        // I [31:0]
                      .b_rd_en_i_3({wr_addr_i[10:9] == 2'b11})  // I

                     );
                     

                     

                     
  // synthesis translate_off
  reg  [8*20:1] state_ascii;
  always @(wr_mem_state)
  begin
    if      (wr_mem_state==`PIO_MEM_ACCESS_WR_RST)    state_ascii <= #`TCQ "PIO_MEM_WR_RST";
    else if (wr_mem_state==`PIO_MEM_ACCESS_WR_WAIT)   state_ascii <= #`TCQ "PIO_MEM_WR_WAIT";
    else if (wr_mem_state==`PIO_MEM_ACCESS_WR_READ)   state_ascii <= #`TCQ "PIO_MEM_WR_READ";
    else if (wr_mem_state==`PIO_MEM_ACCESS_WR_WRITE)  state_ascii <= #`TCQ "PIO_MEM_WR_WRITE";
    else                                              state_ascii <= #`TCQ "PIO MEM STATE ERR";

  end
  // synthesis translate_on

  
endmodule
