# Load necessary libraries
library(sf)
library(ggplot2)
library(dplyr)
library(data.table)
library(viridis)  # For color palettes

# Load spatial grid data
grid <- read_sf("~/MO3/2mapviz/test_grid_40K_2.gpkg")

# Load breeding_site_data
breeding_site_data <- breeding_site_data # Or load your data from RDS if needed
# breeding_site_data <- readRDS("~/MO3/1dataprocess/updated_breeding_site_data.rds")

# Convert to data table for fast operations
grid_dt <- as.data.table(grid)
breeding_site_data_dt <- as.data.table(breeding_site_data)

# Define the day you want to visualize (for example, day 1)
selected_day <- 1

# Filter the breeding_site_data for the selected day
breeding_site_data_day <- breeding_site_data_dt[day == selected_day]

# Merge with the grid
merged_data <- grid_dt[breeding_site_data_day, on = .(id_maille = cell)]

# Convert to sf object for plotting
merged_data_sf <- st_as_sf(merged_data)

# Create the map plot
ggplot(merged_data_sf) +
  geom_sf(aes(fill = wbs), color = NA) +  # Use 'wbs' as the fill variable
  scale_fill_viridis_c(option = "plasma", name = "WBS Value") +  # Use viridis color palette
  theme_minimal() +
  labs(title = paste("Breeding Site Data Visualization for Day", selected_day), 
       subtitle = "Mapped WBS Values")
