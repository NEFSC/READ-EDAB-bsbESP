
`%>%` <- magrittr::`%>%`

dat <- NEesp::asmt %>%
  dplyr::filter(Species == "Black sea bass", 
                Metric == "Recruitment", 
                AssessmentYear == 2019)

dat %>%
  ggplot2::ggplot(ggplot2::aes(x = Year,
                               y = Value)) +
  ggplot2::geom_point()

model <- lm(Value~Year, data = dat)
acf(model$residuals, type = "correlation")

south_rec <- read.table(here::here("black-sea-bass/SOUTH.MT.2021.FINAL.STD.txt"),
                        header = TRUE) %>%
  dplyr::filter(stringr::str_detect(name, "log_recruit_devs")) %>%
  dplyr::mutate(Year = 1989:2019,
                group = "south")
model <- lm(value~Year, data = south_rec)
acf(model$residuals, type = "correlation")

north_rec <- read.table(here::here("black-sea-bass/NORTH.MT.2021.FINAL.STD.txt"),
                        header = TRUE) %>%
  dplyr::filter(stringr::str_detect(name, "log_recruit_devs")) %>%
  dplyr::mutate(Year = 1989:2019,
                group = "north")
model <- lm(value~Year, data = north_rec)
acf(model$residuals, type = "correlation")
