#' CSNEM Generation script
#' @author Yuriy Sverchkov
#'
#' Arguments: ORDER IS IMPORTANT!
#' 1. true.k (integer) (number of contexts)
#' 2. n.actions (integer) (number of actions, must be <= 26)
#' 3. n.effects (integer) (number of effects)
#' 4. edge.density (0 < real < 1) (recommended value of 0.2)
#' 5. output file name (string)

library( Matrix )

transitively.close = function( m ){
  diag( m ) = TRUE
  closure = m %&% m
  if ( all( closure == m ) ) return ( closure )
  else return ( transitively.close ( closure ) )
}

args <- commandArgs( trailingOnly = TRUE )

true.k <- as.integer( args[1] )
n.actions <- as.integer( args[2] )
n.effects <- as.integer( args[3] )
edge.density <- as.double( args[4] )
out.file <- args[5]

# Generate underlying nem mixture
mtxs = list()
for( i in 1:true.k ){
  mx = Matrix( data = ( 1 == rbinom( n.actions*n.actions, 1, edge.density ) ), nrow = n.actions, ncol = n.actions )
  diag( mx ) = TRUE
  mtxs[[i]] = transitively.close( mx )
}

# Effect attachment matrix (k*action x effect)
eam <- rmultinom( n.effects, 1, c( rep( 1/(n.actions * true.k), n.actions * true.k ), 0.3 ) )
eam <- eam[1:(n.actions * true.k),]

# Compute effects matrix
efmx = 0
for ( i in 1:true.k ){
  efmx = efmx | mtxs[[i]] %&% eam[ ( 1:n.actions ) + (true.k-1)*n.actions, ]
}

save( true.k, n.actions, n.effects, edge.density, mtxs, eam, efmx, file = out.file )
