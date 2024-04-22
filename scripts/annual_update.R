

# Metadata ----

### Project name: BSB bottom temperature index
### Code purpose: Annual update for stock assessment

### Author: AT
### Date started: 2024-04-27

### Code reviewer:
### Date reviewed:

# Libraries & functions ----

library(tidyverse)
library(tidync)
library(sf)

# this function is not used but keeping here for reference
# uses raster::mask instead of extracting intersecting cells
# produces slightly different results
create_temp_index <- function(shape, # shapefile to average over
                              fname, # filename of temp data (.nc)
                              region_name # north or south, will be returned in output
) {
  # read in as raster
  r <- rast(fname)

  # crop to size
  this_r <- raster::mask(r, shape)

  # save temp file as .nc
  terra::writeCDF(this_r, "data-raw/temp.nc", overwrite = TRUE)

  # read temp file in as tidync
  data_bt <- tidync("data-raw/temp.nc")

  # convert to tibble
  df_bt <- data_bt %>%
    hyper_tibble(force = TRUE)

  # get time info and add to tibble, filter to feb and march
  tunit <- ncmeta::nc_atts("data-raw/temp.nc", "time") %>%
    dplyr::filter(name == "units") %>%
    tidyr::unnest(cols = c(value))

  data_bt2 <- df_bt %>%
    dplyr::mutate(month = RNetCDF::utcal.nc(tunit$value, .data$time)[,"month"],
                  year = RNetCDF::utcal.nc(tunit$value, .data$time)[,"year"]) %>%
    dplyr::filter(month %in% 2:3) %>%
    # calculate monthly mean
    group_by(longitude, latitude, year, month) %>%
    summarise(bt_temp = mean(temp , na.rm = TRUE)) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(year) %>%
    # calculate results
    summarise(mean = mean(bt_temp, na.rm = TRUE),
              count = n(),
              sd = sd(bt_temp, na.rm = TRUE),
              se = sd/sqrt(count))
  return(data_bt2)
}
# create_temp_index(fname = fname,
#                   shape = shape_bsb,
#                   region_name = "All")


# Data ----
# fname <- here::here("data-raw/PSY_daily_BottomTemp_2020-01-012023-12-01.nc")
fname <- here::here("data-raw/cmems_mod_glo_phy_myint_0.083deg_P1D-m_1713817868836.nc")

shape_bsb <- read_sf('data-raw/bsb_shape.shp') %>%
  st_transform(4140)

# Analyses ----

## load bottom temperature data and calculate monthly mean ----
data_bt <- tidync(fname) %>%
  hyper_tibble(force = TRUE)

### get time info and add to tibble ----
tunit <- ncmeta::nc_atts(fname, "time") %>%
  dplyr::filter(name == "units") %>%
  tidyr::unnest(cols = c(value))

data_bt2 <- data_bt %>%
  dplyr::mutate(month = RNetCDF::utcal.nc(tunit$value, .data$time)[,"month"],
                year = RNetCDF::utcal.nc(tunit$value, .data$time)[,"year"]) %>%
  # filter to feb and march
  dplyr::filter(month %in% 2:3) %>%
  # calculate monthly mean
  group_by(longitude, latitude, year, month) %>%
  summarise(bt_temp = mean(bottomT, na.rm = TRUE))

## cut to area of interest ----
# this could possibly be done quicker with raster::mask

# Extract the grid and create a spatial object for each grid cell (center of the grid cell)
glorys_grid <- unique(data_bt2[c("longitude","latitude")]) %>%
  as.data.frame() %>%
  bind_cols(geometry = st_as_sf(.,coords = c("longitude", "latitude"), crs = st_crs(shape_bsb)),.)

# SPATIAL JOIN - identify cells whose the centers is included or intersect the BSB area
cell_intersects <- st_join(shape_bsb, glorys_grid, join = st_intersects) %>%
  as.data.frame()

# select grid cells within the BSB areas and calculate the winter mean for each area
data_bt_bsb <- inner_join(data_bt2, cell_intersects, by = c("longitude","latitude")) %>%
  filter(month %in% c(2, 3)) %>%
  group_by(Region, year) %>%
  summarise(mean = mean(bt_temp, na.rm = TRUE),
            count = n(),
            sd = sd(bt_temp, na.rm = TRUE),
            se = sd/sqrt(count))

# select grid cells within the BSB areas and calculate the winter mean for entire area
data_bt_bsb_all <- inner_join(data_bt2, cell_intersects, by = c("longitude","latitude")) %>%
  filter(month %in% c(2, 3)) %>%
  group_by(year) %>%
  summarise(mean = mean(bt_temp, na.rm = TRUE),
            count = n(),
            sd = sd(bt_temp, na.rm = TRUE),
            se = sd/sqrt(count))

## create results tibble ----
results <- rbind(data_bt_bsb,
                 data_bt_bsb_all %>%
                   dplyr::mutate(Region = "All"))

write.csv(x = results, file = here::here("data", paste0(Sys.Date(), "_bsb_bt_temp_update.csv")), row.names = FALSE)

## compare to previous data ----
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
