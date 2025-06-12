# Load the ncdf4 package
# library(ncdf4)
# library(dplyr)

## input data = long format indicator time series of all variables

data <- AKesp::get_esp_data("Black Sea Bass")


# data = read.csv(here::here('data','survdat_sweptarea_all.csv'))


var.index <- data |>
  dplyr::select(INDICATOR_NAME, UNITS) |>
  dplyr::distinct()

# var.names = unique(data$variable)
years <- sort(unique(data$YEAR))
# spp.codes <- sort(unique(data$SVSPP)) # Would want spp names not just svspp

data <- data |>
  # expand to include missing years
  dplyr::full_join(expand.grid(YEAR = years,
                               INDICATOR_NAME = unique(data$INDICATOR_NAME))) |>
  dplyr::arrange(YEAR)

# Define dimensions
time_dim <- ncdf4::ncdim_def(name = "year", units = "years", vals = years)
# spp_dim <- ncdim_def(name = "SVSPP", units = "", vals = spp.codes)

## write loop or map function to turn each column into a dimension?

# Build template for variable values
var.blank <- matrix(data = -999, nrow = length(years), ncol = 1)

# Define variables in a loop
var.ls <- list()
for (i in 1:nrow(var.index)) {
  # fill in long name after reading documentation
  var.ls[[i]] <- ncdf4::ncvar_def(
    name = var.index$INDICATOR_NAME[i],
    units = var.index$UNITS[i],
    dim = list(time_dim),
    missval = -999,
    longname = var.index$INDICATOR_NAME[i],
    prec = "float"
  )
}

# Create NetCDF file
nc_file <- ncdf4::nc_create(here::here("data-raw", "bsb_example.nc"), vars = var.ls)

# Add global attributes
ncdf4::ncatt_put(nc_file, 0, "title", "Example BSB Data")

# Puts all the values in
for (j in 1:nrow(var.index)) {
  var.data <- data |>
    dplyr::filter(INDICATOR_NAME == var.index$INDICATOR_NAME[j]) |>
    dplyr::select(YEAR, DATA_VALUE)

  # turn var.data into a matrix with the structure of var.blank
  var.wide <- var.data |>
    # tidyr::spread(key = SVSPP, value = value) |>
    dplyr::select(-YEAR) |>
    as.matrix()

  var.wide[which(is.na(var.wide))] <- -999

  # Write data to file
  ncdf4::ncvar_put(nc_file, var.ls[[j]], var.wide)
  # print(var.ls[[j]])

  # Add attributes to the variable
  # TODO: add loop/ map here to add all attributes
  ncdf4::ncatt_put(nc_file, var.ls[[j]], "Region", "NEUS LME")
}

# Close the NetCDF file
ncdf4::nc_close(nc_file)

# Check the contents of the NetCDF file

nc_file_check <- ncdf4::nc_open(here::here("data-raw", "bsb_example.nc"))

ncdf4::ncvar_get(nc_file_check, var.ls[[1]]) |> View()

ncdf4::ncatt_get(nc_file, 0)

ncdf4::ncatt_get(nc_file, var.ls[[1]])
