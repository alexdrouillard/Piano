vlib work
vlog -novopt level_mux.v
vsim level_mux
log -r {/*}
add wave {/*}

force {clock} 0 0ns, 1 {10ns} -r 20ns

force {resetn} 1
run 20ns

force {resetn} 0
run 20ns

force {enable} 1
run 20ns

force {enable} 0
run 40ns

force {enable} 1
run 20ns

force {enable} 0
run 40ns

force {enable} 1
run 20ns

force {enable} 0
run 40ns