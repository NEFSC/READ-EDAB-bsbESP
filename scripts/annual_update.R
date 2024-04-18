

# Metadata ----

### Project name: BSB bottom temperature index
### Code purpose: Annual update for stock assessment

### Author: AT
### Date started: 2024-04-27

### Code reviewer:
### Date reviewed:

# Libraries & functions ----

library(tidync)
library(ggplot2)
library(terra)
library(tidyr)
library(dplyr)
library(stringr)
library(tidyverse)

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
    dplyr::filter(month %in% 2:3)

  # get mean
  results <- data_bt2 %>%
    group_by(year) %>%
    summarize(subarea = region_name,
              mean = mean(temp, na.rm = TRUE),
              sd = sd(temp, na.rm = TRUE))
  return(results)
}


# Data ----
fname <- here::here("data-raw/PSY_daily_BottomTemp_2020-01-012023-12-01.nc")
bsb_area <- vect("data-raw/bsb_shape.shp")

# Analyses ----

## data update

north <- create_temp_index(shape = subset(bsb_area, bsb_area$Region == "North"),
                           fname = here::here("data-raw/PSY_daily_BottomTemp_2020-01-012023-12-01.nc"),
                           region_name = "NMAB")
south <- create_temp_index(shape = subset(bsb_area, bsb_area$Region == "South"),
                           fname = here::here("data-raw/PSY_daily_BottomTemp_2020-01-012023-12-01.nc"),
                           region_name = "SMAB")

out <- rbind(north, south)
write.csv(out, here::here("data-raw", paste0("output_", Sys.Date(), ".csv")))

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
