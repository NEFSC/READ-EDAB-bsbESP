# Rec trips
ggplot2::ggplot(dat %>% filter(name == 'total_recreational_trips_n'),
  ggplot2::aes(x = YEAR, y = DATA_VALUE,
    group = name)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg + stdev, # was mean and sd --> those are not names in df
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg - stdev, #mean - sd,
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg, #mean,
    group = name),  color = "darkgreen",  linetype = "dotted" ) +
  ggplot2::geom_point() +
  ggplot2::geom_line(data = dat %>% filter(name == 'total_recreational_trips_n') %>% 
                       tidyr::drop_na(DATA_VALUE)) +
  ggplot2::ylab('Total Recreational Trips') +
  ggplot2::scale_y_continuous(labels = scales::comma,
                              n.breaks = 4) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 10),
                 aspect.ratio = 0.25)
# total_recreational_catch_n
ggplot2::ggplot(dat %>% filter(name == 'total_recreational_catch_n'),
                ggplot2::aes(x = YEAR, y = DATA_VALUE,
                             group = name)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg + stdev, # was mean and sd --> those are not names in df
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg - stdev, #mean - sd,
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg, #mean,
    group = name),  color = "darkgreen",  linetype = "dotted" ) +
  ggplot2::geom_point() +
  ggplot2::geom_line(data = dat %>% filter(name == 'total_recreational_catch_n') %>% 
                       tidyr::drop_na(DATA_VALUE)) +
  ggplot2::ylab('Total Recreational Catch (n)') +
  ggplot2::scale_y_continuous(labels = scales::comma,
                              n.breaks = 4) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 10),
                 aspect.ratio = 0.25)
# total_recreational_landings_lbs
ggplot2::ggplot(dat %>% filter(name == 'total_recreational_landings_lbs'),
                ggplot2::aes(x = YEAR, y = DATA_VALUE,
                             group = name)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg + stdev, # was mean and sd --> those are not names in df
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg - stdev, #mean - sd,
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg, #mean,
    group = name),  color = "darkgreen",  linetype = "dotted" ) +
  ggplot2::geom_point() +
  ggplot2::geom_line(data = dat %>% filter(name == 'total_recreational_landings_lbs') %>% 
                       tidyr::drop_na(DATA_VALUE)) +
  ggplot2::ylab('Total Recreational Landings (lbs)') +
  ggplot2::scale_y_continuous(labels = scales::comma,
                              n.breaks = 4) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 10),
                 aspect.ratio = 0.25)
############ commercial 
unique(dat$name)
[1] "Commercial_BLACK_SEABASS_Landings_LBS"     
[2] "N_Commercial_Vessels_Landing_BLACK_SEABASS"
[3] "AVGPRICE_BLACK_SEABASS_2023_DOLlb"         
[4] "TOTALANNUALREV_BLACK_SEABASS_2023Dols"     
[5] "AVGANNUAL_DIESEL_PRICE2023dols"  

# Landings
ggplot2::ggplot(dat %>% filter(name == 'Commercial_BLACK_SEABASS_Landings_LBS'),
                ggplot2::aes(x = YEAR, y = DATA_VALUE,
                             group = name)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg + stdev, # was mean and sd --> those are not names in df
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg - stdev, #mean - sd,
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg, #mean,
    group = name),  color = "darkgreen",  linetype = "dotted" ) +
  ggplot2::geom_point() +
  ggplot2::geom_line(data = dat %>% filter(name == 'Commercial_BLACK_SEABASS_Landings_LBS') %>% 
                       tidyr::drop_na(DATA_VALUE)) +
  ggplot2::ylab('Commercial Landings BSB (lbs)') +
  ggplot2::scale_y_continuous(labels = scales::comma,
                              n.breaks = 4) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 10),
                 aspect.ratio = 0.25)

# Fuel
ggplot2::ggplot(dat %>% filter(name == 'AVGANNUAL_DIESEL_PRICE2023dols'),
                ggplot2::aes(x = YEAR, y = DATA_VALUE,
                             group = name)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg + stdev, # was mean and sd --> those are not names in df
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg - stdev, #mean - sd,
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg, #mean,
    group = name),  color = "darkgreen",  linetype = "dotted" ) +
  ggplot2::geom_point() +
  ggplot2::geom_line(data = dat %>% filter(name == 'AVGANNUAL_DIESEL_PRICE2023dols') %>% 
                       tidyr::drop_na(DATA_VALUE)) +
  ggplot2::ylab('Avg Annual Fuel Price') +
  ggplot2::scale_y_continuous(labels = scales::comma,
                              n.breaks = 4) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 10),
                 aspect.ratio = 0.25)

# Number of Vessels 
ggplot2::ggplot(dat %>% filter(name == 'N_Commercial_Vessels_Landing_BLACK_SEABASS'),
                ggplot2::aes(x = YEAR, y = DATA_VALUE,
                             group = name)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg + stdev, # was mean and sd --> those are not names in df
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg - stdev, #mean - sd,
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg, #mean,
    group = name),  color = "darkgreen",  linetype = "dotted" ) +
  ggplot2::geom_point() +
  ggplot2::geom_line(data = dat %>% filter(name == 'N_Commercial_Vessels_Landing_BLACK_SEABASS') %>% 
                       tidyr::drop_na(DATA_VALUE)) +
  ggplot2::ylab('Number of Vessels') +
  ggplot2::scale_y_continuous(labels = scales::comma,
                              n.breaks = 4) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 10),
                 aspect.ratio = 0.25)
