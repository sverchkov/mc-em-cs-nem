# Make figures for paper

library("dplyr")
library("ggplot2")

#' Extract replicate number from file name
extractReplicateNumber <- function( filename ){
  if ( length( filename ) != 1 ){
    return ( Reduce( c, Map( extractReplicateNumber, filename ) ) )
  }else{
    match <- regexec(pattern = "model-r([0-9]+)", text = filename )[[1]]
    start.char <- match[2]
    end.char <- start.char + attr( match, 'match.length' )[2] - 1
    return ( as.integer( substr( filename, start.char, end.char ) ) )
  }
}

extractDensity <- function( filename ){
  if ( length( filename ) != 1 ){
    return ( Reduce( c, Map( extractDensity, filename ) ) )
  }else{
    match <- regexec(pattern = "model-.*-d([0-9.]+)", text = filename )[[1]]
    start.char <- match[2]
    end.char <- start.char + attr( match, 'match.length' )[2] - 1
    return ( as.numeric( substr( filename, start.char, end.char ) ) )
  }
}

extractBeta <- function( filename ){
  if ( length( filename ) != 1 ){
    return ( Reduce( c, Map( extractBeta, filename ) ) )
  }else{
    match <- regexec(pattern = "model-.*-b([0-9.]+)", text = filename )[[1]]
    start.char <- match[2]
    end.char <- start.char + attr( match, 'match.length' )[2] - 1
    return ( as.integer( substr( filename, start.char, end.char ) ) )
  }
}

results.df <-
  read.csv( file = "csv/table-of-results-v6.csv", check.names = FALSE, stringsAsFactors = FALSE ) %>%
  mutate(
    Rep = extractReplicateNumber( File ),
    Density = extractDensity( File ),
    Beta = extractBeta( File ),
    `Effect matrix F-measure` = 2 / ( (1/`Effect matrix precision`) + (1/`Effect matrix recall`) ),
    `Pairwise ancestry F-measure` = 2 / ( (1/`Pairwise ancestry precision`) + (1/`Pairwise ancestry recall`) ) )

## Make sure plots folder exists
dir.create("plots")

## Main simulation result figure

main.df <- results.df %>%
  filter(
    Beta == 10,
    Rep <= 30,
    `Learning k` <= 8,
    ( ( Actions < 20 ) & ( Density == 0.2 ) ) | ( ( Actions == 20 ) & ( Density == 0.04 ) ) )

ggplot( main.df, aes( x = `Learning k`, y = `Effect matrix F-measure`, group = `Learning k` ) ) +
  facet_grid( `True k` ~ `Actions`, labeller = label_both, scales="free_y" ) +
  geom_boxplot( outlier.size = 0.1, lwd = 0.25 )

ggsave("plots/effect-f-measures.pdf", width = 4, height = 4, units = "in" )

ggplot( main.df, aes( x = `Learning k`, y = `Pairwise ancestry F-measure`, group = `Learning k` ) ) +
  facet_grid( `True k` ~ `Actions`, labeller = label_both ) +
  geom_boxplot( outlier.size = 0.1, lwd = 0.25 )

ggsave("plots/ancestries-f-measures.pdf", width = 4, height = 4, units = "in" )

## Noise runs figure
noise.df.for.mark <- results.df %>%
  filter(
    ( ( Actions == 5 ) & ( Rep <= 20 ) ) | ( ( Actions == 20 ) & ( Rep <= 5 ) ),
    `True k` %in% c(1,3,5),
    `Learning k` <= 8 )

ggplot( noise.df.for.mark, aes( x = `Learning k`, y = `Effect matrix F-measure`, group = `Learning k` ) ) +
  facet_grid( `True k` ~ `Actions` + Beta, labeller = label_both ) +
  geom_boxplot( outlier.size = 0.1, lwd = 0.25 )

ggsave("plots/effect-all-noise-f-measures.pdf", width = 12, height = 4, units = "in" )

ggplot( noise.df.for.mark, aes( x = `Learning k`, y = `Pairwise ancestry F-measure`, group = `Learning k` ) ) +
  facet_grid( `True k` ~ `Actions` + Beta, labeller = label_both ) +
  geom_boxplot( outlier.size = 0.1, lwd = 0.25 )

ggsave("plots/ancestries-all-noise-f-measures.pdf", width = 12, height = 4, units = "in" )

noise.df.for.paper <- results.df %>%
  filter(
    Actions == 20,
    Rep <= 10,
    `True k` %in% c(1,3,5),
    `Learning k` <= 8 )

ggplot( noise.df.for.paper, aes( x = `Learning k`, y = `Effect matrix F-measure`, group = `Learning k` ) ) +
  facet_grid( `True k` ~ Beta, labeller = label_both ) +
  geom_boxplot( outlier.size = 0.1, lwd = 0.25 )

ggsave("plots/effect-noise-f-measures.pdf", width = 4, height = 3, units = "in" )

## Density runs figure

density.df <- results.df %>%
  filter(
    Actions == 10,
    Rep <= 20,
    `True k` %in% c(1,3,5),
    `Learning k` <= 8 )

ggplot( density.df, aes( x = `Learning k`, y = `Effect matrix F-measure`, group = `Learning k` ) ) +
  facet_grid( `True k` ~ Density, labeller = label_both ) +
  geom_boxplot( outlier.size = 0.1, lwd = 0.25 )

ggsave("plots/effect-density-f-measures.pdf", width = 4, height = 3, units = "in" )

#results.with.aicc <- results.df %>%
#  mutate(
#    Parameters = `Effects` + `Learning k`*( `Actions` * ( `Actions` - 1 ) ),
#    AIC = 2 * Parameters - 2 * `Log likelihood`,
#    AICc = AIC + 2 * Parameters * ( Parameters + 1 ) / ( Effects - Parameters - 1 ) )

#ggplot( results.df, aes( x = `Learning k`, y = `Pairwise ancestry recall`, group = `Learning k`, color = `Rep` ) ) +
#  facet_grid( `True k` ~ `Actions`, labeller = label_both ) +
#  geom_boxplot()
#  geom_jitter( position = position_jitter( width = 0.15 ) )

ggplot( main.df%>%filter(`True k` == 3, Actions == 20), aes( x = `Learning k`, y = `Effect matrix F-measure`, group = `Learning k` ) ) +geom_boxplot()
ggsave("plots/effect-for-pres.pdf", width = 6, height = 3, units = "in" )
