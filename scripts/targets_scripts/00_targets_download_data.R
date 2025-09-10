list(
  targets::tar_target(
    mrip_landing_file,
    NEesp2::save_catch(
      species = "black sea bass",
      catch_type = "landings",
      out_folder = here::here("data/mrip_data")
    )
  ),

  targets::tar_target(
    params,
    expand.grid(
      region = c("north atlantic", "mid-atlantic"),
      year = c(1982:syear),
      species = "Black sea bass"
    )
  ),

  targets::tar_target(
    trip_files,
    purrr::map(
      purrr::list_transpose(list(
        region = params$region,
        year = params$year,
        species = params$species
      )),
      ~ try(NEesp2::save_trips(
        this_species = .x$species,
        this_year = .x$year,
        this_region = .x$region,
        out_folder = here::here("data/mrip_data/trips")
      ))
    )
  )
)
