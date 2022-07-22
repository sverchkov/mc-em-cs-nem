#!/bin/bash

gen_k_lim=5
learn_k_lim=8 #10
n_list="3 5 10"
reps=50

mkdir -p rdata

for r in `seq 1 ${reps}`; do
	count=0
	for k in `seq 1 ${gen_k_lim}`; do
		for n in ${n_list}; do
			id="$n-$k-$r"
			for l in `seq 1 ${learn_k_lim}`; do
				id2="$id-$l"
				mfile="model-$id2.RData"
				if ! [[ -s rdata/$mfile ]]; then
					count=$((count+1))
				fi
			done;
		done;
	done;
	echo rep $r has $count incomplete models
done;

