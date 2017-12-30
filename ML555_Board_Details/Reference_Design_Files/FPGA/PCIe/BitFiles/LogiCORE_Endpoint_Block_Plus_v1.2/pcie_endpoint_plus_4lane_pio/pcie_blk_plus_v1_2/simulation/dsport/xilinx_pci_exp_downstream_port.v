
//-- Copyright(C) 2005 by Xilinx, Inc. All rights reserved.
//-- This text contains proprietary, confidential
//-- information of Xilinx, Inc., is distributed
//-- under license from Xilinx, Inc., and may be used,
//-- copied and/or disclosed only pursuant to the terms
//-- of a valid license agreement with Xilinx, Inc. This copyright
//-- notice must be retained as part of this text at all times.

`timescale 1ns/1ns

`include "board_common.v"
`include "xilinx_pci_exp_defines.v"

module `XILINX_PCI_EXP_DOWNSTREAM_PORT (
                                sys_clk_p,
                                sys_clk_n,
                                sys_reset_n,
                                
                                pci_exp_rxn,
                                pci_exp_rxp,
                                pci_exp_txn,
                                pci_exp_txp
                              );

input                                      sys_clk_p;
input                                      sys_clk_n;
input                                      sys_reset_n;

input  [`PCI_EXP_WIDTH - 1:0]              pci_exp_rxn, pci_exp_rxp;
output [`PCI_EXP_WIDTH - 1:0]              pci_exp_txn, pci_exp_txp;

// Local Wires
// Common
wire                                       trn_clk;
wire                                       trn_reset_n;
wire                                       trn_lnk_up_n;

// Tx
wire  [(64 - 1):0]    trn_td;
wire  [(8 - 1):0]     trn_trem_n;
wire                                       trn_tsof_n;
wire                                       trn_teof_n;
wire                                       trn_tsrc_rdy_n;
wire                                       trn_tdst_rdy_n;
wire                                       trn_tsrc_dsc_n;
wire                                       trn_terrfwd_n;
wire                                       trn_tdst_dsc_n;
wire   [(`PCI_EXP_TRN_BUF_AV_WIDTH - 1):0] trn_tbuf_av;
  
// Rx
wire  [(64 - 1):0]     trn_rd;
wire  [(8 - 1):0]      trn_rrem_n;
wire                                        trn_rsof_n;
wire                                        trn_reof_n;
wire                                        trn_rsrc_rdy_n;
wire                                        trn_rsrc_dsc_n;
wire                                        trn_rdst_rdy_n;
wire                                        trn_rerrfwd_n;
wire                                        trn_rnp_ok_n;
wire [(`PCI_EXP_TRN_BAR_HIT_WIDTH - 1):0]   trn_rbar_hit_n;
wire [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]    trn_rfc_nph_av;
wire [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]   trn_rfc_npd_av;
wire [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]    trn_rfc_ph_av;
wire [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]   trn_rfc_pd_av;
wire [(`PCI_EXP_TRN_FC_HDR_WIDTH - 1):0]    trn_rfc_cplh_av;
wire [(`PCI_EXP_TRN_FC_DATA_WIDTH - 1):0]   trn_rfc_cpld_av;

