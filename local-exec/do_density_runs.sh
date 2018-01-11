#!/bin/bash

gen_k_seq="1 3 5"
learn_k_lim=8 #10
n=10
reps=`seq 1 20`
densities="0.04 0.1 0.5"
beta=10

mkdir -p rdata

for r in ${reps}; do
  for density in ${densities}; do
  	for k in ${gen_k_seq}; do
			id="n_${n}_k_${k}_b_${beta}_d_${density}_r_${r}"
			dfile="data_${id}.RData"
			
			if ! [[ -s rdata/${dfile} ]]; then
  			echo generating ${dfile}

  			rscript R/generate.data.R $k $n 1000 ${density} ${beta} rdata/${dfile}
  		fi
  		
			for l in `seq 1 ${learn_k_lim}`; do
				id2="${id}_l_$l"
				mfile="model_${id2}.RData"
				if ! [[ -s rdata/${mfile} ]]; then
					echo learning ${id2}
					rscript R/run.learner.R rdata/${dfile} $l rdata/${mfile}
				fi
  		done;
  	done;
  done;
done;
