# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("tibble") # Packages that your targets need for their tasks.
  # format = "qs", # Optionally set the default storage format. qs is fast.
  #
  # Pipelines that take a long time to run may benefit from
  # optional distributed computing. To use this capability
  # in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller that scales up to a maximum of two workers
  # which run as local R processes. Each worker launches when there is work
  # to do and exits if 60 seconds pass with no tasks to run.
  #
  #   controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package.
  # For the cloud, see plugin packages like {crew.aws.batch}.
  # The following example is a controller for Sun Grid Engine (SGE).
  #
  #   controller = crew.cluster::crew_controller_sge(
  #     # Number of workers that the pipeline can scale up to:
  #     workers = 10,
  #     # It is recommended to set an idle time so workers can shut themselves
  #     # down if they are not running tasks.
  #     seconds_idle = 120,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.2".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("scripts/socio_indicator_functions.R")
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  # tar_target(
  #   name = data,
  #   command = tibble(x = rnorm(100), y = rnorm(100))
  #   # format = "qs" # Efficient storage for general data objects.
  # ),
  # tar_target(
  #   name = model,
  #   command = coefficients(lm(y ~ x, data = data))
  # )

  ## files ----
  targets::tar_target(table_data,
                      here::here("docs/bsb_indicator_table.xlsx"),
                      format = "file"),

  targets::tar_target(map_img,
                      here::here("images/bsb_map.png"),
                      format = "file"),

  # add the code to create this as its own target
  targets::tar_target(condition_img,
                      here::here("images/condition.jpg"),
                      format = "file"),

  targets::tar_target(risk_img,
                      here::here("images/chart.png"),
                      format = "file"),

  targets::tar_target(comm_indicators,
                      here::here("data/commercial_data/SOCIEOECONOMIC_COMMERCIAL_INDICATORS_FINAL.xls"),
                      format = "file"),

  targets::tar_target(mrip_data,
                      here::here("data/mrip"),
                      format = "file"),

  targets::tar_target(swv_data,
                      here::here("data/ShelfWaterVolume_BSB_update_2025.xlsx"),
                      format = "file"),

  targets::tar_target(bt_data,
                      here::here("data/bt_update_2025-01-31.csv"),
                      format = "file"),


  ## indicator creation ----

  # write create_table_data function that adds the file paths within the targets workflow

  ## plot creation ----

  ## render report ----
  tarchetypes::tar_render(rpt_card, here::here("docs/bsb_report_card.qmd"),
                          params = list(tbl_file = table_data,
                                        img1 = map_img,
                                        img2 = condition_img,
                                        img3 = risk_img,
                                        img_dir = here::here("images")))


)

# targets::tar_visnetwork()
