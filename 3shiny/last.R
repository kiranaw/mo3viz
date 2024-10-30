# Load necessary libraries
library(shiny)
library(sf)
library(ggplot2)
library(dplyr)
library(data.table)
library(viridis)  # For color palettes

# Load spatial grid data
grid <- read_sf("~/MO3/2mapviz/test_grid_40K_2.gpkg")

# Load breeding_site_data
breeding_site_data <- breeding_site_data #readRDS("~/MO3/1dataprocess/updated_breeding_site_data.rds")

# Convert to data table for fast operations
grid_dt <- as.data.table(grid)
breeding_site_data_dt <- as.data.table(breeding_site_data)

# Define the Shiny app
ui <- fluidPage(
  titlePanel("Breeding Site Data Visualization"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("day_slider", "Select Day:", 
                  min = min(breeding_site_data$day), 
                  max = max(breeding_site_data$day), 
                  value = min(breeding_site_data$day), 
                  step = 1, 
                  animate = TRUE)
    ),
    
    mainPanel(
      plotOutput("wbs_map")
    )
  )
)

server <- function(input, output, session) {
  
  # Reactive expression to filter the data based on selected day
  filtered_data <- reactive({
    # Filter the breeding_site_data for the selected day
    breeding_site_data_day <- breeding_site_data_dt[day == input$day_slider]
    
    # Merge with the grid
    merged_data <- grid_dt[breeding_site_data_day, on = .(id_maille = cell)]
    
    # Convert to sf object for plotting
    merged_data_sf <- st_as_sf(merged_data)
    
    return(merged_data_sf)
  })
  
  # Render the plot
  output$wbs_map <- renderPlot({
    ggplot(filtered_data()) +
      geom_sf(aes(fill = wbs), color = NA) +  # Use 'wbs' as the fill variable
      scale_fill_viridis_c(option = "plasma", name = "WBS Value") +  # Use viridis color palette
      theme_minimal() +
      labs(title = paste("Breeding Site Data Visualization for Day", input$day_slider), 
           subtitle = "Mapped WBS Values")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
