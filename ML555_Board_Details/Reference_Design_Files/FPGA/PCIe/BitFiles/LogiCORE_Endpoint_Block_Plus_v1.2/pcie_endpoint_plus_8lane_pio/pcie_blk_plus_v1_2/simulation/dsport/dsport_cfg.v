
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
//-- Filename: dsport_cfg.v
//--                    
//-- Description:  PCI Express Endpoint Core Configuration File
//--                    
//--                    
//------------------------------------------------------------------------------

/**********************************************************************
  ** Note 1:
  Base Address Registers (BARs) settings contained in this file 
  are for demonstration purposes only. Users must review and change 
  these to suite their particular application.

  ** Note 2:
  Users may change setting values of the Read Only Capability
  registers to suite their application, but any change must comply
  with PCI Express Base Specification v1.1
 
  ** Note 3:
  Two PLM Autoconfigure setting (cfg[507:506]) must be set to 2'b00, 
  when interfacing the Endpoint Core with a PCIe compliant 
  Downstream Port. 

  ** Note 4:
  Values assigned to Reserved bits should not be changed.
***********************************************************************/

// Declare the module.

module dsport_cfg (cfg);


  // Declare the port directions.

  output [1023:0] cfg;


  //***********************************************************//
  // Configuration bit setting information.                    // 
  //***********************************************************//
  //                                                           //
  // vendor id                      cfg[ 15:  0]               // 
  // device id                      cfg[ 31: 16]               // 
  // revision id                    cfg[ 39: 32]               // 
  // class code                     cfg[ 63: 40]               // 
  // base address                   cfg[ 95: 64]               // 
  // base address                   cfg[127: 96]               // 
  // base address                   cfg[159:128]               // 
  // base address                   cfg[191:160]               // 
  // base address                   cfg[223:192]               // 
  // base address                   cfg[255:224]               // 
  // cardbus cis pointer            cfg[287:256]               // 
  // subsystem vendor id            cfg[303:288]               // 
  // subsystem id                   cfg[319:304]               // 
  // expansion rom bar              cfg[351:320]               // 
  //                                                           //
  //***********************************************************//


  // Vendor Identification.
  assign cfg[ 15:  0] = 16'h10ee;

  // Device Identification.
  assign cfg[ 31: 16] = 16'h0007;

  // Revision Identification.
  assign cfg[ 39: 32] = 8'h00;

  // Class Code.
  assign cfg[ 63: 40] = 24'h00_00_00;
 
  // BAR0. IO BAR 64KB aperture
  assign cfg[ 95: 64] = 32'hffff_0001;
 
  // BAR1. Mem 32 bit BAR 64KB aperture
  assign cfg[127: 96] = 32'hffff_0000;
 
  // BAR2. 
  assign cfg[159:128] = 32'hffff_0004;
 
  // BAR3. Mem 64 bit BAR 1MB BAR {BAR3,BAR2}
  assign cfg[191:160] = 32'hffff_ffff;
 
  // BAR4. 
  assign cfg[223:192] = 32'h0000_0000;
 
  // BAR5. 
  assign cfg[255:224] = 32'h0000_0000;
 
  // Cardbus CIS Pointer.
  assign cfg[287:256] = 32'h0000_0000;

  // Subvendor Identification.
  assign cfg[303:288] = 16'h10ee;

  // Subsystem Identification.
  assign cfg[319:304] = 16'h0007;

  // Expansion ROM BAR. Mem 32 bit BAR 4KB aperture
  assign cfg[351:320] = 32'hffff_f001;
 

  //***********************************************************//
  // Configuration bit setting information.                    // 
  //***********************************************************//
  //                                                           //
  // express capabilities           cfg[367:352]               // 
  // express device capabilities    cfg[399:368]               // 
  // express link capabilities      cfg[431:400]               // 
  // express ack timeout setting    cfg[447:432]               //
  // express replay timer setting   cfg[463:448]               //
  //                                                           //
  //***********************************************************//


  // Express Capabilities (byte offset 03H-02H).
  // -----------------------------------------------------------
  // RsvdP              | cfg[367:366] |       |            00 |
  // -----------------------------------------------------------
  // Interrupt Msg No.  | cfg[365:361] |       |         00000 |
  // -----------------------------------------------------------
  // Slot Implemented   | cfg[360:360] |       |             0 |
  // -----------------------------------------------------------
  // Dev/Port Type      | cfg[359:356] |       |          0000 |
  // -----------------------------------------------------------
  // Capability Version | cfg[355:352] |       |          0001 |
  // -----------------------------------------------------------

  assign cfg[367:352] = 16'h0001;

  // Express Device Capabilities (byte offset 07H-04H).
  // -----------------------------------------------------------
  // RsvdP              | cfg[399:396] |       |          0000 |
  // -----------------------------------------------------------
  // Capt Slt Pwr Lim Sc| cfg[395:394] |       |            00 |
  // -----------------------------------------------------------
  // Capt Slt Pwr Lim Va| cfg[393:386] |       |      00000000 |
  // -----------------------------------------------------------
  // RsvdP              | cfg[385:384] |       |            00 |
  // -----------------------------------------------------------
  // Role based error   | cfg[383]             |             1 |
  // -----------------------------------------------------------
  // Power Indi Prsnt   | cfg[382:382] |       |             0 |
  // -----------------------------------------------------------
  // Attn Indi Prsnt    | cfg[381:381] |       |             0 |
  // -----------------------------------------------------------
  // Attn Butn Prsnt    | cfg[380:380] |       |             0 |
  // -----------------------------------------------------------
  // EP L1 Accpt Lat    | cfg[379:377] |       |           111 |
  // -----------------------------------------------------------
  // EP L0s Accpt Lat   | cfg[376:374] |       |           111 |
  // -----------------------------------------------------------
  // Ext Tag Fld Sup    | cfg[373:373] |       |             0 |
  // -----------------------------------------------------------
  // Phantm Func Sup    | cfg[372:371] |       |            00 |
  // -----------------------------------------------------------
  // Max Payload Size   | cfg[370:368] | (x1)  |           010 |
  // Max Payload Size   | cfg[370:368] | (x4)  |           010 |
  // Max Payload Size   | cfg[370:368] | (x8)  |           001 |
  // -----------------------------------------------------------

