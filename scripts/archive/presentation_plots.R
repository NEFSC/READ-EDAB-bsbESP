
`%>%` <- magrittr::`%>%`


# DATA ----
## temperature ----
dat <- read.csv("data/bsb_bt_temp_nmab_1959-2022.csv")
sdat <- read.csv("data/bsb_bt_temp_smab_1959-2022.csv")

dat2 <- dat %>%
  dplyr::bind_rows(sdat) %>%
  dplyr::rename(val = mean,
                name = Region) %>%
  dplyr::group_by(name) %>%
  dplyr::mutate(mean = mean(val),
                sd = sd(val)) %>%
  dplyr::ungroup()

## recruitment ----
n_rec <- read.table("data-raw/NORTH.MT.2021.FINAL.STD.txt",
                    header = TRUE) %>%
  dplyr::filter(name == "log_recruit_devs") %>%
  dplyr::mutate(year = 1989:2019) %>%
  dplyr::rename(val = value)

s_rec <- read.table("data-raw/SOUTH.MT.2021.FINAL.STD.txt",
                    header = TRUE) %>%
  dplyr::filter(name == "log_recruit_devs") %>%
  dplyr::mutate(year = 1989:2019) %>%
  dplyr::rename(val = value)

rec <- rbind(n_rec %>%
               dplyr::mutate(region = "North"),
             s_rec %>%
               dplyr::mutate(region = "South")) %>%
  dplyr::group_by(region) %>%
  dplyr::mutate(mean = mean(val),
                sd = sd(val))

## shelf water volume ----
n_swv <- readxl::read_excel("data-raw/ShelfWaterVolume_BSB_Update.xlsx",
                            sheet = "N. MAB") %>%
  janitor::clean_names() %>%
  dplyr::select(year,
                val = sh_w_vol) %>%
  dplyr::mutate(region = "North")

