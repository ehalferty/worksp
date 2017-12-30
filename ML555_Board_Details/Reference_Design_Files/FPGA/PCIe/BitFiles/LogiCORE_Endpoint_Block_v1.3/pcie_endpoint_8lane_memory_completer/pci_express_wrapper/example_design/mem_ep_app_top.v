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
// \   \   \/     Version     : 1.3
//  \   \         Application : Example Completer design for PCI Express
//  /   /         Filename    : mem_ep_app_top.v
// /___/   /\     Module      : mem_ep_app_top 
// \   \  /  \
//  \___\/\___\
//
//-----------------------------------------------------------------------------

`include  "config.v"

`timescale  1 ns / 10 ps

module   mem_ep_app_top 
#(
     parameter   G_NO_OF_LANES = 8,   // Number of Lanes to use
     parameter   G_USE_DCM     = 0,     // Use DCM (1) or PLL (0)
     parameter   G_USER_RESETS = 0,     // Use own resets (1) or pcie_reset_logic (0)
     parameter   G_SIM         = 0,     // This is for simulation (1) or not (0)
     parameter   G_CHIPSCOPE   = 0,     // Use Chipscope for debug (1) or not (0) 
     parameter   G_ADV_DEBUG   = 0,     // Use extra ILA cores for pcie_framework (1) 
                                        // (uses 61 BRAMs) or not (0).  Use (0) if
                                        // G_CHIPSCOPE = 0.
     parameter   G_MAXPAYLOADSIZE = 0,  // Use 0 -> 5 for 128 -> 4096
     parameter   G_TC_NUMBER      = 0,  // Traffic Class to use for Completer design (0-7)
     parameter   G_REFCLKFREQ = 100
)

(
   // clock and reset related inputs
     input    wire       REFCLK_N,
     input    wire       REFCLK_P,
     input    wire       RST_N,
     input    wire       GTPRESET_N,
     
     input    wire  [G_NO_OF_LANES - 1: 0] RXN,
     input    wire  [G_NO_OF_LANES - 1: 0] RXP,
     output   wire  [G_NO_OF_LANES - 1: 0] TXN,
     output   wire  [G_NO_OF_LANES - 1: 0] TXP,
     output   wire       LINKUP,
     output   wire       TXCLKOUT,
     output   wire       REFCLKOUT, 
     output   wire       CLKLOCK,
     output   wire       PLLLKDETOUT,
     output   wire       CORECLK,
     output   wire       USERCLK

  );
   
     wire fe_fundamental_reset_n;


//Inputs to the pcie core
     wire       fe_compliance_avoid = 1'b0; 
     wire       fe_l0_cfg_loopback_master = 1'b0; 
     wire       fe_l0_transactions_pending = 1'b0; 
     wire       fe_l0_set_completer_abort_error = 1'b0; 
     wire       fe_l0_set_detected_corr_error = 1'b0; 
     wire       fe_l0_set_detected_fatal_error = 1'b0; 
     wire       fe_l0_set_detected_nonfatal_error = 1'b0; 
     wire       fe_l0_set_user_detected_parity_error = 1'b0; 
     wire       fe_l0_set_user_master_data_parity = 1'b0;  
     wire       fe_l0_set_user_received_master_abort = 1'b0;  
     wire       fe_l0_set_user_received_target_abort = 1'b0;  
     wire       fe_l0_set_user_system_error = 1'b0;  
     wire       fe_l0_set_user_signalled_target_abort = 1'b0;  
     wire       fe_l0_set_unexpected_completion_uncorr_error = 1'b0;  
     wire       fe_l0_set_unexpected_completion_corr_error = 1'b0; 
     wire       fe_l0_set_unsupported_request_nonposted_error = 1'b0;  
     wire       fe_l0_set_unsupported_request_other_error = 1'b0;  
     
     wire       legacy_int_funct0_dutb = 1'b0; 
     wire [3:0] msi_request0_dutb = 4'b0;  
     
     wire       fe_l0_set_completion_timeout_uncorr_error =1'b0; 
     wire       fe_l0_set_completion_timeout_corr_error = 1'b0; 

