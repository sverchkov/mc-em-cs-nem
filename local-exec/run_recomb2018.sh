#!/bin/bash

gen_k_seq=`seq 1 5`
learn_k_lim=8 #10
n_list="3 5 10 20"
reps=`seq 1 50`

beta=10

truths_dir=rdata/truths
data_dir=rdata/data
models_dir=rdata/models
locks_dir=rdata/locks

mkdir -p ${truths_dir}
mkdir -p ${data_dir}
mkdir -p ${models_dir}
mkdir -p ${locks_dir}

for r in ${reps}; do
  for k in ${gen_k_seq}; do
    for n in ${n_list}; do
      density=0.2
      if [ 20 == ${n} ]; then
        density=0.04
      fi
      echo using density ${density}

      idT="r${r}-n${n}-e1000-d${density}-k${k}"
      tfile="${truths_dir}/truth-${idT}.RData"
      
      if ! [[ -s ${tfile} ]]; then
        echo generating ${tfile}
        rscript R/generate-ground-truth.R ${k} ${n} 1000 ${density} ${tfile}
      fi

      idD="${idT}-b${beta}"
      dfile="${data_dir}/data-${idD}.RData"
  			
      if ! [[ -s ${dfile} ]]; then
        echo generating ${dfile}
        rscript R/generate-noisy-log-odds.R ${tfile} ${beta} ${dfile}
      fi
    		
      for l in `seq 1 ${learn_k_lim}`; do
        (
          idM="${idD}-l${l}"
          mfile="${models_dir}/model-${idM}.RData"
          lockfile="${locks_dir}/lock-${idM}"
          if ! [[ -s ${mfile} ]]; then
            if ! [[ -s ${lockfile} ]]; then
              date > "${lockfile}"
              echo learning ${mfile}
              rscript R/run.learner.R ${dfile} ${l} ${mfile}
            fi
          fi
        ) &
      done;
      wait
    done;
  done;
done;

