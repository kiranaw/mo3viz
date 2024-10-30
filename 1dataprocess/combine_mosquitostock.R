# Load required libraries
library(data.table)
library(parallel)

# Generate a list of ratios and corresponding filenames for mosquito-stock dataset
ratios <- seq(0.0, 1.0, by = 0.1)
filenames <- sprintf("dataset_ratio-%.1f.json.gz_mosquito-stock-updated.rds", ratios)

# Detect the number of available cores and use 90% of them
num_cores <- detectCores()
num_cores_to_use <- floor(num_cores * 0.9)

# Function to read, add ratio, and remove columns with only NA values
process_dataset <- function(filename, ratio) {
  # Read the dataset
  dataset <- readRDS(filename)
  
  # Add a new column 'ratio' to indicate the ratio for the current dataset
  dataset[, ratio := ratio]
  
  # Remove columns that contain only NA values
  dataset <- dataset[, lapply(.SD, function(col) if (all(is.na(col))) NULL else col)]
  
  return(dataset)
}

# Parallel processing: Apply the function to all files using mclapply
combined_data_list <- mclapply(1:length(filenames), function(i) {
  process_dataset(filenames[i], ratios[i])
}, mc.cores = num_cores_to_use)

# Combine all datasets into one data.table
combined_data <- rbindlist(combined_data_list, use.names = TRUE, fill = TRUE)

# Modify the dataset
updated_mosquito_stock_data <- mosquito_stock_data %>%
  mutate(#cell = cell + 1,           # Increment cell by 1
         day = hour / 24)  %>%         # Create the day column by dividing hour by 24
  select(cell, day, eow, ew, j, am, mp, mb, ratio) # Select relevant columns

# Save the combined dataset (optional)
saveRDS(updated_mosquito_stock_data, "updated_mosquito_stock_data.rds")
