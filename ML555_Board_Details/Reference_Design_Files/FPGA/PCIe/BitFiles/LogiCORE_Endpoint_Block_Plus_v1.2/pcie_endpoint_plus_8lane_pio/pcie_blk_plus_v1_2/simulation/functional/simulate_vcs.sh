#!/bin/sh

#
# PCI Express Endpoint VCS Run Script
#

/bin/rm *.dat
/bin/rm *.log
/bin/rm vcs.key
/bin/rm -rf simv*
/bin/rm -rf csrc

vcs   +alwaystrigger +v2k +cli \
      -PP \
      +define+VCS \
      -lmc-swift    \
      -L${LMC_HOME}/lib/x86_linux.lib \
      -f xilinx_lib_vcs.f \
      -f board_rtl_x08.f

if (test -e ./simv); then
  ./simv +TESTNAME=sample_smoke_test0
fi

