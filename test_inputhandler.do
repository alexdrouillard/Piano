vlib work
vlog -novopt input_handler.v
vsim input_handler
log -r {/*}
add wave {/*}

force {clock} 0 0ns, 1 {10ns} -r 20ns
force {resetn} 0
run 20ns

force {resetn} 1
run 20ns

force {resetn} 0
force {user_input} 1
force {play} 0
run 20ns

force {level_code} 6'b110001

force {enable} 1

run 40ns

force {enable} 0

run 2000ns

force {resetn} 1
run 20ns

force {resetn} 0
run 20ns

force {play} 1
run 20ns

force {play} 0
run 20ns

force {enable} 1

run 20ns

force {enable} 0
run 20ns