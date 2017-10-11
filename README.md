# MC EM CS NEM
Simulation code and results for the MC-EM-CS-NEM project. Not really for public consumption.

## Files and where to find them
* `PlotResultSummary` is a *shiny* app for plotting the results
* `R` contains R code for assembling the result summary csv as well as R code for running the simulation/learning/evaluation
* `csv` holds csv files, notably including the summary table. 
* `rdata` hold `RData` files, including the ground truth generating models+data, learned models, evaluation statistics.
* `condor` holds HTCondor submit files and a shell script to run R scripts using a tar.gzipped R distribution.
* `dag-tools` includes scripts to make HTCondor DAGs to run the simulatio/learning/evaluation

## Condor Run Details
Things are run by generating and submitting a condor DAG.
Requires preparing a tar-gzipped R installation in `R.tar.gz` according to http://chtc.cs.wisc.edu/r-jobs.shtml

### File naming conventions
(type)-(number of actions)-(true k)-(rep)-(learning k)
where (type) is data/model/eval
and data doesn't have a learning k

### Workflow

generate.condor:
* Runs generate.data.R
* Creates data...RData

learn.condor:
* Runs run.learner.R
* Reads data...RData
* Creates model...RData

evaluate.condor:
* Runs evaluate.csnem.R
* Reads model...RData
* Creates eval...RData

