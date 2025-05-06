

plt_bsb <- function(data, ind_name) {
  plt <- data |>
    dplyr::filter(INDICATOR_NAME == ind_name) |>
    dplyr::group_by(INDICATOR_NAME) |>
    dplyr::mutate(mean = mean(DATA_VALUE, na.rm = TRUE),
                  sd = sd(DATA_VALUE, na.rm = TRUE)) |>
    ggplot2::ggplot(ggplot2::aes(x = YEAR,
                                 y = DATA_VALUE
    )) +
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
    ggplot2::geom_point() +
    ggplot2::geom_path() +
    # ggplot2::xlim(c(1989, 2024)) +
    ggplot2::scale_x_continuous(breaks = c(1990, 2000, 2010, 2020, 2024),
                                limits = c(1989, 2024)) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::theme_classic(base_size = 16) +
    ggplot2::theme(strip.text = ggplot2::element_text(size = 16),
                   axis.title = ggplot2::element_blank(),
                   axis.text.x = ggplot2::element_text(angle = 30,
                                                       hjust = 1),
                   aspect.ratio = 1/4)

  return(plt)
}

#Test plot with AKesp
#plt_bsb(data = AKesp::get_esp_data("Black Sea Bass"), ind_name = 'BSB_Shelf_Water_Volume_North')

# plt_bsb(total_rec_landings |>
#           dplyr::mutate(DATA_VALUE = DATA_VALUE/10^6))
#
# plt_bsb(com_indicators |>
#           dplyr::arrange(YEAR) |>
#           dplyr::filter(INDICATOR_NAME == "N_Commercial_Vessels_Landing_BLACK_SEABASS"))

## data ----
rec_indicators <- read.csv(here::here("data-raw/rec_indicators_2025.csv"))
com_indicators <- readxl::read_excel(here::here("data/commercial_data/SOCIEOECONOMIC_COMMERCIAL_INDICATORS_FINAL.xls"))

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
  rec_trips2,
  prop_sp_trips,
  total_rec_catch,
  total_rec_landings
  # rec_indicators,
  #com_indicators,
  #swv,
  #temp_indicator
)

## plot ----
for(i in unique(all_indicators$INDICATOR_NAME)) {
  this_dat <- all_indicators |>
    dplyr::filter(INDICATOR_NAME == i) |>
    dplyr::arrange(YEAR)

  fname <- here::here("images", paste0(i, "_", Sys.Date(), ".png"))
  if(max(this_dat$DATA_VALUE, na.rm = TRUE) > 10^6) {
    this_dat <- this_dat |>
      dplyr::mutate(DATA_VALUE = ifelse(!is.na(DATA_VALUE), DATA_VALUE/10^6, DATA_VALUE),
                    INDICATOR_NAME = paste(INDICATOR_NAME, "millions"))
    fname <-  here::here("images", paste0(i, "_millions_", Sys.Date(), ".png"))
  }

  print(fname)
  fig <- plt_bsb(this_dat)

  if(stringr::str_detect(i, "North")) {
    fig <- fig +
      ggplot2::labs(title = "North") +
      ggplot2::theme(plot.title.position = "plot")

    ggplot2::ggsave(fname,
                    width = 7,
                    height = 2)

  } else if(stringr::str_detect(i, "South")) {
    fig <- fig +
      ggplot2::labs(title = "South") +
      ggplot2::theme(plot.title.position = "plot")

    ggplot2::ggsave(fname,
                    width = 7,
                    height = 2)

  } else {
    ggplot2::ggsave(fname,
                    width = 6,
                    height = 2)
  }

}

## condition ----
AnnualRelCond2023_Fall <- readr::read_csv("https://raw.githubusercontent.com/NOAA-EDAB/foodweb-risk/main/condition/AnnualRelCond2023_Fall.csv")

survEPUcond <- AnnualRelCond2023_Fall |>
  dplyr::select(Time = YEAR,
                Var = Species,
                EPU,
                Value = MeanCond,
                nCond) |>
  dplyr::group_by(#EPU,
    Var) |>
  dplyr::mutate(scaleCond = scale(Value,scale =T,center=T))

xs <- quantile(survEPUcond$scaleCond, seq(0,1, length.out = 6), na.rm = TRUE)

survEPUcond <- survEPUcond |>
  dplyr::mutate(category = cut(scaleCond,
                               breaks = xs,
                               labels = c( "Poor Condition",
                                           "Below Average",
                                           "Neutral",
                                           "Above Average",
                                           "Good Condition"),
                               include.lowest = TRUE))

survEPUcond |>
  dplyr::filter(Var == "Black sea bass") |>
  dplyr::ungroup() |>
  dplyr::arrange(Time) |>
  dplyr::group_by(EPU) |>
  dplyr::mutate(mean = mean(Value, na.rm = TRUE),
                sd = sd(Value, na.rm = TRUE)) |>
  ggplot2::ggplot(ggplot2::aes(x = Time,
                               y = Value,
                               # y = scaleCond[,1],
                               color = category,
                               shape = EPU
  )) +
  ggplot2::geom_path(color = "black", lty = 2, alpha = 0.5) +
  ggplot2::geom_point(cex = 3) +
  ggplot2::xlim(c(1989, 2024)) +
  # ggplot2::facet_wrap(~EPU, ncol = 1) +
  # ggplot2::scale_y_continuous(labels = scales::comma) +
  ggplot2::theme_classic(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 16),
                 axis.title = ggplot2::element_blank(),
                 aspect.ratio = 0.4,
                 legend.direction = "vertical",
                 legend.box = "horizontal") +
  viridis::scale_color_viridis(discrete = TRUE)

