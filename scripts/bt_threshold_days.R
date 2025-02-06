library(lubridate)
library(dplyr)
library(sf)
library(ggplot2)
`%>%` <- magrittr::`%>%`

#read in 1989-2024 bottom temp and create day column
bt_89_24 <- read.csv(here::here("data/bottomT_89_24.csv"))
bt_89_24$day<- day(ymd(bt_89_24$time))
all_dates <- subset(bt_89_24, select = -c(time))

#read bsb shapefile
shape_bsb <- read_sf(here::here('data-raw/bsb_shape.shp')) %>%
  st_transform(4140)

###########################
# calculate daily mean
data3 <- all_dates %>%
  group_by(longitude, latitude, year, month, day) %>%
  summarise(bt_temp = mean(value, na.rm = TRUE))

# Extract the grid and create a spatial object for each grid cell (center of the grid cell)
glorys_grid <- unique(data3[c("longitude","latitude")]) %>%
  as.data.frame() %>%
  bind_cols(geometry = st_as_sf(.,coords = c("longitude", "latitude"), crs = st_crs(shape_bsb)),.)

# SPATIAL JOIN - identify cells whose the centers is included or intersect the BSB area
cell_intersects <- st_join(shape_bsb, glorys_grid, join = st_intersects) %>%
  as.data.frame()

# select grid cells within the BSB areas and calculate the winter mean for each area
data_bt_bsb <- inner_join(data3, cell_intersects, by = c("longitude","latitude")) %>%
  filter(month %in% c(2, 3)) %>%
  group_by(Region, year, month, day) %>%
  summarise(mean = mean(bt_temp, na.rm = TRUE))


# select grid cells within the BSB areas and calculate the winter mean for entire area
data_bt_bsb_all <- inner_join(data3, cell_intersects, by = c("longitude","latitude")) %>%
  # filter(month %in% c(2, 3)) %>%
  group_by(year, month, day) %>%
  summarise(mean = mean(bt_temp, na.rm = TRUE))

## create results tibble ----
results <- rbind(data_bt_bsb,
                 data_bt_bsb_all %>%
                   dplyr::mutate(Region = "All"))

write.csv(results, here::here("data", "bt_daily_mean.csv"))

###calculate number of days below 8c in each month

days_below_8c <- data_bt_bsb %>%
  dplyr::filter(mean < 8) %>%
  dplyr::summarise(days_below_8 = dplyr::n()) %>%
  dplyr::group_by(year, Region) %>%
  dplyr::summarise(total_days = sum(days_below_8)) %>%
  dplyr::group_by(year, Region) %>%
  dplyr::mutate(mean = mean(days_below_8c$total_days, na.rm = TRUE),
                sd = stats::sd(days_below_8c$total_days, na.rm = TRUE))


###plot

days_below_8c %>%
  ggplot2::ggplot(ggplot2::aes(x = year,
                               y = total_days,
                               color = Region,
  )) +
  ggplot2::geom_point() +
  ggplot2::geom_path() +
  ggplot2::theme_bw() +
  ggplot2::xlim(c(1989, 2024)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = days_below_8c$mean,
    group = days_below_8c$Region
  ),
  color = "darkgreen",
  linetype = "solid"
  ) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept =days_below_8c$sd,
   group = days_below_8c$Region
  ),
  color = "darkorange",
  linetype = "solid"
  ) +
  ggplot2::theme(axis.title = element_text(size = 16),
                 axis.text = element_text(size = 14),
                 legend.title = element_text(size = 16),
                 legend.text = element_text(size = 14)) +
  ggplot2::labs(title = "Days (Feb-Mar) Below Optimal Temperature (8C)",
                x = "Year",
                y = "Days Below 8C") +
  ggplot2::facet_grid("Region")
