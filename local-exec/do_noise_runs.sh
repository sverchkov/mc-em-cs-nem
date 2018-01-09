#!/bin/bash

gen_k_seq="1 3 5"
learn_k_lim=8 #10
n_list="5 20" #"3 5 10 25"
reps=`seq 1 10`
noise="5 2 1"

mkdir -p rdata

for beta in ${noise}; do
  for r in ${reps}; do
  	for k in ${gen_k_seq}; do
  		for n in ${n_list}; do
  			id="n_${n}_k_${k}_b_${beta}_r_${r}"
  			dfile="data_${id}.RData"
  			echo generating ${dfile}
  			
  			density=0.2
  			if [ 20 == ${n} ]; then
  			  density=0.04
  			fi
  			echo using density ${density}
  			
  			rscript R/generate.data.R $k $n 1000 ${density} ${beta} rdata/${dfile}
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
done;
