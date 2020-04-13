## PROJECT:  coRps
## AUTHOR:   Chafetz | USAID
## PURPOSE:  stucture dataset for use in ggplot exercises
## DATE:     2020-04-13
## UPDATTED: 


# DEPENDENCIES ------------------------------------------------------------

library(tidyverse)
library(ICPIutilities)

# IMPORT MASKED DATASET ---------------------------------------------------

  dataset_url <- "https://media.githubusercontent.com/media/ICPI/TrainingDataset/master/Output/MER_Structured_TRAINING_Datasets_PSNU_IM_FY18-20_20200214_v1_1.txt"
  
  df <- read_msd(dataset_url)
  


# LINKAGE -----------------------------------------------------------------


  df_linkage <- df %>% 
    filter(operatingunit == "Saturn",
           indicator %in% c("HTS_TST_POS", "TX_NEW"),
           standardizeddisaggregate == "Total Numerator",
           fiscal_year == 2019) %>% 
    group_by(operatingunit, primepartner, psnu, indicator, fiscal_year) %>% 
    summarise_at(vars(cumulative), sum, na.rm = TRUE) %>% 
    ungroup() %>% 
    spread(indicator, cumulative) %>% 
    mutate(linkage = TX_NEW/HTS_TST_POS)
  
  write_csv(df_linkage, "2020-04-13/FY19_Saturn_linkage.csv", na = "")
  


# TREATMENT TRENDS --------------------------------------------------------

  df_trends <- df %>% 
    filter(operatingunit == "Jupiter",
           indicator %in% c("TX_CURR", "TX_NEW", "TX_NET_NEW"),
           standardizeddisaggregate == "Total Numerator") %>% 
    group_by(operatingunit,  indicator, fiscal_year) %>% 
    summarise_at(vars(starts_with("qtr")), sum, na.rm = TRUE) %>% 
    ungroup() %>% 
    reshape_msd(clean = TRUE) %>% 
    arrange(indicator, period)
  
  write_csv(df_trends, "2020-04-13/FY18-20_Jupiter_txtrends.csv", na = "")
  
  

# TARGET ACHIEVEMENT ------------------------------------------------------

  df_achievement <- df %>% 
    filter(operatingunit == "Neptune",
           indicator == "TX_NEW",
           standardizeddisaggregate == "Age/Sex/HIVStatus",
           fiscal_year == 2020) %>% 
    group_by(fiscal_year, operatingunit, primepartner, indicator, sex) %>% 
    summarise_at(vars(cumulative, targets), sum, na.rm = TRUE) %>% 
    ungroup() %>% 
    filter(primepartner != "Dedup") %>% 
    mutate(achievement = cumulative / targets)
  
  write_csv(df_achievement, "2020-04-13/FY20_Neptune_txnew_achievement.csv", na = "")
  
    
  