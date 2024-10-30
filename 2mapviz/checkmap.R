# Load the required libraries
library(sf)

# Load the .gpkg file (replace the path with your actual file path)
gpkg_file <- st_read("test_grid_40K.gpkg")

# Check the structure of the GeoPackage
print(gpkg_file)

# Check the number of cells (features) in the .gpkg file
num_cells <- nrow(gpkg_file)
cat("Number of cells in the GeoPackage:", num_cells, "\n")


# Assuming gpkg_file is your .gpkg file and sim_result contains the dataset
gpkg_cell_ids <- gpkg_file$id_maille  # Replace with the actual column name for cellID in your .gpkg
dataset_cell_ids <- unique(mosquito_stock_data$cell)  # Assuming sim_result is your dataset

# Find the missing cellID
missing_cells <- setdiff(gpkg_cell_ids, dataset_cell_ids)
cat("Missing cellID(s):", missing_cells, "\n")
