`%>%` <- magrittr::`%>%`


### data ----
channel <- dbutils::connect_to_database(
  server = "sole",
  uid = "atyrell"
)

# pull all trawl data
pull <- survdat::get_survdat_data(channel,
                                  all.season = TRUE,
                                  getBio = FALSE)

bsb_nmfs <- pull$survdat %>%
  dplyr::filter(SVSPP == 141)

# usethis::use_data(bsb_nmfs, overwrite = TRUE)

all_nmfs <- pull$survdat %>%
  dplyr::select(-c(SVSPP, ABUNDANCE, BIOMASS, LENGTH, NUMLEN)) %>%
  dplyr::distinct() %>%
  dplyr::mutate(MONTH = lubridate::month(EST_TOWDATE))
# usethis::use_data(all_nmfs, overwrite = TRUE)

# map setup ----
xmin <- -81
xmax <- -66
ymin <- 26
ymax <- 45
xlims <- c(xmin, xmax)
ylims <- c(ymin, ymax)
crs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

ne_countries <- rnaturalearth::ne_countries(
  scale = 10,
  continent = "North America",
  returnclass = "sf"
) %>%
  sf::st_transform()

ne_states <- rnaturalearth::ne_states(
  country = "united states of america",
  returnclass = "sf"
) %>% sf::st_transform()

# plot
p1 <- ggplot2::ggplot() +
  ggplot2::geom_sf(
    data = ne_countries,
    color = "grey60",
    size = 0.25
  ) +
  ggplot2::geom_sf(
    data = ne_states,
    color = "grey60",
    size = 0.05
  ) +
  ggplot2::coord_sf(
    crs = crs,
    xlim = xlims,
    ylim = ylims
  ) +
  ggthemes::theme_map() +
  ggplot2::theme(legend.direction = "horizontal")


dat <- bsb_nmfs %>%
  dplyr::mutate(MONTH = lubridate::month(EST_TOWDATE)) %>%
  dplyr::group_by(YEAR, MONTH, EST_TOWDATE, LAT, LON, SURFTEMP, SURFSALIN) %>%
  dplyr::summarise(n_fish = sum(NUMLEN)) %>%
  dplyr::ungroup()

### plot ----

# all fish ----
p1 +
  ggplot2::geom_point(
    data = all_nmfs,
    ggplot2::aes(
      x = LON,
      y = LAT
    ),
    fill = "white",
    color = "gray80",
    pch = 21
  ) +
  ggplot2::geom_point(
    data = dat,
    ggplot2::aes(
      x = LON,
      y = LAT,
      color = log(n_fish)
    ),
    cex = 0.9
  ) +
  viridis::scale_color_viridis() +
  ggplot2::facet_wrap(~MONTH,
                      labeller =
                        ggplot2::labeller(
                          MONTH = c(
                            "1" = "January", "2" = "February", "3" = "March",
                            "4" = "April", "5" = "May", "6" = "June",
                            "7" = "July", "8" = "August", "9" = "September",
                            "10" = "October", "11" = "November", "12" = "December"
                          )
                        )
  ) +
  ggplot2::ggtitle("Black sea bass")


# feb & march, over years ----

dat2 <- dat %>%
  dplyr::filter(MONTH %in% 2:3) %>%
  dplyr::group_by(YEAR) %>%
  dplyr::mutate(total_fish = sum(n_fish),
                n_tows = length(unique(EST_TOWDATE))) %>%
  dplyr::filter(total_fish > 0)

for(i in unique(dat2$YEAR)) {
p1 +
  ggplot2::geom_point(
    data = all_nmfs %>%
      dplyr::filter(MONTH %in% 2:3),
    ggplot2::aes(
      x = LON,
      y = LAT
    ),
    fill = "white",
    color = "gray80",
    pch = 21
  ) +
  ggplot2::geom_point(
    data = dat %>%
      dplyr::filter(MONTH %in% 2:3,
                    YEAR == i),
    ggplot2::aes(
      x = LON,
      y = LAT,
      color = log(n_fish)
    ),
    cex = 0.9
  ) +
  viridis::scale_color_viridis() +
  ggplot2::facet_grid(cols = ggplot2::vars(MONTH),
                      # rows = ggplot2::vars(YEAR),
                      labeller =
                        ggplot2::labeller(
                          MONTH = c(
                            "1" = "January", "2" = "February", "3" = "March",
                            "4" = "April", "5" = "May", "6" = "June",
                            "7" = "July", "8" = "August", "9" = "September",
                            "10" = "October", "11" = "November", "12" = "December"
                          )
                        )
  ) +
  ggplot2::ggtitle(paste("Black sea bass", i))
  ggplot2::ggsave(here::here(paste("black-sea-bass/figs/", i, ".png")))
}
