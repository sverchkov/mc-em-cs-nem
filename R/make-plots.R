# Make figures for paper

library("dplyr")
library("ggplot2")

results.df <-
  read.csv( file = "csv/table-of-results-v4.csv", check.names = FALSE, stringsAsFactors = FALSE ) %>%
  mutate( `Effect matrix F-measure` = 2 / ( (1/`Effect-wise precision`) + (1/`Effect-wise recall`) ) ) %>%
  mutate( `Ancestry set F-measure` = 2 / ( (1/`Parent pattern precision`) + (1/`Parent pattern recall`) ) )

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

ggplot( results.with.aicc, aes( x = `Learning k`, y = `AIC`, group = `Learning k` ) ) +
  facet_grid( `True k` ~ `Actions`, labeller = label_both ) +
  geom_boxplot( alpha = 0, color = "red" ) +
  geom_jitter( position = position_jitter( width = 0.15 ) )
