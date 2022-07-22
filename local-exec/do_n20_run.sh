#!/bin/bash

gen_k_lim=5
learn_k_lim=8 #10
n_list=20 #"3 5 10 25"
reps=`seq 1 50`

mkdir -p rdata

for r in ${reps}; do
  for k in `seq 1 ${gen_k_lim}`; do
    for n in ${n_list}; do
      id="$n-$k-$r"
      dfile="data-sparse-${id}.RData"
      echo generating ${dfile}
      if ! [[ -s rdata/${dfile} ]]; then
        rscript R/generate.data.R $k $n 1000 0.04 10 rdata/${dfile}
      fi
      for l in `seq 1 ${learn_k_lim}`; do
        id2="${id}-$l"
        mfile="sparse-model-${id2}.RData"
        if ! [[ -s rdata/${mfile} ]]; then
          echo learning ${id2}
          rscript R/run.learner.R rdata/${dfile} $l rdata/${mfile}
        fi
      done;
    done;
  done;
done;

