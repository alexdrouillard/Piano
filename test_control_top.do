vlib work
vlog -novopt control_top.v
vsim control_top
log -r {/*}
add wave {/*}

force {clock} 0 0ns, 1 {10ns} -r 20ns
force {resetn} 1
force {go} 1

run 40ns

force {resetn} 0
run 20ns

force {go} 1
run 40ns

force {go} 0
run 40ns

force {go} 1
run 1000ns
