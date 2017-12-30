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
//  \   \         Application : Generated by Xilinx PCI Express Wizard
//  /   /         Filename    : pcie_clocking.v
// /___/   /\     Module      : pcie_clocking 
// \   \  /  \
//  \___\/\___\
//
//------------------------------------------------------------------------------

`timescale 1 ns / 10 ps


module pcie_clocking #
  ( parameter    G_USE_DCM     = 1,
    parameter    G_DIVIDE_VAL  = 2,  // use 2 or 4
    parameter    CLKFBOUT_MULT = 5,
    parameter    CLKIN_PERIOD  = 10
  )
  (
    input       clkin_pll,
    input       clkin_dcm,
    input       rst,
    
    output      coreclk,
    output      userclk,
    output      locked
  );
 

    wire        clkfbout;
    wire        clkfbin;
    wire        clkout0;
    wire        clkout1;
    
    wire        clk0;
    wire        clkfb;
    wire        clkdv;
    wire [15:0] not_connected;
    
    parameter G_DVIDED_VAL_PLL = G_DIVIDE_VAL*2;
   
   
    generate
       if (G_USE_DCM == 1 && G_DIVIDE_VAL == 1) 
        begin : use_bufg
            assign coreclk = clkin_dcm;
            assign userclk = clkin_dcm;
            assign locked = 1'b1;
        end
    endgenerate
    

    generate
    if (G_USE_DCM == 1 && G_DIVIDE_VAL > 1) 
        begin : use_dcm
   
    // Instantiate a DCM module to divide the reference clock.
        DCM #
        (
           .CLKDV_DIVIDE               (G_DIVIDE_VAL),
           .DFS_FREQUENCY_MODE         ("LOW"), 
           .DLL_FREQUENCY_MODE         ("HIGH")
        )
        dcm_i
        (
           .CLK0                       (clk0),
           .CLK180                     (not_connected[0]),
           .CLK270                     (not_connected[1]),
           .CLK2X                      (not_connected[2]),
           .CLK2X180                   (not_connected[3]),
           .CLK90                      (not_connected[4]),
           .CLKDV                      (clkdv),
           .CLKFX                      (not_connected[5]),
           .CLKFX180                   (not_connected[6]),
           .LOCKED                     (locked),
           .PSDONE                     (not_connected[7]),
           .STATUS                     (not_connected[15:8]),
           .CLKFB                      (clkfb),
           .CLKIN                      (clkin_dcm),
           .DSSEN                      (1'b0),
           .PSCLK                      (1'b0),
           .PSEN                       (1'b0),
           .PSINCDEC                   (1'b0),
           .RST                        (rst)
        );
        
        BUFG clkfb_dcm_bufg  (.O(clkfb),.I(clk0));   // 250 MHz
        BUFG usrclk_dcm_bufg (.O(userclk),.I(clkdv)); // 125 MHz 0r 62.5 Mhz
        
        assign coreclk = clkfb;
        
        end
    endgenerate


    generate
    if (G_USE_DCM == 0)     
        begin : use_pll
         // OR CALCULATED WAY (easier): must use bitgen -g plladv_xNyM_use_calc:Yes to enable this attribute
        // synthesis attribute CLKOUT1_DIVIDE pll1 "4";
        // synthesis attribute CLKOUT1_PHASE pll1 "0";
        // synthesis attribute CLKOUT1_DUTY_CYCLE pll1 "0.5";

        // synthesis attribute PLL_OPT_INV pll1 "001001";
        // synthesis attribute PLL_CP pll1 "2";
        // synthesis attribute PLL_RES pll1 "8";

           PLL_ADV #
           (
                .CLKFBOUT_MULT (CLKFBOUT_MULT),
                .CLKFBOUT_PHASE(0),
                
                .CLKIN1_PERIOD (CLKIN_PERIOD),
                .CLKIN2_PERIOD (CLKIN_PERIOD),
                
                .CLKOUT0_DIVIDE(2),
                .CLKOUT0_PHASE (0),
                
                .CLKOUT1_DIVIDE(G_DVIDED_VAL_PLL),
                .CLKOUT1_PHASE (0)
                
           )
           pll_adv_i
           
           (
            .CLKIN1(clkin_pll),
            .CLKINSEL(1'b1),
            .CLKFBIN(clkfbin),
            .RST(rst),
            .CLKOUT0(clkout0),
            .CLKOUT1(clkout1),
            .CLKFBOUT(clkfbout),
            .LOCKED(locked)
           );

        if (G_DIVIDE_VAL == 1) begin: userclk_250
            BUFG clkfbin_pll_bufg  (.O(clkfbin),    .I(clkfbout));
            BUFG coreclk_pll_bufg  (.O(coreclk),    .I(clkout0)); // 250 MHz

            assign userclk = coreclk;  // 125 MHz or 62.5 MHz
        end 
        else begin: userclk_not_250
            BUFG clkfbin_pll_bufg  (.O(clkfbin),    .I(clkfbout));
            BUFG coreclk_pll_bufg  (.O(coreclk),    .I(clkout0)); // 250 MHz
            BUFG usrclk_pll_bufg   (.O(userclk),    .I(clkout1)); // 125 MHz or 62.5 MHz
        end 
      end  
    endgenerate      

endmodule