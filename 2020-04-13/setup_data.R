## PROJECT:  coRps
## AUTHOR:   Chafetz | USAID
## PURPOSE:  stucture dataset for use in ggplot overview
## DATE:     2020-03-14
## UPDATTED: 2020-03-30


# DEPENDENCIES ------------------------------------------------------------

library(tidyverse)
library(ICPIutilities)

# IMPORT MASKED DATASET ---------------------------------------------------

  dataset_url <- "https://media.githubusercontent.com/media/ICPI/TrainingDataset/master/Output/MER_Structured_TRAINING_Datasets_PSNU_IM_FY18-20_20200214_v1_1.txt"
  
  df <- read_msd(dataset_url, save_rds = FALSE)
  

# MUNGE HTS --------------------------------------------------------------

  #filter for testing  
    df_hts <- df %>% 
      filter(indicator %in% c("HTS_TST", "HTS_TST_POS"),
             standardizeddisaggregate == "Modality/Age/Sex/Result",
             fiscal_year == 2020) 
  
  #aggregate
    df_hts <- df_hts %>%
      group_by(fiscal_year, operatingunit, psnu, modality, indicator) %>% 
      summarise_at(vars(cumulative), sum, na.rm = TRUE) %>% 
      ungroup()
    
  #spread and create indicators
    df_hts <- df_hts %>% 
      spread(indicator, cumulative, fill = 0) %>% 
      filter_at(vars(HTS_TST, HTS_TST_POS), any_vars(. != 0)) %>% 
      mutate(Positivity = HTS_TST_POS / HTS_TST,
             is_index = str_detect(modality, "Index"))
    

# MUNGE TX ----------------------------------------------------------------

  #filter for testing  
    df_tx <- df %>% 
      filter(indicator %in% c("TX_NEW", "TX_NET_NEW", "TX_CURR"),
             standardizeddisaggregate == "Total Numerator",
             fiscal_year == 2020) 
    
  #aggregate
    df_tx <- df_tx %>%
      group_by(fiscal_year, operatingunit, fundingagency, primepartner,  indicator) %>% 
      summarise_at(vars(cumulative), sum, na.rm = TRUE) %>% 
      ungroup() %>% 
      filter(cumulative != 0,
             primepartner != "Dedup")
    
  #spread and create indicators
    df_tx <- df_tx %>% 
      spread(indicator, cumulative) %>% 
      filter_at(vars(TX_CURR, TX_NEW), any_vars(!is.na(.)))
    
  #additional filters
    df_tx <- df_tx %>% 
      filter(TX_NEW < 1000,
           TX_NET_NEW > -2000)
    
# EXPORT ------------------------------------------------------------------

  write_csv(df_hts, "2020-03-30/FY20_MilkyWay_Testing.csv", na = "")  
  write_csv(df_tx, "2020-03-30/FY20_MilkyWay_NewtoNetNew.csv", na = "")  
    