#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Performance on simulated results"),
   
   plotOutput("plotEP"),
   plotOutput("plotER"),
   plotOutput("plotAP"),
   plotOutput("plotAR"),
   
   dataTableOutput("resultsTable")
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  resultsData <- reactive( read.csv( file = "../csv/table-of-results.csv", check.names = FALSE, stringsAsFactors = FALSE ) )

  output$resultsTable <- renderDataTable( resultsData() )

  output$plotEP <- renderPlot(
    ggplot( resultsData(), aes( x = `Learning k`, y = `Effect-wise precision`, group = `Learning k` ) ) +
      facet_grid( `True k` ~ `Actions`, labeller = label_both ) +
      geom_boxplot( alpha = 0, color = "red" ) +
      geom_jitter( position = position_jitter( width = 0.15 ) )
  )

  output$plotER <- renderPlot(
    ggplot( resultsData(), aes( x = `Learning k`, y = `Effect-wise recall`, group = `Learning k` ) ) +
      facet_grid( `True k` ~ `Actions`, labeller = label_both ) +
      geom_boxplot( alpha = 0, color = "red" ) +
      geom_jitter( position = position_jitter( width = 0.15 ) )
  )

  output$plotAP <- renderPlot(
    ggplot( resultsData(), aes( x = `Learning k`, y = `Parent pattern precision`, group = `Learning k` ) ) +
      facet_grid( `True k` ~ `Actions`, labeller = label_both ) +
      geom_boxplot( alpha = 0, color = "red" ) +
      geom_jitter( position = position_jitter( width = 0.15 ) )
  )
  
  output$plotAR <- renderPlot(
    ggplot( resultsData(), aes( x = `Learning k`, y = `Parent pattern recall`, group = `Learning k` ) ) +
      facet_grid( `True k` ~ `Actions`, labeller = label_both ) +
      geom_boxplot( alpha = 0, color = "red" ) +
      geom_jitter( position = position_jitter( width = 0.15 ) )
  )
  
}

# Run the application 
shinyApp(ui = ui, server = server)