s_swv <- readxl::read_excel("data-raw/ShelfWaterVolume_BSB_Update.xlsx",
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

## center of gravity (upper 95%) ----
cog <- read.csv("https://raw.githubusercontent.com/NOAA-EDAB/esp_data_aggregation/main/black-sea-bass/bsb_cog.csv")

cog2 <- cog %>%
  dplyr::mutate(upper_ci = value + )
  dplyr::select(-c(X, sd)) %>%
  tidyr::pivot_wider(names_from = variable,
                     values_from = value)
cog3 <- cog2 %>%
  dplyr::filter(season == "SPRING") %>%
  dplyr::group_by(year) %>%
  dplyr::mutate(distance = sqrt((max(Eastings) - min(Eastings))^2 +
                                  (max(Northings) - min(Northings))^2))

df_cog <- data.frame(variable = names(parameter_estimates$SD$value),
                         value = parameter_estimates$SD$value,
                         sd = parameter_estimates$SD$sd) %>%
  dplyr::filter(variable == "mean_Z_ctm") %>%
  dplyr::mutate(variable = rep(c("Eastings", "Northings"),
                               each = length(1989:2021) * 2),
                stock = rep(c("North", "South"),
                            times = length(1989:2021) * 2),
                year   = rep(c(1989:2021),
                             each = 2,
                             times = 2))

df_cog %>%
  dplyr::select(-sd) %>%
  tidyr::pivot_wider(names_from = variable,
                     values_from = value) %>%
  ggplot2::ggplot(ggplot2::aes(x = Eastings,
                               y = Northings,
                               shape = stock,
                               color = year)) +
    ggplot2::geom_point() +
  viridis::scale_color_viridis()


## effective area ----
load("data-raw/parameter_estimates.RData")
df_effArea <- data.frame(variable = names(parameter_estimates$SD$value),
                         value = parameter_estimates$SD$value,
                         sd = parameter_estimates$SD$sd) %>%
  dplyr::filter(variable == "effective_area_ctl") %>%
  # I am not sure that these variables are correctly assigned --AT
  dplyr::mutate(size = rep(c("North", "South"),
                           times = length(1989:2021)*11),
                year = rep(c(1989:2021),
                           each = 2,
                           times = 11),
                survey = rep(c(1:11),
                             each = 66)) %>%
  dplyr::filter(survey == 1)

df_effArea2 <- df_effArea %>%
  dplyr::rename(val = value,
                region = size) %>%
  dplyr::select(val, region, year) %>%
  dplyr::group_by(region) %>%
  dplyr::mutate(mean = mean(val),
                sd = sd(val),
                name = "eff_area")

# FUNCTIONS ----
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

test.cor <- function(data, y1, y2, x) {
  for(i in c("North", "South")) {
    message(paste(i, y1))
    res <- cor.test(x = dat %>%
                      dplyr::filter(region == i) %>%
                      dplyr::pull(x),
                    y = dat %>%
                      dplyr::filter(region == i) %>%
                      dplyr::pull(y1))
    print(res$p.value)
    message(paste(i, y2))
    res <- cor.test(x = dat %>%
                      dplyr::filter(region == i) %>%
                      dplyr::pull(x),
                    y = dat %>%
                      dplyr::filter(region == i) %>%
                      dplyr::pull(y2))
    print(res$p.value)
  }
}

# PLOTS ----
## temperature ----
time_series_plot(data = dat2, ylab = "Winter bottom temperature") +
  ggplot2::facet_wrap(~name,
                      nrow = 2)
ggplot2::ggsave("images/temperature.png", width = 5, height = 6)

## recruitment ----
rec %>%
        time_series_plot(ylab = "Log Recruitment Deviations (2021 model)") +
  ggplot2::facet_wrap(~region,
                      nrow = 2,
                      scales = "free_y")

ggplot2::ggsave("images/recruitment.png", width = 5, height = 6)

## temp x rec ----
compare <- rbind(rec,
                 dat2 %>%
                   dplyr::rename(region = name) %>%
                   dplyr::mutate(name = "bottom temperature")) %>%
                 dplyr::mutate(norm_value = (val - mean)/sd)

compare %>%
  ggplot2::ggplot(ggplot2::aes(x = year,
                               y = norm_value,
                               color = name)) +
  ggplot2::geom_line() +
  ggplot2::geom_point() +
  ggplot2::facet_wrap(~region,
                      nrow = 2) +
  ggplot2::xlim(c(1989, 2019)) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(legend.position = "bottom",
                 legend.title = ggplot2::element_blank(),
                 strip.text = ggplot2::element_text(size = 16),
                 axis.title.x = ggplot2::element_blank()) +
  ggplot2::ylab("Normalized value")
ggplot2::ggsave("images/compare.png", width = 5, height = 6)

## shelf water volume ----
swv %>%
  time_series_plot(ylab = "Winter shelf water volume") +
  ggplot2::facet_wrap(~name,
                      nrow = 2,
                      scales = "free_y")
ggplot2::ggsave("images/swv2.png", width = 5, height = 6)

## center of gravity ----
cog2 %>%
  dplyr::filter(season == "SPRING") %>%
  ggplot2::ggplot(ggplot2::aes(x = Eastings,
                                y = Northings,
                                color = year,
                                shape = stock)) +
  ggplot2::geom_point() +
  ggplot2::geom_line(ggplot2::aes(x = Eastings,
                                  y = Northings,
                                  color = year,
                                  group = year),
                     inherit.aes = FALSE,
                     lty = 2,
                     alpha = 0.5) +
  viridis::scale_color_viridis() +
  ggplot2::theme_bw()

cog2 %>%
  tidyr::pivot_longer(cols = c("Eastings", "Northings")) %>%
  dplyr::group_by(stock, name) %>%
  dplyr::mutate(mean = mean(value),
                sd = sd(value)) %>%
  dplyr::rename(val = value) %>%
  time_series_plot(ylab = "km") +
  ggplot2::facet_wrap(~paste(stock, name),
                      ncol = 2,
                      scales = "free_y") +
  ggplot2::theme(aspect.ratio = 0.5)
ggplot2::ggsave("images/north_east.png", width = 8)

cog3 %>%
  dplyr::rename(val = distance) %>%
  dplyr::select(year, val) %>%
  dplyr::distinct() %>%
  dplyr::ungroup() %>%
  dplyr::mutate(mean = mean(val),
                sd = sd(val),
                name = "distance") %>%
  time_series_plot(ylab = "Distance between stock centers") +
  ggplot2::theme(axis.title.y = ggplot2::element_text(size = 14))

ggplot2::ggsave("images/stock_distance.png", width = 5, height = 3)

## effective area ----
df_effArea %>%
  ggplot2::ggplot(ggplot2::aes(x = year,
                               y = value,
                               color = size)) +
  ggplot2::geom_point()

df_effArea %>%
  ggplot2::ggplot(ggplot2::aes(x = year,
                               y = value,
                               fill = size)) +
  ggplot2::geom_col(position = ggplot2::position_dodge())

df_effArea2 %>%
  time_series_plot(ylab = "Effective area (km2)") +
  ggplot2::facet_wrap(~region,
                      nrow = 2,
                      scales = "free_y") +
  ggplot2::theme(aspect.ratio = 0.5)
ggplot2::ggsave("images/effective_area.png", width = 5)

# standardize?
df_effArea2 %>%
  dplyr::mutate(norm_value = (val - mean)/sd) %>%
  ggplot2::ggplot(ggplot2::aes(x = year,
                               y = norm_value,
                               color = region)) +
  ggplot2::geom_line() +
  ggplot2::geom_point() +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(legend.position = "bottom",
                 legend.title = ggplot2::element_blank(),
                 strip.text = ggplot2::element_text(size = 16),
                 axis.title.x = ggplot2::element_blank()) +
  ggplot2::ylab("Normalized effective area")

ggplot2::ggsave("images/compare_eff_area.png", width = 5, height = 4)

## eff area + swv ----

### correlations w swv
dat <- dplyr::full_join(df_effArea2 %>%
                          dplyr::select(-c(mean, sd, name)) %>%
                          dplyr::rename(eff_area = val),
                        swv %>%
                          dplyr::select(-c(mean, sd)) %>%
                          dplyr::rename(swv = val,
                                        region = name)) %>%
  dplyr::full_join(cog3 %>%
                     dplyr::select(-season) %>%
                     dplyr::rename(region = stock)) %>%
  tidyr::drop_na()

test.cor(data = dat, y1 = "eff_area", x = "swv", y2 = "Northings")

lm(eff_area ~ swv + region,
   data = dat) %>%
  summary()

dat %>%
  ggplot2::ggplot(ggplot2::aes(x = swv,
                               y = eff_area,
                               # shape = region,
                               color = year)) +
  ggplot2::geom_point() +
  ggplot2::geom_smooth(method = "lm") +
  viridis::scale_color_viridis() +
  ggplot2::facet_wrap(~region,
                      scales = "free",
                      ncol = 1) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(legend.position = "right",
                 # legend.title = ggplot2::element_blank(),
                 legend.direction = "vertical") +
  ggplot2::ylab("Spring effective area occupied (km2)") +
  ggplot2::xlab("Winter shelf water volume (km3)")
ggplot2::ggsave("images/shw_eff_area.png", width = 8, height = 6)


lm(eff_area ~ swv,
   data = dat %>%
     dplyr::filter(region == "South")) %>%
  summary()
