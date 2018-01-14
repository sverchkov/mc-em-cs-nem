#' Script to monitor model generation progress
#' @author Yuriy Sverchkov

library("glue")
library("dplyr")

n.actions.range <- 1:20
n.effects.range <- 1000
true.k.range <- 1:5
learning.k.range <- 1:10
rep.range <- 1:50
density.range <- c( 0.04, 0.1, 0.2, 0.5 )
beta.range <- c( 1, 2, 5, 10 )

model.candidates <- expand.grid(
  n.actions = n.actions.range,
  n.effects = n.effects.range,
  true.k = true.k.range,
  learning.k = learning.k.range,
  rep = rep.range,
  edge.density = density.range,
  beta.parameter = beta.range ) %>%
  mutate( filename = glue("rdata/models/model-r{rep}-n{n.actions}-e{n.effects}-d{edge.density}-k{true.k}-b{beta.parameter}-l{learning.k}.RData"),
          exists = file.exists( filename ) )
