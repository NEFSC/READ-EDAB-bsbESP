devtools::load_all("../READ-EDAB-NEesp2")

data <- AKesp::get_esp_data("Black Sea Bass") |>
  dplyr::filter(INDICATOR_NAME != "BSB_Winter_Bottom_Temperature_North")

NEesp2::esp_csv_to_nc(
  data = data,
  fname = here::here("data-raw", paste0("test_", Sys.Date(), ".nc"))
)


nc_file_check <- ncdf4::nc_open(here::here(
  "data-raw",
  paste0("test_", Sys.Date(), ".nc")
))
