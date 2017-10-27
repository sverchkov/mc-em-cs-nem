# Model selection

library("dplyr")
library("ggplot2")

#' Extract replicate number from file name
extractReplicateNumber <- function( filename ){
  if ( length( filename ) != 1 ){
    return ( Reduce( c, Map( extractReplicateNumber, filename ) ) )
  }else{
    match <- regexec(pattern = "model-[0-9]+-[0-9]+-([0-9]+)", text = filename )[[1]]
    start.char <- match[2]
    end.char <- start.char + attr( match, 'match.length' )[2] - 1
    return ( substr( filename, start.char, end.char ) )
  }
}

results.df <-
  read.csv( file = "csv/table-of-results-v4.csv", check.names = FALSE, stringsAsFactors = FALSE ) %>%
  mutate( `Effect matrix F-measure` = 2 / ( (1/`Effect-wise precision`) + (1/`Effect-wise recall`) ) ) %>%
  mutate( `Ancestry set F-measure` = 2 / ( (1/`Parent pattern precision`) + (1/`Parent pattern recall`) ) ) %>%
  mutate( Rep = extractReplicateNumber( File ) )