//outputs from the pcie core
     wire       fe_l0_first_cfg_write_occurred;
     wire       fe_l0_cfg_loopback_ack; 
     wire [1:0] fe_l0_rx_mac_link_error; 
     wire       fe_l0_mac_link_up; 
     wire [3:0] fe_l0_mac_negotiated_link_width; 
     wire       fe_l0_mac_link_training; 
     wire [3:0] fe_l0_ltssm_state; 
     wire [7:0] fe_l0_dl_up_down; 
     wire [6:0] fe_l0_dll_error_vector;  
     
     wire        fe_l0_unlock_received;                           
     wire        fe_l0_corr_err_msg_rcvd = 1'b0;                         
     wire        fe_l0_fatal_err_msg_rcvd = 1'b0;                        
     wire        fe_l0_nonfatal_err_msg_rcvd = 1'b0;                     
     wire [15:0] fe_l0_err_msg_req_id = 16'h0000;                            
     
     wire        fe_l0_msi_enable0;                
     wire [2:0]  fe_l0_multi_msg_en0;              
     wire        fe_l0_stats_dllp_received;        
     wire        fe_l0_stats_dllp_transmitted;     
     wire        fe_l0_stats_os_received;          
     wire        fe_l0_stats_os_transmitted;       
     wire        fe_l0_stats_tlp_received;         
     wire        fe_l0_stats_tlp_transmitted;      
     wire        fe_l0_stats_cfg_received;         
     wire        fe_l0_stats_cfg_transmitted;      
     wire        fe_l0_stats_cfg_other_received;   
     wire        fe_l0_stats_cfg_other_transmitted;
     
     wire [1:0]   fe_l0_pwr_state0;                        
     wire         fe_l0_pwr_l23_ready_state;               
     wire         fe_l0_pwr_tx_l0s_state;                  
     wire         fe_l0_pwr_turn_off_req;
     
      wire [1:0]   fe_l0_attention_indicator_control;
      wire [1:0]   fe_l0_power_indicator_control;
      wire         fe_l0_power_controller_control;
      wire         fe_l0_toggle_electromechanical_interlock;
      wire         fe_l0_rx_beacon;
      wire         fe_l0_pme_ack;
      wire         fe_l0_pme_req_out;
      wire         fe_l0_pme_en;
      wire         fe_l0_pwr_inhibit_transfers;
      wire         fe_l0_pwr_l1_state;
      wire         fe_l0_rx_dll_pm;
      wire [2:0]   fe_l0_rx_dll_pm_type;
      wire         fe_l0_tx_dll_pm_updated;
      wire         fe_l0_mac_new_state_ack;
      wire         fe_l0_mac_rx_l0s_state;
      wire         fe_l0_mac_entered_l0;
      wire         fe_l0_dll_rx_ack_outstanding;
      wire         fe_l0_dll_tx_outstanding;
      wire         fe_l0_dll_tx_non_fc_outstanding;
      wire [1:0]   fe_l0_rx_dll_tlp_end;
      wire         fe_l0_tx_dll_sbfc_updated;
      wire [18:0]  fe_l0_rx_dll_sbfc_data;
      wire         fe_l0_rx_dll_sbfc_update;
      wire [7:0]   fe_l0_tx_dll_fc_npost_byp_updated;
      wire [7:0]   fe_l0_tx_dll_fc_post_ord_updated;
      wire [7:0]   fe_l0_tx_dll_fc_cmpl_mc_updated;
      wire [19:0]  fe_l0_rx_dll_fc_npost_byp_cred;
      wire [7:0]   fe_l0_rx_dll_fc_npost_byp_update;
      wire [23:0]  fe_l0_rx_dll_fc_post_ord_cred;
      wire [7:0]   fe_l0_rx_dll_fc_post_ord_update;
      wire [23:0]  fe_l0_rx_dll_fc_cmpl_mc_cred;
      wire [7:0]   fe_l0_rx_dll_fc_cmpl_mc_update;
      wire [3:0]   fe_l0_uc_byp_found;
      wire [3:0]   fe_l0_uc_ord_found;
      wire [2:0]   fe_l0_mc_found;
      wire [2:0]   fe_l0_transformed_vc;
     
     wire [2:0]    max_read_request_size;
     wire          interrupt_disable;
     wire          ur_reporting_enable;
     wire          serr_enable;
     wire          parity_error_response;
     wire          bus_master_enable;
     wire          mem_space_enable;
     wire          io_space_enable;
     
     wire [31:0]   mgmt_rd_data;
     wire          mgmt_wr_done;
     wire          mgmt_rd_done;
     
     wire [12:0]   completer_id_temp; 
     wire [15:0]   completer_id;
     wire [2:0]    maxp; 
     wire [2:0]    mem_tx_tc_select; 
     wire [1:0]    mem_tx_fifo_select; 
     wire [1:0]    mem_tx_enable; 
     wire          mem_tx_header; 
     wire          mem_tx_first; 
     wire          mem_tx_last; 
     wire          mem_tx_discard; 
     wire [63:0]   mem_tx_data; 
     wire          mem_tx_complete; 
     wire [2:0]    mem_rx_tc_select; 
     wire [1:0]    mem_rx_fifo_select; 
     wire          mem_rx_request; 
     wire [31:0]   mem_debug; 
     
     wire [7:0]    fe_rx_posted_available;
     wire [7:0]    fe_rx_non_posted_available;
     wire [7:0]    fe_rx_completion_available;
     wire          fe_rx_config_available;
                                          
     wire [7:0]    fe_rx_posted_partial;
     wire [7:0]    fe_rx_non_posted_partial;
     wire [7:0]    fe_rx_completion_partial;
     wire          fe_rx_config_partial;
     
     wire          fe_rx_request_end;
     wire [1:0]    fe_rx_valid;
     wire          fe_rx_header;
     wire          fe_rx_first;
     wire          fe_rx_last;
     wire          fe_rx_discard;
     wire [63:0]   fe_rx_data; 
     wire [7:0]    fe_tc_status;
     
     wire [7:0]    fe_tx_posted_ready;
     wire [7:0]    fe_tx_non_posted_ready;
     wire [7:0]    fe_tx_completion_ready;
     wire          fe_tx_config_ready;
     wire [7:0]    fe_leds_out; 
     
