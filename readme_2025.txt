Methods for 2025 Black Sea Bass Ecosystem and Socioeconomic Profile Report Card

# Commercial fisheries data

Commercial indicator time series were provided by Samantha Werner. Data are in `data/commercial_data`.

# Recreational fisheries data

Data was downloaded from MRIP (add link here) and saved in `data/mrip_data`. Data were processed with `scripts/run_mrip_indicator_functions.R`, which references functions in `scripts/socio_indicator_functions.R`.

# Environmental data

Shelf water volume data was provided by Paula Fratantoni. Shelf water data can be found at `data/ShelfWaterVolume_BSB_update_2025.xlsx`. 
Bottom temperature data was processed at `docs/winter_bt_annual_update.Rmd`. Bottom temperature data can be found at `data/bt_update_2025-01-31.csv`.

# Plots

Commercial and recreational fisheries datat were plotted with `scripts/create_figs.R`. Environmental data was plotted with `scripts/bt_swv_facet_plots.R`. Plots are saved in `images`.
