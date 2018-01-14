#!/bin/bash

gen_k_seq=`seq 1 5`
learn_k_lim=8 #10
n_list="3 5 10 20"
reps=`seq 1 50`

betas="1 2 5 10"
densities="0.04 0.1 0.2 0.5"

truths_dir=rdata/truths
data_dir=rdata/data

mkdir -p ${truths_dir}
mkdir -p ${data_dir}

for r in ${reps}; do
  for k in ${gen_k_seq}; do
    for n in ${n_list}; do
      for density in ${densities}; do

        idT="r${r}-n${n}-e1000-d${density}-k${k}"
        tfile="${truths_dir}/truth-${idT}.RData"
      
        if ! [[ -s ${tfile} ]]; then
          echo generating ${tfile}
          rscript R/generate-ground-truth.R ${k} ${n} 1000 ${density} ${tfile}
        fi

        for beta in ${betas}; do
          idD="${idT}-b${beta}"
          dfile="${data_dir}/data-${idD}.RData"
  			
          if ! [[ -s ${dfile} ]]; then
            echo generating ${dfile}
            rscript R/generate-noisy-log-odds.R ${tfile} ${beta} ${dfile}
          fi
        done;
      done;
    done;
  done;
done;

