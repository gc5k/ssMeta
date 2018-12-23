#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Old Faithful Geyser Data"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("bins",
                     "Number of bins:",
                     min = 1,
                     max = 50,
                     value = 30),
         selectInput("snpID", "SNP", choices=sort(ceiling(runif(10, 1, 100))), multiple = TRUE),
         textInput("snpText", "SNP Name", value = "Enter SNP..."),
         downloadButton("report", "Generate report")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot(
     {
      # generate bins based on input$bins from ui.R
      x    <- faithful[, 2] 
      bins <- seq(min(x), max(x), length.out = input$bins + 1)
      
      # draw the histogram with the specified number of bins
      hist(x, breaks = bins, col = 'darkgray', border = 'white')
      
     }
   )

   output$report <- downloadHandler(
     # For PDF output, change this to "report.pdf"
     filename = "report.html",
     content = function(file) {
       # Copy the report file to a temporary directory before processing it, in
       # case we don't have write permissions to the current working dir (which
       # can happen when deployed).
       tempReport <- file.path(tempdir(), "report.Rmd")
       file.copy("report.Rmd", tempReport, overwrite = TRUE)
       
       # Set up parameters to pass to Rmd document
#       params <- list(n = input$slider)
       
       # Knit the document, passing in the `params` list, and eval it in a
       # child of the global environment (this isolates the code in the document
       # from the code in this app).
       write.table(input$bins, "haha.txt", row.names = F, col.names = F, quote = F)

#       rmarkdown::render(tempReport, output_file = file,
#                         params = params,
#                         envir = new.env(parent = globalenv())
#       )
     }
   )
}

# Run the application 
shinyApp(ui = ui, server = server)

