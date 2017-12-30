//*******************************************************************************
//
//  File name :    top_ml555_CPLD_250MHz_PCIECLK.v
//
//  Description :  This module is the top level for the CPLD on the ML555 board. 
//                 This design selects 250MHz PCIe REFCLK from ICS874003-02
//                 
//  Date - revision : May 13, 2006       ( ML555 support for LX50T and LX110T )
//                    August 11, 2006    ( Slave SelectMAP fix )              
//                    September 12, 2006 ( ICS874003-02 control )
//                    September 25, 2006 ( Change selection on ICS to 250MHz)
//
//                    January 4, 2007    ( By default ICS874003-02 is not installed
//                                         on ML555 boards. PCIE_REFCLK is always
//                                         100MHz clock from system board)
//
//  Contact : e-mail  hotline@xilinx.com
//            phone   + 1 800 255 7778 
//
//  Disclaimer: LIMITED WARRANTY AND DISCLAMER. These designs are provided to 
//              you "as is". Xilinx and its licensors make and you receive 
//              no warranties or conditions, express, implied, statutory  
//              or otherwise, and Xilinx specifically disclaims any implied
//              warranties of merchantability, non-infringement, or fitness
//              for a particular purpose. Xilinx does not warrant that the 
//              functions contained in these designs will meet your requirements,
//              or that the operation of these designs will be uninterrupted 
//              or error free, or that defects in the Designs will be corrected. 
//              Furthermore, Xilinx does not warrant or make any representations 
//              regarding use or the results of the use of the designs in terms 
//              of correctness, accuracy, reliability, or otherwise. 
//
//              LIMITATION OF LIABILITY. In no event will Xilinx or its 
//              licensors be liable for any loss of data, lost profits, cost 
//              or procurement of substitute goods or services, or for any 
//              special, incidental, consequential, or indirect damages 
//              arising from the use or operation of the designs or 
//              accompanying documentation, however caused and on any theory 
//              of liability. This limitation will apply even if Xilinx 
//              has been advised of the possibility of such damage. This 
//              limitation shall apply not-withstanding the failure of the 
//              essential purpose of any limited remedies herein. 
//
//  Copyright © 2006, 2007 Xilinx, Inc.
//  All rights reserved 
// 
//*****************************************************************************

