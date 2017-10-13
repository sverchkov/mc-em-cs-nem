# R script making precision-recall tables from the result eval files

library("dplyr")

getEvalSummary = function( file ){
  print( file )
  env = new.env()
  load( file = file, envir = env )
  lik = env$big.nem$mLL
  lik = lik[[ length(lik) ]]
  return ( as_tibble( list(
    "Actions" = env$n.actions,
    "Effects" = env$n.effects,
    "True k" = env$true.k,
    "Learning k" = env$learning.k,
    "Effect-wise precision" = env$effect.precision,
    "Effect-wise recall" = env$effect.recall,
    "Parent pattern precision" = env$patterns.precision,
    "Parent pattern recall" = env$patterns.recall,
    "Likelihood" = lik
    ) ) )
}

input.files = paste0("rdata/", dir( "rdata", pattern = "eval-.*\\.RData" ) )

input.files = input.files[ file.info( input.files )$size > 0 ]

result.table = NULL

for ( in.file in input.files ){
  
  row <- getEvalSummary( in.file )
  
  if ( is.null(result.table) )
    result.table <- row
  else
    result.table <- bind_rows( result.table, row )
  
  write.csv( result.table, file = "csv/table-of-results.csv", row.names = FALSE )
}