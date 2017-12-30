//-- Copyright(C) 2005 by Xilinx, Inc. All rights reserved.
//-- This text contains proprietary, confidential
//-- information of Xilinx, Inc., is distributed
//-- under license from Xilinx, Inc., and may be used,
//-- copied and/or disclosed only pursuant to the terms
//-- of a valid license agreement with Xilinx, Inc. This copyright
//-- notice must be retained as part of this text at all times.

//-------------------------------------------------------
// PCI Express Endpoint Module
//-------------------------------------------------------

`ifdef BOARDx01                        

`define PCI_EXP_EP                     pcie_blk_plus_v1_2 
`define XILINX_PCI_EXP_EP               xilinx_pci_exp_1_lane_ep
`define PCI_EXP_LINK_WIDTH              1

`endif // BOARDx01

`ifdef BOARDx04                        

`define PCI_EXP_EP                      pcie_blk_plus_v1_2 
`define XILINX_PCI_EXP_EP               xilinx_pci_exp_4_lane_ep
`define PCI_EXP_LINK_WIDTH              4

`endif // BOARDx04

`ifdef BOARDx08

`define PCI_EXP_EP                      pcie_blk_plus_v1_2
`define XILINX_PCI_EXP_EP               xilinx_pci_exp_8_lane_ep
`define PCI_EXP_LINK_WIDTH              8

`endif // BOARDx08

`define PCI_EXP_EP_INST                 ep

//-------------------------------------------------------
// Config File Module
//-------------------------------------------------------

`define PCI_EXP_CFG                     pci_exp_cfg

`define PCI_EXP_CFG_INST                pci_exp_cfg

//-------------------------------------------------------
// Transaction (TRN) Interface
//-------------------------------------------------------

`define PCI_EXP_TRN_DATA_WIDTH          64
`define PCI_EXP_TRN_REM_WIDTH           8
`define PCI_EXP_TRN_BUF_AV_WIDTH        3

`define PCI_EXP_TRN_BAR_HIT_WIDTH       7
`define PCI_EXP_TRN_FC_HDR_WIDTH        8
`define PCI_EXP_TRN_FC_DATA_WIDTH       12

//-------------------------------------------------------
// Application Stub Module
//-------------------------------------------------------

`define PCI_EXP_APP                     pci_exp_64b_app

//-------------------------------------------------------
// Configuration (CFG) Interface
//-------------------------------------------------------

`define PCI_EXP_CFG_DATA_WIDTH          32
`define PCI_EXP_CFG_ADDR_WIDTH          10
`define PCI_EXP_CFG_BUSNUM_WIDTH        8
`define PCI_EXP_CFG_DEVNUM_WIDTH        5
`define PCI_EXP_CFG_FUNNUM_WIDTH        3
`define PCI_EXP_CFG_CPLHDR_WIDTH        48
`define PCI_EXP_CFG_CAP_WIDTH           16
`define PCI_EXP_CFG_CFG_WIDTH           1024
`define PCI_EXP_CFG_WIDTH               1024
`define PCI_EXP_LNK_STATE_WIDTH         3

`define PCI_EXP_CFG_BUSNUM_WIDTH        8
`define PCI_EXP_CFG_DEVNUM_WIDTH        5
`define PCI_EXP_CFG_FUNNUM_WIDTH        3
`define PCI_EXP_CFG_DSN_WIDTH           64
`define PCI_EXP_EP_OUI                  24'h000A35
`define PCI_EXP_EP_DSN_1                {{8'h1},`PCI_EXP_EP_OUI}
`define PCI_EXP_EP_DSN_2                32'h00000001

