# MC EM CS NEM
This repository serves as
* The location for hosting the supplementary materials for the paper "Context-Specific Nested Effects Models" by Sverchkov et al., to appear at RECOMB 2018, these files are in the `recomb-2018-supplement` folder.
* The source code repository for the simulation studies in the paper.

## Files and where to find them
* `recomb-2018-supplement` contains a PDF of supplementary text and cytoscape files of the yeast salt stress network.
* `R` contains R code for assembling the result summary csv as well as R code for running the simulation and learning
* `csv` holds csv files, notably including the summary table.
* `rdata` would be created by simulation code, and hold `RData` files, including the ground truth generating models+data, learned models, evaluation statistics.
* `plots` would be created by plotting R scripts
* `local-exec` contain bash scripts for running the simulations
* `json` the simulated ground truths, in json

### File naming conventions
Files created in `rdata` follow the pattern
`{type}-r{rep}-n{number of actions}-e{number of effects}-d{edge density}-k{true k}-b{beta parameter}-l{learning k}`
where (type) is truth/data/model,
data doesn't have a learning k,
and truth has neither a learning k nor a beta parameter

## Simulation workflow
* Each of `run_recomb2018.sh`, `do_density_runs.sh`, or `do_noise_runs.sh` in `local-exec` creates ground truth and data if they do not exists, and learns models.
One can first run `generate_data.sh` to ensure all models are created first.
(Note that all of this takes weeks to run on a single machine.)
* The R script `result-table-from-models.R` reads the learned models and creates a csv file listing them and their precision/recall on effect matrix recovery and ancestry recovery.
* The R script `make-plots.R` makes the plots summarizing this.

## Note on `nem` package
I use [my own fork of the NEM package](htps://github.com/sverchkov/nem), for running MC-EMiNEM more memory-efficiently, and for access to some functions that the Bioconductor package doesn't expose.
