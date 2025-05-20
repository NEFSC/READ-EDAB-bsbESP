`%>%` <- magrittr::`%>%`
library(dplyr)

path = (here::here('data-raw/mrip_data'))
# pull in directed trip files
files <- list.files(path = path, pattern = glob2rx('mrip_d*.csv'),
                       full.names = TRUE)
# run directed trip function - this calculated # of trips for spp of interest
rec_trips <- create_rec_trips(files = files)
# How do we want to filter? Just the states we are interested in, combine or sep?
rec_trips2 <- rec_trips %>% filter(STATE %in% c('MAINE',  'CONNECTICUT',
                                 'MASSACHUSETTS',
                                 'NEW HAMPSHIRE',
                                 'NEW JERSEY',
                                 'NEW YORK',
                                 'RHODE ISLAND',
                                 'MARYLAND',
                                 'DELAWARE',
                                 'NORTH CAROLINA')) %>% # northern stock only (Northern MAB))
  group_by(YEAR) %>%
  dplyr::summarise(DATA_VALUE = sum(as.numeric(DATA_VALUE), na.rm = TRUE)) %>%
  mutate(CATEGORY = "Recreational",
         INDICATOR_TYPE = "Socioeconomic",
         INDICATOR_NAME = "total_recreational_trips_n")

# pull in effort file
mrip_effort <- read.csv(here::here(path, 'mrip_effort_series.csv'),
                        skip = 44,# was 24 is now 44
                        na.strings = ".")
# run effort function - this calcs all rec effort to get prop of rec effort for spp of interest
prop_sp_trips <- create_prop_sp_trips(total = mrip_effort, sp = rec_trips)

# read in mrip catch data
mrip_catch <- read.csv(here::here(path, 'mrip_BLACK_SEA_BASS_catch_series.csv'),
                        skip = 46, # of rows you want to ignore
                        na.strings = ".")

total_rec_catch <- create_total_rec_catch(mrip_catch)


mrip_landing <- read.csv(here::here(path, 'mrip_BLACK_SEA_BASS_harvest.csv'),
                       skip = 46, # of rows you want to ignore
                       na.strings = ".")

total_rec_landings <- create_total_rec_landings(mrip_landing)
#### It all worked!! Need to save indicator TS and PLOT! ###
## Also - need to add in the ifelse statements to filter for
## data quality and make them more generalizable based on if ppl
## select sub regions or states

rec_indicators <- rbind(total_rec_landings, total_rec_catch, rec_trips2)
write.csv(rec_indicators, here::here("data-raw", "rec_indicators_2025.csv"))



