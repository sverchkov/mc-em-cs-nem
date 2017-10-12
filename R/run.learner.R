# MC-EM-CS-NEM learning script
#
# Arguments: ORDER IS IMPORTANT!
# 1. data file (string) (must contain matrix D)
# 2. learning k (integer)
# 3. output file (string)

library("nem")
library("Matrix")

args <- commandArgs( trailingOnly = TRUE )

load( args[1] )
k <- as.integer( args[2] )
out.file <- args[3]

n.actions <- ncol( D )
n.effect <- nrow( D )

# prepare data matrix
R <- Reduce( cbind, Map( function (i) {
  R_part <- D
  colnames( R_part ) <- paste0( colnames( D ), "_", i )
  return ( R_part )
}, 1:k ) )

contextualized_actions <- colnames( R )

# Set parameters for MC-EMiNEM
inference <- "mc.eminem"

# action graph prior
actionPrior <- Matrix( 0.2, n.actions, n.actions )
diag( actionPrior ) <- 1

control = set.default.parameters(
  contextualized_actions,
  type = "CONTmLLBayes", # I think?
  mcmc.nsamples = 5e3, # Number of MCMC iterations. Default = 1e6
  mcmc.nburnin = 1.5e4, # MCMC burnin period. Default = 1e6
  #Pe. # "Hidden" prior (attachments?)
  Pm = as.matrix( .bdiag( rep( list( actionPrior ), k ) ) ),
  #eminem.maxsteps, # Max number of em steps. Default = 1000
  eminem.sdVal = k * n.actions, # Number of edges to change in one MCMC step. Default = 1 (check paper)
  #Pm.frac_edges, # Expected fraction of edges in action graph. Default = 0.2
  eminem.changeHfreq = 5e3, # the Empirical Bayes step is performed every <changeHfreq> steps
  #prob.cutoff, # Probability cutoff for edges in graph(?) Default = 0.5
  lambda = 0.5 # (ep in runMCMC) Sparsity prior for acceptance rate (check paper)
)

control$lowMemFootprint <- TRUE

# Run NEM

big.nem <- nem( D = R, inference = inference, control = control )

# Save

learning.k <- k

learning.time <- proc.time()

save.list <- ls()
save.list <- save.list[ !( save.list %in% c(
  "k", "inference", "control", "actionPrior", "contextualized_actions", "args", "R", "out.file" ) ) ]

save( list = save.list, file = out.file )
