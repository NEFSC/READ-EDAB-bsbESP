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

syear <- 2025
image_dir <- here::here("images")
txt_dir <- here::here("data")
risk_plt_file <- here::here("images/risk_plot.png")

if(!file.exists(risk_plt_file)) {
  file.create(risk_plt_file)
}

# targets workflow
list(

  # add the code to create this as its own target
  # targets::tar_target(condition_img,
  #   here::here("images/condition.jpg"),
  #   format = "file"
  # ),
  #
  #   targets::tar_target(risk_img,
  #                       here::here("images/chart.png"),
  #                       format = "file"),

 source(here::here("scripts/targets_scripts/01_targets_read_files.R")),

 source(here::here("scripts/targets_scripts/02_targets_create_indicators.R")),

 source(here::here("scripts/targets_scripts/03_targets_format_data.R")),

 source(here::here("scripts/targets_scripts/04_targets_create_plots.R")),

  # add image file paths to table
  targets::tar_target(
    tbl_info,
    NEesp2::add_fig_paths(
      path = table_data,
      list_files = c(
        swv_plt,
        bt_plt,
        rec_trips_plt,
        # rec_landings_plt,
        com_rev_plt,
        com_vessel_plt
      )
    )
  ) #,

  ## render report ----
  # tarchetypes::tar_render(rpt_card,
  #                         here::here("docs/bsb_report_card.qmd"),
  #                         output_file = here::here("docs/targets_test.pdf"),
  #                         params = list(tbl_file = tbl_info,
  #                                       img1 = map_img,
  #                                       # img2 = condition_img,
  # img2 = cond_plt,
  #                                       img3 = risk_img,
  #                                       img_dir = here::here("images"))
  #                         )
  # tar_render issue seems to be associated with quarto or possibly pandoc?
  # the .tex compiles in overleaf
  # does not render direct from .qmd any more
)

# targets::tar_visnetwork()
# targets::tar_make()

# targets::tar_load_everything()
