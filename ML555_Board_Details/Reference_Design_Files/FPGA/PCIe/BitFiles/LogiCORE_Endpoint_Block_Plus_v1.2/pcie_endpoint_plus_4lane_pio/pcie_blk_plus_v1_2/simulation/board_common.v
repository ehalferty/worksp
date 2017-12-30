
//-- Copyright(C) 2004 by Xilinx, Inc. All rights reserved.
//-- This text contains proprietary, confidential
//-- information of Xilinx, Inc., is distributed
//-- under license from Xilinx, Inc., and may be used,
//-- copied and/or disclosed only pursuant to the terms
//-- of a valid license agreement with Xilinx, Inc. This copyright
//-- notice must be retained as part of this text at all times.

`timescale 1ns/1ns

`define IO_TRUE                      1
`define IO_FALSE                     0

`define XILINX_PCI_EXP_COR_EP                      xilinx_pci_exp_cor_ep
`define XILINX_PCI_EXP_COR_EP_INST                 xilinx_pci_exp_cor_ep

`ifdef BOARDx01
  `define PCI_EXP_WIDTH                            1
  `define PCI_EXP_DSPORT                           pci_exp_1_lane_64b_dsport
  `define PCI_EXP_DSPORT_INST                      pci_exp_1_lane_64b_dsport
  `define XILINX_PCI_EXP_DOWNSTREAM_PORT           xilinx_pci_exp_1_lane_downstream_port
  `define XILINX_PCI_EXP_DOWNSTREAM_PORT_INST      xilinx_pci_exp_1_lane_downstream_port
  `define XILINX_PCI_EXP_DSPORT                    xilinx_pci_exp_1_lane_dsport
  `define XILINX_PCI_EXP_DSPORT_INST               xilinx_pci_exp_1_lane_dsport

  `define BOARD                                    boardx01
`endif

`ifdef BOARDx04
  `define PCI_EXP_WIDTH                            4
  `define PCI_EXP_DSPORT                           pci_exp_4_lane_64b_dsport
  `define PCI_EXP_DSPORT_INST                      pci_exp_4_lane_64b_dsport
  `define XILINX_PCI_EXP_DOWNSTREAM_PORT           xilinx_pci_exp_4_lane_downstream_port
  `define XILINX_PCI_EXP_DOWNSTREAM_PORT_INST      xilinx_pci_exp_4_lane_downstream_port
  `define XILINX_PCI_EXP_DSPORT                    xilinx_pci_exp_4_lane_dsport
  `define XILINX_PCI_EXP_DSPORT_INST               xilinx_pci_exp_4_lane_dsport

  `define BOARD                                    boardx04
`endif

`ifdef BOARDx08
  `define PCI_EXP_WIDTH                            4
  `define PCI_EXP_DSPORT                           pci_exp_4_lane_64b_dsport
  `define PCI_EXP_DSPORT_INST                      pci_exp_4_lane_64b_dsport
  `define XILINX_PCI_EXP_DOWNSTREAM_PORT           xilinx_pci_exp_4_lane_downstream_port
  `define XILINX_PCI_EXP_DOWNSTREAM_PORT_INST      xilinx_pci_exp_4_lane_downstream_port
  `define XILINX_PCI_EXP_DSPORT                    xilinx_pci_exp_4_lane_dsport
  `define XILINX_PCI_EXP_DSPORT_INST               xilinx_pci_exp_4_lane_dsport

  `define BOARD                                    boardx08
`endif

`define PCI_EXP_USRAPP_RX                          pci_exp_usrapp_rx
`define PCI_EXP_USRAPP_TX                          pci_exp_usrapp_tx
`define PCI_EXP_USRAPP_COM                         pci_exp_usrapp_com
`define PCI_EXP_USRAPP_CFG                         pci_exp_usrapp_cfg

`define TX_TASKS                                   `BOARD.`XILINX_PCI_EXP_DOWNSTREAM_PORT_INST.tx_usrapp

// Clock generators
`define SYS_CLK_GEN                                sys_clk_gen_ds
`define SYS_CLK_GEN_COR                            sys_clk_gen_cor
`define SYS_CLK_GEN_DSPORT                         sys_clk_gen_dsport

// Endpoint Sys clock clock frequency 100 MHz -> half clock -> 5000 pS
`define SYS_CLK_COR_HALF_CLK_PERIOD         5000

// Downstrean Port Sys clock clock frequency 250 MHz -> half clock -> 2000 pS
`define SYS_CLK_DSPORT_HALF_CLK_PERIOD      2000

`define RX_LOG                       0
`define TX_LOG                       1

// PCIi Express TLP Types constants
`define  PCI_EXP_MEM_READ32          7'b0000000
`define  PCI_EXP_IO_READ             7'b0000010
`define  PCI_EXP_CFG_READ0           7'b0000100
`define  PCI_EXP_COMPLETION_WO_DATA  7'b0001010
`define  PCI_EXP_MEM_READ64          7'b0100000
`define  PCI_EXP_MSG_NODATA          7'b0110xxx
`define  PCI_EXP_MEM_WRITE32         7'b1000000
`define  PCI_EXP_IO_WRITE            7'b1000010
`define  PCI_EXP_CFG_WRITE0          7'b1000100
`define  PCI_EXP_COMPLETION_DATA     7'b1001010
`define  PCI_EXP_MEM_WRITE64         7'b1100000
`define  PCI_EXP_MSG_DATA            7'b1110xxx

`define  TRN_RX_TIMEOUT              5000