wire [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]      cfg_do;
wire [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]      cfg_di;
wire [(`PCI_EXP_CFG_DATA_WIDTH/8 - 1):0]    cfg_byte_en_n;
wire [(`PCI_EXP_CFG_ADDR_WIDTH - 1):0]      cfg_dwaddr;
wire [(`PCI_EXP_CFG_CPLHDR_WIDTH - 1):0]    cfg_err_tlp_cpl_header;
wire                                        cfg_wr_en_n;
wire                                        cfg_rd_wr_done_n;
wire                                        cfg_rd_en_n;
wire                                        cfg_err_cor_n;
wire                                        cfg_err_ur_n;
wire                                        cfg_err_ecrc_n;
wire                                        cfg_err_cpl_timeout_n;
wire                                        cfg_err_cpl_abort_n;
wire                                        cfg_err_cpl_unexpect_n;
wire                                        cfg_err_posted_n;  
wire                                        cfg_interrupt_n;
wire                                        cfg_interrupt_rdy_n;
wire                                        cfg_turnoff_ok_n;
wire                                        cfg_to_turnoff_n;
wire                                        cfg_pm_wake_n;
wire [(`PCI_EXP_CFG_BUSNUM_WIDTH - 1):0]    cfg_bus_number;
wire [(`PCI_EXP_CFG_DEVNUM_WIDTH - 1):0]    cfg_device_number;
wire [(`PCI_EXP_CFG_FUNNUM_WIDTH - 1):0]    cfg_function_number;
wire [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]       cfg_status;
wire [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]       cfg_command;
wire [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]       cfg_dstatus;
wire [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]       cfg_dcommand;
wire [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]       cfg_lstatus;
wire [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]       cfg_lcommand;
wire                                        cfg_rdy_n;
wire [(`PCI_EXP_LNK_STATE_WIDTH - 1):0]     cfg_pcie_link_state_n;
wire                                        cfg_trn_pending_n;



// PCI-Express FPGA Endpoint Instance

`XILINX_PCI_EXP_DSPORT `XILINX_PCI_EXP_DSPORT  (

        //
        // PCI Express (PCI_EXP) Interface
        //

        .pci_exp_txp(pci_exp_txp),
        .pci_exp_txn(pci_exp_txn),
        .pci_exp_rxp(pci_exp_rxp),
        .pci_exp_rxn(pci_exp_rxn),

        //
        // Transaction (TRN) Interface
        //

        .trn_clk(trn_clk),
        .trn_reset_n(trn_reset_n),
        .trn_lnk_up_n(trn_lnk_up_n),

        // Tx
        .trn_td(trn_td),
        .trn_trem_n(trn_trem_n),
        .trn_tsof_n(trn_tsof_n),
        .trn_teof_n(trn_teof_n),
        .trn_tsrc_rdy_n(trn_tsrc_rdy_n),
        .trn_tdst_rdy_n(trn_tdst_rdy_n),
        .trn_tsrc_dsc_n(trn_tsrc_dsc_n),
        .trn_terrfwd_n(trn_terrfwd_n),
        .trn_tdst_dsc_n(trn_tdst_dsc_n),
        .trn_tbuf_av(trn_tbuf_av),

            
        // Rx
        .trn_rd(trn_rd),
        .trn_rrem_n(trn_rrem_n),
        .trn_rsof_n(trn_rsof_n),
        .trn_reof_n(trn_reof_n),
        .trn_rsrc_rdy_n(trn_rsrc_rdy_n),
        .trn_rsrc_dsc_n(trn_rsrc_dsc_n),
        .trn_rdst_rdy_n(trn_rdst_rdy_n),
        .trn_rerrfwd_n(trn_rerrfwd_n),
        .trn_rnp_ok_n(trn_rnp_ok_n),
        .trn_rbar_hit_n(trn_rbar_hit_n),
        .trn_rfc_nph_av(trn_rfc_nph_av),
        .trn_rfc_npd_av(trn_rfc_npd_av),
        .trn_rfc_ph_av(trn_rfc_ph_av),
        .trn_rfc_pd_av(trn_rfc_pd_av),
        .trn_rfc_cplh_av(trn_rfc_cplh_av),
        .trn_rfc_cpld_av(trn_rfc_cpld_av),

        //
        // Host (CFG) Interface
        //

        .cfg_do(cfg_do),
        .cfg_rd_wr_done_n(cfg_rd_wr_done_n),
        .cfg_di(cfg_di),
        .cfg_byte_en_n(cfg_byte_en_n),
        .cfg_dwaddr(cfg_dwaddr),
        .cfg_wr_en_n(cfg_wr_en_n),
        .cfg_rd_en_n(cfg_rd_en_n),

        .cfg_err_cor_n(cfg_err_cor_n),
        .cfg_err_ur_n(cfg_err_ur_n),
        .cfg_err_ecrc_n(cfg_err_ecrc_n),
        .cfg_err_cpl_timeout_n(cfg_err_cpl_timeout_n),
        .cfg_err_cpl_abort_n(cfg_err_cpl_abort_n),
        .cfg_err_cpl_unexpect_n(cfg_err_cpl_unexpect_n),
        .cfg_err_posted_n(cfg_err_posted_n),
        .cfg_err_tlp_cpl_header(cfg_err_tlp_cpl_header),

        .cfg_interrupt_n(cfg_interrupt_n),
        .cfg_interrupt_rdy_n(cfg_interrupt_rdy_n),

        .cfg_turnoff_ok_n(cfg_turnoff_ok_n),
        .cfg_to_turnoff_n(cfg_to_turnoff_n),
        .cfg_pm_wake_n(cfg_pm_wake_n),

        .cfg_bus_number(cfg_bus_number),
        .cfg_device_number(cfg_device_number),
        .cfg_function_number(cfg_function_number),

        .cfg_status(cfg_status),
        .cfg_command(cfg_command),
        .cfg_dstatus(cfg_dstatus),
        .cfg_dcommand(cfg_dcommand),
        .cfg_lstatus(cfg_lstatus),
        .cfg_lcommand(cfg_lcommand),

        .cfg_pcie_link_state_n(cfg_pcie_link_state_n),
        .cfg_trn_pending_n(cfg_trn_pending_n),

        // System (SYS) Interface

        .sys_clk_p(sys_clk_p),
        .sys_clk_n(sys_clk_n),
        .sys_reset_n(sys_reset_n)

        );

// User Application Instances

// Rx User Application Interface

`PCI_EXP_USRAPP_RX rx_usrapp (

        .trn_clk(trn_clk),
        .trn_reset_n(trn_reset_n),
        .trn_lnk_up_n(trn_lnk_up_n),

        .trn_rd(trn_rd),
        .trn_rrem_n(trn_rrem_n),
        .trn_rsof_n(trn_rsof_n),
        .trn_reof_n(trn_reof_n),
        .trn_rsrc_rdy_n(trn_rsrc_rdy_n),
        .trn_rsrc_dsc_n(trn_rsrc_dsc_n),
        .trn_rdst_rdy_n(trn_rdst_rdy_n),
        .trn_rerrfwd_n(trn_rerrfwd_n),
        .trn_rnp_ok_n(trn_rnp_ok_n),
        .trn_rbar_hit_n(trn_rbar_hit_n),
        .trn_rfc_nph_av(trn_rfc_nph_av),
        .trn_rfc_npd_av(trn_rfc_npd_av),
        .trn_rfc_ph_av(trn_rfc_ph_av),
        .trn_rfc_pd_av(trn_rfc_pd_av),
        .trn_rfc_cplh_av(trn_rfc_cplh_av),
        .trn_rfc_cpld_av(trn_rfc_cpld_av)

        );
             
// Tx User Application Interface

`PCI_EXP_USRAPP_TX tx_usrapp (

        .trn_clk(trn_clk),
        .trn_reset_n(trn_reset_n),
        .trn_lnk_up_n(trn_lnk_up_n),

        .trn_td(trn_td),
        .trn_trem_n(trn_trem_n),
        .trn_tsof_n(trn_tsof_n),
        .trn_teof_n(trn_teof_n),
        .trn_terrfwd_n(trn_terrfwd_n),
        .trn_tsrc_rdy_n(trn_tsrc_rdy_n),
        .trn_tdst_rdy_n(trn_tdst_rdy_n),
        .trn_tsrc_dsc_n(trn_tsrc_dsc_n),
        .trn_tdst_dsc_n(trn_tdst_dsc_n),
        .trn_tbuf_av(trn_tbuf_av)

        );

// Cfg UsrApp

`PCI_EXP_USRAPP_CFG cfg_usrapp (


        .trn_clk(trn_clk),
        .trn_reset_n(trn_reset_n),

        .cfg_do(cfg_do),
        .cfg_di(cfg_di),
        .cfg_byte_en_n(cfg_byte_en_n),
        .cfg_dwaddr(cfg_dwaddr),
        .cfg_wr_en_n(cfg_wr_en_n),
        .cfg_rd_en_n(cfg_rd_en_n),
        .cfg_rd_wr_done_n(cfg_rd_wr_done_n),

        .cfg_err_cor_n(cfg_err_cor_n),
        .cfg_err_ur_n(cfg_err_ur_n),
        .cfg_err_ecrc_n(cfg_err_ecrc_n),
        .cfg_err_cpl_timeout_n(cfg_err_cpl_timeout_n),
        .cfg_err_cpl_abort_n(cfg_err_cpl_abort_n),
        .cfg_err_cpl_unexpect_n(cfg_err_cpl_unexpect_n),
        .cfg_err_posted_n(cfg_err_posted_n),
        .cfg_err_tlp_cpl_header(cfg_err_tlp_cpl_header),
        .cfg_interrupt_n(cfg_interrupt_n),
        .cfg_interrupt_rdy_n(cfg_interrupt_rdy_n),
        .cfg_turnoff_ok_n(cfg_turnoff_ok_n),
        .cfg_pm_wake_n(cfg_pm_wake_n),
        .cfg_to_turnoff_n(cfg_to_turnoff_n),
        .cfg_bus_number(cfg_bus_number),
        .cfg_device_number(cfg_device_number),
        .cfg_function_number(cfg_function_number),
        .cfg_status(cfg_status),
        .cfg_command(cfg_command),
        .cfg_dstatus(cfg_dstatus),
        .cfg_dcommand(cfg_dcommand),
        .cfg_lstatus(cfg_lstatus),
        .cfg_lcommand(cfg_lcommand),
        .cfg_pcie_link_state_n(cfg_pcie_link_state_n),
        .cfg_trn_pending_n(cfg_trn_pending_n)

        );

// Common UsrApp

`PCI_EXP_USRAPP_COM com_usrapp   ();

endmodule // XILINX_PCI_EXP_COR_EP