`ifdef  BOARDx08

  assign cfg[399:368] = 32'h00008FC1;

`else // BOARDx04 or BOARDx01

`ifdef BOARDx04

  assign cfg[399:368] = 32'h00008FC2;

`else  // must be BOARDx01 

  assign cfg[399:368] = 32'h00008FC2;

`endif // BOARDx04

`endif // BOARDx08

  // Express Link Capabilities (byte offset 00H && 0CH-0FH).
  // -----------------------------------------------------------
  // PCI Express Cap ID | cfg[431:424] |       |      00010000 |
  // -----------------------------------------------------------
  // -----------------------------------------------------------
  // RsvdP              | cfg[423:418] |       |        000000 |
  // -----------------------------------------------------------
  // L1 Exit Lat        | cfg[417:415] |       |           111 |
  // -----------------------------------------------------------
  // L0s Exit Lat       | cfg[414:412] |       |           111 |
  // -----------------------------------------------------------
  // ASPM Supported     | cfg[411:410] |       |            01 |
  // -----------------------------------------------------------
  // Max Link Width     | cfg[409:404] | (x1)  |        000001 |
  // Max Link Width     | cfg[409:404] | (x4)  |        000100 |
  // Max Link Width     | cfg[409:404] | (x8)  |        001000 |
  // -----------------------------------------------------------
  // Max Link Speed     | cfg[403:400] |       |          0001 |
  // -----------------------------------------------------------

`ifdef  BOARDx08

  assign cfg[431:400] = 32'h1003F481;

`else // BOARDx04 or BOARDx01

`ifdef BOARDx04

  assign cfg[431:400] = 32'h1003F441;

`else  // must be BOARDx01 

  assign cfg[431:400] = 32'h1003F411;

