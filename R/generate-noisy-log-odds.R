#' Script to reate a noisy log-odds table from a ground truth effect-pattern matrix
#' @author Yuriy Sverchkov
#' 
#' Arguments: ORDER IS IMPORTANT!
#' 1. Input filename
#' 2. beta.parameter (real > 1) (recommended > 5)
#' 2. )utput filename

library( Matrix )

args <- commandArgs( trailingOnly = TRUE )

in.file <- args[1]
beta.parameter <- as.double( args[2] )
out.file <- args[3]

load( file = in.file )

# The matrix of differential expression log-odds-ratios: rows = effects, columns = actions
samples = matrix(
  log( rbeta( n.actions * n.effects, beta.parameter, 1 ) ) - log( rbeta( n.actions * n.effects, 1, beta.parameter ) ),
  nrow = n.actions, ncol = n.effects )
D <- as.matrix( t( samples * ( efmx * 2 - 1 ) ) )
dimnames( D ) <- list( paste0( "e", 1:n.effects ), letters[1:n.actions] )

save( list = setdiff( ls(), c("args", "in.file", "out.file", "samples") ), file = out.file )

