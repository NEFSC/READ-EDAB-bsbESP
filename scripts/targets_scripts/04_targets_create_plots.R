list(
  ### watch AKFIN web service ? not sure this is working
  targets::tar_target(
    all_data,
    AKesp::get_esp_data("Black Sea Bass")
  ),

  ## plot creation ----

  targets::tar_target(
    risk_plt,
    NEesp2::plot_risk(
      risk_elements = tibble::tibble(
        stock = c(2, 2, 0, 4),
        commercial = c(0, 2, 4, 1),
        recreational = c(3, 1, 1, 1)
      )
    )
  ),
  targets::tar_target(
    save_risk,
    ggplot2::ggsave(
      filename = risk_plt_file,
      plot = risk_plt,
      device = "png",
      width = 5.33,
      height = 4,
      units = "in"
    )
  ),
  # watch risk file (is this allowed)
  targets::tar_target(risk_img, risk_plt_file, format = "file"),

  targets::tar_target(
    cond_plt,
    NEesp2::plot_condition(data = condition, var = 'Black sea bass')
  ),

  targets::tar_target(
    save_cond,
    ggplot2::ggsave(
      filename = here::here(paste0("images/condition_", Sys.Date(), ".png")),
      plot = cond_plt,
      device = "png",
      width = 5.33,
      height = 4,
      units = "in"
    )
  ),

  targets::tar_target(
    rec_trips_plt,
    plt_bsb(all_data, ind_name = "BSB_mrip_trips", img_dir = image_dir)
  ),
  targets::tar_target(
    rec_landings_plt,
    plt_bsb(all_data, ind_name = "BSB_mrip_landings", img_dir = image_dir)
  ),
  targets::tar_target(
    com_rev_plt,
    plt_bsb(
      all_data,
      ind_name = "BSB_Commercial_Revenue_Per_Vessel",
      img_dir = image_dir
    )
  ),
  targets::tar_target(
    com_vessel_plt,
    plt_bsb(all_data, ind_name = "BSB_Commercial_Vessels", img_dir = image_dir)
  ),
  targets::tar_target(
    swv_plt,
    plt_bsb(
      all_data,
      ind_name = "Shelf_Water_Volume",
      new_breaks = c(seq(1990, 2010, by = 10), 2015, 2019, 2022),
      img_dir = image_dir
    )
  ),
  targets::tar_target(
    bt_plt,
    plt_bsb(
      all_data |>
        dplyr::filter(INDICATOR_NAME != "BSB_Winter_Bottom_Temperature_All"),
      ind_name = "BSB_Winter_Bottom_Temperature",
      new_breaks = c(seq(1990, 2020, by = 10), 2024),
      img_dir = image_dir
    )
  )
)
