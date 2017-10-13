#!/bin/sh
# script for execution of R files on condor.
# Assumes a distribution of R is packaged in R.tar.gz, containing the binaries at lib64/R/bin
#
r_script=$1
shift 
echo "R/bin/R CMD BATCH '--args $@' $r_script" >> run.me

tar -xzf R.tar.gz

source ./run.me

last_arg=$1
while (( $# )); do
	last_arg=$1
done

if [ ! -f $last_arg ]; then
	which sed >> ${r_script}out
fi
