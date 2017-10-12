#!/bin/sh
# script for execution of R files on condor.
# Assumes a distribution of R is packaged in R.tar.gz, containing the binaries at lib64/R/bin
#
r_script=$1
shift 
args=$@

tar -xzf R.tar.gz
export PATH=$(pwd)/R/bin:$PATH
R CMD BATCH "--args '$args' $r_script"

