

format_indicator <- function(filename,
                             submission_year,
                             indicator_name,
                             description,
                             status,
                             factors,
                             implications,
                             references,
                             years,
                             region,
                             indicator_value
                             ) {

  cat(
    "#Ecosystem and Socioeconomic Profile (ESP) indicator template for Northeast ESPs \n",
    "#This template is required for updating ESP indicator information. There are two required sections to check or update (see below): Indicator Review and Indicator Data. \n",
    '#INSTRUCTIONS: Please fill in the text (surrounded by " ") or data as values in the line after each field marked with a # and capitalized name. Help text is provided following the capitalized field name. \n',
    "#INDICATOR_REVIEW ----------------------------------------------------------------------------------------",
    "#SUBMISSION_YEAR - Current year of contribution submission. This is a integer value.",
    submission_year,
    "#INDICATOR_NAME - Name of the indicator - text string (unique to the indicator).",
    indicator_name,
    "#DESCRIPTION - Brief description of the indicator. Please make sure this description includes information on the spatial distribution of the indicator and how the data for the indicator are collected. The spatial resolution can be a cell size dimension (e.g., 5 km resolution for gridded data) or area of sampling for a survey. The data collection method can be brief (e.g., survey name and gear type, satellite sensor and version, stock assessment model output, fishery observer data, community reports, etc.) and can include a reference to methods detailed elswhere. This is a text string.",
    description,
    "#STATUS_TRENDS - Information on the current status of the indicator in the context of historical trends. This is a text string.",
    status,
    "#FACTORS - Information on the potential causes for observed trends and current status (focus on most recent year). This is a text string.",
    factors,
    "#IMPLICATIONS - Information that briefly answers these questions: What are the implications or impacts of the observed trends on the ecosystem or ecosystem components? What do the trends mean? Why are they important? How can this information be used to inform management decisions? This is a text string.",
    implications,
    "#REFERENCES - Include any full references that are associated with the indicator. This may include data references such as from an ERDDAP webpage or literature cited (plus the DOI where possible). This is a text string.",
    references,
    "\n #INDICATOR_DATA ----------------------------------------------------------------------------------------------",
    "#YEAR - List of years for the indicator contribution. This is a integer value.",
    paste(years, collapse = " "),
    "#REGION/SEASON - List of spatial or temporal scales applicable to indicator. This is a character value.",
    region,
    "#INDICATOR_VALUE - List of data values for the indicator contribution (must match the YEAR list length). This is a numeric value.",
    paste(indicator_value, collapse = " "),

    file = filename,
    sep = "\n"
  )
}

##############################
library(magrittr)

### bottom temp
format_indicator(filename = here::here('data/bsb_winter_bottom_temperature_all.txt'),
                 submission_year = 2025,
                 indicator_name = "BSB_Winter_Bottom_Temperature_All",
                 description = "Winter (Feb-Mar) bottom temperature in the black sea bass North and South stock regions combined. Hubert's data product is a composite before 1993, and from 1993-2019 it is the same as GLORYS. 2020-2024 data are pulled directly from GLORYS. The GLORYS12V1 product is the CMEMS global ocean eddy-resolving (1/12? horizontal resolution, 50 vertical levels) reanalysis.",
                 status = "Bottom temperatures in 2024 are decreasing relative to recent years, but still within 1 sd of the mean.",
                 factors = "Cold winter temperatures in the Northwest Atlantic (north of Hudson Canyon).",
                 implications = "Cold winter temperatures may increase the mortality of young-of-the-year fish, resulting in smaller year classes. Additionally, cold temperatures can cause northern fish to move into the southern subregion, leading to potential misallocation of catch between the northern and southern stock subunits. 2024 temperature in the northern subunit (north of Hudson Canyon) was colder than black sea bass's lower threshold of 8C.",
                 references = "du Pontavice, H., Miller, T. J., Stock, B. C., Chen, Z., & Saba, V. S. (2022). Ocean model-based covariates improve a marine fish stock assessment when observations are limited. ICES Journal of Marine Science, 79(4), 1259?1273. Jean-Michel, L., Eric, G., Romain, B.-B., Gilles, G., Ang?lique, M., Marie, D., Cl?ment, B., Mathieu, H., Olivier, L. G., Charly, R., Tony, C., Charles-Emmanuel, T., Florent, G., Giovanni, R., Mounir, B., Yann, D., & Pierre-Yves, L. T. (2021). The Copernicus Global 1/12? Oceanic and Sea Ice GLORYS12 Reanalysis. Frontiers in Earth Science, 9, 698876. https://doi.org/10.3389/feart.2021.698876",
                 years = 1989:2024,
                 region = "ALL",
                 indicator_value = data$mean)

