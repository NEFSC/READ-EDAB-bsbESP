Methods for 2025 Black Sea Bass Ecosystem and Socioeconomic Profile Report Card

# Commercial fisheries data

Commercial indicator time series were provided by Samantha Werner. Data are in `data/commercial_data`.

# Recreational fisheries data

Data was downloaded from MRIP (add link here) and saved in `data/mrip_data`. Data were processed with `scripts/run_mrip_indicator_functions.Rmd`, which references functions in `scripts/socio_indicator_functions.R`.

# Environmental data

Shelf water volume data was provided by Paula Fratantoni. Shelf water data can be found at `data/ShelfWaterVolume_BSB_update_2025.xlsx`.
Bottom temperature data was processed at `docs/winter_bt_annual_update.Rmd`. Bottom temperature data can be found at `data/bt_update_2025-01-31.csv`.

# Plots

Commercial and recreational fisheries datat were plotted with `scripts/fig_functions.R`. Environmental data was plotted with `scripts/bt_swv_facet_plots.R`. Plots are saved in `images`.

# References

References were formatted using the Cambridge Univeristy Press (numeric) style downloaded from the CSL project [GitHub repository](https://github.com/citation-style-language/styles). More information can be found at https://citationstyles.org/

REWORKING METHODS FOR REPRODUCIBILITY

2025-09-10: I am in the process of revising the methods to be more streamlined. This is the intended workflow, although updates to the `_targets.R` pipeline haven't been tested yet.

# Obtaining data

## Commercial fisheries data

Commercial indicator time series were provided by Samantha Werner. Data are in `data/commercial_data`.

## Environmental data

Shelf water volume data was provided by Paula Fratantoni. Shelf water data can be found at `data/ShelfWaterVolume_BSB_update_2025.xlsx`.
Bottom temperature data was processed at `scripts/winter_bt_annual_update.Rmd`. Bottom temperature data can be found at `data/bt_update_2025-01-31.csv`. I would like to revise this code to access the bottom temperature data directly from ERDDAP.

## MRIP data

MRIP data is downloaded from the query tool in the targets pipeline with script `scripts/00_targets_download_data.R`.

## Bottom trawl data

Bottom trawl data is queried with script `scripts/pull_survdat.R`. Since this is a time consuming pull that requires user credentials, it is not integrated into the targets pipeline.

## All data

All raw data is read into the targets pipeline with script `scripts/01_targets_read_files.R`.

# Wrangling data

Data wrangling for MRIP data, condition, and shelf water volume is done in the targets pipeline with script `02_targets_create_indicators.R`. The commercial data does not need to be wrangled. I would like to add the bottom temperature indicator creation code here, rather than having it live separately.

# Formatting data

Data is formatted for the AKFIN web service in the targets pipeline with script `03_targets_format_data.R`. I would like to also save the data as .csv or .nc files in this step.

# Plotting data

The data is pulled *from the AKFIN web service* and plotted in the targets pipeline with script `04_targets_create_plots.R`. All data except the condition data is pulled from the AKFIN web service, not referenced from previous steps. 

# Generating report

The Quarto report can't be generated within the targets pipeline (threw a lot of errors that I couldn't debug). To generate report, edit `docs/bsb_indicator_table.csv` and `docs/bsb_report_card.qmd` and knit the report. The report references the figures created in the targets pipeline. 