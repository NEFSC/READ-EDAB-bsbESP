# Script to load in updated shelf water volume data and create plots for ESP
# for 2025 update

library(dplyr)

n_swv <- readxl::read_excel(here::here("data/ShelfWaterVolume_BSB_Update_2025.xlsx"),
                            sheet = "N. MAB") %>%
  janitor::clean_names() %>%
  dplyr::select(year,
                val = sh_w_vol) %>%
  dplyr::mutate(region = "North")

s_swv <- readxl::read_excel(here::here("data/ShelfWaterVolume_BSB_Update_2025.xlsx"),
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
                sd = sd(new_val)) %>%
  dplyr::rename(val = new_val)

# problem that there are no "winter" dates sampled since 2021 in either area

time_series_plot <- function(data, ylab) {
  plt <- data %>%
    ggplot2::ggplot(
      ggplot2::aes(
        x = .data$year,
        y = .data$val,
        group = name
      )
    ) +
    ggplot2::geom_hline(ggplot2::aes(
      yintercept = .data$mean + .data$sd,
      group = .data$name
    ),
    color = "darkgreen",
    linetype = "solid"
    ) +
    ggplot2::geom_hline(ggplot2::aes(
      yintercept = .data$mean - .data$sd,
      group = .data$name
    ),
    color = "darkgreen",
    linetype = "solid"
    ) +
    ggplot2::geom_hline(ggplot2::aes(
      yintercept = .data$mean,
      group = .data$name
    ),
    color = "darkgreen",
    linetype = "dotted"
    ) +
    ggplot2::geom_point() +
    ggplot2::geom_line(data = data %>%
                         tidyr::drop_na(.data$val)
    ) +
    ggplot2::ylab(ylab) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::theme_bw(base_size = 16) +
    ggplot2::theme(strip.text = ggplot2::element_text(size = 16),
                   axis.title.x = ggplot2::element_blank())

  return(plt)

}
# tweak this to include open circles for 2022-24
# NO WINTER CRUITSES
swv %>%
  time_series_plot(ylab = "Winter shelf water volume") +
  ggplot2::facet_wrap(~name,
                      nrow = 2,
                      scales = "free_y")+
  ggplot2::scale_x_continuous(breaks = seq(0,2025,10))+
  ggplot2::geom_text(data=data.frame(x = c(2022, 2023), y = 1500, name="South", label="*"),
                     ggplot2::aes(x=x, y=y, label = label),
            stat = "unique",
            size = 10, color = "red")+
  ggplot2::geom_text(data=data.frame(x = c(2020:2023), y = 2000, name="North", label="*"),
                     ggplot2::aes(x=x, y=y, label = label),
                     stat = "unique",
                     size = 10, color = "red")


ggplot2::ggsave(here::here("images", paste0(Sys.Date(), "_swv.missvals.png")),
                width = 8, height = 6)
