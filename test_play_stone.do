vlib work
vlog -novopt play_stone.v
vsim play_stone
log -r {/*}
add wave {/*}

force {clock} 0 0ns, 1 {10ns} -r 20ns

force {resetn} 1
run 20ns

force {resetn} 0
run 20ns

force {enable} 1
force {win} 1
run 20ns

force {enable} 0
run 200ns

force {enable} 1
run 200ns