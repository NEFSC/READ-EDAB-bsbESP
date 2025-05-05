list(
  ## format indicators for web service ----

  targets::tar_target(
    bt_north_web,
    NEesp2::format_from_template(
      ind_name = "BSB_Winter_Bottom_Temperature_North",
      key = meta_data,
      out_dir = txt_dir,
      submission_year = syear,
      years = bt_data |>
        dplyr::filter(Region == "North") |>
        purrr::pluck("year"),
      indicator_value = bt_data |>
        dplyr::filter(Region == "North") |>
        purrr::pluck("mean"),
    )
  ),
  targets::tar_target(
    bt_south_web,
    NEesp2::format_from_template(
      ind_name = "BSB_Winter_Bottom_Temperature_South",
      key = meta_data,
      out_dir = txt_dir,
      submission_year = syear,
      years = bt_data |>
        dplyr::filter(Region == "South") |>
        purrr::pluck("year"),
      indicator_value = bt_data |>
        dplyr::filter(Region == "South") |>
        purrr::pluck("mean"),
    )
  ),
  targets::tar_target(
    swv_north_web,
    NEesp2::format_from_template(
      ind_name = "BSB_Shelf_Water_Volume_North",
      key = meta_data,
      out_dir = txt_dir,
      submission_year = syear,
      years = swv_cleaned |>
        dplyr::filter(name == "North") |>
        purrr::pluck("YEAR"),
      indicator_value = swv_cleaned |>
        dplyr::filter(name == "North") |>
        purrr::pluck("DATA_VALUE"),
    )
  ),
  targets::tar_target(
    swv_south_web,
    NEesp2::format_from_template(
      ind_name = "BSB_Shelf_Water_Volume_South",
      key = meta_data,
      out_dir = txt_dir,
      submission_year = syear,
      years = swv_cleaned |>
        dplyr::filter(name == "South") |>
        purrr::pluck("YEAR"),
      indicator_value = swv_cleaned |>
        dplyr::filter(name == "South") |>
        purrr::pluck("DATA_VALUE"),
    )
  ),
  targets::tar_target(
    mrip_trips_web,
    NEesp2::format_from_template(
      ind_name = "BSB_mrip_trips",
      key = meta_data,
      out_dir = txt_dir,
      submission_year = syear,
      years = rec_trips |>
        purrr::pluck("YEAR"),
      indicator_value = rec_trips |>
        purrr::pluck("DATA_VALUE"),
    )
  ),
  targets::tar_target(
    mrip_land_web,
    NEesp2::format_from_template(
      ind_name = "BSB_mrip_landings",
      key = meta_data,
      out_dir = txt_dir,
      submission_year = syear,
      years = total_rec_landings |>
        purrr::pluck("YEAR"),
      indicator_value = total_rec_landings |>
        purrr::pluck("DATA_VALUE"),
    )
  ),
  targets::tar_target(
    com_rev_vessel_web,
    NEesp2::format_from_template(
      ind_name = "BSB_Commercial_Revenue_Per_Vessel",
      key = meta_data,
      out_dir = txt_dir,
      submission_year = syear,
      years = comm_data |>
        dplyr::filter(INDICATOR_NAME == "AVGVESREVperYr_BLACK_SEABASS_2024_DOLlb") |>
        purrr::pluck("YEAR"),
      indicator_value = comm_data |>
        dplyr::filter(INDICATOR_NAME == "AVGVESREVperYr_BLACK_SEABASS_2024_DOLlb") |>
        purrr::pluck("DATA_VALUE"),
    )
  ),
  targets::tar_target(
    com_vessel_web,
    NEesp2::format_from_template(
      ind_name = "BSB_Commercial_Vessels",
      key = meta_data,
      out_dir = txt_dir,
      submission_year = syear,
      years = comm_data |>
        dplyr::filter(INDICATOR_NAME == "N_Commercial_Vessels_Landing_BLACK_SEABASS") |>
        purrr::pluck("YEAR"),
      indicator_value = comm_data |>
        dplyr::filter(INDICATOR_NAME == "N_Commercial_Vessels_Landing_BLACK_SEABASS") |>
        purrr::pluck("DATA_VALUE"),
    )
  )
)
