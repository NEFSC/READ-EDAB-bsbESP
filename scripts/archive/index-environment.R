
`%>%` <- magrittr::`%>%`

## south ----
south_index1 <- readxl::read_excel(here::here("black-sea-bass/BSB.Southern.Region.Indices.xlsx"),
                                             sheet = 1,
                                   col_types = "numeric") %>%
  dplyr::mutate(Survey = "Albatross")

south_index2 <- readxl::read_excel(here::here("black-sea-bass/BSB.Southern.Region.Indices.xlsx"),
                                  sheet = 2,
                                  col_types = "numeric") %>%
  dplyr::mutate(Survey = "NEAMAP") %>%
  dplyr::mutate(Age1 = 1)

south_index3 <- readxl::read_excel(here::here("black-sea-bass/BSB.Southern.Region.Indices.xlsx"),
                                  sheet = 3,
                                  col_types = "numeric") %>%
  dplyr::mutate(Survey = "Bigelow")

south_index <- rbind(south_index1, south_index3) %>%
  dplyr::full_join(south_index2)

dat <- south_index %>%
  dplyr::mutate(Age1_N = Number * Age1) %>%
  dplyr::select(Year, Survey, Age1_N) %>%
  tidyr::drop_na() %>%
  dplyr::group_by(Survey) %>%
  dplyr::mutate(normalized_N = Age1_N / mean(Age1_N))

dat %>%
  ggplot2::ggplot(ggplot2::aes(x = Year,
                               y = normalized_N,
                               color = Survey)) +
  ggplot2::geom_point() +
  ggplot2::geom_line() +
  ggplot2::theme_bw()



## north ----
north_index1 <- readxl::read_excel(here::here("black-sea-bass/BSB.Northern.Region.Indices.xlsx"),
                                   sheet = 1,
                                   col_types = "numeric") %>%
  dplyr::mutate(Survey = "Albatross")

north_index2 <- readxl::read_excel(here::here("black-sea-bass/BSB.Northern.Region.Indices.xlsx"),
                                   sheet = 2,
                                   col_types = "numeric") %>%
  dplyr::mutate(Survey = "NEAMAP") 

north_index3 <- readxl::read_excel(here::here("black-sea-bass/BSB.Northern.Region.Indices.xlsx"),
                                   sheet = 3,
                                   col_types = "numeric") %>%
  dplyr::mutate(Survey = "Bigelow")

north_index <- rbind(north_index1, north_index2, north_index3) 

dat2 <- north_index %>%
  dplyr::mutate(Age1_N = Number * Age1) %>%
  dplyr::select(Year, Survey, Age1_N) %>%
  tidyr::drop_na() %>%
  dplyr::group_by(Survey) %>%
  dplyr::mutate(normalized_N = Age1_N / mean(Age1_N))

dat2 %>%
  ggplot2::ggplot(ggplot2::aes(x = Year,
                               y = normalized_N,
                               color = Survey)) +
  ggplot2::geom_point() +
  ggplot2::geom_line() +
  ggplot2::theme_bw()

all_index <- rbind(dat %>%
                     dplyr::mutate(Region = "South"),
                   dat2 %>%
                     dplyr::mutate(Region = "North")) 

covariates <- ecodata::ESP_seasonal_oisst_anom %>% 
  dplyr::filter(stringr::str_detect(ESP, "bass")) %>%
  dplyr::mutate(Var = paste(ESP %>% 
                              stringr::str_remove("_spring"), 
                            Var) %>%
                  stringr::str_replace_all("_", " ") %>%
                  stringr::str_wrap(20))

dplyr::left_join(all_index, 
                 covariates %>%
                   dplyr::filter(stringr::str_detect(Var, "summer")) %>%
                   dplyr::mutate(Time = Time + 1,
                                 Var = Var %>%
                                   stringr::str_remove("black sea bass\n")),
                 by = c("Year" = "Time")) %>%
  # dplyr::filter(stringr::str_detect(Var, "bass")) %>%
  ggplot2::ggplot(ggplot2::aes(x = Value,
                               y = normalized_N )) +
  ggplot2::geom_point() +
  ggplot2::facet_grid(cols = ggplot2::vars(Var),
                      rows = ggplot2::vars(Region),
                      scales = "free") +
  ggplot2::theme_bw() +
  ggplot2::geom_hline(ggplot2::aes(yintercept = 0),
                      lty = 2) +
  ggplot2::geom_smooth(method = "lm") +
  ggplot2::ylab("Survey N (normalized to mean)") +
  ggplot2::xlab("covariate value")


