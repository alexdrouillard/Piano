vlib work
vlog -novopt counttest.v
vsim counttest
log -r {/*}
add wave {/*}

force {test} 12'b1111_0000_11111_00000
run 30ns

force {test} 12'b1111_0110_11111_00000
run 30ns