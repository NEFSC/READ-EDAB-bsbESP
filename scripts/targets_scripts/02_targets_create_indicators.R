## indicator creation ----
list(
  targets::tar_target(
  rec_trips,
  NEesp2::create_rec_trips(files = mrip_trips)
),
targets::tar_target(
  total_rec_landings,
  NEesp2::create_total_rec_landings(mrip_landing |>
                                      read.csv(
                                        skip = 46, # of rows you want to ignore
                                        na.strings = "."
                                      ) |>
                                      janitor::clean_names(case = "all_caps"))
),

targets::tar_target(condition,
                    NEesp2::species_condition(data = bio_data,
                                              LWparams = NEesp2::LWparams,
                                              species.codes = NEesp2::species.codes))

# TODO: bottom temp creation target
)
