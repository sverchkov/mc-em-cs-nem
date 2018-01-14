source.dir <- "rdata"
dest.truths.dir <- "rdata/truths"
dest.data.dir <- "rdata/data"
dest.models.dir <- "rdata/models"


source.model.files <- list.files( path = source.dir, pattern = ".*model.*.RData", full.names = TRUE )
nonempty = file.info( source.model.files )$size > 0
source.model.files <- source.model.files[ nonempty ]

for ( source.model.file in source.model.files ){
  sf.env <- new.env()
  load( file = source.model.file, envir = sf.env )
  
  n.actions <- sf.env$n.actions
  n.effects <- sf.env$n.effects
  true.k <- sf.env$true.k
  learning.k <- sf.env$learning.k
  edge.density <- sf.env$edge.density
  beta.parameter <- sf.env$beta.parameter
  learning.k <- sf.env$learning.k
  mtxs <- sf.env$mtxs
  efmx <- sf.env$efmx
  D <- sf.env$D
  
  truth.spec <- glue( "n{n.actions}-e{n.effects}-d{edge.density}-k{true.k}" )
  data.spec <- glue( "{truth.spec}-b{beta.parameter}" )
  model.spec <- glue( "{data.spec}-l{learning.k}" )

  print( model.spec )  
  
  # Here we figure out which rep this really is
  
  rep.str = NULL
  found.data = FALSE
  
  data.source.candidates <- list.files( path = dest.data.dir, pattern = glue( "^data-r[[:digit:]]+-{data.spec}.RData$" ) )

  for ( data.source.candidate in glue( "{dest.data.dir}/{data.source.candidates}" ) ) if ( !found.data ){
    data.env <- new.env()
    load( file = data.source.candidate, envir = data.env )
    if ( all( sf.env$D == data.env$D ) ) {
      rep.str <- str_extract( data.source.candidate, "r[[:digit:]]" )
      found.data <- TRUE
    }
  }
  
  if ( !found.data ) {
    rep.num <- 1
    found.truth = FALSE
    while( !found.truth ) {
      truth.candidate <- glue( "{dest.truths.dir}/truth-r{rep.num}-{truth.spec}.RData" )
      
      if( file.exists( truth.candidate ) ) {
        truth.env <- new.env()
        load( file = truth.candidate, envir = truth.env )
        if ( all( sf.env$efmx == truth.env$efmx ) &&
             Reduce( `&`, Map( function(a,b) all(a==b), sf.env$mtxs, truth.env$mtxs ) ) ){
          rep.str <- glue( "r{rep.num}" )
          found.truth <- TRUE
        } else rep.num <- rep.num + 1
      } else {
        save( true.k, n.actions, n.effects, edge.density, mtxs, efmx, file = truth.candidate )
        rep.str <- glue( "r{rep.num}" )
        found.truth = TRUE
      }
    }
    
    save( true.k, n.actions, n.effects, edge.density, mtxs, efmx, beta.parameter, D, file = glue( "{dest.data.dir}/data-{rep.str}-{data.spec}.RData" ) )
  }
  
  file.copy( from = source.model.file, to = glue( "{dest.models.dir}/model-{rep.str}-{model.spec}.RData" ) )
}