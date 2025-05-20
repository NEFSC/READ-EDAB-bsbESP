## files ----
list(
targets::tar_target(table_data,
                    here::here("docs/bsb_indicator_table.xlsx"),
                    format = "file"
),
targets::tar_target(meta_key,
                    here::here("docs/indicator_metadata_template.xlsx"),
                    format = "file"
),

targets::tar_target(
  meta_data,
  readxl::read_excel(meta_key)
),

### image file paths ----
targets::tar_target(map_img,
                    here::here("images/bsb_map.png"),
                    format = "file"
),
### files to create indicators ----
targets::tar_target(comm_indicators,
                    here::here("data/commercial_data/SOCIEOECONOMIC_COMMERCIAL_INDICATORS_FINAL.xls"),
                    format = "file"
),
targets::tar_target(
  comm_data,
  readxl::read_excel(comm_indicators)
),

#### mrip data
targets::tar_target(mrip_trips,
                    list.files(
                      path = here::here("data/mrip_data/mrip_directed_trips"),
                      pattern = glob2rx("mrip*.csv"),
                      full.names = TRUE
                    ),
                    format = "file"
),
targets::tar_target(mrip_landing,
                    here::here("data/mrip_data/mrip_BLACK_SEA_BASS_harvest_update040325.csv"),
                    format = "file"
),


#### environmental data
targets::tar_target(swv_data,
                    here::here("data/ShelfWaterVolume_BSB_update_2025.xlsx"),
                    format = "file"
),
targets::tar_target(
  swv_cleaned,
  clean_swv_data(swv_data)
),
targets::tar_target(bt_file,
                    here::here("data/bt_update_2025-01-31.csv"),
                    format = "file"
),
targets::tar_target(
  bt_data,
  read.csv(bt_file)
),

### bio data
targets::tar_target(bio_file,
                    here::here("data/survey_bio_data.csv"),
                    format = "file"
),
targets::tar_target(
  bio_data,
  read.csv(bio_file)
),

### watch AKFIN web service ? not sure this is working
targets::tar_target(
  all_data,
  AKesp::get_esp_data("Black Sea Bass")
)
)
