# -------------------------------------------
# rm(list=ls())
# -------------------------------------------
library(tidyverse)
library(tidync)
library(sf)

# load a dataframe linking year, month, day and calendar_day (I created this df some years ago because R function doing that messed up with leap years)
# load("data/y_m_cd.Rda")
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

# -------------------------------------------
# extract data old data set "bt_temp_product_month_1963_2021.nc"
# ------------------------------------------
# load bottom temperature data and calculate monthly mean
data_bt_2 <- tidync("data/bt_temp_product_month_1963_2021.nc") %>%
  hyper_tibble(force = TRUE)

# Extract the grid
glorys_grid_2 <- unique(data_bt_2[c("lon","lat")]) %>% as.data.frame() %>%
  bind_cols(geometry = st_as_sf(.,coords = c("lon", "lat"),crs=st_crs(shape_bsb)),.) # create a spatial object for each grid cell (center of the grid cell)

# SPATIAL JOIN - identify cells whose the centers is included or intersect the BSB area
cell_intersects_2 <- st_join(shape_bsb,glorys_grid_2,join = st_intersects) %>%
  as.data.frame()

# select grid cells within the BSB area and calculate the mean
data_bt_bsb_2 <- inner_join(data_bt_2,cell_intersects_2,by=c("lon","lat")) %>%
  group_by(lon,lat,year) %>%
  summarise(bt_temp=mean(bt_temp))

# -------------------------------------------
# extract data Rick data set "bt_temp_product_black_seabass.nc"
# ------------------------------------------
# load bottom temperature data and calculate monthly mean
data_bt_3 <- tidync("data/bt_temp_product_black_seabass.nc") %>%
  hyper_tibble(force = TRUE)
unique(data_bt_3$month)
# Extract the grid
glorys_grid_3 <- unique(data_bt_3[c("lon","lat")]) %>%
  as.data.frame() %>%
  bind_cols(geometry = st_as_sf(.,coords = c("lon", "lat"),crs=st_crs(shape_bsb)),.) # create a spatial object for each grid cell (center of the grid cell)

# SPATIAL JOIN - identify cells whose the centers is included or intersect the BSB area
cell_intersects_3 <- st_join(shape_bsb,glorys_grid_3,join = st_intersects) %>%
  as.data.frame()

# select grid cells within the BSB area and calculate the mean
data_bt_bsb_3 <- inner_join(data_bt_3,cell_intersects_3,by=c("lon","lat")) %>%
  group_by(lon,lat,year) %>%
  summarise(bt_temp=mean(bt_temp))
# ------------------------------------------
# MAP SPATIAL EXTENT
# ------------------------------------------
# -------------------------------------
# 1/12° grid
load("toolbox/grid_cell_no.Rda")
# extract land border
load("toolbox/geo_epu.Rda")
# EPU delineation
load("toolbox/geo_borders.Rda")
# ---------------------------------------------------------------------------
ymax<-45
ymin<-35
xmax<-(-65)
xmin<-(-76.2)
xlim1<-c(xmin,xmax)
ylim1<-c(ymin,ymax)
# ---------------------------------------------------------------------------
# MAP the spatial extents
# ---------------------------------------------------------------------------
extent_cell1 <- select(cell_intersects_1, longitude, latitude) %>%
  inner_join(data_bt_1,by=c("longitude","latitude")) %>%
  select(longitude, latitude) %>% unique() %>%
  inner_join(glorys_grid_1,.,by=c("longitude","latitude"))

extent_cell2 <- select(cell_intersects_2, lon, lat) %>%
  inner_join(data_bt_2,by=c("lon","lat")) %>%
  select(lon, lat) %>% unique() %>%
  inner_join(glorys_grid_2,.,by=c("lon","lat"))

extent_cell3 <- select(cell_intersects_3, lon, lat) %>%
  inner_join(data_bt_3,by=c("lon","lat")) %>%
  select(lon, lat) %>% unique() %>%
  inner_join(glorys_grid_3,.,by=c("lon","lat"))

jpeg(file = "map_spatial_extent.jpeg", width = 15, height = 5,res = 500,units = "in")
egg::ggarrange(
  ggplot() +
    geom_sf(data=extent_cell1,fill="red",size=0.1) +
    geom_sf(data=geo_epu, colour="gray50", fill=NA,size=0.1) +
    geom_sf(data=geo_borders, colour="black", fill="gray60",size=0.2),
  ggplot() +
    geom_sf(data=extent_cell2,fill="red",size=0.1) +
    geom_sf(data=geo_epu, colour="gray50", fill=NA,size=0.1) +
    geom_sf(data=geo_borders, colour="black", fill="gray60",size=0.2),
  ggplot() +
    geom_sf(data=extent_cell3,fill="red",size=0.1) +
    geom_sf(data=geo_epu, colour="gray50", fill=NA,size=0.1) +
    geom_sf(data=geo_borders, colour="black", fill="gray60",size=0.2),
  ncol=3,
  label.args = list(gp = grid::gpar(font = 1, cex = 1)),
  labels=c("bottom_temp_combined_product_1959_2022.nc","bt_temp_product_month_1963_2021.nc","bt_temp_product_black_seabass.nc"))