`endif // BOARDx04

`endif // BOARDx08

  // Express User Ack Timeout override
  // -----------------------------------------------------------
  // Ack Timeout Override | cfg[447]   |       |              0 |
  // -----------------------------------------------------------
  // Ack Timout Value   | cfg[446:432] |       |           0204 |
  // -----------------------------------------------------------

  assign cfg[447] = 1'b0;
  assign cfg[446:432] = 15'h0204;

  // Express User Replay Timeout override
  // -----------------------------------------------------------
  // Replay Timeout Override | cfg[463] |       |             1 |
  // -----------------------------------------------------------
  // Replay Timout Value   | cfg[462:448] |       |        060d |
  // -----------------------------------------------------------

  assign cfg[463] = 1'b1;
  assign cfg[462:448] = 15'h060d;

  //***********************************************************//
  // Configuration bit setting information.                    // 
  //***********************************************************//
  //                                                           //
  // Reserved 			            cfg[501:464]               // 
  // PCI Config Space               cfg[502]                   // 
  // Extended Config Space          cfg[503]                   // 
  // Slot Clock Configure           cfg[504]                   // 
  // Two PLM Autoconfigure          cfg[506:505]               //
  // Fast train simulation          cfg[507]                   //
  // Trim TLP Digest ECRC           cfg[508]                   //
  // swap_ab_pairs                  cfg[509]                   //
  // Force Noscramble               cfg[510]                   //
  // calibration_block disable      cfg[511]                   //
  //***********************************************************//

  // Reserved
  assign cfg[501:464] = 36'b0;

  // PCI Configuration Space Access
  assign cfg[502] = 1'b0;

  // Extended Configuration Space Access
  assign cfg[503] = 1'b0;

  // Slot Clock Configure
  assign cfg[504] = 1'b1;

  // Two PLM Autoconfigure
  assign cfg[506:505]= 2'b00;

  // fast train simulation          
