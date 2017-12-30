
//-- Copyright(C) 2005 by Xilinx, Inc. All rights reserved.
//-- This text contains proprietary, confidential
//-- information of Xilinx, Inc., is distributed
//-- under license from Xilinx, Inc., and may be used,
//-- copied and/or disclosed only pursuant to the terms
//-- of a valid license agreement with Xilinx, Inc. This copyright
//-- notice must be retained as part of this text at all times.

`include "board_common.v"

module pci_exp_usrapp_cfg (

                          cfg_do,
                          cfg_di,
                          cfg_byte_en_n,
                          cfg_dwaddr,
                          cfg_wr_en_n,
                          cfg_rd_en_n,
                          cfg_rd_wr_done_n,
                    
                          cfg_err_cor_n,
                          cfg_err_ur_n,      
                          cfg_err_ecrc_n,
                          cfg_err_cpl_timeout_n,
                          cfg_err_cpl_abort_n,
                          cfg_err_cpl_unexpect_n,
                          cfg_err_posted_n,
                          cfg_err_tlp_cpl_header,
                          cfg_interrupt_n,
                          cfg_interrupt_rdy_n,
                          cfg_turnoff_ok_n,
                          cfg_to_turnoff_n,
                          cfg_bus_number,
                          cfg_device_number,
                          cfg_function_number,
                           cfg_status,
                          cfg_command,
                          cfg_dstatus,
                          cfg_dcommand,
                          cfg_lstatus,
                          cfg_lcommand,

                          cfg_pcie_link_state_n,
                          cfg_trn_pending_n,
                          cfg_pm_wake_n,
                    
                          trn_clk,
                          trn_reset_n
                    
                          );



input   [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]     cfg_do;
output  [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]     cfg_di;
output  [(`PCI_EXP_CFG_DATA_WIDTH/8 - 1):0]   cfg_byte_en_n;
output  [(`PCI_EXP_CFG_ADDR_WIDTH - 1):0]     cfg_dwaddr;
output                                        cfg_wr_en_n;
output                                        cfg_rd_en_n;
input                                         cfg_rd_wr_done_n;

output                                        cfg_err_cor_n;
output                                        cfg_err_ur_n;
output                                        cfg_err_ecrc_n;
output                                        cfg_err_cpl_timeout_n;
output                                        cfg_err_cpl_abort_n;
output                                        cfg_err_cpl_unexpect_n;
output                                        cfg_err_posted_n;  
output  [(`PCI_EXP_CFG_CPLHDR_WIDTH - 1):0]   cfg_err_tlp_cpl_header;
output                                        cfg_interrupt_n;
input                                         cfg_interrupt_rdy_n;
output                                        cfg_turnoff_ok_n;
input                                         cfg_to_turnoff_n;
output                                        cfg_pm_wake_n;
input    [(`PCI_EXP_CFG_BUSNUM_WIDTH - 1):0]  cfg_bus_number;
input    [(`PCI_EXP_CFG_DEVNUM_WIDTH - 1):0]  cfg_device_number;
input    [(`PCI_EXP_CFG_FUNNUM_WIDTH - 1):0]  cfg_function_number;
input   [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]      cfg_status;
input   [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]      cfg_command;
input   [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]      cfg_dstatus;
input   [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]      cfg_dcommand;
input   [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]      cfg_lstatus;
input   [(`PCI_EXP_CFG_CAP_WIDTH - 1):0]      cfg_lcommand;

input  [(`PCI_EXP_LNK_STATE_WIDTH - 1):0]     cfg_pcie_link_state_n;
output                                        cfg_trn_pending_n;

input                                         trn_clk;
input                                         trn_reset_n;

parameter                                     Tcq = 1;

reg  [(`PCI_EXP_CFG_DATA_WIDTH - 1):0]        cfg_di;
reg  [(`PCI_EXP_CFG_DATA_WIDTH/8 - 1):0]      cfg_byte_en_n;
reg  [(`PCI_EXP_CFG_ADDR_WIDTH - 1):0]        cfg_dwaddr;
reg                                           cfg_wr_en_n;
reg                                           cfg_rd_en_n;

reg                                           cfg_err_cor_n;
reg                                           cfg_err_ecrc_n;
reg                                           cfg_err_ur_n;
reg                                           cfg_err_cpl_timeout_n;
reg                                           cfg_err_cpl_abort_n;
reg                                           cfg_err_cpl_unexpect_n;
reg                                           cfg_err_posted_n;  
reg  [(`PCI_EXP_CFG_CPLHDR_WIDTH - 1):0]      cfg_err_tlp_cpl_header;
reg                                           cfg_interrupt_n;
reg                                           cfg_turnoff_ok_n;
reg                                           cfg_pm_wake_n;
reg                                           cfg_trn_pending_n;

initial begin

  cfg_err_cor_n <= 1'b1;
  cfg_err_ur_n <= 1'b1;
  cfg_err_ecrc_n <= 1'b1;
  cfg_err_cpl_timeout_n <= 1'b1;
  cfg_err_cpl_abort_n <= 1'b1;
  cfg_err_cpl_unexpect_n <= 1'b1;
  cfg_err_posted_n <= 1'b0;
  cfg_interrupt_n <= 1'b1;
  cfg_turnoff_ok_n <= 1'b1;

  cfg_dwaddr <= 0;
  cfg_err_tlp_cpl_header <= 0;

  cfg_di <= 0;
  cfg_byte_en_n <= 4'hf;
  cfg_wr_en_n <= 1;
  cfg_rd_en_n <= 1;

  cfg_pm_wake_n <= 1;
  cfg_trn_pending_n <= 1'b0;

end

/************************************************************
Task : TSK_READ_CFG_DW                
Description : Read Configuration Space DW
*************************************************************/

task TSK_READ_CFG_DW;

input   [31:0]   addr_;

begin           

  if (!trn_reset_n) begin
  
    $display("[%t] : trn_reset_n is asserted", $realtime);
    $finish(1); 
  
  end

  wait ( cfg_rd_wr_done_n == 1'b1)

  @(posedge trn_clk);
  cfg_dwaddr <= #(Tcq) addr_;
  cfg_wr_en_n <= #(Tcq) 1'b1;
  cfg_rd_en_n <= #(Tcq) 1'b0;

  $display("[%t] : Reading Cfg Addr [0x%h]", $realtime, addr_);
  $fdisplay(`BOARD.`XILINX_PCI_EXP_DOWNSTREAM_PORT_INST.com_usrapp.tx_file_ptr, 
            "\n[%t] : Local Configuration Read Access :", 
            $realtime);
                 
  @(posedge trn_clk); 
  #(Tcq);
  wait ( cfg_rd_wr_done_n == 1'b0)
  #(Tcq);
  
  $fdisplay(`BOARD.`XILINX_PCI_EXP_DOWNSTREAM_PORT_INST.com_usrapp.tx_file_ptr, 
            "\t\t\tCfg Addr [0x%h] -> Data [0x%h]\n", 
            {addr_,2'b00}, cfg_do);
  cfg_rd_en_n <= #(Tcq) 1'b1;
         
end

endtask // TSK_READ_CFG_DW;


endmodule // pci_exp_usrapp_cfg

