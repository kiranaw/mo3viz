# MO3 Directory


## Directory Overview

The main folder is **MO3**, which is structured into three subfolders:

- `1dataprocess`: Contains data processing scripts and raw datasets.
- `2mapviz`: Contains files related to map visualization and spatial data.
- `3shiny`: Contains Shiny application scripts for the project.

---

## 1. `1dataprocess`

This folder contains scripts and datasets used for processing raw data. The main files and their purposes are:

### Key Files:
- `updated_breeding_site_data.rds`: Processed breeding site data in RDS format.
- `updated_mosquito_stock_data.rds`: Processed mosquito stock data.
- `downloadextract.R` : R script to download and extract the json data to R directory
- `parsejsonall.R`: R script for preprocessing the raw datasets (e.g., filtering, aggregation).

### Purpose:
The files in this folder are responsible for preparing the data for further analysis and visualization. All necessary preprocessing steps are implemented here, and the processed data is saved in `.rds` format for fast loading.

---

## 2. `2mapviz`

This folder contains files related to spatial data and map visualization.

### Key Files:
- `test_grid_40K_2.gpkg`: Geospatial grid data for visualizing breeding sites and mosquito stock at the subdistrict level.
- `dopa_shp_2020.shp`: Shapefile containing the subdistrict boundaries.
- `generate_map.R`: R script for visualizing the grid and mosquito data on maps.

### Purpose:
This folder is focused on the preparation and visualization of geospatial data. The files here are used in conjunction with the Shiny app to display spatial trends and aggregations of breeding site and mosquito data.

---

## 3. `3shiny`

This folder contains the Shiny application scripts and related files.

### Key Files:
- `app.R`: The main Shiny app script that integrates the map visualizations and sensitivity analysis.
- `sensitivity_results_all_columns.csv`: Precomputed sensitivity analysis results used in the Shiny app for plotting and displaying.


### Purpose:
The Shiny application in this folder is responsible for interactive visualization. Users can interact with the map and sensitivity analysis through the app, which pulls data from the processed datasets and spatial files.

---

## Data Flow

1. **Data Processing** (`1dataprocess`):
   - Raw data is processed and cleaned here.
   - Processed data is saved as `.rds` files for faster access.

2. **Map Visualization** (`2mapviz`):
   - Geospatial data are stored here.
   - R scripts to generate maps.

3. **Shiny App** (`3shiny`):
   - The processed data and visualization files are integrated into an interactive Shiny app.

---

## Future Work
- **Enhance Visualization**: Improve the interactivity of the maps.
- **Additional plots**: Add more plots for further analysis.