dev.off()

# ---------------------------------------------------------------------------
# Check consistency between datasets
# ---------------------------------------------------------------------------
# Compare "bt_temp_product_month_1963_2021.nc" and "bottom_temp_combined_product_1959_2022.nc"
# BT temp from"bottom_temp_combined_product_1959_2022.nc" within the spatial extent shared by "bt_temp_product_month_1963_2021.nc"
bt_temp_1_2 <- inner_join(data_bt_1,cell_intersects_1,by=c("longitude","latitude")) %>%
  inner_join(cell_intersects_2,by=c("longitude"="lon","latitude"="lat"))
dim(unique(bt_temp_1_2[,c("longitude","latitude")])) # 824 grid cell

bt_temp_1_2_mean <- bt_temp_1_2 %>% group_by(year) %>%  summarise(bt_temp=mean(bt_temp))

# BT temp from "bt_temp_product_month_1963_2021.nc"within the spatial extent shared by "bottom_temp_combined_product_1959_2022.nc"
bt_temp_2_1 <- inner_join(data_bt_2,cell_intersects_2,by=c("lon","lat")) %>%
  inner_join(cell_intersects_1,by=c("lon"="longitude","lat"="latitude"))
dim(unique(bt_temp_2_1[,c("lon","lat")])) # 824 grid cell

bt_temp_2_1_mean <- bt_temp_2_1 %>% group_by(year) %>%  summarise(bt_temp=mean(bt_temp))

jpeg(file ="comparison_new_dataset_vs_dataset_1963_2021.jpeg", width = 10, height = 4,res = 500,units = "in")
ggplot() +
  geom_point(data=bt_temp_1_2_mean, aes(x=year, y=bt_temp), color = "red") +
  geom_line(data=bt_temp_1_2_mean, aes(x=year, y=bt_temp), color = "red") +
  geom_point(data=bt_temp_2_1_mean, aes(x=year, y=bt_temp)) +
  geom_line(data=bt_temp_2_1_mean, aes(x=year, y=bt_temp))
dev.off()

# ---------------------------------------------------------------------------
# Compare "bt_temp_product_black_seabass.nc" and "bottom_temp_combined_product_1959_2022.nc"
# BT temp from"bottom_temp_combined_product_1959_2022.nc" within the spatial extent shared by "bt_temp_product_black_seabass.nc"
bt_temp_1_3 <- inner_join(data_bt_1,cell_intersects_1,by=c("longitude","latitude")) %>%
  filter(month %in% c(2,3)) %>%
  inner_join(cell_intersects_3,by=c("longitude"="lon","latitude"="lat"))
dim(unique(bt_temp_1_3[,c("longitude","latitude")])) # 1331 grid cell

bt_temp_1_3_mean <- bt_temp_1_3 %>% group_by(year) %>%  summarise(bt_temp=mean(bt_temp))

# BT temp from "bt_temp_product_black_seabass.nc" within the spatial extent shared by "bottom_temp_combined_product_1959_2022.nc"
bt_temp_3_1 <- inner_join(data_bt_3,cell_intersects_3,by=c("lon","lat")) %>%
  inner_join(cell_intersects_1,by=c("lon"="longitude","lat"="latitude"))
dim(unique(bt_temp_3_1[,c("lon","lat")])) # 1331 grid cell

bt_temp_3_1_mean <- bt_temp_3_1 %>% group_by(year) %>%  summarise(bt_temp=mean(bt_temp))

jpeg(file ="comparison_new_dataset_vs_dataset_from_rick.jpeg", width = 10, height = 4,res = 500,units = "in")
ggplot() +
  geom_point(data=bt_temp_1_3_mean, aes(x=year, y=bt_temp), color = "red") +
  geom_line(data=bt_temp_1_3_mean, aes(x=year, y=bt_temp), color = "red") +
  geom_point(data=bt_temp_3_1_mean, aes(x=year, y=bt_temp)) +
  geom_line(data=bt_temp_3_1_mean, aes(x=year, y=bt_temp))
dev.off()
