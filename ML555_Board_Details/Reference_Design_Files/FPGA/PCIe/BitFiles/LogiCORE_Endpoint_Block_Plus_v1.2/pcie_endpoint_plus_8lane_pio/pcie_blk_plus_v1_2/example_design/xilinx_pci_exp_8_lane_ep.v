//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------
//-- Filename: XILINX_PCI_EXP_EP.v
//--
//-- Description:  PCI Express Endpoint Core example design top level wrapper.
//--               
//--
//------------------------------------------------------------------------------


module     `XILINX_PCI_EXP_EP (

                        // PCI Express Fabric Interface

                        pci_exp_txp,
                        pci_exp_txn,
                        pci_exp_rxp,
                        pci_exp_rxn,

                        // System (SYS) Interface

                        sys_clk_p,
                        sys_clk_n,
                        sys_reset_n,
                        
                        //ML555 LEDs
                        
                        LED_link_up_n, //On if Link is Up
                        LED_4_lane_n,  //On if Link is x4
                        LED_8_lane_n   //On if Link is x8
                        
                        );//synthesis syn_noclockbuf=1

    //-------------------------------------------------------
    // 1. PCI Express Fabric Interface
    //-------------------------------------------------------

    // Tx
    output    [(`PCI_EXP_LINK_WIDTH - 1):0]           pci_exp_txp;
    output    [(`PCI_EXP_LINK_WIDTH - 1):0]           pci_exp_txn;

    // Rx
    input     [(`PCI_EXP_LINK_WIDTH - 1):0]           pci_exp_rxp;
    input     [(`PCI_EXP_LINK_WIDTH - 1):0]           pci_exp_rxn;


    //-------------------------------------------------------
    // 4. System (SYS) Interface
    //-------------------------------------------------------

    input                                             sys_clk_p;
    input                                             sys_clk_n;
    input  
                                               sys_reset_n;
    //-------------------------------------------------------
    // LEDs
    //-------------------------------------------------------
    
    output LED_link_up_n;
    output LED_4_lane_n;
    output LED_8_lane_n;


    //-------------------------------------------------------
    // Local Wires
    //-------------------------------------------------------

    wire                                              sys_clk_c;
    wire                                              sys_reset_n_c;
    wire                                              trn_clk_c;//synthesis attribute max_fanout of trn_clk_c is "100000"
    wire                                              trn_reset_n_c;
    wire                                              trn_lnk_up_n_c;
    wire                                              cfg_trn_pending_n_c;
    wire [(`PCI_EXP_CFG_DSN_WIDTH - 1):0]             cfg_dsn_n_c;
    wire                                              trn_tsof_n_c;
    wire                                              trn_teof_n_c;
    wire                                              trn_tsrc_rdy_n_c;
    wire                                              trn_tdst_rdy_n_c;
    wire                                              trn_tsrc_dsc_n_c;
    wire                                              trn_terrfwd_n_c;
    wire                                              trn_tdst_dsc_n_c;
    wire    [(`PCI_EXP_TRN_DATA_WIDTH - 1):0]         trn_td_c;
    wire    [(`PCI_EXP_TRN_REM_WIDTH - 1):0]          trn_trem_n_c;

    wire    [(`PCI_EXP_TRN_BUF_AV_WIDTH - 1):0]       trn_tbuf_av_c;

    wire                                              trn_rsof_n_c;
    wire                                              trn_reof_n_c;
    wire                                              trn_rsrc_rdy_n_c;
    wire                                              trn_rsrc_dsc_n_c;
    wire                                              trn_rdst_rdy_n_c;
    wire                                              trn_rerrfwd_n_c;
    wire                                              trn_rnp_ok_n_c;
    wire    [(`PCI_EXP_TRN_DATA_WIDTH - 1):0]         trn_rd_c;
    wire    [(`PCI_EXP_TRN_REM_WIDTH - 1):0]          trn_rrem_n_c;

    wire    [(`PCI_EXP_TRN_BAR_HIT_WIDTH - 1):0]      trn_rbar_hit_n_c;
    wire    [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]       trn_rfc_nph_av_c;
    wire    [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]      trn_rfc_npd_av_c;
    wire    [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]       trn_rfc_ph_av_c;
    wire    [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]      trn_rfc_pd_av_c;
    wire    [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]       trn_rfc_cplh_av_c;
    wire    [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]      trn_rfc_cpld_av_c;
    wire                                              trn_rcpl_streaming_n_c;

    wire    [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]         cfg_do_c;
    wire    [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]         cfg_di_c;
    wire    [(`PCI_EXP_CFG_ADDR_WIDTH - 1):0]         cfg_dwaddr_c;
    wire    [(`PCI_EXP_CFG_DATA_WIDTH/8 - 1):0]       cfg_byte_en_n_c;
    wire    [(`PCI_EXP_CFG_CPLHDR_WIDTH - 1):0]       cfg_err_tlp_cpl_header_c;
    wire                                              cfg_wr_en_n_c;
    wire                                              cfg_rd_en_n_c;
    wire                                              cfg_rd_wr_done_n_c;
    wire                                              cfg_err_cor_n_c;
    wire                                              cfg_err_ur_n_c;
    wire                                              cfg_err_ecrc_n_c;
    wire                                              cfg_err_cpl_timeout_n_c;
    wire                                              cfg_err_cpl_abort_n_c;
    wire                                              cfg_err_cpl_unexpect_n_c;
    wire                                              cfg_err_posted_n_c;    
    wire                                              cfg_interrupt_n_c;
    wire                                              cfg_interrupt_rdy_n_c;
    wire                                              cfg_turnoff_ok_n_c;
    wire                                              cfg_to_turnoff_n;
    wire                                              cfg_pm_wake_n_c;
    wire    [(`PCI_EXP_LNK_STATE_WIDTH - 1):0]        cfg_pcie_link_state_n_c;
    wire    [(`PCI_EXP_CFG_BUSNUM_WIDTH - 1):0]       cfg_bus_number_c;
    wire    [(`PCI_EXP_CFG_DEVNUM_WIDTH - 1):0]       cfg_device_number_c;
    wire    [(`PCI_EXP_CFG_FUNNUM_WIDTH - 1):0]       cfg_function_number_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_status_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_command_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_dstatus_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_dcommand_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_lstatus_c;
    wire    [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]          cfg_lcommand_c;

  //-------------------------------------------------------
  // System Reset Input Pad Instance
  //-------------------------------------------------------

  IBUFDS refclk_ibuf (.O(sys_clk_c), .I(sys_clk_p), .IB(sys_clk_n));  // 100 MHz
  IBUF sys_reset_n_ibuf (.O(sys_reset_n_c), .I(sys_reset_n));

  //-------------------------------------------------------
  // LED Logic
  //-------------------------------------------------------

    wire LED_link_up_n_c;
    wire LED_4_lane_n_c;
    wire LED_8_lane_n_c;
                      
    assign LED_link_up_n_c =  trn_lnk_up_n_c ;     //on if link is up                
    assign LED_4_lane_n_c  = !cfg_lstatus_c[6] ;   //on if x4
    assign LED_8_lane_n_c  = !cfg_lstatus_c[7] ;   //on if x8
    
    OBUF LED_LINK_UP (.O(LED_link_up_n), .I(LED_link_up_n_c)); 
    OBUF LED_4_LANE  (.O(LED_4_lane_n), .I(LED_4_lane_n_c));
    OBUF LED_8_LANE  (.O(LED_8_lane_n), .I(LED_8_lane_n_c));
    
  //-------------------------------------------------------
  // Endpoint Implementation Application
  //-------------------------------------------------------

  `PCI_EXP_APP app (    

      //
      // Transaction ( TRN ) Interface
      //

      .trn_clk( trn_clk_c ),                   // I
      .trn_reset_n( trn_reset_n_c ),           // I
      .trn_lnk_up_n( trn_lnk_up_n_c ),         // I

      // Tx Local-Link

      .trn_td( trn_td_c ),                     // O [63/31:0]
      .trn_trem( trn_trem_n_c ),               // O [7:0]
      .trn_tsof_n( trn_tsof_n_c ),             // O
      .trn_teof_n( trn_teof_n_c ),             // O
      .trn_tsrc_rdy_n( trn_tsrc_rdy_n_c ),     // O
      .trn_tsrc_dsc_n( trn_tsrc_dsc_n_c ),     // O
      .trn_tdst_rdy_n( trn_tdst_rdy_n_c ),     // I
      .trn_tdst_dsc_n( trn_tdst_dsc_n_c ),     // I
      .trn_terrfwd_n( trn_terrfwd_n_c ),       // O
      .trn_tbuf_av( trn_tbuf_av_c ),           // I [4/3:0]

      // Rx Local-Link

      .trn_rd( trn_rd_c ),                     // I [63/31:0]
      .trn_rrem( trn_rrem_n_c ),               // I [7:0]
      .trn_rsof_n( trn_rsof_n_c ),             // I
      .trn_reof_n( trn_reof_n_c ),             // I
      .trn_rsrc_rdy_n( trn_rsrc_rdy_n_c ),     // I
      .trn_rsrc_dsc_n( trn_rsrc_dsc_n_c ),     // I
      .trn_rdst_rdy_n( trn_rdst_rdy_n_c ),     // O
      .trn_rerrfwd_n( trn_rerrfwd_n_c ),       // I
      .trn_rnp_ok_n( trn_rnp_ok_n_c ),         // O
      .trn_rbar_hit_n( trn_rbar_hit_n_c ),     // I [6:0]
      .trn_rfc_npd_av( trn_rfc_npd_av_c ),     // I [11:0]
      .trn_rfc_nph_av( trn_rfc_nph_av_c ),     // I [7:0]
      .trn_rfc_pd_av( trn_rfc_pd_av_c ),       // I [11:0]
      .trn_rfc_ph_av( trn_rfc_ph_av_c ),       // I [7:0]
      .trn_rfc_cpld_av( trn_rfc_cpld_av_c ),   // I [11:0]
      .trn_rfc_cplh_av( trn_rfc_cplh_av_c ),   // I [7:0]
      .trn_rcpl_streaming_n( trn_rcpl_streaming_n_c ),  // O

      //
      // Host ( CFG ) Interface
      //

      .cfg_do( cfg_do_c ),                                   // I [31:0]
      .cfg_rd_wr_done_n( cfg_rd_wr_done_n_c ),               // I
      .cfg_di( cfg_di_c ),                                   // O [31:0]
      .cfg_byte_en_n( cfg_byte_en_n_c ),                     // O
      .cfg_dwaddr( cfg_dwaddr_c ),                           // O
      .cfg_wr_en_n( cfg_wr_en_n_c ),                         // O
      .cfg_rd_en_n( cfg_rd_en_n_c ),                         // O
      .cfg_err_cor_n( cfg_err_cor_n_c ),                     // O
      .cfg_err_ur_n( cfg_err_ur_n_c ),                       // O
      .cfg_err_ecrc_n( cfg_err_ecrc_n_c ),                   // O
      .cfg_err_cpl_timeout_n( cfg_err_cpl_timeout_n_c ),     // O
      .cfg_err_cpl_abort_n( cfg_err_cpl_abort_n_c ),         // O
      .cfg_err_cpl_unexpect_n( cfg_err_cpl_unexpect_n_c ),   // O
      .cfg_err_posted_n( cfg_err_posted_n_c ),               // O
      .cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header_c ),   // O [47:0]
      .cfg_interrupt_n( cfg_interrupt_n_c ),                 // O
      .cfg_interrupt_rdy_n( cfg_interrupt_rdy_n_c ),         // I
      .cfg_turnoff_ok_n( cfg_turnoff_ok_n_c ),               // O
      .cfg_to_turnoff_n( cfg_to_turnoff_n_c ),               // I
      .cfg_pm_wake_n( cfg_pm_wake_n_c ),                     // O
      .cfg_pcie_link_state_n( cfg_pcie_link_state_n_c ),     // I [2:0]
      .cfg_trn_pending_n( cfg_trn_pending_n_c ),             // O
      .cfg_dsn( cfg_dsn_n_c),                                // O [63:0]

      .cfg_bus_number( cfg_bus_number_c ),                   // I [7:0]
      .cfg_device_number( cfg_device_number_c ),             // I [4:0]
      .cfg_function_number( cfg_function_number_c ),         // I [2:0]
      .cfg_status( cfg_status_c ),                           // I [15:0]
      .cfg_command( cfg_command_c ),                         // I [15:0]
      .cfg_dstatus( cfg_dstatus_c ),                         // I [15:0]
      .cfg_dcommand( cfg_dcommand_c ),                       // I [15:0]
      .cfg_lstatus( cfg_lstatus_c ),                         // I [15:0]
      .cfg_lcommand( cfg_lcommand_c )                        // I [15:0]

      );

  //-------------------------------------------------------
  // PCI Express Core Instance
  //-------------------------------------------------------

  `PCI_EXP_EP    `PCI_EXP_EP_INST  (

      //
      // PCI Express Fabric Interface
      //

      .pci_exp_txp( pci_exp_txp ),             // O [7/3/0:0]
      .pci_exp_txn( pci_exp_txn ),             // O [7/3/0:0]
      .pci_exp_rxp( pci_exp_rxp ),             // O [7/3/0:0]
      .pci_exp_rxn( pci_exp_rxn ),             // O [7/3/0:0]

      //
      // Transaction ( TRN ) Interface
      //

      .trn_clk( trn_clk_c ),                   // O
      .trn_reset_n( trn_reset_n_c ),           // O
      .trn_lnk_up_n( trn_lnk_up_n_c ),         // O

      // Tx Local-Link

      .trn_td( trn_td_c ),                     // I [63/31:0]
      .trn_trem_n( trn_trem_n_c ),             // I [7:0]
      .trn_tsof_n( trn_tsof_n_c ),             // I
      .trn_teof_n( trn_teof_n_c ),             // I
      .trn_tsrc_rdy_n( trn_tsrc_rdy_n_c ),     // I
      .trn_tsrc_dsc_n( trn_tsrc_dsc_n_c ),     // I
      .trn_tdst_rdy_n( trn_tdst_rdy_n_c ),     // O
      .trn_tdst_dsc_n( trn_tdst_dsc_n_c ),     // O
      .trn_terrfwd_n( trn_terrfwd_n_c ),       // I
      .trn_tbuf_av( trn_tbuf_av_c ),           // O [4/3:0]

      // Rx Local-Link

      .trn_rd( trn_rd_c ),                     // O [63/31:0]
      .trn_rrem_n( trn_rrem_n_c ),             // O [7:0]
      .trn_rsof_n( trn_rsof_n_c ),             // O
      .trn_reof_n( trn_reof_n_c ),             // O
      .trn_rsrc_rdy_n( trn_rsrc_rdy_n_c ),     // O
      .trn_rsrc_dsc_n( trn_rsrc_dsc_n_c ),     // O
      .trn_rdst_rdy_n( trn_rdst_rdy_n_c ),     // I
      .trn_rerrfwd_n( trn_rerrfwd_n_c ),       // O
      .trn_rnp_ok_n( trn_rnp_ok_n_c ),         // I
      .trn_rbar_hit_n( trn_rbar_hit_n_c ),     // O [6:0]
      .trn_rfc_nph_av( trn_rfc_nph_av_c ),     // O [11:0]
      .trn_rfc_npd_av( trn_rfc_npd_av_c ),     // O [7:0]
      .trn_rfc_ph_av( trn_rfc_ph_av_c ),       // O [11:0]
      .trn_rfc_pd_av( trn_rfc_pd_av_c ),       // O [7:0]
      .trn_rcpl_streaming_n( trn_rcpl_streaming_n_c ),       // I

      //
      // Host ( CFG ) Interface
      //

      .cfg_do( cfg_do_c ),                                    // O [31:0]
      .cfg_rd_wr_done_n( cfg_rd_wr_done_n_c ),                // O
      .cfg_di( cfg_di_c ),                                    // I [31:0]
      .cfg_byte_en_n( cfg_byte_en_n_c ),                      // I [3:0]
      .cfg_dwaddr( cfg_dwaddr_c ),                            // I [9:0]
      .cfg_wr_en_n( cfg_wr_en_n_c ),                          // I
      .cfg_rd_en_n( cfg_rd_en_n_c ),                          // I

      .cfg_err_cor_n( cfg_err_cor_n_c ),                      // I
      .cfg_err_ur_n( cfg_err_ur_n_c ),                        // I
      .cfg_err_ecrc_n( cfg_err_ecrc_n_c ),                    // I
      .cfg_err_cpl_timeout_n( cfg_err_cpl_timeout_n_c ),      // I
      .cfg_err_cpl_abort_n( cfg_err_cpl_abort_n_c ),          // I
      .cfg_err_cpl_unexpect_n( cfg_err_cpl_unexpect_n_c ),    // I
      .cfg_err_posted_n( cfg_err_posted_n_c ),                // I
      .cfg_err_tlp_cpl_header( cfg_err_tlp_cpl_header_c ),    // I [47:0]
      .cfg_interrupt_n( cfg_interrupt_n_c ),                  // I
      .cfg_interrupt_rdy_n( cfg_interrupt_rdy_n_c ),          // O
      .cfg_pm_wake_n( cfg_pm_wake_n_c ),                      // I
      .cfg_pcie_link_state_n( cfg_pcie_link_state_n_c ),      // O [2:0]
      .cfg_to_turnoff_n( cfg_to_turnoff_n_c ),                // I
      .cfg_trn_pending_n( cfg_trn_pending_n_c ),              // I
      .cfg_dsn( cfg_dsn_n_c),                                 // I [63:0]

      .cfg_bus_number( cfg_bus_number_c ),                    // O [7:0]
      .cfg_device_number( cfg_device_number_c ),              // O [4:0]
      .cfg_function_number( cfg_function_number_c ),          // O [2:0]
      .cfg_status( cfg_status_c ),                            // O [15:0]
      .cfg_command( cfg_command_c ),                          // O [15:0]
      .cfg_dstatus( cfg_dstatus_c ),                          // O [15:0]
      .cfg_dcommand( cfg_dcommand_c ),                        // O [15:0]
      .cfg_lstatus( cfg_lstatus_c ),                          // O [15:0]
      .cfg_lcommand( cfg_lcommand_c ),                        // O [15:0]

       // The following is used for simulation only.  Setting
       // the following core input to 1 will result in a fast
       // train simulation to happen.  This bit should not be set
       // during synthesis or the core may not operate properly.

       `ifdef SIMULATION
       .fast_train_simulation_only(1'b1),
       `else
       .fast_train_simulation_only(1'b0),
       `endif


       `ifdef TWO_PLM_AUTO_CONFIG
       .two_plm_auto_config(2'b11),
       `else
       .two_plm_auto_config(2'b00),
       `endif

      // .cfg_cfg( cfg_cfg ),                                    // I [1023:0]
        
      //
      // System ( SYS ) Interface
      //

      .sys_clk( sys_clk_c ),                                 // I
      .sys_reset_n( sys_reset_n_c )                          // I

      );


endmodule // XILINX_PCI_EXP_EP
