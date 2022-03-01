# PROJECT:  coRps
# AUTHOR:   A.Chafetz | USAID
# PURPOSE:  provide additional FY21Q3 partner review slides
# LICENSE:  MIT
# DATE:     2021-08-30
# UPDATED:  
# NOTE:     adapted from rebooTZ/FY21Q3/TZA_partner-review.R
#           inspriation: https://baseballsavant.mlb.com/savant-player/juan-soto-665742?stats=statcast-r-hitting-mlb

# SOURCE META DATA --------------------------------------------------------

# DATIM DATA GENIE
# PSNU By IM
# DATIM data as of: 08/14/2021 21:59:04 UTC
# Genie report updated: 08/19/2021 01:43:13 UTC
# 
# Current period(s): 2020 Target,  2020 Q1,  2020 Q2,  2020 Q3,  2020 Q4,  2021 Target,  2021 Q1,  2021 Q2,  2021 Q3 

# Operating Unit: Tanzania
# Daily/Frozen: Daily


# DEPENDENCIES ------------------------------------------------------------

library(tidyverse)
library(glitr)
library(glamr)
library(gophr)
library(extrafont)
library(scales)
library(tidytext)
library(patchwork)
library(ggtext)
library(glue)
library(gisr)
library(sf)


# GLOBAL VARIABLES --------------------------------------------------------

  #path to genie output file
  genie_path <- si_path("path_downloads") %>% 
    file.path("Genie-PSNUByIMs-Tanzania-Daily-2021-08-19.zip")
  
  #select indicators
  ind_sel <- c("HTS_INDEX",  "HTS_INDEX_NEWPOS", "HTS_TST", "HTS_TST_POS",
               "HTS_SELF", "PMTCT_STAT_D", "PMTCT_STAT", "PMTCT_STAT_POS",
               "TX_NEW", "TX_CURR", "TX_PVLS_D", "TX_PVLS")
  
  #table of preferred partner names
  df_ptnr <- tribble(
    ~mech_code,             ~partner,
    "81965",               "EpiC",
    "82164", "Police and Prisons",
    "18060",              "EGPAF",
    "18237",           "Deloitte",
    "70356",             "Baylor"
  )
  

  #caption info for plotting
  source <- source_info(genie_path)
  
  #current FY and quarter
  curr_fy <- source_info(genie_path, return = "fiscal_year")
  curr_qtr <- source_info(genie_path, return = "quarter")
  
  
# IMPORT ------------------------------------------------------------------
  
  df_genie <- read_msd(genie_path)   
  
  
# MUNGE -------------------------------------------------------------------
  
  #subset to key indicators
  df_sub <- df_genie %>% 
    filter(fundingagency == "USAID",
           fiscal_year == curr_fy,
           indicator %in% ind_sel) %>% 
    clean_indicator()
  
  #limit to select partners with preferred names
  df_sub <-  inner_join(df_sub, df_ptnr)
  
  
# MUNGE - NAT/SNU ACHIEVEMENT ---------------------------------------------
  
  #aggregate to regional level
  df_achv <- df_sub %>% 
    bind_rows(df_sub %>% 
                mutate(snu1 = "NATIONAL",
                       snu1uid = "NATIONAL")) %>% 
    filter(standardizeddisaggregate %in% c("Total Numerator", "Total Denominator")) %>% 
    group_by(fiscal_year, partner, snu1, snu1uid, indicator) %>% 
    summarize(across(c(targets, cumulative), sum, na.rm = TRUE), 
              .groups = "drop")
  
  #calculate achievement
  df_achv <- df_achv %>% 
    adorn_achievement(curr_qtr)
  
  #viz adjustments
  df_achv_viz <- df_achv %>% 
    complete(indicator, nesting(partner), fill = list(fiscal_year = curr_fy, snu1 = "NATIONAL")) %>% 
    mutate(natl_achv = case_when(snu1 == "NATIONAL" ~ achievement),
           achievement = ifelse(snu1 == "NATIONAL", NA, achievement),
           indicator = factor(indicator, ind_sel),
           baseline_pt_1 = 0,
           baseline_pt_2 = .25,
           baseline_pt_3 = .5,
           baseline_pt_4 = .75,
           baseline_pt_5 = 1,
    )
  #adjust facet label to include indicator and national values
  df_achv_viz <- df_achv_viz %>% 
    mutate(ind_w_natl_vals = case_when(snu1 == "NATIONAL" & is.na(targets) ~ 
                                         glue("**{indicator}**<br><span style = 'font-size:9pt;'>No MER reporting</span>"),
                                       snu1 == "NATIONAL" ~ 
                                         glue("**{indicator}**<br><span style = 'font-size:9pt;'>{comma(cumulative, 1)} / {comma(targets, 1)}</span>"))) %>% 
    group_by(partner, indicator) %>% 
    fill(ind_w_natl_vals, .direction = "downup") %>% 
    ungroup() %>% 
    arrange(partner, indicator) %>% 
    mutate(ind_w_natl_vals = fct_inorder(ind_w_natl_vals))
  
  
  
  

