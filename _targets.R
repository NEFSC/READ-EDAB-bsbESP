# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.

# remotes::install_github("NEFSC/READ-EDAB-NEesp2")

# Set target options:
tar_option_set(
  packages = c("tibble") # Packages that your targets need for their tasks.
  # format = "qs", # Optionally set the default storage format. qs is fast.
)

# Run the R scripts in the R/ folder with your custom functions:
# tar_source("scripts/socio_indicator_functions.R")
tar_source("scripts/fig_functions.R")
tar_source("scripts/clean_data.R")
tar_source("scripts/format_indicator.R")

syear <- 2025

# Replace the target list below with your own:
list(

  ## files ----
  targets::tar_target(table_data,
                      here::here("docs/bsb_indicator_table.xlsx"),
                      format = "file"
                      ),

  targets::tar_target(meta_key,
                      here::here("docs/indicator_metadata_template.xlsx"),
                      format = "file"
                      ),

  ### image file paths ----
  targets::tar_target(map_img,
                      here::here("images/bsb_map.png"),
                      format = "file"
                      ),

  # add the code to create this as its own target
  targets::tar_target(condition_img,
                      here::here("images/condition.jpg"),
                      format = "file"
                      ),
#
#   targets::tar_target(risk_img,
#                       here::here("images/chart.png"),
#                       format = "file"),

  ### files to create indicators ----
  targets::tar_target(comm_indicators,
                      here::here("data/commercial_data/SOCIEOECONOMIC_COMMERCIAL_INDICATORS_FINAL.xls"),
                      format = "file"
                      ),

targets::tar_target(comm_data,
                    readxl::read_excel(comm_indicators)
                    ),

  #### mrip data
  targets::tar_target(mrip_trips,
                      list.files(path = here::here('data/mrip_data/mrip_directed_trips'),
                                 pattern = glob2rx('mrip*.csv'),
                                 full.names = TRUE),
                      format = "file"
                      ),

  targets::tar_target(mrip_landing,
                      here::here('data/mrip_data/mrip_BLACK_SEA_BASS_harvest_update040325.csv'),
                      format = "file"
                      ),


  #### environmental data
  targets::tar_target(swv_data,
                      here::here("data/ShelfWaterVolume_BSB_update_2025.xlsx"),
                      format = "file"
                      ),

targets::tar_target(swv_cleaned,
                      clean_swv_data(swv_data)
                    ),

  targets::tar_target(bt_file,
                      here::here("data/bt_update_2025-01-31.csv"),
                      format = "file"
                      ),

targets::tar_target(bt_data,
                    read.csv(bt_file)
                    ),

  ### watch AKFIN web service ? not sure this is working
  targets::tar_target(all_data,
                      AKesp::get_esp_data("Black Sea Bass")
                      ),

  ## indicator creation ----
  targets::tar_target(rec_trips,
                      NEesp2::create_rec_trips(files = mrip_trips)
                      ),

  targets::tar_target(total_rec_landings,
                      NEesp2::create_total_rec_landings(mrip_landing |>
                                                          read.csv(skip = 46, # of rows you want to ignore
                                                                   na.strings = ".") |>
                                                          janitor::clean_names(case = "all_caps")
                                                        )
                      ),

# TODO: create add in bottom temp creation target

## format indicators for web service ----

targets::tar_target(meta_data,
                    readxl::read_excel(meta_key)),

targets::tar_target(bt_north_web,
                    format_from_template(ind_name = "BSB_Winter_Bottom_Temperature_North",
                                         key = meta_data,
                                         out_dir = here::here("data"),
                                         submission_year = syear,
                                         years = bt_data |>
                                           dplyr::filter(Region == "North") |>
                                           purrr::pluck("year"),
                                         indicator_value = bt_data |>
                                           dplyr::filter(Region == "North") |>
                                           purrr::pluck("mean"),
                                         )
                    ),

targets::tar_target(bt_south_web,
                    format_from_template(ind_name = "BSB_Winter_Bottom_Temperature_South",
                                         key = meta_data,
                                         out_dir = here::here("data"),
                                         submission_year = syear,
                                         years = bt_data |>
                                           dplyr::filter(Region == "South") |>
                                           purrr::pluck("year"),
                                         indicator_value = bt_data |>
                                           dplyr::filter(Region == "South") |>
                                           purrr::pluck("mean"),
                    )
),

targets::tar_target(swv_north_web,
                    format_from_template(ind_name = "BSB_Shelf_Water_Volume_North",
                                         key = meta_data,
                                         out_dir = here::here("data"),
                                         submission_year = syear,
                                         years = swv_cleaned |>
                                           dplyr::filter(name == "North") |>
                                           purrr::pluck("YEAR"),
                                         indicator_value = swv_cleaned |>
                                           dplyr::filter(name == "North") |>
                                           purrr::pluck("DATA_VALUE"),
                    )
),

targets::tar_target(swv_south_web,
                    format_from_template(ind_name = "BSB_Shelf_Water_Volume_South",
                                         key = meta_data,
                                         out_dir = here::here("data"),
                                         submission_year = syear,
                                         years = swv_cleaned |>
                                           dplyr::filter(name == "South") |>
                                           purrr::pluck("YEAR"),
                                         indicator_value = swv_cleaned |>
                                           dplyr::filter(name == "South") |>
                                           purrr::pluck("DATA_VALUE"),
                    )
),

targets::tar_target(mrip_trips_web,
                    format_from_template(ind_name = "BSB_mrip_trips",
                                         key = meta_data,
                                         out_dir = here::here("data"),
                                         submission_year = syear,
                                         years = rec_trips |>
                                           purrr::pluck("YEAR"),
                                         indicator_value = rec_trips |>
                                           purrr::pluck("DATA_VALUE"),
                    )
),

targets::tar_target(mrip_land_web,
                    format_from_template(ind_name = "BSB_mrip_landings",
                                         key = meta_data,
                                         out_dir = here::here("data"),
                                         submission_year = syear,
                                         years = total_rec_landings |>
                                           purrr::pluck("YEAR"),
                                         indicator_value = total_rec_landings |>
                                           purrr::pluck("DATA_VALUE"),
                    )
),

targets::tar_target(com_rev_vessel_web,
                    format_from_template(ind_name = "BSB_Commercial_Revenue_Per_Vessel",
                                         key = meta_data,
                                         out_dir = here::here("data"),
                                         submission_year = syear,
                                         years = comm_data |>
                                           dplyr::filter(INDICATOR_NAME == 'AVGVESREVperYr_BLACK_SEABASS_2024_DOLlb') |>
                                           purrr::pluck("YEAR"),
                                         indicator_value = comm_data |>
                                           dplyr::filter(INDICATOR_NAME == 'AVGVESREVperYr_BLACK_SEABASS_2024_DOLlb') |>
                                           purrr::pluck("DATA_VALUE"),
                    )
),
targets::tar_target(com_vessel_web,
                    format_from_template(ind_name = "BSB_Commercial_Vessels",
                                         key = meta_data,
                                         out_dir = here::here("data"),
                                         submission_year = syear,
                                         years = comm_data |>
                                           dplyr::filter(INDICATOR_NAME == 'N_Commercial_Vessels_Landing_BLACK_SEABASS') |>
                                           purrr::pluck("YEAR"),
                                         indicator_value = comm_data |>
                                           dplyr::filter(INDICATOR_NAME == 'N_Commercial_Vessels_Landing_BLACK_SEABASS') |>
                                           purrr::pluck("DATA_VALUE"),
                    )
),



  ## plot creation ----

  targets::tar_target(risk_plt,
                      NEesp2::plot_risk(risk_elements = tibble::tibble(
                        stock = c(2, 2, 0, 4),
                        commercial = c(0, 2, 4, 1),
                        recreational = c(3, 1, 1, 1)))
                      ),

  targets::tar_target(rec_trips_plt,
                      plt_bsb(all_data,
                                     ind_name = "BSB_mrip_trips")
                      ),

  targets::tar_target(rec_landings_plt,
                      plt_bsb(all_data,
                                     ind_name = "BSB_mrip_landings")
                      ),

  targets::tar_target(com_rev_plt,
                      plt_bsb(all_data,
                                     ind_name = "BSB_Commercial_Revenue_Per_Vessel")
                      ),

  targets::tar_target(com_vessel_plt,
                      plt_bsb(all_data,
                                     ind_name = "BSB_Commercial_Vessels")
                      ),

  targets::tar_target(swv_plt,
                      plt_bsb(all_data,
                                     ind_name = "Shelf_Water_Volume",
                                     new_breaks = c(seq(1990,2010, by = 10), 2019, 2021))
                      ),

targets::tar_target(bt_plt,
                    plt_bsb(all_data |>
                                     dplyr::filter(INDICATOR_NAME != "BSB_Winter_Bottom_Temperature_All"),
                                   ind_name = "BSB_Winter_Bottom_Temperature",
                                   new_breaks = c(seq(1990,2020, by = 10), 2024))
                    ),

  # add image file paths to table
  targets::tar_target(tbl_info,
                      add_fig_paths(path = table_data,
                                    list_files = c(swv_plt,
                                                   bt_plt,
                                                   rec_trips_plt,
                                                   rec_landings_plt,
                                                   com_rev_plt,
                                                   com_vessel_plt))
                      ),

  ## render report ----
  tarchetypes::tar_render(rpt_card,
                          here::here("docs/bsb_report_card.qmd"),
                          output_file = here::here("docs/targets_test.pdf"),
                          params = list(tbl_file = tbl_info,
                                        img1 = map_img,
                                        img2 = condition_img,
                                        img3 = risk_plt,
                                        img_dir = here::here("images"))
                          )
# tar_render issue seems to be associated with quarto or possibly pandoc?
# the .tex compiles in overleaf
# does not render direct from .qmd any more


)

# targets::tar_visnetwork()
# targets::tar_make()