`ifdef SIMULATION
  assign cfg[507] = 1'b1;
`else
  `ifdef SIM_USERTB
    assign cfg[507] = 1'b1;
  `else
    assign cfg[507] = 1'b0;
  `endif
`endif

  // Trim TLP Digest ECRC.
  assign cfg[508] = 1'b0;

  // swap A-B pairs          
  assign cfg[509] = 1'b0;

  // Force No Scrambling.
  assign cfg[510] = 1'b0;

  // calibration block enable        
  assign cfg[511] = 1'b0;

  //***********************************************************//
  // Power Management Capabilities Register                    //
  // (byte offset 03-02H).                                     //
  // Section 3.2.3 PCI Bus PM Interface Specification v1.2     //
  // -----------------------------------------------------------
  // PME Support        | cfg[527:523] |       |         01111 | 
  //                    |              |                       |
  //                    |              |  D3cold = 1'b0        |
  //                    |              |  D3hot  = 1'b1        |
  //                    |              |  D2     = 1'b1        |
  //                    |              |  D1     = 1'b1        |
  //                    |              |  D0     = 1'b1        |
  // -----------------------------------------------------------
  // D2 Support         | cfg[522:522] |       |             1 |
  // -----------------------------------------------------------
  // D1 Support         | cfg[521:521] |       |             1 |
  // -----------------------------------------------------------
  // AUX Current        | cfg[520:518] |       |           000 |
  // -----------------------------------------------------------
  // DSI                | cfg[517:517] |       |             0 |
  // -----------------------------------------------------------
  // Reserved           | cfg[516:516] |       |             0 |
  // -----------------------------------------------------------
  // PME Clock          | cfg[515:515] |       |             0 |
  // -----------------------------------------------------------
  // Version            | cfg[514:512] |       |           010 |
  // -----------------------------------------------------------

  assign cfg[527:512] = 16'h7E03; 

  // -----------------------------------------------------------
  // Power consumed in D0 state.                              // 
  // -----------------------------------------------------------

  assign cfg[535:528] = 8'h01; 

  // -----------------------------------------------------------
  // Scale Factor for power consumed in D0 state.             // 
  // Actual power consumed in D0 state :=                     //
  // Power consumed in D0 state * Scale Factor                // 
  // -----------------------------------------------------------

  assign cfg[543:536] = 8'h01; 

  // -----------------------------------------------------------
  // Power consumed in D1 state.                              // 
  // -----------------------------------------------------------

  assign cfg[551:544] = 8'h01; 

  // -----------------------------------------------------------
  // Scale Factor for power consumed in D1 state.             //
  // Actual power consumed in D1 state :=                     //
  // Power consumed in D1 state * Scale Factor                //     
  // -----------------------------------------------------------

  assign cfg[559:552] = 8'h01; 

  // -----------------------------------------------------------
  // Power Consumed in D2 state.                              // 
  // -----------------------------------------------------------

  assign cfg[567:560] = 8'h01; 

  // -----------------------------------------------------------
  // Scale Factor for power consumed in D2 state.             // 
  // Actual power consumed in D2 state :=                     // 
  // Power consumed in D2 state * Scale Factor                // 
  // -----------------------------------------------------------

  assign cfg[575:568] = 8'h01; 

  // -----------------------------------------------------------
  // Power Consumed in D3 state                               // 
  // -----------------------------------------------------------

  assign cfg[583:576] = 8'h01; 

  // -----------------------------------------------------------
  // Scale Factor for power consumed in D3 state.             // 
  // Actual power consumed in D3 state :=                     // 
  // Power consumed in D2 state * Scale Factor                // 
  // -----------------------------------------------------------

  assign cfg[591:584] = 8'h01; 

  // -----------------------------------------------------------
  // Power Dissipated in D0 state.                            // 
  // -----------------------------------------------------------

  assign cfg[599:592] = 8'h01; 

  // -----------------------------------------------------------
  // Scale Factor for power dissipated in D0 state.           //
  // Actual power dissipated in D0 state :=                   //
  // Power dissipated in D0 state * Scale Factor              //
  // -----------------------------------------------------------

   assign cfg[607:600] = 8'h01; 

  // -----------------------------------------------------------
  // Power Dissipated in D1 state.                            //
  // -----------------------------------------------------------

  assign cfg[615:608] = 8'h01; 

  // -----------------------------------------------------------
  // Scale Factor for power dissipated in D1 state.           //
  // Actual power dissipated in D1 state :=                   //
  // Power dissipated in D1 state * Scale Factor              //   
  // -----------------------------------------------------------

  assign cfg[623:616] = 8'h01; 

  // -----------------------------------------------------------
  // Power Dissipated in D2 state.                            //
  // -----------------------------------------------------------

  assign cfg[631:624] = 8'h01; 

  // -----------------------------------------------------------
  // Scale Factor for power dissipated in D2 state.           //
  // Actual power dissipated in D2 state :=                   //
  // Power dissipated in D2 state * Scale Factor              // 
  // -----------------------------------------------------------

  assign cfg[639:632] = 8'h01; 

  // -----------------------------------------------------------
  // Power Dissipated in D3 state.                            //
  // -----------------------------------------------------------

  assign cfg[647:640] = 8'h01; 

  // -----------------------------------------------------------
  // Scale Factor for power dissipated in D3 state.           //
  // Actual power dissipated in D3 state :=                   //
  // Power dissipated in D3 state * Scale Factor              // 
  // -----------------------------------------------------------

  assign cfg[655:648] = 8'h01; 

  //***********************************************************//
  // Device Serial Number Capabilities Serial Number Registers //
  // Section 7.12 PCI Express Base Specification v1.1          //
  //***********************************************************//
 
  // EUI-64 1st DW
  assign cfg[687:656] = 32'h0;

  // EUI-64 2nd DW
  assign cfg[719:688] = 32'h0;

  // RESERVED FOR FUTURE USE 
  assign cfg[1023:720] = 0;

endmodule