##### Commercial Longfin 
############ commercial 
unique(dat$name)
[1] "Commercial_LONGFINSQUID_Landings_LBS"     
[2] "N_Commercial_Vessels_Landing_LONGFINSQUID"
[3] "AVGPRICE_LONGFINSQUID_2023_DOLlb"         
[4] "TOTALANNUALREV_LONGFINSQUID_2023Dols"     
[5] "AVGANNUAL_DIESEL_PRICE2023dols"    

# Landings
ggplot2::ggplot(dat %>% filter(name == 'Commercial_LONGFINSQUID_Landings_LBS'),
                ggplot2::aes(x = YEAR, y = DATA_VALUE,
                             group = name)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg + stdev, # was mean and sd --> those are not names in df
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg - stdev, #mean - sd,
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg, #mean,
    group = name),  color = "darkgreen",  linetype = "dotted" ) +
  ggplot2::geom_point() +
  ggplot2::geom_line() +
    # ggplot2::geom_line(data = dat %>% filter(name == 'Commercial_Longfin_Landings_LBS'),
  #                      aes(x = YEAR, y = DATA_VALUE)) +
  ggplot2::ylab('Commercial Landings Longfin (lbs)') +
  ggplot2::scale_y_continuous(labels = scales::comma,
                              n.breaks = 4) +
  ggplot2::theme_bw(base_size = 13) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 10),
                 aspect.ratio = 0.25)

# Fuel
ggplot2::ggplot(dat %>% filter(name == 'AVGANNUAL_DIESEL_PRICE2023dols'),
                ggplot2::aes(x = YEAR, y = DATA_VALUE,
                             group = name)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg + stdev, # was mean and sd --> those are not names in df
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg - stdev, #mean - sd,
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg, #mean,
    group = name),  color = "darkgreen",  linetype = "dotted" ) +
  ggplot2::geom_point() +
  ggplot2::geom_line(data = dat %>% filter(name == 'AVGANNUAL_DIESEL_PRICE2023dols') %>% 
                       tidyr::drop_na(DATA_VALUE)) +
  ggplot2::ylab('Avg Annual Fuel Price') +
  ggplot2::scale_y_continuous(labels = scales::comma,
                              n.breaks = 4) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 10),
                 aspect.ratio = 0.25)

# Number of Vessels 
ggplot2::ggplot(dat %>% filter(name == 'N_Commercial_Vessels_Landing_LONGFINSQUID'),
                ggplot2::aes(x = YEAR, y = DATA_VALUE,
                             group = name)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg + stdev, # was mean and sd --> those are not names in df
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg - stdev, #mean - sd,
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg, #mean,
    group = name),  color = "darkgreen",  linetype = "dotted" ) +
  ggplot2::geom_point() +
  ggplot2::geom_line(data = dat %>% filter(name == 'N_Commercial_Vessels_Landing_LONGFINSQUID') %>% 
                       tidyr::drop_na(DATA_VALUE)) +
  ggplot2::ylab('Number of Vessels') +
  ggplot2::scale_y_continuous(labels = scales::comma,
                              n.breaks = 4) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 10),
                 aspect.ratio = 0.25)

# AVGPRICE_LONGFINSQUID_2023_DOLlb
ggplot2::ggplot(dat %>% filter(name == 'AVGPRICE_LONGFINSQUID_2023_DOLlb'),
                ggplot2::aes(x = YEAR, y = DATA_VALUE,
                             group = name)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg + stdev, # was mean and sd --> those are not names in df
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg - stdev, #mean - sd,
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg, #mean,
    group = name),  color = "darkgreen",  linetype = "dotted" ) +
  ggplot2::geom_point() +
  ggplot2::geom_line(data = dat %>% filter(name == 'AVGPRICE_LONGFINSQUID_2023_DOLlb') %>% 
                       tidyr::drop_na(DATA_VALUE)) +
  ggplot2::ylab('Avg Price Longfin (Dollars/lbs)') +
  ggplot2::scale_y_continuous(labels = scales::comma,
                              n.breaks = 4) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 10),
                 aspect.ratio = 0.25)
# TOTALANNUALREV_LONGFINSQUID_2023Dols

ggplot2::ggplot(dat %>% filter(name == 'TOTALANNUALREV_LONGFINSQUID_2023Dols'),
                ggplot2::aes(x = YEAR, y = DATA_VALUE,
                             group = name)) +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg + stdev, # was mean and sd --> those are not names in df
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg - stdev, #mean - sd,
    group = name),  color = "darkgreen",  linetype = "solid") +
  ggplot2::geom_hline(ggplot2::aes(
    yintercept = avg, #mean,
    group = name),  color = "darkgreen",  linetype = "dotted" ) +
  ggplot2::geom_point() +
  ggplot2::geom_line(data = dat %>% filter(name == 'TOTALANNUALREV_LONGFINSQUID_2023Dols') %>% 
                       tidyr::drop_na(DATA_VALUE)) +
  ggplot2::ylab('Total Revenue (Dollars)') +
  ggplot2::scale_y_continuous(labels = scales::comma,
                              n.breaks = 4) +
  ggplot2::theme_bw(base_size = 16) +
  ggplot2::theme(strip.text = ggplot2::element_text(size = 10),
                 aspect.ratio = 0.25)
