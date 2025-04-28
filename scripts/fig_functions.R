plt_bsb <- function(data) {
  plt <- data |>
    dplyr::group_by(INDICATOR_NAME) |>
    dplyr::mutate(mean = mean(DATA_VALUE, na.rm = TRUE),
                  sd = sd(DATA_VALUE, na.rm = TRUE)) |>
    ggplot2::ggplot(ggplot2::aes(x = YEAR,
                                 y = DATA_VALUE
    )) +
    ggplot2::geom_hline(ggplot2::aes(
      yintercept = .data$mean + .data$sd
    ),
    color = "darkgreen",
    linetype = "solid"
    ) +
    ggplot2::geom_hline(ggplot2::aes(
      yintercept = .data$mean - .data$sd
    ),
    color = "darkgreen",
    linetype = "solid"
    ) +
    ggplot2::geom_hline(ggplot2::aes(
      yintercept = .data$mean
    ),
    color = "darkgreen",
    linetype = "dotted"
    ) +
    ggplot2::geom_point() +
    ggplot2::geom_path() +
    ggplot2::xlim(c(1989, 2024)) +
    ggplot2::scale_x_continuous(breaks = c(1990, 2000, 2010, 2020, 2024)#,
                                # limits = c(1989, 2024)
                                ) +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::theme_classic(base_size = 16) +
    ggplot2::theme(strip.text = ggplot2::element_text(size = 16),
                   axis.title = ggplot2::element_blank(),
                   axis.text.x = ggplot2::element_text(angle = 30,
                                                       hjust = 1),
                   aspect.ratio = 1/4)

  return(plt)
}

plot_indicator <- function(data,
                           ind_name, # indicator name to filter by, will also be part of the file name
                           # facet = FALSE,
                           # facet_by,
                           new_breaks = NA
                           ) {

  this_dat <- data |>
    dplyr::filter(stringr::str_detect(INDICATOR_NAME, ind_name)) |>
    dplyr::arrange(YEAR)

  facet <- length(unique(this_dat$INDICATOR_NAME)) > 1

  if(facet) {
    this_dat <- this_dat |>
      dplyr::mutate(Region = INDICATOR_NAME |>
                      stringr::str_extract("(?<=_).{3}th$"))
  }

  short_name <- paste0(ind_name, "_", Sys.Date(), ".png")
    fname <- here::here("images", short_name)
    if(max(this_dat$DATA_VALUE, na.rm = TRUE) > 10^6) {
      this_dat <- this_dat |>
        dplyr::mutate(DATA_VALUE = ifelse(!is.na(DATA_VALUE), DATA_VALUE/10^6, DATA_VALUE),
                      INDICATOR_NAME = paste(INDICATOR_NAME, "millions"))
      fname <-  here::here("images", paste0(ind_name, "_millions_", Sys.Date(), ".png"))
    }

    # print(fname)
    fig <- plt_bsb(this_dat)

    if(facet) {
      fig <- fig +
        ggplot2::facet_grid(rows = ggplot2::vars(Region))
    }

    if(!is.na(new_breaks[1])) {
      fig <- fig +
        ggplot2::scale_x_continuous(breaks = new_breaks)
    }

    if(facet) {
      ggplot2::ggsave(fname,
                      width = 6,
                      height = 3)
    } else{
      ggplot2::ggsave(fname,
                      width = 6,
                      height = 2)
    }

      return(short_name)
}

add_fig_paths <- function(path,
                          list_files) {
  # print(paste(list_files, collapse = "','"))

  # output <- data |>
  #   dplyr::mutate(time_series = list_files)

  output <- readxl::read_excel(path) |>
    dplyr::mutate(time_series = list_files)

  # data$time_series <- list_files
  # return(data)

  return(output)
}
