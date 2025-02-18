
`%>%` <- magrittr::`%>%`
files <- list.files(here::here("black-sea-bass/Oceanography indicator data"),
                    full.names = TRUE)

winter_temp <- rbind(read.csv(files[2]) %>%
                       dplyr::mutate(Region = "All"),
                     read.csv(files[3]) %>%
                       dplyr::mutate(Region = "North"),
                     read.csv(files[7]) %>%
                       dplyr::mutate(Region = "South")
)   

shelfwater <- rbind(read.csv(files[4]) %>%
                      dplyr::mutate(Region = "All"),
                    read.csv(files[5]) %>%
                      dplyr::mutate(Region = "North"),
                    read.csv(files[6]) %>%
                      dplyr::mutate(Region = "South")
)

winter_temp %>%
  ggplot2::ggplot(ggplot2::aes(x = year,
                               y = mean_bot_T,
                               color = Region)) +
  ggplot2::geom_point() + 
  ggplot2::geom_line() +
  ggplot2::theme_bw()


south_rec <- read.table(here::here("black-sea-bass/SOUTH.MT.2021.FINAL.STD.txt"),
                        header = TRUE) %>%
  dplyr::filter(stringr::str_detect(name, "log_recruit_devs")) %>%
  dplyr::mutate(Year = 1989:2019,
                group = "south")

north_rec <- read.table(here::here("black-sea-bass/NORTH.MT.2021.FINAL.STD.txt"),
                        header = TRUE) %>%
  dplyr::filter(stringr::str_detect(name, "log_recruit_devs")) %>%
  dplyr::mutate(Year = 1989:2019,
                group = "north")

all_rec <- dplyr::full_join(north_rec, south_rec)

covariates <- dplyr::full_join(ecodata::bottom_heatwave,
                               ecodata::bottom_temp) %>%
  dplyr::full_join(ecodata::bottom_temp_glorys) %>%
  dplyr::full_join(ecodata::ESP_seasonal_oisst_anom %>% 
                     dplyr::filter(stringr::str_detect(ESP, "bass")) %>%
                     dplyr::mutate(Var = paste(ESP %>% 
                                                 stringr::str_remove("_spring"), 
                                               Var),
                                   EPU = "MAB")
                   ) %>%
  dplyr::filter(EPU == "MAB",
                Time %in% 1988:2018,
                Var != "reference bt in situ (1981-2010)",
                Var != "reference sst in situ (1981-2010)"
                ) %>%
  dplyr::mutate(Time = Time + 1,
                Var = stringr::str_replace_all(Var, "_", " ") %>%
                  stringr::str_wrap(20))
  
dplyr::full_join(all_rec, 
                 covariates %>%
                   dplyr::filter(stringr::str_detect(Var, "winter")),
                 by = c("Year" = "Time")) %>%
  dplyr::filter(stringr::str_detect(Var, "bass")) %>%
  ggplot2::ggplot(ggplot2::aes(x = Value,
                               y = value)) +
  ggplot2::geom_point() +
  ggplot2::facet_grid(cols = ggplot2::vars(Var),
                      rows = ggplot2::vars(group),
                      scales = "free") +
  ggplot2::theme_bw() +
  ggplot2::geom_hline(ggplot2::aes(yintercept = 0),
                      lty = 2) +
  ggplot2::geom_smooth(method = "lm")

