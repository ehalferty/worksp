///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  / Vendor: Xilinx
// \   \   \/ Version: 1.6
//  \   \ Application : MIG
//  /   / Filename: mem_param_0.v
// /___/   /\Date Last Modified:  Wed Jun 1 2005
// \   \  /  \Date Created: Mon May 2 2005
//  \___\/\___\
//Device: Virtex-5
//Design Name: DDR2_V5
//Description : According to the user inputs the parameters are defined here.
//              These parameters are used for the generic memory interface
//              code. Various parameters are address widths, data widths,
//              timing parameters according to the frequency selected by the
//              user and some internal parameters also.
///////////////////////////////////////////////////////////////////////////////

// counter values in the controller in tCK units
// write latency (WL) = Read Latency (RL) - 1 = AL + CL -1
// Read Latency (RL ) = AL + CL
`timescale 1ns/1ps
`define    data_width                               64 // 72
`define    data_strobe_width                        8 // 9
`define    data_mask_width                          8 // 9
`define    clk_width                                2 //1
`define    fifo16                                   4 //5
`define    ReadEnable                               3
`define    cs_width                                 1
`define    odt_width                                1
`define    cke_width                                1
`define    deep_memory                              1
`define    row_address                              14
`define    column_address                           10
`define    bank_address                             2
`define    memory_width                             8
`define    registered                               0 //1
`define    unbuffered                               0
`define    col_ap_width                             11
`define    DatabitsPerStrobe                        8
`define    DatabitsPerMask                          8
`define    no_of_CS                                 1
`define    RESET                                    1
`define    data_mask                                1
`define    col_range_start                          0
`define    col_range_end                            10
`define    row_range_start                          11
`define    row_range_end                            24
`define    bank_range_start                         25
`define    bank_range_end                           26
`define    cs_range_start                           27
`define    cs_range_end                             28
`define    ecc_enable                               0
`define    ecc_disable                              1
`define    ecc_width                                0
`define    dq_width                                 64 //72
`define    dm_width                                 8 //9
`define    tb_enable                                1
`define    tb_disable                               0
`define    dcm_enable                               1
`define    dcm_disable                              0
`define    low_frequency                            0
`define    high_frequency                           1
`define    foundation_ise                           1
`define   burst_length                                     3'b010
`define   burst_type                                       1'b0
`define   cas_latency_value                                3'b100 //3'b101 
`define   mode                                             1'b0
`define   dll_rst                                          1'b0
`define   write_recovery                                   3'b100 //3'b101 
`define   pd_mode                                          1'b0
//`define    load_mode_register       14'b00100001010010 CL = 5
`define    load_mode_register       14'b00100001000010
`define   output                                           1'b0
`define   dqs_n_ena                                        1'b0
`define   ocd_operation                                    3'b000
`define   odt_enable                                       2'b00
`define   additive_latency_value                           3'b000
`define   dll_ena                                          1'b0
`define   op_drive_strength                                1'b0
`define    ext_load_mode_register   14'b00000000000100
`define    chip_address                     1
`define    data_window                     15
`define    rcd_count_value                 3'b100
`define    ras_count_value                 4'b1100 //4'b1101
`define    mrd_count_value                 1'b1
`define    rp_count_value                  3'b100
`define    rfc_count_value                 6'b011111 //6'b100010
`define    trtp_count_value                3'b010
`define    twr_count_value                 3'b101
`define    twtr_count_value                3'b011
`define     max_ref_width                   12
`define    max_ref_cnt                  12'b101000001000
