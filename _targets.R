# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.
# source(here::here("../READ-EDAB-NEesp2"))

# remotes::install_github("NEFSC/READ-EDAB-NEesp2", ref = "abby_dev")

# Set target options:
# tar_option_set(
#   packages = c("tibble") # Packages that your targets need for their tasks.
#   # format = "qs", # Optionally set the default storage format. qs is fast.
# )

# Run the R scripts in the R/ folder with your custom functions:
tar_source("scripts/fig_functions.R")
tar_source("scripts/clean_data.R")

# update survdat pull with script scripts/pull_survdat.R if needed

syear <- 2025
image_dir <- here::here("images")
txt_dir <- here::here("data")
risk_plt_file <- here::here("images/risk_plot.png")

if (!file.exists(risk_plt_file)) {
  file.create(risk_plt_file)
}

# targets workflow
list(
  source(here::here("scripts/targets_scripts/00_targets_download_data.R")),

  source(here::here("scripts/targets_scripts/01_targets_read_files.R")),

  source(here::here("scripts/targets_scripts/02_targets_create_indicators.R")),

  source(here::here("scripts/targets_scripts/03_targets_format_data.R")),

  source(here::here("scripts/targets_scripts/04_targets_create_plots.R")),
)

# targets::tar_visnetwork()
# targets::tar_make()

# targets::tar_load_everything()
