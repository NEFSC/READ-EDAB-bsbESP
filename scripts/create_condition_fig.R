
devtools::load_all("../READ-EDAB-NEesp2")

bio_data <- read.csv(here::here("data/survey_bio_data.csv"))

condition <- NEesp2::species_condition(data = bio_data,
                                       LWparams = NEesp2::LWparams,
                                       species.codes = NEesp2::species.codes,
                                       by_EPU = FALSE)

plt <- NEesp2::plot_condition(data = condition,
                       var = 'Black sea bass')

plt +
  ggplot2::guides(shape = "none"#,
                  # color = ggplot2::guide_legend(ncol = 3)
                  ) +
  ggplot2::theme(aspect.ratio = 0.6,
                 # legend.position = "bottom",
                 # legend.direction = "horizontal",
                 # legend.box = "horizontal",
                 legend.title = ggplot2::element_blank(),
                 # legend.byrow = TRUE,
                 plot.background = ggplot2::element_rect(color = "black",
                                                         linewidth = 2)) +
  ggplot2::ylab("Relative condition") +
  ggplot2::scale_y_continuous(breaks = seq(0.9, 1.05, by = 0.05),
                              limits = c(0.88, 1.05))

ggplot2::ggsave(here::here("images/new_condition.png"),
                 width = 6,
                 height = 2.4,
                 dpi = 300,
                 units = "in",
                 device = ragg::agg_png(bg = "white"))