`timescale 1ns/100ps

module top( FLASH_IMAGE0_SELECT, FLASH_IMAGE1_SELECT, MAN_AUTO, PROG_SW_B, 
            PB_SW_B, FPGA_BUSY_B, FPGA_DONE, FLASH_SEL, INIT_B, PROG_B, 
		      FLASH_OE_RESET_B, FLASH_CF_B, FLASH_CE_B, FLASH_CE1_B, 
		      BUSY_TO_FLASH_B, FPGA_CS_B, FPGA_RDWR_B,
            ICS_FSEL0, ICS_FSEL1, ICS_FSEL2, ICS_MR, ICS_OEA
           );

 input  FLASH_IMAGE0_SELECT;
 input  FLASH_IMAGE1_SELECT;
 input  MAN_AUTO;
 input  PROG_SW_B;
 input  PB_SW_B;
 input  FPGA_BUSY_B;
 input  FPGA_DONE;
 input  INIT_B;       


 output  [1:0] FLASH_SEL;	 
 output  PROG_B;
 output  FLASH_OE_RESET_B;
 output  FLASH_CF_B;
 output  FLASH_CE_B;
 output  FLASH_CE1_B;
 output  BUSY_TO_FLASH_B;
 output  FPGA_CS_B;
 output  FPGA_RDWR_B;

// Add outputs to control ICS874003-02 PCI Express Jitter Attentuator 
// Default selection to 250MHz PCI Express Reference Clock for V5 GTP

 output  ICS_FSEL0;
 output  ICS_FSEL1;
 output  ICS_FSEL2;
 output  ICS_MR;
 output  ICS_OEA;

/////////////////////////////////////////////////////////////////////////////////
//
//  Design to support multiple design images on the ML555 Board
//
//  Two Platform Flash XCF32P 32Mbit configuration devices on ML555.
//    A. 2 XC5VLX50T designs image in one PF device (4 total)
//    B. 1 XC5VLX110T design image in one PF device (2 total)
//  
//  Three inputs from board header P3 to determine manual selection of image:
//  Four outputs to the Platform Flash devices
//
//  <<====== INPUTS =======================>|<===== OUTPUTS ===========> 
//  MAN_AUTO  FLASH_IMG1_SEL  FLASH_IMG0_SEL  CE0* CE1* PF_SEL1 PF_SEL0
//  P3-5,6       P3-3,4          P3-1,2
//     0           0               0           0    1     0       0  
//     0           0               1           0    1     0       1  
//     0           1               0           1    0     0       0  
//     0           1               1           1    0     0       1  
//----------------------------------------------------------------------
//     1           0               0           0    1     0       0  
//     1           0               1           0    1     0       0  
//     1           1               0           1    0     0       0  
//     1           1               1           1    0     0       0  
//
//  For XC5VLX50T  MAN_AUTO INSTALL shunt on P3 pins 5-6
//  For XC5VLX110T MAN_AUTO REMOVE  shunt on P3 pins 5-6
 
 assign FLASH_SEL[0]  =  MAN_AUTO ? 1'b0 : FLASH_IMAGE0_SELECT;
 assign FLASH_SEL[1]  =  1'b0 ;  
 assign FLASH_CE_B    =  FLASH_IMAGE1_SELECT ? 1'b1 : FPGA_DONE ;
 assign FLASH_CE1_B   =  FLASH_IMAGE1_SELECT ? FPGA_DONE : 1'b1 ;
 
// Route Pushbutton SW7 to FPGA INIT_B and PlatformFlash FLASH_OE_RESET_B inputs
 assign FLASH_OE_RESET_B = INIT_B;    //ST 8:11:2006
 
// Connect Flash and FPGA BUSY ports together
 assign BUSY_TO_FLASH_B  = FPGA_BUSY_B;
 
// Route PROG_SW_B pushbutton SW6 to PlatformFlash and FPGA inputs
 assign PROG_B       = PROG_SW_B ;
 assign FLASH_CF_B   = PROG_SW_B ;
 
 // Configure FPGA SelectMAP databus as inputs
 assign FPGA_CS_B    = 1'b0 ;
 assign FPGA_RDWR_B  = 1'b0 ;



/////////////////////////////////////////////////////////////////////////////////////////////////
// New function 9/12/2006
// Add ICS874003-02 control logic. 
// Create 250MHz PCIe REFCLK for FPGA transceivers from incoming 100MHz spread spectrum clock 
// received from system board on PCIe connector pins P13-A13 and P13-A14.
// Note: FPGA interface CPLD_SPARE(3:1) not used to dynamically control ICS874003-02 frequency
/////////////////////////////////////////////////////////////////////////////////////////////////
//
// FSEL2     FSEL1     FSEL0   |  QA/QAn LVDS OUTPUT FREQUENCY TO GPT MGT_REFCLK
//-----------------------------|------------------------------------------------------------------
//   0         0         0     |   250MHz (/2)
//   1         0         0     |   100MHz (/5)
//   0         1         0     |   125MHz (/4)
//   1         1         0     |   250MHz (/2)
//   0         0         1     |   250MHz (/2)
//   1         0         1     |   100MHz (/5)
//   0         1         1     |   125MHz (/4)
//   1         1         1     |   125MHz (/4)
//////////////////////////////////////////////////////////////////////////////////////////////////

 assign  ICS_FSEL0   =  1'b0;
 assign  ICS_FSEL1   =  1'b0;
 assign  ICS_FSEL2   =  1'b0;
 assign  ICS_MR      =  1'b0;  // deassert master reset input 
 assign  ICS_OEA     =  1'b1;  // enable ICS clock synthesis A LVDS outputs (with 250MHz PCIe REFCLK generation)



endmodule