data <- bt_update_2025_01_31 %>%
  dplyr::filter(Region == 'All')

########################
### swv

swv_n <- swv %>%
  dplyr::filter(name == 'North')

format_indicator(filename = here::here('data/BSB_Shelf_Water_Volume_North.txt'),
                 submission_year = 2025,
                 indicator_name = "BSB_Shelf_Water_Volume_North",
                 description = "Shelf water volume (km^3) for the NoBSB_Shelf_Water_Volume_Northrthern stock subunit. Shelf water volume is a measure of the volume of water inshore of the shelf-slope front, a narrow transition region between masses of cool, low salinity shelf water and warm, high salinity slope water. This in-situ data was derived from CTD data from NEFSC surveys and is maintained by Paula Fratantoni.",
                 status = "There has been no winter sampling since 2021, no trend for 2024.",
                 factors = "There has been no winter sampling since 2021, no trend for 2024.",
                 implications = "Shelf water volume is a proxy for suitable winter habitat; higher shelf water volume indicates less suitable habitat, potentially leading to northern fish migrating into the southern subregion.",
                 references = "Fratantoni PS, Holzworth-Davis T, Taylor MH. 2015. Description of oceanographic conditions on the Northeast US Continental Shelf during 2014. US Dept Commer, Northeast Fisheries Science Center. Ref Doc. 15-21; 41 p. Available at: http://www.nefsc.noaa.gov/publications/doi:10.7289/V5SQ8XD2",
                 years = c(1978:1987,1990:2014,2017,2019,2022),
                 region = "NORTH",
                 indicator_value = swv_n$val)

swv_s <- swv %>%
  dplyr::filter(name == 'South')

format_indicator(filename = here::here('data/BSB_Shelf_Water_Volume_South.txt'),
                 submission_year = 2025,
                 indicator_name = "BSB_Shelf_Water_Volume_South",
                 description = "Shelf water volume (km^3) for the Southern stock subunit. Shelf water volume is a measure of the volume of water inshore of the shelf-slope front, a narrow transition region between masses of cool, low salinity shelf water and warm, high salinity slope water. This in-situ data was derived from CTD data from NEFSC surveys and is maintained by Paula Fratantoni.",
                 status = "There has been no winter sampling since 2021, no trend for 2024.",
                 factors = "There has been no winter sampling since 2021, no trend for 2024.",
                 implications = "Shelf water volume is a proxy for suitable winter habitat; higher shelf water volume indicates less suitable habitat, potentially leading to northern fish migrating into the southern subregion.",
                 references = "Fratantoni PS, Holzworth-Davis T, Taylor MH. 2015. Description of oceanographic conditions on the Northeast US Continental Shelf during 2014. US Dept Commer, Northeast Fisheries Science Center. Ref Doc. 15-21; 41 p. Available at: http://www.nefsc.noaa.gov/publications/doi:10.7289/V5SQ8XD2",
                 years = c(1978:1982,1984:1988,1991:2015,2017:2022),
                 region = "SOUTH",
                 indicator_value = swv_s$val)

######################

### rec indicators

