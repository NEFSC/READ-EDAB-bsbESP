`%>%` <- magrittr::`%>%`
dat <- read.csv(here::here("data-raw/bsb_For_Rob.csv"))

all_temp <- dplyr::full_join(phys_data %>%
                               dplyr::select(-Salinity, -Annual_Avg_S) %>%
                               dplyr::mutate(Region = dplyr::case_when(Region == "NMAB" ~ "North",
                                                                       Region == "SMAB" ~ "South")),
                             dat %>%
                               dplyr::select(-Proportion, -X),
                             by = c("Region" = "Stock",
                                    "Year",
                                    "month" = "Month"))

all_temp %>%
  tidyr::drop_na() %>%
  ggplot2::ggplot(ggplot2::aes(x = Btemp,
                               y = Temp - Annual_avg_T,
                               color = Region,
                               shape = as.factor(month))) +
  ggplot2::geom_point() +
  ggplot2::theme(aspect.ratio = 1) +
  ggplot2::xlim(c(1, 12)) +
  ggplot2::ylim(c(-2, 9))




dat %>%
  tidyr::drop_na() %>%
  ggplot2::ggplot(ggplot2::aes(x = Btemp,
                               y = Proportion,
                               color = Year)) +
  ggplot2::geom_point() +
  ggplot2::facet_grid(cols = ggplot2::vars(Month),
                      rows = ggplot2::vars(Stock)) +
  ggplot2::geom_smooth(method = "lm") +
  viridis::scale_color_viridis() +
  ggplot2::theme_bw()


dat %>%
  tidyr::drop_na() %>%
  ggplot2::ggplot(ggplot2::aes(x = Year,
                               y = Btemp,
                               color = Stock)) +
  ggplot2::geom_point(cex = 2) +
  ggplot2::geom_line() +
  ggplot2::geom_point(ggplot2::aes(y = Proportion / 10),
                      shape = 17) +
  ggplot2::facet_grid(cols = ggplot2::vars(Month)) +
  viridis::scale_color_viridis(discrete = TRUE) +
  ggplot2::theme_bw()


dat %>%
  dplyr::select(-X) %>%
  tidyr::drop_na() %>%
  tidyr::pivot_wider(names_from = c(Stock, Month), values_from = Btemp)







dat %>%
  tidyr::pivot_wider(names_from = Month, values_from = Btemp)

temps <- dat %>%
  tidyr::drop_na() %>%
  dplyr::select(Year, Stock, Month, Btemp) %>%
  dplyr::distinct() %>%
  tidyr::pivot_wider(names_from = Stock, values_from = Btemp)
# colnames(temps)[3:4] <- c("February", "March")

props <- dat %>%
  tidyr::drop_na() %>%
  dplyr::select(Year, Stock, Proportion) %>%
  dplyr::distinct()

dat2 <- dplyr::full_join(props, temps)

dat2 %>%
  dplyr::mutate(del_temp = North - South) %>%
  ggplot2::ggplot(ggplot2::aes(x = South,
                               y = Proportion,
                               color = Stock)) +
  ggplot2::geom_point(cex = 2) +
  ggplot2::geom_line(ggplot2::aes(group = Stock),
                     lty = 2,
                     color = "gray") +
  # ggplot2::geom_col() +
  # ggplot2::geom_line(data = tibble::tibble(x = 1:12,
  #                                          y = 1:12),
  #                    ggplot2::aes(x = x,
  #                                 y = y),
  #                    inherit.aes = FALSE,
  #                    lty = 2) +
  ggplot2::facet_grid(cols = ggplot2::vars(Month)#,
                      # rows = ggplot2::vars(Stock)
                      ) +
  viridis::scale_color_viridis(discrete = TRUE) +
  ggplot2::theme_bw()


dat2 %>%
  ggplot2::ggplot(ggplot2::aes(x = Year,
                               y = Proportion,
                               color = Stock,
                               fill = February)) +
  ggplot2::geom_col() +
  # ggplot2::facet_wrap(~Stock) +
  viridis::scale_fill_viridis() +
  ggplot2::theme_bw()
View(dat)
