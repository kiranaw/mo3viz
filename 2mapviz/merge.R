library(sf)
library(dplyr)
library(ggplot2)

# Load the 40k-cell GeoPackage (.gpkg)
map_40k <- st_read("PBS_estim_lite_40k.gpkg")

# Load the 160-cell shapefile (.shp)
map_160 <- st_read("shp_kw_160_2022.shp")

# Load the updated breeding site and mosquito stock datasets
breeding_site_data <- readRDS("updated_breeding_site_data.rds")
mosquito_stock_data <- readRDS("updated_mosquito_stock_data.rds")

# Merge breeding site and mosquito stock data by 'cell' and 'day'
sim_result <- inner_join(breeding_site_data, mosquito_stock_data, 
                         by = c("cell" = "cell", "hour" = "hour", "ratio" = "ratio"))

sim_result <- sim_result %>%
  mutate(day = floor(hour / 24))

# Join simulation data with the 40k cells (adjust 'id_maille' to match the column name in map_40k)
# mapjoin_40k <- inner_join(sim_result, map_40k, by = c("cell" = "id_maille"))
# 
# # Assign each of the 40k cells to one of the 160 larger cells using a spatial join
# # This step uses the centroids of the 40k cells and intersects them with the 160 cells
# cell_district <- mapjoin_40k %>%
#   st_centroid() %>%
#   st_intersection(map_160) %>%
#   st_drop_geometry()

mapjoin_40k_sf <- st_as_sf(mapjoin_40k)  # No need for coords if geometry is present

# Now you can apply st_centroid and st_intersection
cell_district <- mapjoin_40k_sf %>%
  st_centroid() %>%
  st_intersection(map_160) %>%
  st_drop_geometry()

# Merge the district (160-cell) information back into the mapjoin_40k dataset
mapjoin <- mapjoin_40k %>%
  left_join(cell_district, by = "id_grid")  # Adjust 'id_maille' as necessary

# Aggregate the data by the 160 larger cells (CODE), day, and scenario (ratio)
sim_result_mean <- mapjoin %>%
  group_by(CODE, day, ratio) %>%
  summarize(mean_wbs = mean(wbs, na.rm = TRUE),
            mean_am = mean(am, na.rm = TRUE)) %>%
  ungroup()

# Join with the 160-cell spatial data for final plotting
amwbsjoin <- inner_join(sim_result_mean, map_160, by = c("CODE" = "CODE")) %>%
  st_as_sf()

# Plot the result for a specific day and scenario
plot(amwbsjoin %>% filter(day == 30, ratio == 0.5) %>% select(-CODE, -day, -ratio))

