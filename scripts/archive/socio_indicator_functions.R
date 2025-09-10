#' Create commercial indicators
#'
#' This function transforms bluefish commercial indicators from an input spreadsheet to an R object
#' @param data Filepath to the indicator data
#' @param return Boolean. Whether to return the indicators as an object in the global environment
#' @return Saves R object `comm_indicators`, returns commercial indicators
#' @export
#'

create_comm_indicators <- function(data = here::here("data-raw/SOCIEOECONOMIC_COMMERCIAL_INDICATORS_BLACK_SEABASS_FINAL.csv"),
                                   return = TRUE){
  comm_indicators <- read.csv(data)

  usethis::use_data(comm_indicators, overwrite = TRUE)

  if(return) return(comm_indicators)
}


#' Create BSB recreational trips indicator
#'
#' This function creates the trips indicator for black sea bass
#' @param files A list of the full file names of annual directed trip data (.csv format)
#' @param return Boolean. Whether to return the indicator as an object in the global environment
#' @return Saves R object `rec_trips`, returns directed recreational trips indicator
#'
#' Files for each year of recreational trips in ESP Google drive folder:
#' Report Cards > Black Sea Bass > 2025 > data > mrip_data
#'
#' For new data queries, use MRIP Query Tool (https://www.fisheries.noaa.gov/data-tools/recreational-fisheries-statistics-queries)
#' Query 'Directed Trip' under 'Effort Data'.
#' Choose year of interest, summarize by Annual, Calendar Year, Atlantic Coast by State, Black Sea Bass, all modes and areas, Primary Target
#' Download csv as output
#'
#'
#' @export

create_rec_trips <- function(files) {
  rec_directed_trips <- c()
  for (i in files) {
    this_dat <- read.csv(i,
                         skip = 44,# was 24 is now 44
                         na.strings = "."
    )
    message(unique(this_dat$Year)) # make sure all years are downloaded
    rec_directed_trips <- rbind(rec_directed_trips, this_dat)
  }

  rec_trips <- rec_directed_trips %>%
    dplyr::group_by(Year, State) %>%
    dplyr::summarise(DATA_VALUE = sum(Directed.Trips, na.rm = TRUE)) %>%
    dplyr::mutate(CATEGORY = "Recreational",
                  INDICATOR_TYPE = "Socioeconomic",
                  INDICATOR_NAME = "rec_trips") %>%
    dplyr::rename(YEAR = Year,
                  STATE = State)

  #usethis::use_data(rec_trips, overwrite = TRUE)

  return(rec_trips)

}


#' Create BSB effort indicator
#'
#' This function creates the proportion trips targeting black sea bass (effort) indicator
#' @param total The mrip trip data (R object `mrip_effort`)
#' @param rec_trips The black sea bass directed trips (R object `rec_trips`)
#' @param return Boolean. Whether to return the indicator as an object in the global environment
#' @return Saves the R data object `prop_sp_trips`
#'
#' MRIP effort data in GDrive: Report Cards > Black Sea Bass > 2025 > data > mrip_data > mrip_effort_series.csv
#'
#' For new data queries, use MRIP Query Tool (https://www.fisheries.noaa.gov/data-tools/recreational-fisheries-statistics-queries)
#' Query 'Time Series' under 'Effort Data'.
#' Choose years of interest, summarize by Annual, Calendar Year, Atlantic Coast by State, all modes and areas
#' Download csv as output
#'
#' @export

create_prop_sp_trips <- function(total = mrip_effort,
                                 sp = rec_trips,
                                 states = c('MAINE',
                                            'CONNECTICUT',
                                            'MASSACHUSETTS',
                                            'NEW HAMPSHIRE',
                                            'NEW JERSEY',
                                            'NEW YORK',
                                            'RHODE ISLAND',
                                            'MARYLAND',
                                            'DELAWARE',
                                            'NORTH CAROLINA'
                                 ),
                                 return = TRUE){
  total_trips <- total %>%
    # dplyr::filter(sub_reg %in% 4:6) %>% # atlantic coast only
    # need to add in an ifelse for the category that was dl (sub_reg, state, etc)
    dplyr::filter(State %in% states
                    ) %>% # northern stock only (Northern MAB)
    dplyr::group_by(Year) %>%
    dplyr::summarise(total_trips = sum(as.numeric(Angler.Trips), na.rm = TRUE)) %>% # replaced estrips w/angler.trips
    dplyr::mutate(YEAR = as.numeric(Year)) %>%
    dplyr::select(-Year)
  sp <- sp %>% dplyr::group_by(YEAR) %>%
    dplyr::summarise(DATA_VALUE = sum(as.numeric(DATA_VALUE), na.rm = TRUE))
  prop_sp_trips <- dplyr::full_join(total_trips,
                                    sp,
                                    by = c("YEAR")) %>%
    dplyr::mutate(DATA_VALUE = DATA_VALUE/total_trips,
                  INDICATOR_NAME = "proportion_sp_trips") %>%
    dplyr::select(-total_trips)

  #usethis::use_data(prop_sp_trips, overwrite = TRUE)
  if(return) return(prop_sp_trips)
}


