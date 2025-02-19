#### Shelf water volume N/S Facet Plot####
`%>%` <- magrittr::`%>%`

# read in data
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
  dplyr::ungroup() %>%
  dplyr::group_by(name) %>%
  dplyr::mutate(mean = mean (new_val),
                sd = sd(new_val)) %>%
  dplyr::rename(val = new_val)


#plot
swv %>%
  ggplot2::ggplot(ggplot2::aes(x = year,
                               y = val,
                               group_by = name,
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
  ggplot2::xlim(c(1989, 2024)) +
  ggplot2::scale_y_continuous(labels = scales::comma) +
  ggplot2::scale_x_continuous(breaks = c(seq(1990,2010, by = 10), 2019, 2021)) +
  ggplot2::theme_classic(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 16),
                 axis.text.x = ggplot2::element_text(size = 12, angle = 30),
                 axis.title = ggplot2::element_blank(),
                 aspect.ratio = 1/4) +
  ggplot2::facet_grid('name')


### Winter bottom temp facet plot ###

#read in data, calculate mean and sd for N and S, and rejoin
bottomT <- read.csv(here::here("data/bt_update_2025-01-31.csv"))
bottomT <- bottomT[1:72, ] %>%
  dplyr::rename(val = mean) %>%
  dplyr::select(Region, year, val)

north <- bottomT[1:36, ] %>%
  dplyr::mutate(mean = mean(val, na.rm = TRUE),
              sd = sd(val, na.rm = TRUE))

south <- bottomT[37:72, ] %>%
  dplyr::mutate(mean = mean(val, na.rm = TRUE),
                sd = sd(val, na.rm = TRUE))

bottomT <- rbind(north, south)


bottomT %>%
  ggplot2::ggplot(ggplot2::aes(x = year,
                               y = val,
                               group_by = Region,
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
  ggplot2::xlim(c(1989, 2024)) +
  ggplot2::scale_y_continuous(labels = scales::comma) +
  ggplot2::scale_x_continuous(breaks = c(seq(1990,2020, by = 10), 2024)) +
  ggplot2::theme_classic(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 16),
                 axis.title = ggplot2::element_blank(),
                 aspect.ratio = 1/4) +
  ggplot2::facet_grid('Region')
