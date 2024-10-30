library(shiny)
library(shinydashboard)
library(leaflet)
library(sf)
library(dplyr)
library(ggplot2)
library(grid)
library(png)

# Load your validated data
sim_result <- readRDS("sim_result_valid.rds")

# Available days for which static images have been pre-generated
available_days <- c(55, 87, 115, 153, 181, 287, 357)

# Shiny app UI
ui <- dashboardPage(
  dashboardHeader(title = "My Shiny App"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Animated Map", tabName = "map", icon = icon("map"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              h2("Animated Map with Leaflet on Demand"),
              fluidRow(
                column(12, plotOutput("ggplot_map", height = "400px", width = "600px"))
              ),
              fluidRow(
                column(12, sliderInput("day_in_slider", 
                                       label = "Day of Year",
                                       min = 1, 
                                       max = length(available_days), 
                                       value = 1,
                                       step = 1,
                                       animate = animationOptions(interval = 2000, loop = TRUE),
                                       ticks = FALSE))
              ),
              fluidRow(
                column(12, actionButton("show_leaflet", "Show Leaflet Map"))
              ),
              fluidRow(
                column(12, uiOutput("leaflet_ui"))
              )
      )
    )
  )
)

# Shiny app server
server <- function(input, output, session) {
  
  # Convert slider index to the actual day
  current_day <- reactive({
    available_days[input$day_in_slider]
  })
  
  # Render the ggplot2 map for the current day
  output$ggplot_map <- renderPlot({
    day <- current_day()
    
    # Load the pre-rendered image
    img_path <- paste0("wbs_images/wbs_day_", day, ".png")
    img <- png::readPNG(img_path)
    
    ggplot() + 
      annotation_custom(rasterGrob(img, width = unit(1, "npc"), height = unit(1, "npc")), 
                        xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf) + 
      theme_void() +
      ggtitle(paste("Day:", day))
  })
  
  # Placeholder UI for the leaflet map, hidden by default
  output$leaflet_ui <- renderUI({
    if (input$show_leaflet == 0) {
      return(NULL)  # Hide the leaflet map initially
    }
    leafletOutput("leaflet_map", height = "400px", width = "600px")  # Matching height and width for consistent layout
  })
  
  # Set up the Leaflet map, only rendered after the button is clicked
  observeEvent(input$show_leaflet, {
    # Filter the data for the current day
    filtered_data <- sim_result %>% filter(day == current_day())
    
    # Print the filtered data to console to debug
    print(filtered_data)
    
    # Check if the filtered data has any rows
    if (nrow(filtered_data) > 0) {
      output$leaflet_map <- renderLeaflet({
        leaflet(data = filtered_data) %>%
          addTiles() %>%
          addPolygons(
            fillColor = ~colorNumeric(palette = "YlOrRd", domain = filtered_data$mean_wbs)(mean_wbs),
            weight = 1,
            color = "lightgrey",
            fillOpacity = 0.7,
            popup = ~paste("Region:", CODE, "<br>WBS:", mean_wbs)
          ) %>%
          fitBounds(lng1 = 100.45, lat1 = 13.7, lng2 = 100.55, lat2 = 13.8) %>%
          setView(lng = 100.492, lat = 13.753, zoom = 10.3)
      })
    } else {
      output$leaflet_map <- renderLeaflet({
        leaflet() %>% addTiles() %>% setView(lng = 100.492, lat = 13.753, zoom = 10.3)
      })
    }
  })
}

shinyApp(ui, server)
