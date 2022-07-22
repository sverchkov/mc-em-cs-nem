#!/bin/bash

gen_k_lim=5
learn_k_lim=8 #10
n_list="3 5 10"
#reps=`seq 1 50`
#reps=`seq 1 5`
#reps="14 15 32 39 50"
reps="20 11 33 35 36"

mkdir -p rdata

for r in ${reps}; do
	for k in `seq 1 ${gen_k_lim}`; do
		for n in ${n_list}; do
			id="$n-$k-$r"
			dfile="data-${id}.RData"
			for l in `seq 1 ${learn_k_lim}`; do
				id2="${id}-$l"
				mfile="model-${id2}.RData"
				if ! [[ -s rdata/${mfile} ]]; then
					echo running ${id2}
					rscript R/run.learner.R rdata/${dfile} $l rdata/${mfile}
				fi
			done;
		done;
	done;
done;