#' Create BSB total recreational catch indicator
#'
#' This function creates the total recreational catch indicator
#' @param data The mrip data (R object `mrip_catch`), already subset to species of interest only
#' @param return Boolean. Whether to return the indicator as an object in the global environment
#' @return Saves the R data object `total_rec_catch`
#'
#' MRIP effort data in GDrive: Report Cards > Black Sea Bass > 2025 > data > mrip_data > mrip_BLACK_SEA_BASS_catch_series.csv
#'
#' For new data queries, use MRIP Query Tool (https://www.fisheries.noaa.gov/data-tools/recreational-fisheries-statistics-queries)
#' Query 'Time Series' under 'Catch Data'.
#' Choose years of interest, summarize by Annual, Calendar Year, Atlantic Coast by State, Black Sea Bass, all modes and areas, Total Catch
#' Download csv as output
#'
#' @export
#'

create_total_rec_catch <- function(data = mrip_catch){
  total_rec_catch <- data %>%
    dplyr::rename(tot_cat = Total.Catch..A.B1.B2.) %>%
    dplyr::filter(State %in%
                    c('MAINE',
                      'CONNECTICUT',
                      'MASSACHUSETTS',
                      'NEW HAMPSHIRE',
                      'NEW JERSEY',
                      'NEW YORK',
                      'RHODE ISLAND',
                      'MARYLAND',
                      'DELAWARE',
                      'NORTH CAROLINA'
                    )) %>%
    dplyr::group_by(Year) %>% # changed y to Y
    dplyr::summarise(DATA_VALUE = sum(tot_cat, na.rm = TRUE)) %>%
    dplyr::mutate(CATEGORY = "Recreational",
                  INDICATOR_TYPE = "Socioeconomic",
                  INDICATOR_NAME = "total_recreational_catch_n") %>%
    dplyr::rename(YEAR = Year) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(YEAR = as.numeric(YEAR))

  # usethis::use_data(total_rec_catch, overwrite = TRUE)
  return(total_rec_catch)
}


#' Create BSB recreational landings indicator
#'
#' This function creates the bluefish recreational landings indicator
#' @param data The mrip catch data (R object `mrip_catch`)
#' @param return Boolean. Whether to return the indicator as an object in the global environment
#' @return Saves the R data object `total_rec_landings`
#'
#' MRIP effort data in GDrive: Report Cards > Black Sea Bass > 2025 > data > mrip_data > mrip_BLACK_SEA_BASS_harvest.csv
#'
#' For new data queries, use MRIP Query Tool (https://www.fisheries.noaa.gov/data-tools/recreational-fisheries-statistics-queries)
#' Query 'Time Series' under 'Catch Data'.
#' Choose years of interest, summarize by Annual, Calendar Year, Atlantic Coast by State, Black Sea Bass, all modes and areas, Harvest (A + B1), choose # of fish/weight (lbs), mean length and weight
#' Download csv as output
#'
#'
#' @export

create_total_rec_landings <- function(data = mrip_landing, return = TRUE){
  total_rec_landings <- data %>%
    dplyr::rename(lbs_ab1 = Harvest..A.B1..Total.Weight..lb.) %>%
    dplyr::filter(State %in%
                    c('MAINE',
                      'CONNECTICUT',
                      'MASSACHUSETTS',
                      'NEW HAMPSHIRE',
                      'NEW JERSEY',
                      'NEW YORK',
                      'RHODE ISLAND',
                      'MARYLAND',
                      'DELAWARE',
                      'NORTH CAROLINA'
                    )) %>%
    dplyr::group_by(Year) %>%
    dplyr::summarise(DATA_VALUE = sum(lbs_ab1, na.rm = TRUE)) %>%
    dplyr::mutate(CATEGORY = "Recreational",
                  INDICATOR_TYPE = "Socioeconomic",
                  INDICATOR_NAME = "total_recreational_landings_lbs") %>%
    dplyr::rename(YEAR = Year) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(YEAR = as.numeric(YEAR))

  # usethis::use_data(total_rec_landings, overwrite = TRUE)

  if(return) return(total_rec_landings)
}
