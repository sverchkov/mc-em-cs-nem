library("Matrix")
library("graph")
library("nem")

# Compute effect matrix
nem.effect.matrix <- function( nem ){
  actions <- nem$control$Sgenes
  effects <- names( nem$LLperGene[[1]] )
  attachments = matrix( data = FALSE, nrow = length( actions ), ncol = length( effects ), dimnames = list( actions, effects ) )
  for ( a in actions ){
    map.pos = nem$mappos[[a]]
    attachments[ a, map.pos ] = TRUE
  }
  
  acc <- transitive.closure( nem.object$graph, mat = TRUE )
  
  acc %&% attachments
}

getEffectsFromBigNEM <- function( big.nem, n.actions, learning.k ){
  big.effect.matrix <- nem.effect.matrix( big.nem )
  Reduce( `|`, Map( function ( i ) big.effect.matrix[ (1:n.actions) + (i-1)*n.actions, ] , 1:learning.k ) )
}

getPRStatsBinary <- function( predictions, truth ){
  # Compute effect precision+recall
  tp <- sum( truth & predictions )
  tn <- sum( !truth & !predictions )
  fp <- sum( !truth & predictions )
  fn <- sum( truth & !predictions )
  
  precision <- tp / ( tp + fp )
  recall <- tp / ( tp + fn )
  
  return (list( precision=precision, recall=recall, tp=tp, tn=tn, fp=fp, fn=fn ))
}

getPRStatsSets <- function( predictions, truth ){
  tp <- sum( predictions %in% truth )
  precision <- tp / length( predictions )
  recall <- tp / length( truth )

  return (list( precision=precision, recall=recall, tp=tp ))
}

getPatternsFromNEM <- function( big.nem, n.actions, learning.k ){
  big.adj <- as( big.nem$graph, "matrix" )
  diag( big.adj ) = TRUE
  
  getPatternsFromMatrixList( Map( function( i ) big.adj[ (1:n.actions) + (i-1)*n.actions, (1:n.actions) + (i-1)*n.actions ], 1:learning.k ) )
}

getPatternsFromMatrixList <- function( matrices ){
  true.patterns <- Reduce( cbind, matrices )
  true.patterns <- unique( Map( function( i ) as.numeric( true.patterns[,i] ), 1:ncol( true.patterns ) ) )
}