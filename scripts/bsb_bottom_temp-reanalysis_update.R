library(tidyverse)
library(tidync)
library(sf)

# -------------------------------------------
# Load management area of BSB
shape_bsb <- read_sf('data-raw/bsb_shape.shp') %>%
  st_transform(4140)

# -------------------------------------------
# extract data New data set "bottom_temp_combined_product_1959_2022.nc"
# ------------------------------------------

fname <- "data-raw/PSY_daily_BottomTemp_2020-01-012023-12-01.nc"


# load bottom temperature data and calculate monthly mean
data_bt <-
  tidync("data-raw/PSY_daily_BottomTemp_2020-01-012023-12-01.nc") %>%
  hyper_tibble(force = TRUE)

# get time info and add to tibble, filter to feb and march
tunit <- ncmeta::nc_atts("data-raw/PSY_daily_BottomTemp_2020-01-012023-12-01.nc", "time") %>%
  dplyr::filter(name == "units") %>%
  tidyr::unnest(cols = c(value))

data_bt2 <- data_bt %>%
  dplyr::mutate(month = RNetCDF::utcal.nc(tunit$value, .data$time)[,"month"],
                year = RNetCDF::utcal.nc(tunit$value, .data$time)[,"year"]) %>%
  dplyr::filter(month %in% 2:3)

data_bt3 <- data_bt2 %>%
  group_by(longitude, latitude, year, month) %>% # calculate monthly mean
  summarise(bt_temp = mean(tob , na.rm = TRUE))


# Extract the grid and create a spatial object for each grid cell (center of the grid cell)
glorys_grid <- unique(data_bt3[c("longitude","latitude")]) %>%
  as.data.frame() %>%
  bind_cols(geometry = st_as_sf(.,coords = c("longitude", "latitude"), crs = st_crs(shape_bsb)),.)

# SPATIAL JOIN - identify cells whose the centers is included or intersect the BSB area
cell_intersects <- st_join(shape_bsb, glorys_grid, join = st_intersects) %>%
  as.data.frame()

# select grid cells within the BSB areas and calculate the winter mean for each area
data_bt_bsb <- inner_join(data_bt3, cell_intersects, by = c("longitude","latitude")) %>%
  filter(month %in% c(2, 3)) %>%
  group_by(Region, year) %>%
  summarise(mean = mean(bt_temp, na.rm = TRUE),
            count = n(),
            sd = sd(bt_temp, na.rm = TRUE),
            se = sd/sqrt(count))

# select grid cells within the BSB areas and calculate the winter mean for entire area
data_bt_bsb_all <- inner_join(data_bt3, cell_intersects, by = c("longitude","latitude")) %>%
  filter(month %in% c(2, 3)) %>%
  group_by(year) %>%
  summarise(mean = mean(bt_temp, na.rm = TRUE),
            count = n(),
            sd = sd(bt_temp, na.rm = TRUE),
            se = sd/sqrt(count))

write.csv(x = data_bt_bsb_all, file = here::here("data", paste0(Sys.Date(), "_bsb_bt_temp_1959-2022.csv")), row.names = FALSE)
write.csv(x = data_bt_bsb %>% filter(Region == "South"), file = here::here("data", paste0(Sys.Date(), "_bsb_bt_temp_smab_1959-2022.csv")), row.names = FALSE)
write.csv(x = data_bt_bsb %>% filter(Region == "North"), file = here::here("data", paste0(Sys.Date(), "_bsb_bt_temp_nmab_1959-2022.csv")), row.names = FALSE)
