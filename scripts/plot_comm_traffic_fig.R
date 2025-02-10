library(readxl)
comm_indicators_sqd <- read.csv(here::here('SOCIEOECONOMIC_COMMERCIAL_INDICATORS_LONGFINSQUID_FINAL.csv'))
comm_indicators_bsb <- read.csv(here::here('SOCIEOECONOMIC_COMMERCIAL_INDICATORS_BLACK_SEABASS_FINAL.csv'))


esp_traffic(data = total_rec_landings)
esp_traffic_fig(data = total_rec_landings)

mrip_data = rbind(rec_trips2, total_rec_catch, total_rec_landings)
esp_traffic_tab(total_rec_landings, 2007:2012, cap = "Summary of recent indicator values") 
  