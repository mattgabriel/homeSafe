library(shiny)
library(shinydashboard)
library(shinyjs)

source("/Users/d.timmers1/hackaway/dutchopen2016/homeSafe/Demo/shiny/liveData.R")
source("/Users/d.timmers1/hackaway/dutchopen2016/homeSafe/Demo/shiny/temperature.R")

ui <- dashboardPage(
  dashboardHeader(title = "AUTONO-ME"),
  
  dashboardSidebar(),
  
  dashboardBody(
    useShinyjs(),
    fluidRow(
      box(width = 12, plotOutput("plotLive", height = 200))
      ),
    fluidRow(
      box(width = 12, plotOutput("plotTemperature", height = 300))
    ),
    fluidRow(
      box(width = 12, plotOutput("plotAirQuality", height = 200))
    ),
    fluidRow(
      box(width = 6, 
          img(src = "toothbrush.svg", height = 250),
          height = 300),
      box(width = 6, 
          img(src = "kettle.svg", height = 250),
          height = 300)
    )
  )
)

server <- function(input, output, session) {
  addClass(selector = "body", class = "sidebar-collapse") #make sure sidebar is hidden
  refreshRate <- 3 * 1000 #milliseconds
  stepSize <- 4 * 6 # 6 hours
  windowSize <- 4 * 24 # 24 hours
  
  startIdx <- reactiveValues(counter = 0)
  alertStatus <- reactiveValues(low = TRUE, high = TRUE)
  
  sourceData <- reactive({
    invalidateLater(refreshRate, session)
    startIdx$counter <- isolate(startIdx$counter) + 1
    getLiveData()
  }) 
  
  output$plotLive <- renderPlot({ 
    plotLiveData(sourceData()) })
  
  output$plotTemperature <- renderPlot({ 
    newAlertStatus <- plotTemperature(1 + startIdx$counter * stepSize, windowSize, 
                                      alertStatus$low, alertStatus$high) 
    if(isolate(alertStatus$low)){
      alertStatus$low <- newAlertStatus$low
    }
    if(isolate(alertStatus$high)){
      alertStatus$high <- newAlertStatus$high
    }
  })
  
  output$plotAirQuality <- renderPlot({ 
    plotAirQuality(1 + startIdx$counter * stepSize, windowSize) 
  })
}

shinyApp(ui, server)