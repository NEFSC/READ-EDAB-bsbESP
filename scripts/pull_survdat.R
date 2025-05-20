
source(here::here("../../Abigail.Tyrell/channel.R"))

# full data pull
data <- survdat::get_survdat_data(channel)

# bio data pull
data <- survdat::get_survdat_data(channel, getBio = TRUE, getLengths = TRUE)

# my data pull isn't working, save data from NEesp2

write.csv(NEesp2::survdat_subset,
          here::here("data/survey_bio_data.csv"))
