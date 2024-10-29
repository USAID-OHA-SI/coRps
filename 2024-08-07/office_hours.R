# PROJECT:  coRps
# PURPOSE:  setting up for workingw ith MSD
# AUTHOR:   A.Chafetz | USAID
# REF ID:   048a90db 
# LICENSE:  MIT
# DATE:     2024-08-07
# UPDATED: 


# RESOURCES ---------------------------------------------------------------
  
#SI packages - https://usaid-oha-si.github.io/tools/
#R analysts SI guide - https://usaid-oha-si.github.io/reference/book-si-manual/
#snippets - https://gist.github.com/achafetz/366595c418ae1872f880db6ad5bbd132


# DEPENDENCIES ------------------------------------------------------------
  
  #general
  library(tidyverse)
  library(glue)
  #oha
  library(gagglr) ##install.packages('gagglr', repos = c('https://usaid-oha-si.r-universe.dev', 'https://cloud.r-project.org'))
  #viz extensions
  library(scales, warn.conflicts = FALSE)
  library(systemfonts)
  library(tidytext)
  library(patchwork)
  library(ggtext)
  

# GLOBAL VARIABLES --------------------------------------------------------
  
  ref_id <- "048a90db"  #a reference to be places in viz captions 
  
  path_msd <-  si_path() %>% 
    return_latest("TRAINING")
  
  meta <- get_metadata(path_msd)  #extract MSD metadata
  
  
  
# IMPORT ------------------------------------------------------------------
  
  df_msd <- read_psd(path_msd)
  

# MUNGE -------------------------------------------------------------------

  df_msd %>% 
    filter(indicator == "HTS_TST_POS",
           fiscal_year == 2061) %>% 
    count(standardizeddisaggregate)
  
  df_msd %>% 
    filter(indicator %in% c("HTS_TST_POS", "TX_NEW", "TX_CURR"),
           # use_for_age == "Y",
            fiscal_year == 2061) %>% 
    count(standardizeddisaggregate,
          indicator, use_for_age,
          wt = cumulative) %>% 
    prinf()
  
  
  df_hts <- df_msd %>% 
    filter(indicator %in% c("HTS_TST_POS", "TX_NEW", "TX_CURR"),
           sex == "Female",
           target_age_2024 == "15-24",
           use_for_age == "Y",
           fiscal_year >= 2060) 
  
  
  df_agg <- df_hts %>% 
    group_by(fiscal_year, snu1, indicator) %>% 
    summarise(targets = sum(targets, na.rm = TRUE),
              cumulative = sum(cumulative, na.rm = TRUE),
              .groups = "drop")
  
  
  df_agg %>% 
    adorn_achievement(qtr = meta$curr_qtr)
  
    
    
  df_viz <- df_hts %>% 
    group_by(fiscal_year, snu1, indicator) %>% 
    summarise(across(c(targets, starts_with("qtr")), \(x) sum(x, na.rm =TRUE)),
              .groups = "drop") %>% 
    reshape_msd("quarters") %>% 
    adorn_achievement(meta$curr_qtr)
  
  

  # VIZ ---------------------------------------------------------------------
  
  
  df_viz %>% 
    ggplot(aes(period, results, fill = achv_color)) +
    geom_col() +
    facet_wrap(indicator ~ snu1, scale = "free_y") +
    scale_fill_identity()
