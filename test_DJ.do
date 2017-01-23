vlib work
vlog -novopt DJ.v
vsim DJ
log -r {/*}
add wave {/*}

force {clock} 0 0ns, 1 {10ns} -r 20ns

force {user_input} 6'b100_000
force {resetn} 1
run 20ns

force {resetn} 0
run 400ns

force {user_input} 6'b100_010
run 400ns

