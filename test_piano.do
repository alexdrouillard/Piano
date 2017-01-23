vlib work
vlog -novopt control_top.v
vsim control_top
log -r {/*}
add wave {/*}

force {CLOCK_50} 0 0ns, 1 {10ns} -r 20ns
force {KEY[0]} 1
run 20ns

force {KEY[0]} 0
run 20ns

force {KEY[0]} 1
force {KEY[1]} 1
force {KEY[2]} 1
run 20ns

