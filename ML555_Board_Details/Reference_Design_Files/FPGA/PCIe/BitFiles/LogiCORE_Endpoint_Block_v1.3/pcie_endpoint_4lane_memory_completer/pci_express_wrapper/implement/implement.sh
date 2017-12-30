#!/bin/csh -f

echo ""
echo ""
echo ""

set cmd = $0
set cmd = $cmd:t

set number_of_lanes = 4
set part = lx50t
set fullpart = xc5vlx50t-1-ff1136
set speed = -1
set user_clk_freq = 125
set user_clk_per = 8

#------------------------------------------------------------------------------
# Handle -h (help) options.
#------------------------------------------------------------------------------

while ($#argv > 0) 
  set arg1 = $argv[1]

  switch ($arg1)
    case "-h"
        shift argv
        set display_usage = 1
    breaksw

    case "-help"
        shift argv
        set display_usage = 1
    breaksw

#------------------------------------------------------------------------------
# Handle -board (board used, either ML523 or ML555) options.
#------------------------------------------------------------------------------

    case "-board"
        shift argv
        if ($#argv > 0) then
            set board = $argv[1]
            shift argv
        else
            echo "   Please provide board name:  -board <ML523 or ML555 or ML525>]"
            echo ""
            exit 0
        endif
    breaksw

    default:
      shift argv
      echo "Error: Unknown command line switch" 
      set display_usage = 1
    endsw
end

#------------------------------------------------------------------------------
# Handle -h (Usage help)
#------------------------------------------------------------------------------
if ($?display_usage) then
    echo ""
    echo "Usage:"
    echo ""
    echo "  $cmd [-h]"
    echo "    or"
    echo "  $cmd [-board <ML523 or ML555 or ML525>]"
    echo ""
    echo "Options:"
    echo ""
    echo "  -h          -- display help (usage)"
    echo "  -board      -- Type of board used in design, either ML523 or ML555"
    echo ""
    exit
endif

#------------------------------------------------------------------------------
# Check that the -board argument is valid.
#------------------------------------------------------------------------------

if (! $?board) then
   echo "  Board name unspecified.  Use default ml555"
   set board = ml555
endif

if ($board == ML555) then
    set board = ml555
  endif
endif 

if ($board == ML523) then
  set board = ml523
endif 

if ($board == ML525) then
  set board = ml525
endif

if !($board == ml523 || $board == ml555 || $board == ml525) then
  if ($dev == 1) then
    echo ""
    echo "Error:  Unknown board type.  Please specify either ml523 or ml555 or ml525"
    echo ""
    exit 0
  else
    echo ""
    echo "Error:  Unknown board type.  Defaulting to ml555."
    echo ""
    set board = ml555
  endif  
endif

#------------------------------------------------------------------------------
# Clean up old files
#------------------------------------------------------------------------------

if (-e mem_ep_app_top.prj) then
    rm mem_ep_app_top.prj
endif

#------------------------------------------------------------------------------
# User-specified wrapper name (passed through Coregen)
#------------------------------------------------------------------------------
  set coregen_name = pci_express_wrapper

#------------------------------------------------------------------------------
# Set names for UCF, results directory, and bit file
#------------------------------------------------------------------------------
set ucf_filename = mem_ep_app_$number_of_lanes\_$board\_$part.ucf
set results_dir = results_x$number_of_lanes\_$board\_$part
set bit_filename = mem_ep_app_top_x$number_of_lanes\_$board\_$part

#------------------------------------------------------------------------------
# Generate top level design name
#------------------------------------------------------------------------------

if ($board == ml523) then
  set top_filename = mem_ep_app_top_ml523.v
  cp -f ../example_design/mem_ep_app_top.v ../example_design/mem_ep_app_top_ml523.v 
  echo "Created mem_ep_app_top_ml523.v from mem_ep_app_top.v"
  echo ""
endif

if ($board == ml525) then
  set top_filename = mem_ep_app_top_ml525.v
  cp -f ../example_design/mem_ep_app_top.v ../example_design/mem_ep_app_top_ml525.v 
  echo "Created mem_ep_app_top_ml525.v from mem_ep_app_top.v"
  echo ""
endif

if ($board == ml555) then
  set top_filename = mem_ep_app_top_ml555.v
   sed 's/.I(LINK_UP/.I(~LINK_UP/' ../example_design/mem_ep_app_top.v >&! ../example_design/mem_ep_app_top_ml555_tmp.v
   sed 's/.I(clock_lock/.I(~clock_lock/' ../example_design/mem_ep_app_top_ml555_tmp.v >&! ../example_design/mem_ep_app_top_ml555.v
  rm ../example_design/mem_ep_app_top_ml555_tmp.v
  echo "Created mem_ep_app_top_ml555.v from mem_ep_app_top.v"
  echo ""
endif


  #------------------------------------------------------------------------------
  # Create XST project file
  #------------------------------------------------------------------------------

  # Create an XST constraint file
  
      echo "NET core_clk PERIOD = 4ns;" > mem_ep_app_top.xcf
      echo "NET user_clk PERIOD = $user_clk_per ns;" >> mem_ep_app_top.xcf
  
  # creating the xst project file using $XILINX reference
      echo "verilog work $XILINX/virtex5/verilog/src/iSE/unisim_comp.v" > mem_ep_app_top.prj;
  
      set src_dir = ../src
  
  # Compiling top level files
      echo "verilog work $src_dir/$coregen_name.v" >> mem_ep_app_top.prj
  
  # Compiling SRC files
      echo "verilog work $src_dir/pcie_gt_wrapper.v" >> mem_ep_app_top.prj;
      echo "verilog work $src_dir/bram_common.v" >> mem_ep_app_top.prj;
      echo "verilog work $src_dir/pcie_mim_wrapper.v" >> mem_ep_app_top.prj;
      echo "verilog work $src_dir/pcie_reset_logic.v" >> mem_ep_app_top.prj;
      echo "verilog work $src_dir/pcie_clocking.v" >> mem_ep_app_top.prj;
      echo "verilog work $src_dir/pcie_bar_decoder.v" >> mem_ep_app_top.prj;
      echo "verilog work $src_dir/pcie_cmm_decoder.v" >> mem_ep_app_top.prj;
      echo "verilog work $src_dir/pcie_blk_cf_mgmt.v" >> mem_ep_app_top.prj;
      echo "verilog work $src_dir/pcie_top.v" >> mem_ep_app_top.prj;
  
      set src_dir = ../example_design
    
  # Compiling Example Design files
      echo "verilog work $src_dir/completer_mem_block_machine.v" >> mem_ep_app_top.prj;
      echo "verilog work $src_dir/completer_mem_block.v" >> mem_ep_app_top.prj;
      echo "verilog work $src_dir/completer_mem_block_top.v" >> mem_ep_app_top.prj;
      echo "verilog work $src_dir/$top_filename" >> mem_ep_app_top.prj;
  
  


  echo "Synthesizing sample design with XST"
   
  #------------------------------------------------------------------------------
  # Run XST
  #------------------------------------------------------------------------------
    
  if (-e mem_ep_app_top.ngc) then
    echo "Removing old ngc file"
    rm mem_ep_app_top.ngc
  endif
    
    
  echo "Running XST ..."
  xst -ifn mem_ep_app_top.scr -intstyle silent
    
    if (! -e mem_ep_app_top.ngc) then
      exit 0
    endif
    
  #------------------------------------------------------------------------------
  # Clean up the results directory
  #------------------------------------------------------------------------------
  
  if (-e $results_dir) then
     rm -rf $results_dir
     mkdir $results_dir
  else
     mkdir $results_dir
  endif
  
  echo "Copying mem_ep_app_top.ngc to results directory"
  cp mem_ep_app_top.ngc $results_dir


  set src_dir = ../example_design



  echo "Copying constraint file $ucf_filename to results directory"
  cp $src_dir\/$ucf_filename $results_dir


  cd $results_dir

  #------------------------------------------------------------------------------
  # Running ngdbuild with ucf file associated with the particular board
  # If board name is unspecified, default to ML555
  #------------------------------------------------------------------------------

  echo 'Running ngdbuild'

  echo "Using $ucf_filename"

  if (! -e $ucf_filename) then
    echo ""
    echo "Error : The UCF corresponding to this design is not found."
    echo "        Please make sure $ucf_filename is in the ../$src_dir directory"
    echo ""
    exit 0
  endif
  
  ngdbuild -sd "../../example_design" -uc $ucf_filename -p $fullpart mem_ep_app_top mem_ep_app_top.ngd

  if (! -e mem_ep_app_top.ngd) then
    exit 0
  endif

  #------------------------------------------------------------------------------
  # Run Map
  #------------------------------------------------------------------------------
  
  echo 'Running map'
  
  map -p $fullpart -logic_opt off -ol high -o mapped.ncd mem_ep_app_top.ngd mapped.pcf
  
  if (! -e mapped.ncd) then
    exit 0
  endif


  #------------------------------------------------------------------------------
  # Run Par
  #------------------------------------------------------------------------------
  
  echo 'Running par'
  
  par -ol high -w mapped.ncd routed.ncd mapped.pcf
  
  if (! -e routed.ncd) then
    exit 0
  endif


  #------------------------------------------------------------------------------
  # Run Trace
  #------------------------------------------------------------------------------
  
  echo 'Running trce'
  
  trce -u -e 10 -s $speed routed -o routed mapped.pcf
  
  if (! -e routed.twr) then
    exit 0
  endif


  #------------------------------------------------------------------------------
  # Run bitgen
  #------------------------------------------------------------------------------
  
  echo 'Running design through bitgen'
  
  bitgen -dw -g plladv_x0y2_use_calc:Yes -g StartupClk:Cclk routed $bit_filename
