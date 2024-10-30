library(ggplot2)
library(dplyr)

# Aggregate the mean value of 'wbs' for each scenario in breeding_site_data
scenario_summary_breeding <- breeding_site_data %>%
  group_by(ratio) %>%
  summarize(mean_wbs = mean(wbs, na.rm = TRUE))

# Create a quick plot to compare the mean 'wbs' across scenarios
ggplot(scenario_summary_breeding, aes(x = factor(ratio), y = mean_wbs)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Comparison of Mean WBS Across Scenarios (Breeding Site Data)",
       x = "Scenario (Ratio)",
       y = "Mean WBS") +
  theme_minimal()


library(dplyr)

# Calculate variance of 'wbs' across days for each cell to find a dynamic one
dynamic_cells <- breeding_site_data %>%
  group_by(cell) %>%
  summarize(variance_wbs = var(wbs, na.rm = TRUE)) %>%
  arrange(desc(variance_wbs))  # Sort by variance in descending order

# Select the cell with the highest variance
selected_cell <- dynamic_cells$cell[1]
cat("Selected dynamic cell:", selected_cell, "\n")


# Filter the breeding_site_data for the selected dynamic cell
filtered_data_breeding <- breeding_site_data %>%
  filter(cell == 13285)

# Plot time series for 'wbs' across days for the selected cell
ggplot(filtered_data_breeding, aes(x = day, y = wbs)) +
  geom_line(color = "blue") +
  labs(title = paste("WBS Time Series for Cell", selected_cell),
       x = "hour",
       y = "WBS") +
  theme_minimal()




