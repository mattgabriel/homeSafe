library(shiny)
library(shinydashboard)
source("/Users/d.timmers1/hackaway/dutchopen2016/homeSafe/Demo/shiny/liveData.R")

ui <- dashboardPage(
  dashboardHeader(title = "AUTONOMOUS-ME"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Live data", tabName = "live_data", icon = icon("dashboard")),
      menuItem("Widgets", tabName = "widgets", icon = icon("th"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Tab content for live data
      tabItem(tabName = "live_data",
              fluidRow(
                box(width = 12, plotOutput("plotLive", height = 800))
              )
      ),
      
      # Second tab content
      tabItem(tabName = "widgets",
              h2("Widgets tab content")
      )
    )
  )
)

server <- function(input, output, session) {
  refreshRate <- 4 * 1000 #milliseconds
  
  sourceData <- reactive({
    invalidateLater(refreshRate, session)
    
    getLiveData()
  }) 
  
  output$plotLive <- renderPlot({ plotLiveData(sourceData()) })
}

shinyApp(ui, server)