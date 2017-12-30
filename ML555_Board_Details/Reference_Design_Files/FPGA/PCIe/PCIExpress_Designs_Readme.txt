This directory contains PCI Express designs for the ML555 board generated using 
the Xilinx CORE Generator tool Release Version 9.1i. Please refer to Xilinx Answer 
Record 9785 for more information on installing the applicable software to target 
the Endpoint Block for PCI Express.

     http://www.xilinx.com/xlnx/xil_ans_display.jsp?getPagePath=9795

These are the latest IP Updates available for the Virtex-5 LXT FPGA designs as of 
March 2007. Please note that Xilinx implementation tools and IP cores change
over time and please consult the Xilinx website for current ISE software releases
and IP updates. If you have any questions please contact the Xilinx hotline for 
technical support.

Xilinx offers two different LogiCORE Endpoint IP solutions for PCI Express to help
you configure the built-in low power Endpoint Block for PCI Express in the Virtex-5 
LXT FPGA device on the ML555 board: 

(1) LogiCORE Endpoint Block for PCI Express.
(2) LogiCORE Endpoint Block Plus for PCI Express. 

Please go to http://www.xilinx.com/pciexpress to learn more about these two solutions.
Please unzip: BitFiles.zip to create the following directory structure referenced in
the discussion below

|-BitFiles
	|- LogiCORE_Endpoint_Block_Plus_v1.2
	|- LogiCORE_Endpoint_Block_v1.3

The directory "LogiCORE_Endpoint_Block_Plus_v1.2" contains three 
subdirectories.

  "pcie_endpoint_plus_4lane_pio" is a 4 lane PCI Express Endpoint design directory.  
  This directory contains all files required to implement a 4 lane Programmed I/O design 
  on the ML555 board. This is the top level directory created by the Core Generator tool. 
  The design uses the CoreGen defaults, 100MHz REFCLK, 4 lane design, with a 32-bit 
  non-prefetctable memory BAR.


  "pcie_endpoint_plus_8lane_pio" is a 8 lane PCI Express Endpoint design directory. 
  This directory contains all files required to implement a 8 lane Programmed I/O design
  on the ML555 board. This is the top level directory created by the Core Generator tool. 
  The design uses the CoreGen defaults, 100MHz REFCLK, 8 lane design, with a 32-bit 
  non-prefecthable memory BAR.


  "ML555_Bitfiles" directory contains two BIT files that can be downloaded onto the 
  ML555 board. These designs use the default 100MHz PCIE_REFCLK input to the ML555 board 
  to GTP X0Y2. Both designs are based upon the Programmed I/O design and contain a 32-bit 
  non-prefetchable Memory BAR in Base Address Register 0. Both designs have been verified
  on the ML555 board. USER_LED0 will be illuminated for a 4 lane negotiated link, 
  USER_LED1 will be illuminated for an 8 lane negotiated link, and USER_LED2 will be 
  illuminated when the PCI Express link is active on the ML555. 

  There is a MCS and CFI file that can be used to load one of the two Platform Flash 
  configuration devices on the ML555 board. When configuring the Platform Flash devices 
  using the Xilinx Impact softare, both the MCS and CFI file must be used (failure to 
  use the CFI file may result in only one of the two design revisions in the MCS file
  being programmed into the configuration memory).



The directory "LogiCORE_Endpoint_Block_v1.3" contains three subdirectories.

  "pcie_endpoint_4lane_memory_completer" is a 4 lane PCI Express Endpoint design.  
  This directory in turn contains all files required to implement a 4 lane memory 
  completer endpoint design on the ML555 board. This is the top level directory created 
  by the Core Generator tool. The design uses the CoreGen defaults, 100MHz REFCLK,
  4 lane design, with a 64-bit prefetchable memory BAR0/1.


  "pcie_endpoint_8lane_memory_completer" is a 8 lane PCI Express Endpoint design. 
  This directory in turn contains all files required to implement a 8 lane design 
  on the ML555 board. This is the top level directory created by the Core Generator 
  tool. The design uses the CoreGen defaults, 100MHz REFCLK, 8 lane design, with a
  64-bit prefetchable memory BAR0/1.

  "ML555_Bitfiles" directory contains two BIT files that can be downloaded onto the
  ML555 board. These designs use the default 100MHz PCIE_REFCLK input to the ML555 board
  to GTP X0Y2. Both designs are based upon the memory completer design and contain a 
  64-bit prefetchable Memory BAR in Base Address Register 0 and 1. Both designs have 
  been verified on the ML555 board. USER_LED0 will be illuminated for a 4 lane negotiated
  link, USER_LED1 will be illuminated for an 8 lane negotiated link, and USER_LED2 will 
  be illuminated when the PCI Express link is active on the ML555. 

  There is a MCS and CFI file that can be used to load one of the two Platform Flash 
  configuration devices on the ML555 board. When configuring the Platform Flash devices 
  using the Xilinx Impact softare, both the MCS and CFI file must be used (failure to 
  use the CFI file may result in only one of the two design revisions in the MCS file
  being programmed into the configuration memory).

Xilinx developed a set of reference designs / labs / demonstrations for the ML555. These
documents are provided as a resource to help you get a jump start with the ML555 and 
LogiCORE Endpoint IP solutions for Virtex-5 LXT FPGA designs. Please see the "Reference
Design section" at
			www.xilinx.com/v5pciekit

If you have any questions on getting started with the ML555 or the LogiCORE designs, 
please contact your local Field Application Engineer and/or the Xilinx Technical Support
hotline.




