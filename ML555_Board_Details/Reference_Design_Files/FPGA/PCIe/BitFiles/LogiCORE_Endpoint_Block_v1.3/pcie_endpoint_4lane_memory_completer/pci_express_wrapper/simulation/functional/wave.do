onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider Test_bench
add wave -noupdate -format Logic /tb/*

add wave -noupdate -divider Mem_Wrapper
add wave -noupdate -format Logic tb/pcie_ne_inst/pcie_mim_wrapper_i/*

add wave -noupdate -divider RX_Ram
add wave -noupdate -format Logic /tb/pcie_ne_inst/pcie_mim_wrapper_i/bram_tl_tx/*

add wave -noupdate -divider DUT_A
add wave -noupdate -format Logic /tb/pcie_ne_inst/*

add wave -noupdate -divider DUT_B
add wave -noupdate -format Logic /tb/mem_ep_app_top_i/*

add wave -noupdate -divider PCIE_TOP_WRAPPER
add wave -noupdate -format Logic /tb/mem_ep_app_top_i/dut_b/*

add wave -noupdate -divider PCIE_WRAPPER
add wave -noupdate -format Logic /tb/mem_ep_app_top_i/dut_b/pcie_top_inst/*

add wave -noupdate -divider PCIE_CLOCKING
add wave -noupdate -format Logic /tb/mem_ep_app_top_i/dut_b/pcie_top_inst/pcie_clocking_i/*

add wave -noupdate -divider PCIE_MEM_WRAPPER
add wave -noupdate -format Logic /tb/mem_ep_app_top_i/dut_b/pcie_top_inst/pcie_mim_wrapper_i/*

add wave -noupdate -divider PCIE_GTP_WRAPPER
add wave -noupdate -format Logic /tb/mem_ep_app_top_i/dut_b/pcie_top_inst/pcie_gt_wrapper_i/*

add wave -noupdate -divider PCIE_RESET_LOGIC
add wave -noupdate -format Logic /tb/mem_ep_app_top_i/dut_b/pcie_top_inst/use_reset_logic/pcie_reset_logic_i/*

add wave -noupdate -divider COMPLETER 
add wave -noupdate -format Logic /tb/mem_ep_app_top_i/completer/*


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {1 ns}
