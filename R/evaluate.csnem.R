# CSNEM Evaluation
#
# Arguments: ORDER IS IMPORTANT!
# 1. data file (string) (must contain matrix D)
# 2. output file (string)

library( Matrix )
library( graph )


args <- commandArgs( trailingOnly = TRUE )

load( args[1] )
out.file <- args[2]
csv.file <- args[3]

# Compute effect matrix
nem.effect.matrix = function( nem ){
  actions <- nem$control$Sgenes
  effects <- names( nem$LLperGene[[1]] )
  attachments = matrix( data = FALSE, nrow = length( actions ), ncol = length( effects ), dimnames = list( actions, effects ) )
  for ( a in actions ){
    map.pos = nem$mappos[[a]]
    attachments[ a, map.pos ] = TRUE
  }
  
  adj = as( nem$graph, "matrix" )
  diag( adj ) = TRUE
  
  adj %&% attachments
}

big.effect.matrix <- nem.effect.matrix( big.nem )
effect.matrix <- Reduce( `|`, Map( function ( i ) big.effect.matrix[ (1:n.actions) + (i-1)*n.actions, ] , 1:learning.k ) )

# Compute effect precision+recall
effect.tp <- sum( efmx & effect.matrix )
effect.tn <- sum( !efmx & !effect.matrix )
effect.fp <- sum( !efmx & effect.matrix )
effect.fn <- sum( efmx & !effect.matrix )

effect.precision <- effect.tp / ( effect.tp + effect.fp )
effect.recall <- effect.tp / ( effect.tp + effect.fn )

# Compute ancestry pattern precision+recall
big.adj <- as( big.nem$graph, "matrix" )
diag( big.adj ) = TRUE

patterns <- Reduce( cbind, Map( function( i ) big.adj[ (1:n.actions) + (i-1)*n.actions, (1:n.actions) + (i-1)*n.actions ], 1:learning.k ) )
patterns <- unique( Map( function( i ) as.numeric( patterns[,i] ), 1:ncol( patterns ) ) )

true.patterns <- Reduce( cbind, mtxs )
true.patterns <- unique( Map( function( i ) as.numeric( true.patterns[,i] ), 1:ncol( true.patterns ) ) )

patterns.tp <- sum( patterns %in% true.patterns )
patterns.precision <- patterns.tp / length( patterns )
patterns.recall <- patterns.tp / length( true.patterns )

# Save rdata
save.image( file = out.file )

# Save csv
write_csv( data.frame(
	n.actions = n.actions,
	n.effects = n.effects,
	true.k = true.k,
	learning.k = learning.k,
	effect.tp = effect.tp,
	effect.tn = effect.tn,
	effect.fp = effect.fp,
	effect.precision = effect.precision,
	effect.recall = effect.recall,
	patterns.tp = patterns.tp,
	patterns.precision = patterns.precision,
	patterns.recall = patterns.recall
), file = csv.file, row.names = FALSE)
