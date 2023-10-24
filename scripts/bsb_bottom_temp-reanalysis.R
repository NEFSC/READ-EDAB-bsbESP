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
# load bottom temperature data and calculate monthly mean
data_bt <- tidync("data-raw/bottom_temp_combined_product_1959_2022.nc") %>%
  hyper_tibble(force = TRUE) %>%
  mutate(origin = as.Date(paste0(year, "-01-01"), tz = "UTC") - days(1),
         date = as.Date(day, origin = origin, tz = "UTC"),
         month = month(date)) %>%
  group_by(longitude, latitude, year, month) %>% # calculate monthly mean
  summarise(bt_temp = mean(sea_water_temperature_at_sea_floor, na.rm = TRUE))


# Extract the grid and create a spatial object for each grid cell (center of the grid cell)
glorys_grid <- unique(data_bt[c("longitude","latitude")]) %>%
  as.data.frame() %>%
  bind_cols(geometry = st_as_sf(.,coords = c("longitude", "latitude"), crs = st_crs(shape_bsb)),.)

# SPATIAL JOIN - identify cells whose the centers is included or intersect the BSB area
cell_intersects <- st_join(shape_bsb, glorys_grid, join = st_intersects) %>%
  as.data.frame()

# select grid cells within the BSB areas and calculate the winter mean for each area
data_bt_bsb <- inner_join(data_bt, cell_intersects, by = c("longitude","latitude")) %>%
  filter(month %in% c(2, 3)) %>%
  group_by(Region, year) %>%
  summarise(mean = mean(bt_temp, na.rm = TRUE),
            count = n(),
            sd = sd(bt_temp, na.rm = TRUE),
            se = sd/sqrt(count))

# select grid cells within the BSB areas and calculate the winter mean for entire area
data_bt_bsb_all <- inner_join(data_bt, cell_intersects, by = c("longitude","latitude")) %>%
  filter(month %in% c(2, 3)) %>%
  group_by(year) %>%
  summarise(mean = mean(bt_temp, na.rm = TRUE),
            count = n(),
            sd = sd(bt_temp, na.rm = TRUE),
            se = sd/sqrt(count))

write.csv(x = data_bt_bsb_all, file = here::here("data/bsb_bt_temp_1959-2022.csv"), row.names = FALSE)
write.csv(x = data_bt_bsb %>% filter(Region == "South"), file = here::here("data/bsb_bt_temp_smab_1959-2022.csv"), row.names = FALSE)
write.csv(x = data_bt_bsb %>% filter(Region == "North"), file = here::here("data/bsb_bt_temp_nmab_1959-2022.csv"), row.names = FALSE)
