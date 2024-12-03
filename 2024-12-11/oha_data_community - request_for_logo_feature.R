# PROJECT: coRps
# PURPOSE: OHA DC - Request for LOGO Feature
# AUTHOR: Baboyma Kagniniwa | USAID/GH - Office of HIV-AIDS
# LICENSE: MIT
# REF. ID: 0ca8dae2
# CREATED: 2024-12-02
# UPDATED: 2024-12-02
# NOTES:   Sample code on how to add an image to a ggplot

# Libraries ====

  library(tidyverse)
  library(gagglr)
  library(tidytext)
  library(ggtext)
  library(scales)
  library(patchwork)
  library(cowplot)   # user ggdraw to add plots on top of each other
  library(glue)
  

# Set paths  ====

  dir_data   <- "Data"
  dir_dataout <- "Dataout"
  dir_images  <- "Images"
  dir_graphics  <- "Graphics"
 
  dir_mer <- glamr::si_path("path_msd")
  
# Params 

  ref_id <- "0ca8dae2"
  ou <-  "Minoria"
  cntry <- ou
  agency <- "USAID"
  
# FILES 
  
  themask::msk_available()
  
  themask::msk_download(folderpath = dir_mer, tag = "latest")
  
  dir_mer %>% fs::dir_ls()

  file_training <- return_latest(
    folderpath = dir_mer,
    pattern = "TRAINING"
  )
  
  file_aids <- "https://careresource.org/wp-content/uploads/2023/11/WAD-2023-300x300.png"
  
  meta <- get_metadata(path = file_training)
  
# Functions  ====
  


# LOAD DATA ====

  df_msd <- file_training %>% read_psd()
  
  

# MUNGE ====
  
  df_msd %>% glimpse()
  
  df_msd %>% distinct(country, funding_agency)
  
  df_msd %>% 
    filter(fiscal_year == meta$curr_fy) %>% 
    distinct(indicator, standardizeddisaggregate)
  
  ## Extract HTS Data for Positivity
  
  df_hts <- df_msd %>% 
    filter(fiscal_year == meta$curr_fy,
           country == cntry,
           funding_agency == agency,
           indicator %in% c("HTS_TST", "HTS_TST_POS"),
           standardizeddisaggregate == "Total Numerator") %>% 
    summarise(value = sum(cumulative, na.rm = T),
              .by = c(country, psnu, indicator))
  
  df_hts <- df_hts %>% 
    summarise(value = value[indicator == "HTS_TST_POS"] / value[indicator == "HTS_TST"],
              .by = c(country, psnu)) %>% 
    mutate(indicator = "HTS_TST_YIELD") %>% 
    bind_rows(df_hts, .)
  
# VIZ ====
  
  df_viz <- df_hts %>% 
    pivot_wider(
      names_from = indicator,
      values_from = value
    )
  
  viz_hts_pos <- df_viz %>% 
    ggplot(aes(y = reorder(psnu, HTS_TST))) +
    geom_col(aes(x = HTS_TST), fill = trolley_grey_light, show.legend = T) +
    geom_col(aes(x = HTS_TST_POS), fill = burnt_sienna, show.legend = T) +
    geom_text(aes(x = HTS_TST_POS, label = comma(HTS_TST_POS)), hjust = -0.2) +
    scale_x_continuous(labels = comma, position = "top") +
    labs(x = "", y = "",
         title = glue("{meta$curr_pd} - {toupper(cntry)} HIV TESTING SERVICES"),
         #title = glue("<span style='line-height:50px;display:inline-block;border-width:3px;border-color:red;'></span>{meta$curr_pd} - {toupper(cntry)} HIV TESTING SERVICES"),
         subtitle = glue("As of **{meta$curr_pd}**, {cntry} reported **{comma(sum(df_viz$HTS_TST_POS))} HIV+** from {length(unique(df_viz$psnu))} PSNUs"),
         caption = meta$caption) +
    si_style_xgrid() +
    theme(legend.title = element_blank(),
          plot.title = element_markdown(),
          plot.subtitle = element_markdown()) 
  
  viz_hts_yield <- 
    df_viz %>% 
    ggplot(aes(y = reorder(psnu, HTS_TST_YIELD))) +
    geom_col(aes(x = HTS_TST_YIELD), width = .7, fill = burnt_sienna, show.legend = T) +
    geom_text(aes(x = 0, y = reorder(psnu, HTS_TST_YIELD), label = toupper(psnu)), 
              fontface = "bold", color = usaid_black, hjust = -0.05) +
    geom_text(aes(x = HTS_TST_YIELD, label = percent(HTS_TST_YIELD, .01)), 
              fontface = "bold", color = "#FFF", hjust = 1.2) +
    scale_x_continuous(labels = comma, position = "top") +
    labs(x = "", y = "", title = "POSITIVITY RATES") +
    si_style_transparent() +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_blank(),
          axis.text = element_blank(),
          plot.title = element_markdown(),
          plot.subtitle = element_markdown())
  
  df_viz %>% 
    mutate(psnu = fct_reorder(psnu, -HTS_TST_YIELD)) %>% 
    ggplot(aes(y = psnu)) +
    geom_col(aes(x = HTS_TST_YIELD), fill = burnt_sienna, width = .8, show.legend = T) +
    geom_text(aes(x = HTS_TST_YIELD, label = percent(HTS_TST_YIELD, .01)), 
              fontface = "bold", color = "#FFF", hjust = 1.2) +
    scale_x_continuous(labels = percent, position = "top", expand = c(0, 0)) +
    scale_y_discrete(guide = "none") +
    facet_wrap(~psnu, ncol = 1, scales = "free_y") +
    labs(x = "", y = "") +
    si_style_transparent() +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.major.y = element_blank(),
          panel.spacing = unit(.2, "lines"),
          axis.text = element_blank(),
          plot.title = element_markdown(),
          plot.subtitle = element_markdown(),
          strip.text = element_text(
            hjust = 0,
            margin = margin(1, 0, 1, 0),
            size = rel(1.1), 
            face = "bold"
          ))
  
  logo <- png::readPNG("figures/logo.png") %>% 
    grid::rasterGrob()
  
  ggdraw() +
    draw_image("figures/logo.png")
  
  ggdraw() +
    draw_image("figures/logo.png") +
    draw_plot(viz_hts_yield,
              x = 0.3, y = .3,
              width = .5, height = .5)
  
  
  ggdraw() +
    draw_plot(viz_hts_pos) +
    draw_plot(viz_hts_yield)
  
  ggdraw() +
    draw_plot(viz_hts_pos) +
    draw_plot(viz_hts_yield,
              x = .5, y = 0.02,
              width = .5, height = .5)
  
  ggdraw() +
    draw_plot(viz_hts_pos) +
    draw_image("figures/logo.png",
              x = 0, y = .9,
              width = .1, height = .1) +
    theme(plot.title = element_markdown(margin = margin(t = 5, l = .1)))
  
  ggdraw() +
    draw_image(file_aids) +
    draw_plot(viz_hts_yield,
              x = 0, y = 0,
              width = .8, height = 1)
  
  viz_hts_pos +
    annotation_custom(
      grob = logo,
      xmin = max(df_viz$HTS_TST) - 10000, 
      xmax = max(df_viz$HTS_TST) + 10000,
      ymin = 1, ymax = 3) 
  

# EXPORT ====

  