# VIZ ---------------------------------------------------------------------

  #pick 1 partner
  ptnr <- "EGPAF"
  
  #basic jitter plot
  (v <- df_achv_viz %>% 
      filter(partner == {ptnr}) %>% 
      ggplot(aes(achievement, indicator, color = achv_color)) +
      geom_point(position = position_jitter(width = 0, height = 0.1, seed = 42), na.rm = TRUE,
                 alpha = .4, size = 3))
  
  #facet by indicator with the values included
  (v <- v +
    facet_wrap(~ind_w_natl_vals))
  
  #adjust facet scales and facet title
  (v <- v + 
    facet_wrap(~ind_w_natl_vals, scales = "free_y") +
    theme(strip.text = element_markdown()))

  #add in a line range
  (v <- v + 
      geom_linerange(aes(xmin = 0, xmax = 1.1, y = 1), color = "#D3D3D3"))
  
  #add in the reference lines
  (v <- v +
    geom_point(aes(baseline_pt_1), shape = 3, color = "#D3D3D3") +
    geom_point(aes(baseline_pt_2), shape = 3, color = "#D3D3D3") +
    geom_point(aes(baseline_pt_3), shape = 3, color = "#D3D3D3") +
    geom_point(aes(baseline_pt_4), shape = 3, color = "#D3D3D3") +
    geom_point(aes(baseline_pt_5), shape = 3, color = "#D3D3D3"))
  
  #squish
  (v <- v + 
    scale_x_continuous(limit=c(0,1.1),oob=scales::squish))

  #adjust theme
  (v <- v +
      si_style_nolines() +
      theme(strip.text = element_markdown(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank()))  

  #fix color
  (v <- v +
      scale_color_identity())
  
  #add point for national level achievement
  (v <- v + 
      geom_point(aes(natl_achv), size = 8, alpha = .8, na.rm = TRUE))

  #add national achievement value text
  (v <- v +
    geom_text(aes(natl_achv, label = percent(natl_achv, 1)), na.rm = TRUE,
              color = "#202020", family = "Source Sans Pro", size = 9/.pt))
  
  #adjust titles and captions
  (v <- v +
    labs(x = NULL, y = NULL,
         title = glue("FY{curr_fy}Q{curr_qtr} Tanzania | {ptnr}") %>% toupper,
         subtitle = glue("Partner achievement nationally (large, labeled points) with regional reference points<br>
                         <span style = 'font-size:11pt;color:{color_caption};'>Goal for 75% at Q3 (snapshot indicators pegged to year end target 100%)</span>"),
         caption = glue("Target achievement capped at 110%
                        Source: {source}
                        US Agency for International Development")) +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          plot.subtitle = element_markdown(),
          strip.text = element_markdown(),
          panel.spacing.y = unit(0, "lines")))

  #save
  si_save(glue("2021-08-30/FY{curr_fy}Q{curr_qtr}_TZA_Partner-Achievement_{ptnr}.png"))
  
  #adjust points getting clipped
  (v <- v + coord_cartesian(clip = "off"))
  
  #save
  si_save(glue("2021-08-30/FY{curr_fy}Q{curr_qtr}_TZA_Partner-Achievement_{ptnr}.png"))
  
  
  

# FUNCTIONALIZE -----------------------------------------------------------

  plot_achv <- function(ptnr, export = TRUE){
    df_achv_viz %>% 
      filter(partner == {ptnr}) %>% 
      ggplot(aes(achievement, indicator, color = achv_color)) +
      geom_blank() +
      geom_linerange(aes(xmin = 0, xmax = 1.1, y = 1), color = "#D3D3D3") +
      geom_point(aes(baseline_pt_1), shape = 3, color = "#D3D3D3") +
      geom_point(aes(baseline_pt_2), shape = 3, color = "#D3D3D3") +
      geom_point(aes(baseline_pt_3), shape = 3, color = "#D3D3D3") +
      geom_point(aes(baseline_pt_4), shape = 3, color = "#D3D3D3") +
      geom_point(aes(baseline_pt_5), shape = 3, color = "#D3D3D3") +
      geom_jitter(position = position_jitter(width = 0, height = 0.1), na.rm = TRUE,
                  alpha = .4, size = 3) +
      geom_point(aes(natl_achv), size = 8, alpha = .8, na.rm = TRUE) +
      geom_text(aes(natl_achv, label = percent(natl_achv, 1)), na.rm = TRUE,
                color = "#202020", family = "Source Sans Pro", size = 9/.pt) +
      coord_cartesian(clip = "off") +
      scale_x_continuous(limit=c(0,1.1),oob=scales::squish) +
      scale_color_identity() +
      facet_wrap(~ind_w_natl_vals, scales = "free_y") +
      labs(x = NULL, y = NULL,
           title = glue("FY{curr_fy}Q{curr_qtr} Tanzania | {ptnr}") %>% toupper,
           subtitle = glue("Partner achievement nationally (large, labeled points) with regional reference points<br>
                         <span style = 'font-size:11pt;color:{color_caption};'>Goal for 75% at Q3 (snapshot indicators pegged to year end target 100%)</span>"),
           caption = glue("Target achievement capped at 110%
                        Source: {source}
                        US Agency for International Development")) +
      si_style_nolines() +
      theme(axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            plot.subtitle = element_markdown(),
            strip.text = element_markdown(),
            panel.spacing.y = unit(0, "lines"))
    
    if(export == TRUE)
      si_save(glue("2021-08-30/FY{curr_fy}Q{curr_qtr}_TZA_Partner-Achievement_{ptnr}.png"))
  }
  
  walk(unique(df_achv_viz$partner), plot_achv)  
  