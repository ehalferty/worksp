
vlib work
vmap work
vlog -work work +incdir+../.+../../example_design \
      -f board_rtl_x04.f -f xilinx_lib_mti.f

vsim +notimingchecks +TESTNAME=sample_smoke_test0 -L work \
    work.boardx04 glbl

run -all
