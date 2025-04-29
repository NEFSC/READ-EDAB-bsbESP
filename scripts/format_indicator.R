

format_indicator <- function(out_dir,
                             submission_year,
                             indicator_name,
                             description,
                             status,
                             factors,
                             implications,
                             references,
                             years,
                             region,
                             indicator_value,
                             ... # getting an error that there are unused arguments -- hacky fix
                             ) {
  filename <- paste0(out_dir, "/", indicator_name, ".txt")

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
    paste(years, collapse = "\t"),
    "#REGION/SEASON - List of spatial or temporal scales applicable to indicator. This is a character value.",
    region,
    "#INDICATOR_VALUE - List of data values for the indicator contribution (must match the YEAR list length). This is a numeric value.",
    paste(indicator_value, collapse = "\t"),

    file = filename,
    sep = "\n"
  )
}

# format_indicator(filename = here::here('data/test_data_template.txt'),
#                  submission_year = 2025,
#                  indicator_name = "TEST_INDICATOR",
#                  description = "Winter (Feb-Mar) bottom temperature across black sea bass North and South stock regions. Hubert's data product is a composite before 1993, and from 1993-2019 it is the same as GLORYS. 2020-2024 data are pulled directly from GLORYS. The GLORYS12V1 product is the CMEMS global ocean eddy-resolving (1/12? horizontal resolution, 50 vertical levels) reanalysis.",
#                  status = "Bottom temperatures in 2024 are decreasing relative to recent years, but still within 1 sd of the mean.",
#                  factors = "Cold winter temperatures in the Northwest Atlantic (north of Hudson Canyon).",
#                  implications = "Cold winter temperatures may increase the mortality of young-of-the-year fish, resulting in smaller year classes. Additionally, cold temperatures can cause northern fish to move into the southern subregion, leading to potential misallocation of catch between the northern and southern stock subunits. 2024 temperature in the northern subunit (north of Hudson Canyon) was colder than black sea bass's lower threshold of 8C.",
#                  references = "du Pontavice, H., Miller, T. J., Stock, B. C., Chen, Z., & Saba, V. S. (2022). Ocean model-based covariates improve a marine fish stock assessment when observations are limited. ICES Journal of Marine Science, 79(4), 1259?1273. Jean-Michel, L., Eric, G., Romain, B.-B., Gilles, G., Ang?lique, M., Marie, D., Cl?ment, B., Mathieu, H., Olivier, L. G., Charly, R., Tony, C., Charles-Emmanuel, T., Florent, G., Giovanni, R., Mounir, B., Yann, D., & Pierre-Yves, L. T. (2021). The Copernicus Global 1/12? Oceanic and Sea Ice GLORYS12 Reanalysis. Frontiers in Earth Science, 9, 698876. https://doi.org/10.3389/feart.2021.698876",
#                  years = 2000:2024,
#                  region = "NORTH",
#                  indicator_value = rnorm(25))

format_from_template <- function(key,
                                 ind_name,
                                 # dir_out,
                                 ...) {
  this_dat <- key |>
    dplyr::filter(indicator_name == ind_name)

  # print(this_dat)

  format_indicator(indicator_name = ind_name,
                   description = this_dat$description,
                   status = this_dat$status,
                   factors = this_dat$factors,
                   implications = this_dat$implications,
                   references = this_dat$references,
                   region = this_dat$region,
                   ...
                   )


}

# format_indicator(out_dir = here::here('data'),
#                  submission_year = 2025,
#                  indicator_name = "BSB_Winter_Bottom_Temperature_South",
#                  description = this_dat$description,
#                  status = this_dat$status,
#                  factors = this_dat$factors,
#                  implications = this_dat$implications,
#                  references = this_dat$references,
#                  years = bt_data|> dplyr::filter(Region == "South") |> purrr::pluck("year"),
#                  region = this_dat$region,
#                  indicator_value = bt_data|> dplyr::filter(Region == "South") |> purrr::pluck("mean")
#                  # ...
# )
