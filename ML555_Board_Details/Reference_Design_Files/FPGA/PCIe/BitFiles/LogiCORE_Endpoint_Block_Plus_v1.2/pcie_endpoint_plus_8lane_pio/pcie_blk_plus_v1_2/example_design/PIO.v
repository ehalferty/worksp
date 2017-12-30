
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
//-- Filename: PIO.v
//--
//-- Description: Programmed I/O module. Design implements 8 KBytes of programmable
//--              memory space. Host processor can access this memory space using
//--              Memory Read 32 and Memory Write 32 TLPs. Design accepts 
//--              1 Double Word (DW) payload length on Memory Write 32 TLP and
//--              responds to 1 DW length Memory Read 32 TLPs with a Completion
//--              with Data TLP (1DW payload).
//--              
//--              Module is designed to operate with 32 bit and 64 bit interfaces.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module PIO (

                  trn_clk,
                  trn_reset_n,
                  trn_lnk_up_n,

                  trn_td,
`ifdef PIO_64
                  trn_trem_n,
`endif // PIO_64
                  trn_tsof_n,
                  trn_teof_n,
                  trn_tsrc_rdy_n,
                  trn_tsrc_dsc_n,
                  trn_tdst_rdy_n,
                  trn_tdst_dsc_n,

                  trn_rd,
`ifdef PIO_64
                  trn_rrem_n,
`endif // PIO_64
                  trn_rsof_n,
                  trn_reof_n,
                  trn_rsrc_rdy_n,
                  trn_rsrc_dsc_n,
                  trn_rbar_hit_n,
                  trn_rdst_rdy_n,


                  cfg_to_turnoff_n,
                  cfg_turnoff_ok_n,

                  cfg_completer_id,
                  cfg_bus_mstr_enable

                  ); // synthesis syn_hier = "hard"

    ///////////////////////////////////////////////////////////////////////////////
    // Port Declarations
    ///////////////////////////////////////////////////////////////////////////////

    input         trn_clk;         
    input         trn_reset_n;
    input         trn_lnk_up_n;

`ifdef PIO_64
    output [63:0] trn_td;
    output [7:0]  trn_trem_n;
`else // PIO_64
    output [31:0] trn_td;
`endif // PIO_64
    output        trn_tsof_n;
    output        trn_teof_n;
    output        trn_tsrc_rdy_n;
    output        trn_tsrc_dsc_n;
    input         trn_tdst_rdy_n;
    input         trn_tdst_dsc_n;

`ifdef PIO_64
    input [63:0]  trn_rd;
    input [7:0]   trn_rrem_n;
`else // PIO_64
    input [31:0]  trn_rd;
`endif // PIO_64
    input         trn_rsof_n;
    input         trn_reof_n;
    input         trn_rsrc_rdy_n;
    input         trn_rsrc_dsc_n;
    input [6:0]   trn_rbar_hit_n;
    output        trn_rdst_rdy_n;


    input         cfg_to_turnoff_n;
    output        cfg_turnoff_ok_n;

    input [15:0]  cfg_completer_id;
    input         cfg_bus_mstr_enable;

    // Local wires

    wire          req_compl;
    wire          compl_done;
    wire          pio_reset_n = trn_reset_n & ~trn_lnk_up_n;

    //
    // PIO instance
    // 

    PIO_EP PIO_EP (

                        .clk  ( trn_clk ),                           // I
                        .rst_n ( pio_reset_n ),                      // I

                        .trn_td ( trn_td ),                          // O [63/31:0]
`ifdef PIO_64
                        .trn_trem_n ( trn_trem_n ),                  // O [7:0]
`endif // PIO_64
                        .trn_tsof_n ( trn_tsof_n ),                  // O
                        .trn_teof_n ( trn_teof_n ),                  // O
                        .trn_tsrc_rdy_n ( trn_tsrc_rdy_n ),          // O
                        .trn_tsrc_dsc_n ( trn_tsrc_dsc_n ),          // O
                        .trn_tdst_rdy_n ( trn_tdst_rdy_n ),          // I
                        .trn_tdst_dsc_n ( trn_tdst_dsc_n ),          // I

                        .trn_rd ( trn_rd ),                          // I [63/31:0]
`ifdef PIO_64
                        .trn_rrem_n ( trn_rrem_n ),                  // I
`endif // PIO_64
                        .trn_rsof_n ( trn_rsof_n ),                  // I
                        .trn_reof_n ( trn_reof_n ),                  // I
                        .trn_rsrc_rdy_n ( trn_rsrc_rdy_n ),          // I                        
                        .trn_rsrc_dsc_n ( trn_rsrc_dsc_n ),          // I
                        .trn_rbar_hit_n ( trn_rbar_hit_n ),          // I [6:0]                                                                                              
                        .trn_rdst_rdy_n ( trn_rdst_rdy_n ),          // O

                        .req_compl_o(req_compl),                     // O
                        .compl_done_o(compl_done),                   // O

                        .cfg_completer_id ( cfg_completer_id ),      // I [15:0]
                        .cfg_bus_mstr_enable ( cfg_bus_mstr_enable ) // I

                       );


    // 
    // Turn-Off controller
    //

    PIO_TO_CTRL PIO_TO  (

                        .clk( trn_clk ),                             // I
                        .rst_n( trn_reset_n ),                       // I

                        .req_compl_i( req_compl ),                   // I
                        .compl_done_i( compl_done ),                 // I

                        .cfg_to_turnoff_n( cfg_to_turnoff_n ),       // I
                        .cfg_turnoff_ok_n( cfg_turnoff_ok_n )        // O
     
                       );

   
endmodule // PIO
