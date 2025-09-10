## files ----
list(
  targets::tar_target(
    meta_key,
    here::here("docs/indicator_metadata_template.csv"),
    format = "file"
  ),

  targets::tar_target(
    meta_data,
    read.csv(meta_key)
  ),

  ### image file paths ----
  targets::tar_target(
    map_img,
    here::here("images/bsb_map.png"),
    format = "file"
  ),
  ### files to create indicators ----
  targets::tar_target(
    comm_indicators,
    here::here(
      "data/commercial_data/SOCIEOECONOMIC_COMMERCIAL_INDICATORS_FINAL.xls"
    ),
    format = "file"
  ),
  targets::tar_target(
    comm_data,
    readxl::read_excel(comm_indicators)
  ),

  #### mrip data
  targets::tar_target(
    mrip_trips,
    create_mrip_trips(
      files = trip_files
  ),

  targets::tar_target(
    mrip_landing_data,
    readRDS(mrip_landing_file)
  ),

  #### environmental data
  targets::tar_target(
    swv_data,
    here::here("data/ShelfWaterVolume_BSB_update_2025.xlsx"),
    format = "file"
  ),

  targets::tar_target(
    bt_file,
    here::here("data/bt_update_2025-01-31.csv"),
    format = "file"
  ),
  targets::tar_target(
    bt_data,
    read.csv(bt_file)
  ),

  ### bio data
  targets::tar_target(
    bio_file,
    here::here("data/survey_bio_data.csv"),
    format = "file"
  ),
  targets::tar_target(
    bio_data,
    read.csv(bio_file)
  )
)
