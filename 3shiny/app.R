# Load necessary libraries
library(shiny)
library(sf)
library(ggplot2)
library(dplyr)
library(data.table)
library(viridis)  # For color palettes

# Load spatial grid data and subdistricts
grid <- read_sf("~/MO3/2mapviz/test_grid_40K_2.gpkg")
dopa <- read_sf("~/MO3/2mapviz/dopa_shp_2020.shp")

# Load breeding site data and mosquito stock data (for AM)
breeding_site_data <- readRDS("updated_breeding_site_data.rds")  # Or load the data from RDS if needed
mosquito_stock_data <- mosquito_stock_data  # The dataset containing 'AM' values

# Convert grid and breeding site data to data tables for fast operations
grid_dt <- as.data.table(grid)
breeding_site_data_dt <- as.data.table(breeding_site_data)
mosquito_stock_data_dt <- as.data.table(mosquito_stock_data)

# Convert the subdistrict shapefile's column and rename it
dopa <- dopa %>% dplyr::select(SUBDISTRI) %>% rename(kw = SUBDISTRI)

# Convert grid to centroids (as each cell is smaller than subdistricts)
grid_pts <- grid %>% st_centroid()

# Intersect the grid points with subdistricts (kw)
grid_pts <- grid_pts %>% st_intersection(dopa)

# Keep only relevant columns (id_maille, kw)
grid_pts <- grid_pts %>% st_drop_geometry() %>%
  dplyr::select(id_maille, kw)

# Load sensitivity analysis results
sensitivity_results <- read.csv("~/MO3/1dataprocess/sensitivity_results_all_columns.csv")  # Load the precomputed sensitivity results

# Define the Shiny app UI
ui <- navbarPage(
  title = "Mosquito Stock Visualization and Sensitivity Analysis",
  
  # First tab: Side-by-side map of WBS and AM
  tabPanel("Map Visualization",
           fluidPage(
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
                 fluidRow(
                   column(6, plotOutput("wbs_map")),   # WBS Map
                   column(6, plotOutput("am_map"))     # AM Map
                 )
               )
             )
           )
  ),
  
  # Second tab: Sensitivity Analysis
  tabPanel("Sensitivity Analysis",
           fluidPage(
             sidebarLayout(
               sidebarPanel(),
               mainPanel(
                 plotOutput("sensitivity_plot"),
                 tableOutput("sensitivity_table")
               )
             )
           )
  )
)

# Define the Shiny app server logic
server <- function(input, output, session) {
  
  # Reactive expression to filter and aggregate the WBS data based on the selected day
  filtered_wbs_data <- reactive({
    breeding_site_data_day <- breeding_site_data_dt[day == input$day_slider]
    
    grid_merged <- grid_pts %>%
      left_join(breeding_site_data_day, by = c("id_maille" = "cell"))
    
    subdistrict_aggregated <- grid_merged %>%
      group_by(kw) %>%
      summarise(wbs_sum = sum(wbs, na.rm = TRUE))
    
    dopa_aggregated <- dopa %>%
      left_join(subdistrict_aggregated, by = "kw")
    
    return(dopa_aggregated)
  })
  
  # Reactive expression to filter and aggregate the AM data based on the selected day
  filtered_am_data <- reactive({
    mosquito_stock_data_day <- mosquito_stock_data_dt[day == input$day_slider]
    
    grid_merged <- grid_pts %>%
      left_join(mosquito_stock_data_day, by = c("id_maille" = "cell"))
    
    subdistrict_aggregated <- grid_merged %>%
      group_by(kw) %>%
      summarise(am_sum = sum(am, na.rm = TRUE))
    
    dopa_aggregated <- dopa %>%
      left_join(subdistrict_aggregated, by = "kw")
    
    return(dopa_aggregated)
  })
  
  # Render WBS map
  output$wbs_map <- renderPlot({
    ggplot(filtered_wbs_data()) +
      geom_sf(aes(fill = wbs_sum), color = NA) +
      scale_fill_viridis_c(option = "plasma", name = "Total WBS Value") +
      theme_minimal() +
      labs(title = paste("Aggregated WBS Values by Subdistrict for Day", input$day_slider), 
           subtitle = "Visualizing the total WBS values per subdistrict")
  })
  
  # Render AM map
  output$am_map <- renderPlot({
    ggplot(filtered_am_data()) +
      geom_sf(aes(fill = am_sum), color = NA) +
      scale_fill_viridis_c(option = "inferno", name = "Total AM Value") +
      theme_minimal() +
      labs(title = paste("Aggregated AM Values by Subdistrict for Day", input$day_slider), 
           subtitle = "Visualizing the total AM values per subdistrict")
  })
  
  # Sensitivity plot
  output$sensitivity_plot <- renderPlot({
    ggplot(sensitivity_results, aes(x = ratio)) +
      geom_line(aes(y = total_eow, color = "eow")) +
      geom_line(aes(y = total_ew, color = "ew")) +
      geom_line(aes(y = total_j, color = "j")) +
      geom_line(aes(y = total_am, color = "am")) +
      geom_line(aes(y = total_mp, color = "mp")) +
      geom_line(aes(y = total_mb, color = "mb")) +
      scale_color_manual(values = c("eow" = "blue", "ew" = "green", "j" = "purple", 
                                    "am" = "red", "mp" = "orange", "mb" = "brown")) +
      theme_minimal() +
      labs(title = "Sensitivity Analysis by Ratio",
           x = "Ratio", y = "Total Value",
           color = "Variables")
  })
  
  # Sensitivity summary table
  output$sensitivity_table <- renderTable({
    sensitivity_results
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
