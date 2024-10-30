# Load the datasets
breeding_site_data <- readRDS("combined_breeding_site_data_with_ratios_no_na_columns.rds")
mosquito_stock_data <- readRDS("combined_mosquito_stock_data_with_ratios_no_na_columns.rds")

# Check the structure of the breeding site dataset
cat("Breeding Site Data Structure:\n")
str(breeding_site_data)

# Check the structure of the mosquito stock dataset
cat("\nMosquito Stock Data Structure:\n")
str(mosquito_stock_data)

# Summary statistics to compare the number of columns and rows
cat("\nBreeding Site Data - Dimensions:\n")
print(dim(breeding_site_data))  # Number of rows and columns

cat("\nMosquito Stock Data - Dimensions:\n")
print(dim(mosquito_stock_data))  # Number of rows and columns

breeding_site_data_fixcellid <- breeding_site_data

mosquito_stock_data_fixcellid <- mosquito_stock_data

# Update the 'cell' column by adding 1 to align with the .gpkg file
breeding_site_data_fixcellid <- breeding_site_data_fixcellid %>%
  mutate(cell = cell + 1)

mosquito_stock_data_fixcellid <- mosquito_stock_data_fixcellid %>%
  mutate(cell = cell + 1)

# Save the updated datasets to new .rds files
saveRDS(breeding_site_data_fixcellid, "updated_breeding_site_data.rds")
saveRDS(mosquito_stock_data_fixcellid, "updated_mosquito_stock_data.rds")


