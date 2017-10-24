# R script making precision-recall tables from the result eval files

library("dplyr")
source("R/helper-functions.R")

getEvalSummary <- function( file ){
  print( file )
  env = new.env()
  load( file = file, envir = env )
  mll = env$big.nem$mLL
  mll = mll[[ length(mll) ]]
  
  ll = sum( nem.effect.matrix( env$big.nem ) * t( makeBigRMatrix( env$D, env$learning.k ) ) )
  
  effect.matrix <- getEffectsFromBigNEM( env$big.nem, env$n.actions, env$learning.k )
  patterns <- getPatternsFromNEM( env$big.nem, env$n.actions, env$learning.k )
  true.patterns <- getPatternsFromMatrixList( env$mtxs )
  
  effect.stats <- getPRStatsBinary( effect.matrix, env$efmx )
  pattern.stats <- getPRStatsSets( patterns, true.patterns )
  
  return ( as_tibble( list(
    "Actions" = env$n.actions,
    "Effects" = env$n.effects,
    "True k" = env$true.k,
    "Learning k" = env$learning.k,
    "Effect-wise precision" = effect.stats$precision,
    "Effect-wise recall" = effect.stats$recall,
    "Parent pattern precision" = pattern.stats$precision,
    "Parent pattern recall" = pattern.stats$recall,
    "Log posterior" = mll,
    "Log likelihood" = ll,
    "File" = file
    ) ) )
}

out.file = "csv/table-of-results-v3.csv"

input.files <- paste0("rdata/", dir( "rdata", pattern = "model-.*\\.RData" ) )

input.files <- input.files[ file.info( input.files )$size > 0 ]

#skip.files <- c( "rdata/model-25-1-12-8.RData" )

#input.files <- input.files[ !( input.files %in% skip.files ) ]

if ( file.exists( out.file ) ){
  result.table <- read.csv( file = out.file, check.names = FALSE, stringsAsFactors = FALSE )
  input.files <- input.files[ !( input.files %in% result.table$`File` ) ]
} else {
  result.table <- NULL
}

for ( in.file in input.files ){
  
  row <- getEvalSummary( in.file )
  
  if ( is.null(result.table) )
    result.table <- row
  else
    result.table <- bind_rows( result.table, row )
  
  write.csv( result.table, file = out.file, row.names = FALSE )
}