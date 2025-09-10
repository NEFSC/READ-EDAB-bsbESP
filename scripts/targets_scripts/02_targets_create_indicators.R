## indicator creation ----
list(
  # rec trips
  targets::tar_target(
    rec_trips,
    NEesp2::create_rec_trips(files = mrip_trips)
  ),

  # rec landings
  targets::tar_target(
    total_rec_landings,
    NEesp2::create_total_rec_catch(
      data = mrip_landing_data,
      var_name = "landings"
    )
  ),

  # condition
  targets::tar_target(
    condition,
    NEesp2::species_condition(
      data = bio_data,
      LWparams = NEesp2::LWparams,
      species.codes = NEesp2::species.codes
    )
  ),

  # shelf water volume
  targets::tar_target(
    swv_cleaned,
    clean_swv_data(swv_data)
  ),

  # TODO: bottom temp creation target
)
