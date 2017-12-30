PCI and PCIX designs for ML555

These designs are out-of-the-box demonstrations of the PCI/PCI-X parallel bus interface and are preloaded on 
Platform Flash U15.



The following files are included in this directory

|- BitFiles
	|-pci32_v4_1_ml555.bit (V4.1 PCI LogiCore 32-bit 33MHz PCI example design bitfile for XC5VLX50T-FF1136-1)
	|
	|-pcix_v6_1_ml555.bit  (V6.1 PCI/PCI-X LogiCore 64-bit PCI-X example design bitfile for XC5VLX50T-FF1136-1)
	|
	|-ML555_PCI_PCIX.mcs   (PROM file for Platform Flash XCF32P - includes the above 2 designs; ML-555 
	|                       Platform Flash (U15) comes preloaded with this file)
	|
	|-ML555_PCI_PCIX.cfi/prm/sig (PROM information files - describes PROM format for ML555_PCI_PCIX.mcs)


The included PCI and PCI-X bitstreams are example implementations of the PCI32 v4.1 and PCI-X v6.1 LogiCores.  
In these example implementations, the cores are configured to provide one IO BAR and one memory BAR.  
The example application on the user interface in these PCI implementations is the same as that provided 
with the cores: a simple 1-dword register behind the IO BAR, and a 16-dword memory behind the memory BAR.

To use the provided PCI/PCI-X example implementations:

  1. Configure the PCI and PCI-X jumpers P8 and P9:
     
     a. For PCI mode:
        Shunt ON pins 2-3 of P8
        SHUNT ON P9

     b. For PCI-X mode:
        Remove shunts on both P8 for 133 MHz (P9 has no effect)
     
     For more information on these headers please see UG201

  2. Load the bitstream onto the ML-555 FPGA: 

     a. To Load from the PLATFORM FLASH:
        Set the following shunts on Header P3 to select the bitstream that is loaded from the PF:

        MAN_AUTO       FLASH_IMAGE1_SEL          FLASH_IMAGE2_SEL     DESIGN LOADED
	PINs 5-6       PINs 2-3                  PINs 1-2        
 
        SHUNT ON       SHUNT OFF                 SHUNT ON             pci32_v4_1_ml555.bit

	SHUNT ON       SHUNT OFF                 SHUNT OFF            pcix_v6_1_ml555.bit


  3. Boot the host computer 
     
  4. The host BIOS will configure the PCI core in the design 

     NOTE: If a PCI or PCI-X design is loaded from a JTAG programming cable, the system unit must be re-booted WITHOUT
           power-cycling the ML-555 in order for step 3 to execute correctly

  5. Use the PCI bust test software included on the CD to verify that the PCI device was configured properly: 
     Jungo's WinDriver or PCITree (available for free on http://pcitree.de/) may be used as test software

  6. Look for a PCI device with a VendorID of 0X10EE (Xilinx's Vendor ID)

  7. Use the Memory/IO write/read feature to write and read the IO BAR and the memory BAR 
 

To find out more about the PCI LogiCores provided by Xilinx, please visit http://www.xilinx.com/pci


  

