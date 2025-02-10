

plt_bsb <- function(data) {
  plt <- data |>
    dplyr::group_by(INDICATOR_NAME) |>
    dplyr::mutate(mean = mean(DATA_VALUE, na.rm = TRUE),
                  sd = sd(DATA_VALUE, na.rm = TRUE)) |>
    ggplot2::ggplot(ggplot2::aes(x = YEAR,
                                 y = DATA_VALUE
    )) +
    ggplot2::geom_point() +
    ggplot2::geom_path() +
    ggplot2::geom_hline(ggplot2::aes(
      yintercept = .data$mean + .data$sd
    ),
    color = "darkgreen",
    linetype = "solid"
    ) +
    ggplot2::geom_hline(ggplot2::aes(
      yintercept = .data$mean - .data$sd
    ),
    color = "darkgreen",
    linetype = "solid"
    ) +
    ggplot2::geom_hline(ggplot2::aes(
      yintercept = .data$mean
    ),
    color = "darkgreen",
    linetype = "dotted"
    ) +
    ggplot2::xlim(c(1989, 2024)) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::theme_classic(base_size = 16) +
    ggplot2::theme(strip.text = ggplot2::element_text(size = 16),
                   axis.title = ggplot2::element_blank(),
                   aspect.ratio = 1/4)

  return(plt)
}

plt_bsb(total_rec_landings |>
          dplyr::mutate(DATA_VALUE = DATA_VALUE/10^6))
## data ----
rec_indicators <- read.csv(here::here("data-raw/rec_indicators_2025.csv"))
com_indicators <- readxl::read_excel(here::here("data-raw/commercial_data/SOCIEOECONOMIC_COMMERCIAL_INDICATORS_BLACK_SEABASS_FINAL.xls"))

bottomT <- read.csv(here::here("data/bt_update_2025-01-31.csv"))
temp_indicator <- bottomT |>
  dplyr::filter(Region != "All") |>
  dplyr::mutate(INDICATOR_NAME = paste("winter bottom temp", Region)) |>
  dplyr::rename(YEAR = year,
                DATA_VALUE = mean) |>
  dplyr::select(INDICATOR_NAME, YEAR, DATA_VALUE)

n_swv <- readxl::read_excel(here::here("data-raw/ShelfWaterVolume_BSB_Update.xlsx"),
                            sheet = "N. MAB") %>%
  janitor::clean_names() %>%
  dplyr::select(year,
                val = sh_w_vol) %>%
  dplyr::mutate(region = "North")

s_swv <- readxl::read_excel(here::here("data-raw/ShelfWaterVolume_BSB_Update.xlsx"),
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
  dplyr::ungroup() |>
  dplyr::mutate(INDICATOR_NAME = paste("winter SWV", name)) |>
  dplyr::rename(YEAR = year,
                DATA_VALUE = new_val) |>
  dplyr::select(INDICATOR_NAME, YEAR, DATA_VALUE)

all_indicators <- dplyr::bind_rows(
  rec_indicators,
  com_indicators,
  swv,
  temp_indicator
)

## plot ----
for(i in unique(all_indicators$INDICATOR_NAME)) {
  this_dat <- all_indicators |>
    dplyr::filter(INDICATOR_NAME == i)

  fname <- here::here("images", paste0(i, "_", Sys.Date(), ".png"))
  if(max(this_dat$DATA_VALUE, na.rm = TRUE) > 10^6) {
    this_dat <- this_dat |>
      dplyr::mutate(DATA_VALUE = ifelse(!is.na(DATA_VALUE), DATA_VALUE/10^6, DATA_VALUE),
                    INDICATOR_NAME = paste(INDICATOR_NAME, "millions"))
    fname <-  here::here("images", paste0(i, "_millions_", Sys.Date(), ".png"))
  }

  print(fname)
  fig <- plt_bsb(this_dat)
  ggsave(fname,
         width = 7,
         height = 2)

}
