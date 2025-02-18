# install.packages("tidync")
library(tidync)
library(dplyr)


shp <- readOGR("data-raw/bsb_shape.shp")

# bottom temp ----
src <- tidync(here::here("data-raw/bt_temp_product_black_seabass.nc")) %>%
  hyper_tibble() %>%
  group_by(year) %>%
  summarize(mean_bt = mean(bt_temp, na.rm = TRUE)) %>%
  as.data.frame()

p1 <- ggplot(src, aes(year, mean_bt)) +
  geom_point() +
  geom_line() +
  labs(x = "", y = "Mean winter Bottom temperature (C)") +
  theme_minimal()
p1

write.csv(src, file = "bsb_bt_temp-all regions.csv", row.names = FALSE)
ggsave("bsb_bt_temp-all regions.png", p1, bg = "white", width = 205, height = 75, units = "mm")
