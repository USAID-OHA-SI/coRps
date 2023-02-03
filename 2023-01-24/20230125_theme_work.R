# PROJECT:  coRps
# AUTHOR:   A.Chafetz | USAID
# PURPOSE:  
# REF ID:   449655bd 
# LICENSE:  MIT
# DATE:     2023-01-24
# UPDATED: 

# DEPENDENCIES ------------------------------------------------------------
  
  library(tidyverse)
  library(gagglr)
  library(glue)
  library(scales)
  library(extrafont)
  library(tidytext)
  library(patchwork)
  library(ggtext)
  

# GLOBAL VARIABLES --------------------------------------------------------
  
  ref_id <- "449655bd" #id for adorning to plots, making it easier to find on GH

# IMPORT ------------------------------------------------------------------
  
  data(package = "glitr")
  data(hts)
  
# MUNGE -------------------------------------------------------------------
  
  df_viz <- hts %>% 
    filter(period_type == "results") %>% 
    count(modality, indicator, period, wt = value, name = "value") %>% 
    pivot_wider(names_from = "indicator",
                names_glue = "{tolower(indicator)}") %>% 
    mutate(positivity = hts_tst_pos / hts_tst)
  
  df_title <- df_viz %>% 
    filter(period == max(period)) %>% 
    arrange(desc(hts_tst_pos)) %>% 
    mutate(share_tot_pos = hts_tst_pos / sum(hts_tst_pos)) %>% 
    slice_head(n = 1)
  
  lst_top <- df_viz %>% 
    filter(period == max(period)) %>% 
    arrange(desc(hts_tst)) %>% 
    slice_head(n = 1) %>% 
    pull(modality)
  
  df_viz %>% 
    ggplot(aes(period, positivity, group = modality)) +
    geom_line(na.rm = TRUE) +
    geom_point(aes(size = hts_tst_pos), na.rm = TRUE) +
    facet_wrap(~fct_reorder2(modality, period, hts_tst_pos)) +
    scale_y_continuous(label = percent) +
    labs(x = NULL, y = NULL,
         title = glue("{percent(df_title$share_tot_pos,1)} of Saturn's positivies in {df_title$period} came from the {df_title$modality} modality") %>% toupper,
         subtitle = glue("Though the high number of test were in {lst_top}"),
         caption = glue("Source: glitr hts dataset | Ref ID: {ref_id}"))

  