# PROJECT:  thrt_lvl_mdnght
# PURPOSE:
# AUTHOR:   A.Chafetz | USAID
# REF ID:   61a3fb5d
# LICENSE:  MIT
# DATE:     2024-10-28
# UPDATED:

# DEPENDENCIES ------------------------------------------------------------

  #general
  library(tidyverse)
  library(glue)
  #oha
  library(gagglr) ##install.packages('gagglr', repos = c('https://usaid-oha-si.r-universe.dev', 'https://cloud.r-project.org'))
  library(selfdestructin5)
  library(themask)
  #viz extensions
  library(scales, warn.conflicts = FALSE)
  library(systemfonts)
  library(tidytext)
  library(patchwork)
  library(ggtext)


# SETUP -------------------------------------------------------------------

# oha_update(core_only = TRUE)
# si_setup()
# pepfar_data_calendar
# pepfar_country_list %>% prinf()

#download the training dataset
# themask::msk_download(glamr::si_path())

# GLOBAL VARIABLES --------------------------------------------------------

  #a reference to be places in viz captions
  ref_id <- "61a3fb5d"   # glamr::gen_ref_id()

  #file path to dataset
  path_msk <-  glamr::si_path() %>% glamr::return_latest("TRAINING")

  #extract msk metadata
  meta <- gophr::get_metadata(path_msk)


# IMPORT ------------------------------------------------------------------

  #read in the training data PSD
  df_msk <- gophr::read_psd(path_msk)



# HTS_POS ACHIEVEMENT -----------------------------------------------------

  #aggregate annual agency HTS_POS for calculating achvievement
  df_achv <- df_msk %>%
    filter(indicator == "HTS_TST_POS") %>%
    gophr::pluck_totals() %>%
    group_by(fiscal_year, snu1, funding_agency, indicator) %>%
    summarise(across(c(targets, cumulative), \(x) sum(x, na.rm = TRUE)),
              .groups = "drop")

  #clean funding agency for easier reability and calculate achievement based on curr quarter
  df_achv <- df_achv %>%
    gophr::clean_agency() %>%
    gophr::adorn_achievement(qtr = meta$curr_qtr)

  #create a quarter indicator achievement table
  # df_sum <- selfdestruct::make_mdb_df(df_msk, FALSE)
  # df_tbl  <- selfdestruct::reshape_mdb_df(df_sum)
  # selfdestruct::create_mdb(df_tbl, ou = "Minoria", type = "main")

  #visualize achievement with a faceted column chart
  df_achv %>%
    filter(fiscal_year != 2062) %>%
    ggplot(aes(achievement, fct_reorder(snu1, achievement, .na_rm = TRUE), fill = achv_color)) +
    geom_col(na.rm = TRUE) +
    geom_text(aes(label = label_percent()(achievement)),
              family = "Source Sans Pro", na.rm = TRUE,
              color = matterhorn, hjust = -.3) +
    facet_grid(funding_agency ~ fiscal_year, switch = "y", scales = "free_y", space = "free_y") +
    scale_x_continuous(label = label_percent()) +
    scale_fill_identity() +
    coord_cartesian(clip= "off") +
    labs(x = NULL, y = NULL,
         title = "Gaps exists for USAID in the Pacific Coast" %>% toupper,
         subtitle = glue("{unique(df_achv$indicator)} | Minoria | {meta$curr_fy_lab} only through Q{meta$curr_qtr}"),
         caption = meta$caption) +
    glitr::si_style_xgrid() +
    theme(axis.text.x = element_blank(),
          strip.placement = "outside",
          strip.text.y = element_text(hjust = .5))

  #preview output
  glitr::si_preview()

  #export to png for usage
  glitr::si_save(glue("{meta$curr_pd}_MNR_{unique(df_achv$indicator)}_achv.png"),
                 path ="Images")