// Local Link Transmit
     wire [7:0]    llk_tc_status;
     wire [63:0]   llk_tx_data;
     wire [9:0]    llk_tx_chan_space;
     wire [1:0]    llk_tx_enable_n;
     wire [2:0]    llk_tx_ch_tc;
     wire [1:0]    llk_tx_ch_fifo;
     wire [7:0]    llk_tx_ch_posted_ready_n;
     wire [7:0]    llk_tx_ch_non_posted_ready_n;
     wire [7:0]    llk_tx_ch_completion_ready_n;
     wire          llk_rx_src_last_req_n;
     wire          llk_rx_dst_req_n;
     
     
     // Local Link Receive
     wire [63:0]   llk_rx_data;
     wire [1:0]    llk_rx_valid_n;
     wire [15:0]   llk_rx_preferred_type;
     wire [2:0]    llk_rx_ch_tc;
     wire [1:0]    llk_rx_ch_fifo;
     wire [7:0]    llk_rx_ch_posted_available_n;
     wire [7:0]    llk_rx_ch_non_posted_available_n;
     wire [7:0]    llk_rx_ch_completion_available_n;
     wire [7:0]    llk_rx_ch_posted_partial_n;
     wire [7:0]    llk_rx_ch_non_posted_partial_n;
     wire [7:0]    llk_rx_ch_completion_partial_n;
     
     wire          refclk;
     wire          LINK_UP;
     
     wire          gtpclk_bufg;
     wire          refclk_out_bufg;
     
     wire [7:0]    resetdone;
     wire [3:0]    plllkdet_out;
     
     wire [106:0]  debug;
     wire          GSR;
     
     wire          RST_i;
     wire          gtpreset_i;
     
     reg [0:3]     debounce_rst;
     reg [0:3]     debounce_gtpreset;
     
     wire [6:0]    bar_hit; 
     wire          user_clk;
     
      IBUFDS mgtclk (.O(refclk), .I(REFCLK_P), .IB(REFCLK_N)); 
     
     
      OBUF obuf1    (.I(gtpclk_bufg),     .O(TXCLKOUT));
      OBUF obuf2    (.I(refclk_out_bufg), .O(REFCLKOUT));
      OBUF obuf3    (.I(LINK_UP),         .O(LINKUP));
      OBUF obuf4    (.I(clock_lock),      .O(CLKLOCK));
      OBUF obuf5    (.I(plllkdet_out[0]), .O(PLLLKDETOUT)); 
      OBUF obuf6    (.I(core_clk),        .O(CORECLK));
      OBUF obuf7    (.I(user_clk),        .O(USERCLK));
      
     
     // Debounce the RESET signals 
     
     always @(posedge refclk_out_bufg)
        debounce_rst <=  {~RST_N, debounce_rst[0:2]};
     
     assign  RST_i  =  & debounce_rst;
     
     
     always @(posedge refclk_out_bufg)
        debounce_gtpreset <=  {~GTPRESET_N,debounce_gtpreset[0:2]};
     
     assign  gtpreset_i  =  & debounce_gtpreset;
     
      
     reg mem_tx_first_reg;
     
     always @(posedge user_clk) begin
       mem_tx_first_reg <= mem_tx_first;
     end
     
     
     assign fe_fundamental_reset_n = ~RST_i;
          
     generate
       if (G_SIM == 1) begin : sim_resets
         /* synthesis translate_off */
         assign GSR = glbl.GSR;
         /* synthesis translate_on */
       end else begin : imp_resets
         assign GSR = 1'b0;
       end
     endgenerate
     
     assign LINK_UP = fe_l0_mac_link_up;
     
     
 pci_express_wrapper #
      (
         .NO_OF_LANES    (G_NO_OF_LANES),
         .G_SIM          (G_SIM),
         .G_USE_DCM      (G_USE_DCM),
         .G_USER_RESETS  (G_USER_RESETS),
         .MAXPAYLOADSIZE (G_MAXPAYLOADSIZE),
         .REFCLKFREQ     (G_REFCLKFREQ)
      )
      dut_b
      (
         // inputs
           .gsr            (GSR),
           .user_reset_n   (fe_fundamental_reset_n),
           
           .clock_lock     (clock_lock),
           .core_clk       (core_clk),                  
           .user_clk       (user_clk),
     
           .crm_urst_n                (fe_fundamental_reset_n),                      
           .crm_nvrst_n               (fe_fundamental_reset_n),                     
           .crm_mgmt_rst_n            (fe_fundamental_reset_n),                  
           .crm_user_cfg_rst_n        (fe_fundamental_reset_n),  
           .crm_mac_rst_n             (fe_fundamental_reset_n),                                
           .crm_link_rst_n            (fe_fundamental_reset_n), 
     
           .compliance_avoid          (fe_compliance_avoid),
           .l0_cfg_loopback_master    (fe_l0_cfg_loopback_master), 
           .l0_transactions_pending   (fe_l0_transactions_pending), 
     
     
           .l0_set_completer_abort_error              (fe_l0_set_completer_abort_error),                   
           .l0_set_detected_corr_error                (fe_l0_set_detected_corr_error),                     
           .l0_set_detected_fatal_error               (fe_l0_set_detected_fatal_error),                    
           .l0_set_detected_nonfatal_error            (fe_l0_set_detected_nonfatal_error),                 
           .l0_set_user_detected_parity_error         (fe_l0_set_user_detected_parity_error),              
           .l0_set_user_master_data_parity            (fe_l0_set_user_master_data_parity),                 
           .l0_set_user_received_master_abort         (fe_l0_set_user_received_master_abort),              
           .l0_set_user_received_target_abort         (fe_l0_set_user_received_target_abort),              
           .l0_set_user_system_error                  (fe_l0_set_user_system_error),                       
           .l0_set_user_signalled_target_abort        (fe_l0_set_user_signalled_target_abort),             
           .l0_set_completion_timeout_uncorr_error    (fe_l0_set_completion_timeout_uncorr_error),         
           .l0_set_completion_timeout_corr_error      (fe_l0_set_completion_timeout_corr_error),           
           .l0_set_unexpected_completion_uncorr_error (fe_l0_set_unexpected_completion_uncorr_error),      
           .l0_set_unexpected_completion_corr_error   (fe_l0_set_unexpected_completion_corr_error),        
           .l0_set_unsupported_request_nonposted_error(fe_l0_set_unsupported_request_nonposted_error),     
           .l0_set_unsupported_request_other_error    (fe_l0_set_unsupported_request_other_error),         
           .l0_legacy_int_funct0                      (legacy_int_funct0_dutb),                           
     
           .mgmt_wdata           (32'h00000000),                                     
           .mgmt_bwren           (4'h0),                                     
           .mgmt_wren            (1'b0),                                      
           .mgmt_addr            (11'h000),                                      
           .mgmt_rden            (1'b0),                                   
           .mgmt_rdata           (mgmt_rd_data),                                   
           .mgmt_rddone          (mgmt_rd_done),
           .mgmt_wrdone          (mgmt_wr_done),
     
           .mgmt_stats_credit_sel(7'b0),
         
           .crm_do_hot_reset_n   (),                           
           .crm_pwr_soft_reset_n (), 
         
           .mgmt_pso             (),                                     
           .mgmt_stats_credit    (),     
           
           .l0_first_cfg_write_occurred   (fe_l0_first_cfg_write_occurred),                  
           .l0_cfg_loopback_ack           (fe_l0_cfg_loopback_ack),                          
           .l0_rx_mac_link_error          (fe_l0_rx_mac_link_error),                         
           .l0_mac_link_up                (fe_l0_mac_link_up),                               
           .l0_mac_negotiated_link_width  (fe_l0_mac_negotiated_link_width),                 
           .l0_mac_link_training          (fe_l0_mac_link_training),                         
           .l0_ltssm_state                (fe_l0_ltssm_state),                               
            
           .l0_mac_new_state_ack          (fe_l0_mac_new_state_ack),
           .l0_mac_rx_l0s_state           (fe_l0_mac_rx_l0s_state),
           .l0_mac_entered_l0             (fe_l0_mac_entered_l0),
     
           .l0_dl_up_down                 (fe_l0_dl_up_down),                                
           .l0_dll_error_vector           (fe_l0_dll_error_vector),                          
            
           .l0_completer_id               (completer_id_temp),                              
           
           .l0_msi_enable0                (fe_l0_msi_enable0),                               
           .l0_multi_msg_en0              (fe_l0_multi_msg_en0),
           .l0_stats_dllp_received        (fe_l0_stats_dllp_received),                       
           .l0_stats_dllp_transmitted     (fe_l0_stats_dllp_transmitted),                    
           .l0_stats_os_received          (fe_l0_stats_os_received),                         
           .l0_stats_os_transmitted       (fe_l0_stats_os_transmitted),                      
           .l0_stats_tlp_received         (fe_l0_stats_tlp_received),                        
           .l0_stats_tlp_transmitted      (fe_l0_stats_tlp_transmitted),                    
           .l0_stats_cfg_received         (fe_l0_stats_cfg_received),                        
           .l0_stats_cfg_transmitted      (fe_l0_stats_cfg_transmitted),                     
           .l0_stats_cfg_other_received   (fe_l0_stats_cfg_other_received),                  
           .l0_stats_cfg_other_transmitted(fe_l0_stats_cfg_other_transmitted),               
           
           .l0_pwr_state0          (fe_l0_pwr_state0),                                
           .l0_pwr_l23_ready_state (fe_l0_pwr_l23_ready_state),                       
           .l0_pwr_tx_l0s_state    (fe_l0_pwr_tx_l0s_state),                          
           .l0_pwr_turn_off_req    (fe_l0_pwr_turn_off_req),
           
           .io_space_enable        (io_space_enable),                              
           .mem_space_enable       (mem_space_enable),                             
           .bus_master_enable      (bus_master_enable),                            
           .parity_error_response  (parity_error_response),                        
           .serr_enable            (serr_enable),                                  
           .interrupt_disable      (interrupt_disable),                            
           .ur_reporting_enable    (ur_reporting_enable),    
           
            //Local Link Interface ports 
            // TX ports
          .llk_tx_data                 (llk_tx_data),                     
          .llk_tx_src_rdy_n            (llk_tx_src_rdy_n),                
          .llk_tx_sof_n                (llk_tx_sof_n),                    
          .llk_tx_eof_n                (llk_tx_eof_n),                    
          .llk_tx_sop_n                (llk_tx_sop_n),                    
          .llk_tx_eop_n                (llk_tx_eop_n),                    
          .llk_tx_enable_n             (llk_tx_enable_n),                 
          .llk_tx_ch_tc                (llk_tx_ch_tc),                    
          .llk_tx_ch_fifo              (llk_tx_ch_fifo),                  
           
          .llk_tx_dst_rdy_n            (llk_tx_dst_rdy_n),
          .llk_tx_chan_space           (llk_tx_chan_space),
          .llk_tx_ch_posted_ready_n    (llk_tx_ch_posted_ready_n),
          .llk_tx_ch_non_posted_ready_n(llk_tx_ch_non_posted_ready_n),
          .llk_tx_ch_completion_ready_n(llk_tx_ch_completion_ready_n),
           
          //RX Ports 
          .llk_rx_dst_req_n                (llk_rx_dst_req_n),                
          .llk_rx_dst_cont_req_n           (1'b1),                
          .llk_rx_ch_tc                    (llk_rx_ch_tc),                    
          .llk_rx_ch_fifo                  (llk_rx_ch_fifo),                  
           
          .llk_tc_status                   (llk_tc_status),
           
          .llk_rx_data                     (llk_rx_data),
          .llk_rx_src_rdy_n                (),
          .llk_rx_src_last_req_n           (llk_rx_src_last_req_n),
          .llk_rx_sof_n                    (llk_rx_sof_n),
          .llk_rx_eof_n                    (llk_rx_eof_n),
          .llk_rx_sop_n                    (llk_rx_sop_n),
          .llk_rx_eop_n                    (),
          .llk_rx_valid_n                  (llk_rx_valid_n),
          .llk_rx_preferred_type           (llk_rx_preferred_type),
          .llk_rx_ch_posted_available_n    (llk_rx_ch_posted_available_n),
          .llk_rx_ch_non_posted_available_n(llk_rx_ch_non_posted_available_n),
          .llk_rx_ch_completion_available_n(llk_rx_ch_completion_available_n),
          
           .TXN           (TXN),
           .TXP           (TXP),
           .RXN           (RXN),
           .RXP           (RXP),
           .gtpclk_bufg   (gtpclk_bufg),
           .refclkout_bufg(refclk_out_bufg),
           .plllkdet_out  (plllkdet_out),
           .resetdone     (resetdone),
           .gtpreset      (gtpreset_i),
           .debug         (debug),
           .refclk        (refclk),
           
           // used for auto negotiation. If number of lanes is set to 8
           // auto negotiation can be acheived on x4 x2 and x1 by setting
           // the corresponding bits to 1 and the others to z
           // Setting lanes to z implies there is no reciver present on the
           // other end.
           
           .gt_rx_present(8'b11111111),
           .bar_hit      (bar_hit), 
     
           .max_payload_size (maxp),
           .max_read_request_size (max_read_request_size)      
           
                   
     );
     
      
     //------------------------------------------------------------------------------
     // instatiate Optional Memory Backend
     //------------------------------------------------------------------------------
     assign completer_id               = {completer_id_temp, 3'b000} ;
     assign fe_rx_completion_available = ~llk_rx_ch_completion_available_n;
     assign fe_rx_completion_partial   = 1'b0;//~llk_rx_ch_completion_partial_n;
     assign fe_rx_config_available = 1'b0;    //~llk_rx_ch_config_available_n;
     assign fe_rx_config_partial   = 1'b0;    //~llk_rx_ch_config_partial_n;
     assign fe_rx_data             = llk_rx_data;
     assign fe_rx_discard          = 1'b0;   //~llk_rx_src_dsc_n;
     assign fe_rx_first            = ~llk_rx_sof_n;
     assign fe_rx_header           = ~llk_rx_sop_n;
     assign fe_rx_last             = ~llk_rx_eof_n;
     assign fe_rx_non_posted_available = ~llk_rx_ch_non_posted_available_n;
     assign fe_rx_non_posted_partial   = 1'b0;//~llk_rx_ch_non_posted_partial_n;
     assign fe_rx_posted_available = ~llk_rx_ch_posted_available_n;
     assign fe_rx_posted_partial   = 1'b0;    //~llk_rx_ch_posted_partial_n;
     assign fe_rx_request_end      =~llk_rx_src_last_req_n;
     assign fe_rx_valid            = ~llk_rx_valid_n;
     assign fe_tc_status           = llk_tc_status;
     assign fe_tx_completion_ready = ~llk_tx_ch_completion_ready_n;
     assign fe_tx_config_ready     = 1'b0;
     assign fe_tx_non_posted_ready = ~llk_tx_ch_non_posted_ready_n;
     assign fe_tx_posted_ready     = ~llk_tx_ch_posted_ready_n;
     
     assign llk_rx_ch_fifo   = mem_rx_fifo_select;
     assign llk_rx_ch_tc     = mem_rx_tc_select;
     assign llk_tx_data      = mem_tx_data;
     assign llk_tx_enable_n  = ~mem_tx_enable; 
     assign llk_tx_ch_fifo   = mem_tx_fifo_select;
     assign llk_tx_sof_n     = ~mem_tx_first;
     assign llk_tx_eof_n     = ~mem_tx_last;
     assign llk_tx_ch_tc     = mem_tx_tc_select;
     assign llk_rx_dst_req_n = ~mem_rx_request;
     assign llk_tx_eop_n     = ~mem_tx_last;
     assign llk_tx_src_rdy_n = ~(|mem_tx_enable);
     assign llk_tx_sop_n     = ~mem_tx_first_reg;
     
     
     completer_mem_block_top #(
       .G_RAM_READ_LATENCY      (2), // 1 for no output BRAM reg, 2 for output BRAM reg
       .G_TC_NUMBER             (G_TC_NUMBER)
     )
     completer(
       .clock                   (user_clk),
       .reset_n                 (fe_fundamental_reset_n),
       .completer_id            (completer_id),
       .maxp                    (maxp),
       .rx_completion_available (fe_rx_completion_available),
       .rx_completion_partial   (fe_rx_completion_partial),
       .rx_config_available     (fe_rx_config_available),
       .rx_config_partial       (fe_rx_config_partial),
       .rx_data                 (fe_rx_data),
       .rx_discard              (fe_rx_discard),
       .rx_first                (fe_rx_first),
       .rx_header               (fe_rx_header),
       .rx_last                 (fe_rx_last),
       .rx_non_posted_available (fe_rx_non_posted_available),
       .rx_non_posted_partial   (fe_rx_non_posted_partial),
       .rx_posted_available     (fe_rx_posted_available),
       .rx_posted_partial       (fe_rx_posted_partial),
       .rx_request_end          (fe_rx_request_end),
       .rx_valid                (fe_rx_valid),
       .tc_status               (fe_tc_status),
       .tx_completion_ready     (fe_tx_completion_ready), 
       .tx_config_ready         (fe_tx_config_ready),
       .tx_non_posted_ready     (fe_tx_non_posted_ready),
       .tx_posted_ready         (fe_tx_posted_ready),
       .leds_out                (fe_leds_out),
       .mem_debug               (mem_debug),
       .rx_fifo_select          (mem_rx_fifo_select),
       .rx_request              (mem_rx_request),
       .rx_tc_select            (mem_rx_tc_select),
       .tx_complete             (mem_tx_complete),
       .tx_data                 (mem_tx_data),
       .tx_discard              (mem_tx_discard),
       .tx_enable               (mem_tx_enable),
       .tx_fifo_select          (mem_tx_fifo_select),
       .tx_first                (mem_tx_first),
       .tx_header               (mem_tx_header),
       .tx_last                 (mem_tx_last),
       .tx_tc_select            (mem_tx_tc_select));
 
  endmodule
