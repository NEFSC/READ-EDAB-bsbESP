# library(tidync)
library(ggplot2)
library(terra)
library(tidyr)
library(dplyr)
library(stringr)
# library(patchwork)
library(lubridate)


f <- here::here("data-raw/bt_temp_product_black_seabass.nc")
# f <- here::here("data-raw/bt_temp_product_month_1963_2021.nc")

## Full netcdf of bottom temperature
# f <- here::here("data-raw/bottom_temp_combined_product_1959_2022.nc")
r <- rast(f)
# names(r)
# ## Create an index of year-month to create monthly mean
# months <- data.frame(names = names(r)) %>%
#   mutate(#doy = str_extract(names, "(?<=day=)[0-9]*"),
#          year = str_extract(names, "(?<=year=)[0-9]*"),
#          month = str_extract(names, "(?<=month=)[0-9]"),
#          date = as.Date(paste(year, month, "01", sep = "-"), format = "%Y-%m-%d"),
#          # month = lubridate::month(date),
#          monthly = factor(format(date, "%Y-%m"))) %>%
#   # fill(monthly) %>%
#   # mutate(monthly = factor(monthly)) %>%
#   pull(monthly)
#
# # monthly_m = terra::tapp(r, index = months, fun = mean, na.rm = T)
#
# ## Subset only for February and March months
# monthly_m_w <- r["^.*month=2|^.*month=3"]

## Create index of year to create annual winter (February and March) mean
years <- data.frame(names = names(r)) %>%
  mutate(year = factor(str_extract(names, "[0-9]{1,4}$"))) %>%
  pull(year)

annual_m_w <- terra::tapp(monthly_m_w, index = years, fun = mean, na.rm = T)

## Subset to the appropriate black sea bass regions
bsb_area <- vect("data-raw/bsb_shape.shp")
smab_area <- subset(bsb_area, bsb_area$Region == "South")
nmab_area <- subset(bsb_area, bsb_area$Region == "North")

smab_r <- crop(annual_m_w, smab_area)
nmab_r <- crop(annual_m_w, nmab_area)

## Create global statistics for the north and south subunits
smab_dat <- data.frame(year = gsub("X", "", names(smab_r))) %>%
  mutate(mean = as.numeric(global(smab_r, "mean", na.rm = TRUE)$mean),
         sd = global(smab_r, "sd", na.rm = TRUE)$sd,
         n = global(smab_r, "notNA", na.rm = TRUE)$notNA,
         se = sd/sqrt(n))

nmab_dat <- data.frame(year = gsub("X", "", names(nmab_r))) %>%
  mutate(mean = as.numeric(global(nmab_r, "mean", na.rm = TRUE)$mean),
         sd = global(nmab_r, "sd", na.rm = TRUE)$sd,
         n = global(nmab_r, "notNA", na.rm = TRUE)$notNA,
         se = sd/sqrt(n))

all_dat <- bind_rows(smab_dat, nmab_dat)
write.csv(x = all_dat, file = here::here("data/bsb_bt_temp-by region_1959-2022.csv"), row.names = FALSE)
write.csv(x = smab_dat, file = here::here("data/bsb_bt_temp-smab_1959-2022.csv"), row.names = FALSE)
write.csv(x = nmab_dat, file = here::here("data/bsb_bt_temp-nmab_1959-2022.csv"), row.names = FALSE)


old_s <- read.csv("data/bsb_bt_temp-smab_1963-2021.csv")
old_n <- read.csv("data/bsb_bt_temp-smab_1963-2021.csv")
str(smab_dat)
ggplot() +
  geom_point(data = smab_dat, aes(x = as.numeric(year), y = mean)) +
  # geom_line(data = smab_dat, aes(x = as.numeric(year), y = mean)) +
  geom_point(data = old_s, aes(x = as.numeric(year), y = mean), color = "red")


ggplot() +
  geom_point(data = nmab_dat, aes(x = as.numeric(year), y = mean)) +
  # geom_line(data = smab_dat, aes(x = as.numeric(year), y = mean)) +
  geom_point(data = old_n, aes(x = as.numeric(year), y = mean), color = "red")

