#' Create BSB trips indicator
#'
#' This function creates the trips indicator for spp of interest
#' @param files A list of the full file names of annual directed trip data (.csv format)
#' @param return Boolean. Whether to return the indicator as an object in the global environment
#' @return Updates the package object `bluefish_trips`
#'
#' Directed trip data must be downloaded manually from the MRIP query tool
#' https://www.fisheries.noaa.gov/data-tools/recreational-fisheries-statistics-queries
#' 2022 bluefieh ESP: downloaded atlantic coast by state, all modes by mode,
#' all waves, all areas by area;
#' selected all bluefish associated trips - if it was a target species, if it was
#' caught, if it was released
#'
#' @export

create_rec_trips <- function(files, return = TRUE) {
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
  
  if(return) return(rec_trips)
  
}

#' Create proportion trips targeting bluefish indicator
#'
#' This function creates the proportion trips targeting bluefish indicator
#' @param total The mrip trip data (R object `mrip_effort`)
#' @param rec_trips The bluefish directed trips (R object `rec_trips`)
#' @param return Boolean. Whether to return the indicator as an object in the global environment
#' @return Saves the R data object `prop_sp_trips`
#' @export

create_prop_sp_trips <- function(total = mrip_effort,
                                       sp = rec_trips,
                                       return = TRUE){
  total_trips <- total %>%
   # dplyr::filter(sub_reg %in% 4:6) %>% # atlantic coast only
    # need to add in an ifelse for the category that was dl (sub_reg, state, etc)
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
                      )) %>% # northern stock only (Northern MAB)
    dplyr::group_by(Year) %>% # was year (with lowercase y, changed to Y) 
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

#' Create total recreational catch indicator
#'
#' This function creates the total recreational catch indicator
#' @param data The mrip data (R object `mrip_catch`), already subset to sp of interest only
#' @param return Boolean. Whether to return the indicator as an object in the global environment
#' @return Saves the R data object `mrip_catch`
#' @export
#'

create_total_rec_catch <- function(data = mrip_catch, return = TRUE){
  total_rec_catch <- data %>%
   rename(tot_cat = Total.Catch..A.B1.B2.) %>% 
    # dplyr::filter(sub_reg %in% 4:6) %>% # atlantic coast only
    # need to add in an ifelse for the category that was dl (sub_reg, state, etc)
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
    # add ifelse statement about if catch meets MRIP standard 
    dplyr::summarise(DATA_VALUE = sum(tot_cat, na.rm = TRUE)) %>% 
    dplyr::mutate(CATEGORY = "Recreational",
                  INDICATOR_TYPE = "Socioeconomic",
                  INDICATOR_NAME = "total_recreational_catch_n") %>%
    dplyr::rename(YEAR = Year) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(YEAR = as.numeric(YEAR))
  
 # usethis::use_data(total_rec_catch, overwrite = TRUE)
  if(return) return(total_rec_catch)
}

#' Create bluefish recreational landings indicator
#'
#' This function creates the bluefish recreational landings indicator
#' @param data The mrip catch data (R object `mrip_catch`)
#' @param return Boolean. Whether to return the indicator as an object in the global environment
#' @return Saves the R data object `total_rec_landings`
#' @export

create_total_rec_landings <- function(data = mrip_landing, return = TRUE){
  total_rec_landings <- data %>%
    dplyr::rename(lbs_ab1 = Harvest..A.B1..Total.Weight..lb.) %>% 
     # dplyr::filter(sub_reg %in% 4:6) %>% # atlantic coast only
    # need to add in an ifelse for the category that was dl (sub_reg, state, etc)
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