format_indicator(filename = here::here('data/bsb_rec_trips.txt'),
                 submission_year = 2025,
                 indicator_name = "BSB_mrip_trips",
                 description = "Total annual recreational black sea bass fishing trips for both North and South subunits. Data from NOAA Fisheries’ Marine Recreational Information Program (MRIP).",
                 status = "Recent trip numbers are near an all-time high, but may have decreased from 2023.",
                 factors = "Catch generally reflects trip patterns. High regulatory complexity is likely contributing to recreational fishing trends.",
                 implications = "Black sea bass is an important Mid-Atlantic stock with high recreational engagement.",
                 references = "",
                 years = 1989:2024,
                 region = "ALL",
                 indicator_value = rec_trips2$DATA_VALUE)

format_indicator(filename = here::here('data/bsb_rec_landings.txt'),
                 submission_year = 2025,
                 indicator_name = "BSB_mrip_landings",
                 description = "Total annual recreational landings of black sea bass for both North and South subunits. Data from NOAA Fisheries’ Marine Recreational Information Program (MRIP)",
                 status = "Recreational landings have decreased from 2023 but remain near the long-term average.",
                 factors = "The recreational black sea bass fishery has a catch-and-release component, and management measures are being implemented to reduce recreational harvest.",
                 implications = "Black sea bass is an important Mid-Atlantic stock with high recreational engagement.",
                 references = "",
                 years = 1989:2024,
                 region = "ALL",
                 indicator_value = total_rec_landings$DATA_VALUE)

######################

### com indicators

com_indicators <- read.csv(here::here("SOCIEOECONOMIC_COMMERCIAL_INDICATORS_FINAL.csv"))

revenue <- com_indicators %>%
  dplyr::filter(INDICATOR_NAME == 'TOTALANNUALREV_BLACK_SEABASS_2024Dols')

format_indicator(filename = here::here('data/bsb_com_revenue.txt'),
                 submission_year = 2025,
                 indicator_name = "BSB_Commercial_Revenue",
                 description = "Black sea bass commercial revenue (2024 USD)",
                 status = "Commercial revenue for black sea bass has increased from 2023 and remains well above the long term average",
                 factors = "Black sea bass has high commercial value that continues to increase in 2024 despite fewer active vessels in the fleet.",
                 implications = "Commercial revenue per vessel has an overall increasing trend, despite decreases in both total landings and average price ($/lb).",
                 references = "",
                 years = 1996:2024,
                 region = "ALL",
                 indicator_value = revenue$DATA_VALUE)

rev_vessel <- com_indicators %>%
  dplyr::filter(INDICATOR_NAME == 'AVGVESREVperYr_BLACK_SEABASS_2024_DOLlb')

format_indicator(filename = here::here('data/bsb_com_revenue_per_vessel.txt'),
                 submission_year = 2025,
                 indicator_name = "BSB_Commercial_Revenue_Per_Vessel",
                 description = "Black sea bass commercial revenue per vessel (2024 USD)",
                 status = "Commercial revenue for black sea bass has increased from 2023 and remains well above the long term average",
                 factors = "Black sea bass has high commercial value that continues to increase in 2024 despite fewer active vessels in the fleet.",
                 implications = "Commercial revenue per vessel has an overall increasing trend, despite decreases in both total landings and average price ($/lb).",
                 references = "",
                 years = 1996:2024,
                 region = "ALL",
                 indicator_value = rev_vessel$DATA_VALUE)

vessels <- com_indicators %>%
  dplyr::filter(INDICATOR_NAME == 'N_Commercial_Vessels_Landing_BLACK_SEABASS')

format_indicator(filename = here::here('data/bsb_com_vessels.txt'),
                 submission_year = 2025,
                 indicator_name = "BSB_Commercial_Vessels",
                 description = "Number of commercial fishing vessels targeting black sea bass",
                 status = "Number of commercial vessels has decreased slightly from 2023 and remains well below the long term average.",
                 factors = "A decrease in targeted black sea bass trips coincides with decreased catch and landings in 2024.",
                 implications = "The number of active vessels has been decreasing since 2017, which could impact revenue distributions and fleet composition.",
                 references = "",
                 years = 1996:2024,
                 region = "ALL",
                 indicator_value = vessels$DATA_VALUE)
