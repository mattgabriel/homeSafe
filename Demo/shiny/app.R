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
                box(plotOutput("plot1", height = 250))
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
  refreshRate <- 5 * 1000 #milliseconds
  
  sourceData <- reactive({
    invalidateLater(refreshRate, session)
    
    getData()
  })  
  
}

shinyApp(ui, server)