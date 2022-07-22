#!/bin/bash

gen_k_seq=`seq 1 5`
learn_k_lim=8 #10
n_list="3 5 10 20"
reps=`seq 1 50`

beta=10

data_dir=rdata/data
models_dir=rdata/models
locks_dir=rdata/locks

mkdir -p ${models_dir}
mkdir -p ${locks_dir}

for l in `seq 1 ${learn_k_lim}`; do
  (
    for r in ${reps}; do
      for k in ${gen_k_seq}; do
        for n in ${n_list}; do
          density=0.2
          if [ 20 == ${n} ]; then
            density=0.04
          fi

          idT="r${r}-n${n}-e1000-d${density}-k${k}"
          idD="${idT}-b${beta}"
          dfile="${data_dir}/data-${idD}.RData"

          if [[ -s ${dfile} ]]; then
    		
            idM="${idD}-l${l}"
            mfile="${models_dir}/model-${idM}.RData"
            lockfile="${locks_dir}/lock-${idM}"
            if ! [[ -s ${mfile} ]]; then
              if ! [[ -s ${lockfile} ]]; then
                date > "${lockfile}"
                echo learning ${mfile}
                rscript R/run.learner.R ${dfile} ${l} ${mfile}
                rm "${lockfile}"
              fi # lock file
            fi # model file
          fi # data file
        done;
      done;
    done;
  ) &
done;
wait

