# Load necessary libraries
library(sf)
library(ggplot2)
library(dplyr)
library(data.table)
library(viridis)  # For color palettes

# Load spatial grid data and subdistricts
grid <- read_sf("~/MO3/2mapviz/test_grid_40K_2.gpkg")
dopa <- read_sf("~/MO3/2mapviz/dopa_shp_2020.shp")

# Load breeding site data
breeding_site_data <- breeding_site_data # Or load the data from RDS if needed
# breeding_site_data <- readRDS("~/MO3/1dataprocess/updated_breeding_site_data.rds")

# Convert grid and breeding site data to data tables for fast operations
grid_dt <- as.data.table(grid)
breeding_site_data_dt <- as.data.table(breeding_site_data)

# Convert the subdistrict shapefile's column and rename it
dopa <- dopa %>% dplyr::select(SUBDISTRI) %>% rename(kw = SUBDISTRI)

# Convert grid to centroids (as each cell is smaller than subdistricts)
grid_pts <- grid %>% st_centroid()

# Intersect the grid points with subdistricts (kw)
grid_pts <- grid_pts %>% st_intersection(dopa)

# Keep only relevant columns (id_maille, kw)
grid_pts <- grid_pts %>% st_drop_geometry() %>%
  dplyr::select(id_maille, kw)

# Merge grid points with the breeding site data on id_maille (cell)
grid_merged <- grid_pts %>%
  left_join(breeding_site_data_dt, by = c("id_maille" = "cell"))

# Aggregate the wbs values by subdistrict (kw)
subdistrict_aggregated <- grid_merged %>%
  group_by(kw) %>%
  summarise(wbs_sum = sum(wbs, na.rm = TRUE))  # Aggregate sum of wbs values per subdistrict

# Merge the aggregated wbs data with the subdistrict shapefile
dopa_aggregated <- dopa %>%
  left_join(subdistrict_aggregated, by = "kw")

# Plot the aggregated map with subdistricts and their corresponding wbs values
ggplot(dopa_aggregated) +
  geom_sf(aes(fill = wbs_sum), color = NA) +  # Fill by aggregated wbs values
  scale_fill_viridis_c(option = "plasma", name = "Total WBS Value") +  # Color palette for fill
  theme_minimal() +
  labs(title = "Aggregated WBS Values by Subdistrict", 
       subtitle = "Visualizing the total WBS values per subdistrict")
