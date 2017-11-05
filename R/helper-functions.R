library("Matrix")
library("graph")
library("nem")

#' Make the big R matrix
#' @param small.R.matrix the "small" R matrix, the one where each action appears once
#' @param k the number of times to append the small R matrix to itself
#' @return the small R matrix appended to itself k times with column names remapped to <name>_i for i in 1...k
makeBigRMatrix <- function ( small.R.matrix, k ){
  Reduce( cbind, Map( function (i) {
    R_part <- small.R.matrix
    colnames( R_part ) <- paste0( colnames( small.R.matrix ), "_", i )
    return ( R_part )
  }, 1:k ) )
}

# Compute effect matrix
nem.effect.matrix <- function( nem ){
  actions <- nem$control$Sgenes
  effects <- names( nem$LLperGene[[1]] )
  attachments = matrix( data = FALSE, nrow = length( actions ), ncol = length( effects ), dimnames = list( actions, effects ) )
  for ( a in actions ){
    map.pos = nem$mappos[[a]]
    attachments[ a, map.pos ] = TRUE
  }
  
  acc <- transitive.closure( nem$graph, mat = TRUE )
  
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

#' Get precision/recall statistics on pairwise ancestry relations
#'
#' @param true.mtx.list List of ancestry matrices making up the generating model
#' @param inferred.big.nem Inferred "big" nem (with replicated action columns)
getPRStatsPairwiseAncestry <- function( true.mtx.list, inferred.big.nem, n.actions, learning.k ) {
  true.ancestries <- Reduce( `|`, true.mtx.list )
  big.matrix <- transitive.closure( inferred.big.nem$graph, mat = TRUE )
  inferred.ancestries <- Reduce( `|`, Map( function( i ){
    big.matrix[ (i-1)*n.actions + (1:n.actions), (i-1)*n.actions + (1:n.actions) ]
  }, 1:learning.k ) )
  
  tp = true.ancestries & inferred.ancestries
  fp = inferred.ancestries & !true.ancestries
  fn = !inferred.ancestries $ true.ancestries
  
  return ( list( precision = tp/(tp+fp), recall = tp/(tp+fn) ) )
}

#' Get ancestry list from matrix list
#' 
#' 
getAncestryListFromMatrixList <- function( matrices ){
  unique( Reduce( c, Map( function ( mtx ){
    Map( function( i ) list( i, as.numeric( mtx[,i] ) ), 1:ncol( mtx ) )
  }, matrices ) ) )
}

#' Get precision of one ancestry list predicting another
#' 
#' see getAncestryListFromMatrixList to see what ancestry lists are.
#' 
#' To get recall, just call this but switch truth and guess.
#' 
#' @param guess an ancestry list
#' @param truth an ancestry list
getPrecisionFromAncestryLists <- function ( guess, truth ){
  tp <- 0 # True positives
  pp <- 0 # Predicted positives
  for( guess.tuple in guess ) {
    node <- guess.tuple[[1]]
    pp <- pp + sum( guess.tuple[[2]] )
    
    # Select best match in truth
    best.tp <- 0
    for ( truth.tuple in truth ) if ( truth.tuple[[1]] == node ){
      tuple.tp = sum( guess.tuple[[2]] & truth.tuple[[2]] )
      if ( tuple.tp > best.tp ) best.tp <- tuple.tp
    }
    tp <- tp + best.tp
  }
  return ( tp / pp )
}

getMatrixListFromBigNEM <- function ( big.nem, n.actions, learning.k ){
  big.matrix <- transitive.closure( big.nem$graph, mat = TRUE )
  Map( function( i ){
    big.matrix[ (i-1)*n.actions + (1:n.actions), (i-1)*n.actions + (1:n.actions) ]
  }, 1:learning.k )
}