# TX_NEW QUARTERLY TRENDS -------------------------------------------------

  #aggregate quarterly TX_NEW values for plotting trend
  df_trend <- df_msk %>%
    filter(indicator == "TX_NEW") %>%
    gophr::pluck_totals() %>%
    group_by(fiscal_year, snu1, indicator) %>%
    summarise(across(c(starts_with("qtr")), \(x) sum(x, na.rm = TRUE)),
              .groups = "drop")

  #pivot the wide data to make it tidy in order to plot
  df_trend <- df_trend %>%
    gophr::reshape_msk(include_type = FALSE) %>%
    mutate(fill_color = ifelse(snu1 == "Midwest", orchid_bloom, slate))

  #check out different SI colors
  glitr::si_palettes$siei %>% show_col()
  glitr::si_palettes$orchid_bloom_d %>% show_col()
  glitr::si_palettes$orchid_bloom_t %>% show_col()
  glitr::si_palettes$orchid_bloom_c %>% show_col()

  #line graph of quarterly trends, highliting Midwest decline
  df_trend %>%
    ggplot(aes(period, value, group = snu1, color = fill_color, fill = fill_color)) +
    geom_area(alpha = .4) +
    geom_line() +
    facet_wrap(~fct_reorder2(snu1, period, value)) +
    scale_fill_identity(aesthetics = c("fill", "color")) +
    scale_x_discrete(breaks = c("FY59Q1", "FY60Q1", "FY61Q1")) +
    labs(x = NULL, y = NULL,
         title = "Continued decline in " %>% toupper,
         subtitle = glue("{meta$curr_fy_lab} only through Q{meta$curr_qtr}"),
         caption = meta$caption) +
    glitr::si_style_ygrid() +
    theme(legend.position = "none")


# VL MAP ------------------------------------------------------------------

  #aggregate PSNU values for each VL indicator
  df_vl <- df_msk %>%
    filter(indicator %in% c("TX_CURR_Lag2", "TX_PVLS"),
           fiscal_year == meta$curr_fy) %>%
    gophr::pluck_totals() %>%
    gophr::clean_indicator() %>%
    group_by(fiscal_year, psnu, psnuuid, indicator) %>%
    summarise(cumulative = sum(cumulative, na.rm = TRUE),
              .groups = "drop")

  #reshape to calculate VL indicators and pivot long for plotting
  df_vl <- df_vl %>%
    pivot_wider(names_from = indicator,
                values_from = cumulative,
                names_glue = "{tolower(indicator)}") %>%
    mutate(vlc = tx_pvls_d / tx_curr_lag2,
           vls = tx_pvls / tx_pvls_d) %>%
    select(psnu, psnuuid, vlc, vls) %>%
    pivot_longer(c(vlc, vls), names_to = "indicator") %>%
    mutate(indicator = toupper(indicator)) %>%
    filter(indicator != "VLC")

  #join with sf file in order to map
  df_vl <- df_vl %>%
    full_join(minoria_shp_psnu, by = c("psnu", "psnuuid"))

  #VL value to PSNU name to render in plot
  df_vl <- df_vl %>%
    mutate(indicator = "VLS",
           psnu_lab = ifelse(is.na(value), psnu,
                             glue("{psnu}\n{percent_format(1)(value)}")))

  #map VLS geographically in Minoria
  df_vl %>%
    ggplot() +
    geom_sf(data = minoria_shp_psnu, aes(geometry = geometry)) +
    geom_sf(aes(geometry = geometry, fill = value)) +
    geom_sf_text(aes(geometry = geometry, label = psnu_lab), size = 7/.pt) +
    glitr::scale_fill_si(palette = "lavender_haze_c", discrete = FALSE, label = percent_format(1),
                  na.value = glitr::si_palettes$slate_t[5]) +
    si_style_map() +
    labs(x = NULL, y = NULL, fill = NULL,
         title = "Hillsboro is the only PSNU below 95% VLS" %>% toupper,
         subtitle = glue("{unique(df_vl$indicator)} | Minoria | {meta$curr_pd}"),
         caption = meta$caption) +
    theme(panel.background = element_rect(fill = "#edf5fc", color = "white"),
          legend.position = "none")

