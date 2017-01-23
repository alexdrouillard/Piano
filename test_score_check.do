vlib work
vlog -novopt score_check.v
vsim score_check
log -r {/*}
add wave {/*}

force {clock} 0 0ns, 1 {10ns} -r 20ns

force {input_score} 5'd6
force {level_code} 12'b111111_000000

force {resetn} 1
run 20ns

force {resetn} 0
run 200ns

force {enable} 1
run 200ns

force {enable} 0
run 20ns

force {resetn} 1
run 20ns

force {resetn} 0
run 20ns

force {input_score} 5'd2
run 20ns

force {enable} 1
run 200ns

