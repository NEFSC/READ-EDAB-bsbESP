
clean_swv_data <- function(fname) {
  n_swv <- readxl::read_excel(fname,
                              sheet = "N. MAB") %>%
    janitor::clean_names() %>%
    dplyr::select(year,
                  val = sh_w_vol) %>%
    dplyr::mutate(region = "North")

  s_swv <- readxl::read_excel(fname,
                              sheet = "S. MAB") %>%
    janitor::clean_names() %>%
    dplyr::select(year,
                  val = sh_w_vol) %>%
    dplyr::mutate(region = "South")

  swv <- rbind(n_swv,
               s_swv) %>%
    dplyr::mutate(whole_year = trunc(year),
                  dec_year = year - whole_year) %>%
    dplyr::filter(dec_year < 0.25) %>% # winter only
    dplyr::select(-year, -dec_year) %>%
    dplyr::rename(year = whole_year,
                  name = region) %>%
    dplyr::group_by(year, name) %>%
    dplyr::summarise(new_val = mean(val)) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(name) %>%
    dplyr::mutate(mean = mean (new_val),
                  sd = sd(new_val),
                  INDICATOR_NAME = paste0("shelf_water_volume_", name)) %>%
    dplyr::rename(DATA_VALUE = new_val,
                  YEAR = year)

  return(swv)

}
