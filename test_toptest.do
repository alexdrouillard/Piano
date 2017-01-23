vlib work
vlog -novopt toptest.v
vsim toptest
log -r {/*}
add wave {/*}

force {CLOCK_50} 0 0ns, 1 {10ns} -r 20ns
force {KEY[0]} 0

run 20ns

force {KEY[0]} 1
run 20ns

force {KEY[3]} 1
run 40ns

force {KEY[3]} 0
run 3000ns
