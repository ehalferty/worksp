
//-- Copyright(C) 2005 by Xilinx, Inc. All rights reserved.
//-- This text contains proprietary, confidential
//-- information of Xilinx, Inc., is distributed
//-- under license from Xilinx, Inc., and may be used,
//-- copied and/or disclosed only pursuant to the terms
//-- of a valid license agreement with Xilinx, Inc. This copyright
//-- notice must be retained as part of this text at all times.

`include "board_common.v"
`include "xilinx_pci_exp_defines.v"

module `BOARD();

integer             i;

//
// System reset
//

reg                cor_sys_reset_n;

//
// System clock
//

wire               dsport_sys_clk_p;
wire               dsport_sys_clk_n;
wire               cor_sys_clk_p;
wire               cor_sys_clk_n;

//
// PCI-Express facric interface
//
wire  [`PCI_EXP_WIDTH - 1:0]  cor_pci_exp_txn;
wire  [`PCI_EXP_WIDTH - 1:0]  cor_pci_exp_txp;
wire  [`PCI_EXP_WIDTH - 1:0]  cor_pci_exp_rxn;
wire  [`PCI_EXP_WIDTH - 1:0]  cor_pci_exp_rxp;

defparam `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_ep .pcie_internal_1_1_swift_1.TEST_MODE = "1";

`ifdef BOARDx01
    defparam `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_gt_wrapper_i/GTPD[0].GTP_i .SIM_GTPRESET_SPEEDUP = 1;
`endif

`ifdef BOARDx04
    defparam `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_gt_wrapper_i/GTPD[0].GTP_i .SIM_GTPRESET_SPEEDUP = 1;
    defparam `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_gt_wrapper_i/GTPD[2].GTP_i .SIM_GTPRESET_SPEEDUP = 1;
`endif

`ifdef BOARDx08
  initial
  begin
    force `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_gt_wrapper_i/GTPD[4].GTP_i .SIM_RECEIVER_DETECT_PASS0_BINARY =1'b0; 
    force `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_gt_wrapper_i/GTPD[4].GTP_i .SIM_RECEIVER_DETECT_PASS1_BINARY =1'b0; 
    force `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_gt_wrapper_i/GTPD[6].GTP_i .SIM_RECEIVER_DETECT_PASS0_BINARY =1'b0; 
    force `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_gt_wrapper_i/GTPD[6].GTP_i .SIM_RECEIVER_DETECT_PASS1_BINARY =1'b0; 
  end
    defparam `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_gt_wrapper_i/GTPD[0].GTP_i .SIM_GTPRESET_SPEEDUP = 1;
    defparam `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_gt_wrapper_i/GTPD[2].GTP_i .SIM_GTPRESET_SPEEDUP = 1;
    defparam `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_gt_wrapper_i/GTPD[4].GTP_i .SIM_GTPRESET_SPEEDUP = 1;
    defparam `XILINX_PCI_EXP_EP.`PCI_EXP_EP_INST.\BU2/U0/pcie_ep0/pcie_blk/pcie_gt_wrapper_i/GTPD[6].GTP_i .SIM_GTPRESET_SPEEDUP = 1;
`endif


//
// PCI-Express End Point Instance
//
`XILINX_PCI_EXP_EP `XILINX_PCI_EXP_EP(  
        // SYS Inteface
        .sys_clk_p(cor_sys_clk_p),
        .sys_clk_n(cor_sys_clk_n),

        // PCI-Express Interface
        .pci_exp_txn(cor_pci_exp_txn),
        .pci_exp_txp(cor_pci_exp_txp),
  `ifdef BOARDx08
        .pci_exp_rxn({4'h0, cor_pci_exp_rxn}),
        .pci_exp_rxp({4'h0, cor_pci_exp_rxp}),
   `else 
        .pci_exp_rxn(cor_pci_exp_rxn),
        .pci_exp_rxp(cor_pci_exp_rxp),
  `endif    
        .sys_reset_n(cor_sys_reset_n)
        );


`XILINX_PCI_EXP_DOWNSTREAM_PORT `XILINX_PCI_EXP_DOWNSTREAM_PORT_INST (  

        // SYS Inteface
        .sys_clk_p(dsport_sys_clk_p),
        .sys_clk_n(dsport_sys_clk_n),
        .sys_reset_n(cor_sys_reset_n),

        // PCI-Express Interface
        .pci_exp_txn(cor_pci_exp_rxn),
        .pci_exp_txp(cor_pci_exp_rxp),
        .pci_exp_rxn(cor_pci_exp_txn),
        .pci_exp_rxp(cor_pci_exp_txp)
    
        );

  `SYS_CLK_GEN     `SYS_CLK_GEN_DSPORT (

          .sys_clk_p(dsport_sys_clk_p),
          .sys_clk_n(dsport_sys_clk_n)

          );

  defparam     `SYS_CLK_GEN_DSPORT.halfcycle = `SYS_CLK_DSPORT_HALF_CLK_PERIOD;
  defparam     `SYS_CLK_GEN_DSPORT.offset = 0;

  `SYS_CLK_GEN     `SYS_CLK_GEN_COR (

          .sys_clk_p(cor_sys_clk_p), 
          .sys_clk_n(cor_sys_clk_n)

          );

  defparam     `SYS_CLK_GEN_COR.halfcycle = `SYS_CLK_COR_HALF_CLK_PERIOD;
  defparam     `SYS_CLK_GEN_COR.offset = 0;

initial begin
  if ($test$plusargs ("dump_all")) begin
`ifdef NCV //Cadence TRN dump
    $recordsetup(
  `ifdef BOARDx01
                   "design=boardx01", 
  `endif
  `ifdef BOARDx04
                   "design=boardx04", 
  `endif
  `ifdef BOARDx08
                   "design=boardx08", 
  `endif

                   "compress", 
                   "wrapsize=1G", 
                   "version=1", 
                   "run=1");
    $recordvars();
`else
  `ifdef VCS //Synopsys VPD dump
    `ifdef BOARDx01
      $vcdplusfile("boardx01.vpd");
    `endif
    `ifdef BOARDx04
      $vcdplusfile("boardx04.vpd");
    `endif
    `ifdef BOARDx08
      $vcdplusfile("boardx08.vpd");
    `endif
    $vcdpluson;
    $vcdplusglitchon;
    $vcdplusflush;
  `else 
    // VCD dump
    `ifdef BOARDx01
      $dumpfile("boardx01.dump");
    `endif
    `ifdef BOARDx04
      $dumpfile("boardx04.dump");
    `endif
    `ifdef BOARDx08
      $dumpfile("boardx08.dump");
    `endif

    $dumpvars(0, `BOARD);
  `endif
`endif
  end

  $display("[%t] : System Reset Asserted...", $realtime);
  cor_sys_reset_n = 1'b0;

         for (i = 0; i < 500; i = i + 1) begin

                 @(posedge cor_sys_clk_p);

         end

  $display("[%t] : System Reset De-asserted...", $realtime);

         cor_sys_reset_n = 1'b1;

end

endmodule // BOARD
