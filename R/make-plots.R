# Make figures for paper

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
    return ( as.integer( substr( filename, start.char, end.char ) ) )
  }
}

results.df <-
  read.csv( file = "csv/table-of-results-v5.csv", check.names = FALSE, stringsAsFactors = FALSE ) %>%
  mutate( Rep = extractReplicateNumber( File ) ) %>%
  filter(
    ( ( Actions < 20 ) & ( Rep %in% c( 1:5, 14, 15, 32, 39, 50 ) ) ) |
    ( ( Actions == 20 ) & ( Rep %in% 1:10 ) ) )
  #mutate( `Effect matrix F-measure` = 2 / ( (1/`Effect-wise precision`) + (1/`Effect-wise recall`) ) ) %>%
  #mutate( `Ancestry set F-measure` = 2 / ( (1/`Parent pattern precision`) + (1/`Parent pattern recall`) ) )

ggplot( results.df, aes( x = `Learning k`, y = `Effect matrix F-measure`, group = `Learning k` ) ) +
  facet_grid( `True k` ~ `Actions`, labeller = label_both ) +
  geom_boxplot( alpha = 0, color = "red" ) +
  geom_jitter( position = position_jitter( width = 0.15 ) )

ggsave("plots/effect-f-measures.pdf")

ggplot( results.df, aes( x = `Learning k`, y = `Ancestry set F-measure`, group = `Learning k` ) ) +
  facet_grid( `True k` ~ `Actions`, labeller = label_both ) +
  geom_boxplot( alpha = 0, color = "red" ) +
  geom_jitter( position = position_jitter( width = 0.15 ) )

ggsave("plots/ancestrys-f-measures.pdf")

results.with.aicc <- results.df %>%
  mutate(
    Parameters = `Effects` + `Learning k`*( `Actions` * ( `Actions` - 1 ) ),
    AIC = 2 * Parameters - 2 * `Log likelihood`,
    AICc = AIC + 2 * Parameters * ( Parameters + 1 ) / ( Effects - Parameters - 1 ) )

ggplot( results.df, aes( x = `Learning k`, y = `Pairwise ancestry recall`, group = `Learning k`, color = `Rep` ) ) +
  facet_grid( `True k` ~ `Actions`, labeller = label_both ) +
  geom_boxplot()
#  geom_jitter( position = position_jitter( width = 0.15 ) )
