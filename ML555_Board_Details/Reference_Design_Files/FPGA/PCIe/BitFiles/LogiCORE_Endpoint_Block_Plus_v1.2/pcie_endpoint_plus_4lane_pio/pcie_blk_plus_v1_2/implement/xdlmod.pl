#!/usr/local/bin/perl
## Description : Modify a xdl file to support V5 ES silicon PCIE clock inversion

#Initialize regression counters
$fondPCIEGTP = 0;
$xdlfile = shift @ARGV;

`rm -f modified*.xdl`;
open(INPUT, "$xdlfile") or die "$xdlfile file not found \n";
open(OUTPUT, ">modified_$xdlfile");

while (<INPUT>) 
{
  if(/inst/)
  {
	  if (/pcie_gt_wrapper_i\/GTPD\[[0,2,4,6]\]\.GTP_i/)
	  {
      $foundPCIEGTP = 1;
    }
  }

  if($foundPCIEGTP)
  {
    if(/TXUSRCLK0INV\:\:TXUSRCLK0/)
    {
      print OUTPUT "       TXUSRCLK0INV::TXUSRCLK0_B TXUSRCLK1INV::TXUSRCLK1_B TXUSRCLK20INV::TXUSRCLK20_B\n";
    }
    elsif(/TXUSRCLK21INV\:\:TXUSRCLK21/)
    {
      print OUTPUT "       TXUSRCLK21INV::TXUSRCLK21_B TX_BUFFER_USE_0::TRUE TX_BUFFER_USE_1::TRUE\n";
      $foundPCIEGTP = 0;
    }
    else
    {
      print OUTPUT $_;
    }
  }
  else
  {
    print OUTPUT $_;
  }
}

close(OUTPUT);
close(INPUT);
