library(data.table)
library(jsonlite)
library(parallel)

json_files <- sprintf("ratio-%.1f.json.gz", seq(0.0, 1.0, by = 0.1))

num_cores <- detectCores()
num_cores_to_use <- floor(num_cores * 0.9)

process_json_file <- function(file_path, chunk_size = 50000) {  
  data_splits <- list()  # To hold data splits by "type"
  
  con <- gzfile(file_path, "r")
  
  # Process the entire file in chunks
  while(TRUE) {
    # Read the next chunk
    lines <- readLines(con, n = chunk_size, warn = FALSE)
    
    # Break the loop if the end of the file is reached
    if(length(lines) == 0) break
    
    # Parse and combine the chunk into a data.table
    chunk_data <- rbindlist(lapply(lines, fromJSON), fill = TRUE)
    
    # Split data based on "type" column
    unique_types <- unique(chunk_data$type)
    for (type_value in unique_types) {
      type_data <- chunk_data[chunk_data$type == type_value, ]
      
      # Append or initialize the data split for each type
      if (is.null(data_splits[[type_value]])) {
        data_splits[[type_value]] <- type_data
      } else {
        data_splits[[type_value]] <- rbindlist(list(data_splits[[type_value]], type_data), fill = TRUE)
      }
    }
  }
  
  # Save each type split to an RDS file
  for (type_value in names(data_splits)) {
    saveRDS(data_splits[[type_value]], paste0("dataset_", basename(file_path), "_", type_value, ".rds"))
  }
  
  # Close the file connection
  close(con)
}

# Use parallel processing to handle multiple JSON files
cl <- makeCluster(num_cores_to_use)
clusterEvalQ(cl, {
  library(data.table)
  library(jsonlite)
})

# Apply the processing function to all files in parallel
parLapply(cl, json_files, process_json_file)

# Stop the cluster
stopCluster(cl)

cat("Processing complete. Entire dataset processed and saved by 'type'.\n")
