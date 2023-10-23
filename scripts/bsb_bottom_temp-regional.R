library(tidync)
library(ggplot2)
library(terra)
library(tidyr)
library(dplyr)
library(stringr)

# f <- here::here("data-raw/bt_temp_product_black_seabass.nc")
f <- here::here("data-raw/bt_temp_product_month_1963_2021.nc")
r <- rast(f)

bsb_area <- vect("data-raw/bsb_shape.shp")

smab_area <- subset(bsb_area, bsb_area$Region == "South")
nmab_area <- subset(bsb_area, bsb_area$Region == "North")
smab_r <- crop(r, smab_area)
nmab_r <- crop(r, nmab_area)

nmab_dat <- as.data.frame(nmab_r) %>%
  pivot_longer(cols = everything(), names_to = "year") %>%
  separate(col = year, into = c("var1", "var2", "month", "year"), sep = "_") %>%
  mutate(year = as.numeric(str_extract(year, "[[:digit:]]+")),
         month = as.numeric(str_extract(month, "[[:digit:]]+"))) %>%
  filter(month %in% c(2,3)) %>%
  group_by(year) %>%
  summarize(subarea = "north",
            mean = mean(value, na.rm = TRUE),
            sd = sd(value, na.rm = TRUE))

smab_dat <- as.data.frame(smab_r) %>%
  pivot_longer(cols = everything(), names_to = "year") %>%
  separate(col = year, into = c("var1", "var2", "month", "year"), sep = "_") %>%
  mutate(year = as.numeric(str_extract(year, "[[:digit:]]+")),
         month = as.numeric(str_extract(month, "[[:digit:]]+"))) %>%
  filter(month %in% c(2,3)) %>%
  group_by(year) %>%
  summarize(subarea = "south",
            mean = mean(value, na.rm = TRUE),
            sd = sd(value, na.rm = TRUE))

all_dat <- bind_rows(smab_dat, nmab_dat)
write.csv(x = all_dat, file = here::here("data/bsb_bt_temp-by region.csv"), row.names = FALSE)
write.csv(x = smab_dat, file = here::here("data/bsb_bt_temp-smab.csv"), row.names = FALSE)
write.csv(x = nmab_dat, file = here::here("data/bsb_bt_temp-nmab.csv"), row.names = FALSE)

ggplot(all_dat, aes(x = year, y = mean, ymin = mean - sd, ymax = mean + sd, color = subarea)) +
  geom_errorbar() +
  geom_point() +
  theme_minimal() +
  facet_wrap(~subarea, ncol = 1)


smab_ricky <- read.csv(here::here("data/SMAB_winter_bot.csv")) %>%
  select(-X, -mean_bot_S,
         mean = mean_bot_T) %>%
  mutate(subarea = "ricky_S")

nmab_ricky <- read.csv(here::here("data/NMAB_winter_bot.csv")) %>%
  select(-X, -mean_bot_S,
         mean = mean_bot_T) %>%
  mutate(subarea = "ricky_N")

n_dat <- bind_rows(nmab_dat, nmab_ricky)
s_dat <- bind_rows(smab_dat, smab_ricky)

n_dat_c <- n_dat %>%
  filter(year %in% 1989:2019) %>%
  select(-sd) %>%
  pivot_wider(names_from = subarea, values_from = mean)

s_dat_c <- s_dat %>%
  filter(year %in% 1989:2019) %>%
  select(-sd) %>%
  pivot_wider(names_from = subarea, values_from = mean)


ggplot(n_dat, aes(x = year, y = mean, ymin = mean - sd, ymax = mean + sd, color = subarea)) +
  geom_errorbar() +
  geom_point() +
  theme_minimal() +
  facet_wrap(~subarea, ncol = 1)

ggplot(s_dat, aes(x = year, y = mean, ymin = mean - sd, ymax = mean + sd, color = subarea)) +
  geom_errorbar() +
  geom_point() +
  theme_minimal()



n1 <- ggplot(n_dat_c, aes(x = ricky_N, y = north)) +
  geom_point() +
  labs(x = "NMAB_winter_bot.csv", y = "bsb_bt_temp-nmab.csv",
       title = "North MAB Bottom Temperature",
       subtitle = "Ricky's in situ vs Hubert's reanalysis") +
  theme_minimal()

s1 <- ggplot(s_dat_c, aes(x = ricky_S, y = south)) +
  geom_point() +
  labs(x = "SMAB_winter_bot.csv", y = "bsb_bt_temp-smab.csv",
       title = "South MAB Bottom Temperature",
       subtitle = "Ricky's in situ vs Hubert's reanalysis") +
  theme_minimal()

p2 <- n1/s1

library(patchwork)
ggsave("bsb_bt_temp-comparison.png", p2, bg = "white", width = 205, height = 150, units = "mm")

rc %>%
  group_by(names) %>%
  summarise(mean)
