#' Script for converting generated RData to JSON. Included for historical reasons
#' @author Yuriy Sverchkov

library("jsonlite")
library("glue")
library("futile.logger")

#' Turn a logical matrix object into a tuple-list
#' @param m a logical matrix
#' @return a list with two named entities: dim, the dimensions, and nonzeros, a matrix that has a row for each nonzero
#' and whose column correspond to (1-based) row and column indeces
sparseLogicalMatrixToList <- function( m ) list(
  dim = dim( m ),
  nonzeros = Matrix::which( m, arr.ind = T )
)

# Origin and destination folders
rdata.truths.folder <- "rdata/truths"
json.truths.folder <- "json/truths"
rdata.data.folder <- "rdata/data"
json.data.folder <- "json/data"

# Make sure output folder exists
dir.create( json.truths.folder, recursive = T )

# Loop for truths
for ( file in list.files( rdata.truths.folder ) ) {
  rdata.file <- glue( "{rdata.truths.folder}/{file}" )
  json.filename <- sub( ".RData", ".json", file, fixed = T ) 
  json.file <- glue( "{json.truths.folder}/{json.filename}" )
  if ( file.exists( json.file ) ) flog.warn( glue( "{json.file} exists, skipping." ) )
  else {
    flog.info( glue( "{rdata.file} -> {json.file}" ) )
    env <- new.env()
    load( rdata.file, envir = env )
    flog.info( "RData loaded" )
    l <- as.list( env )
    l$learning.time <- as.list( env$learning.time )
    l$efmx <- sparseLogicalMatrixToList( env$efmx )
    l$mtxs <- Map( sparseLogicalMatrixToList, env$mtxs )
    j <- toJSON( l, digits = I(13) )
    write( j, json.file )
    flog.info( "JSON written" )
  }
}

# Make sure output folder exists
dir.create( json.data.folder, recursive = T )

# Loop for data
for ( file in list.files( rdata.data.folder ) ) {
  rdata.file <- glue( "{rdata.data.folder}/{file}" )
  json.filename <- sub( ".RData", ".json", file, fixed = T ) 
  json.file <- glue( "{json.data.folder}/{json.filename}" )
  rdata.truth.filename <- sub( "-b[0-9]+", "", sub( "data", "truth", file, fixed = T ) )
  rdata.truth.file <- glue( "{rdata.truths.folder}/{rdata.truth.filename}" )
  if (file.exists( json.file ) ) flog.warn( glue( "{json.file} exists, skipping." ) )
  else {
    flog.info( glue( "{rdata.file} -> {json.file}" ) )
    data.env <- new.env()
    truth.env <- new.env()
    load( rdata.file, envir = data.env )
    load( rdata.truth.file, envir = truth.env )
    flog.info( "RData loaded" )
    
    l.truth <- as.list( truth.env )
    l.data <- l.d.truth <- as.list( data.env )
    l.d.truth$D <- NULL
    l.d.truth$beta.parameter <- NULL
    l.data <- l.data[c("D","beta.parameter")]
    
    all.equal.report <- all.equal( l.truth, l.d.truth )
    
    # Verify the truth
    if ( isTRUE( all.equal.report ) ) {
      j <- toJSON( l.data, digits = I(13) )
      write( j, json.file )
      flog.info( "JSON written" )
    } else {
      flog.error( "Truth mismatch!", all.equal.report, capture = T )
    }
  }
}

# Loop for models
flog.warn( "Writing models to json not impelemented" )