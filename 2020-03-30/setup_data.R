## PROJECT:  coRps
## AUTHOR:   Chafetz | USAID
## PURPOSE:  stucture dataset for use in ggplot overview
## DATE:     2020-03-14


# DEPENDENCIES ------------------------------------------------------------

library(tidyverse)
library(ICPIutilities)

# IMPORT MASKED DATASET ---------------------------------------------------

  dataset_url <- "https://media.githubusercontent.com/media/ICPI/TrainingDataset/master/Output/MER_Structured_TRAINING_Datasets_PSNU_IM_FY18-20_20200214_v1_1.txt"
  
  df <- read_msd(dataset_url, save_rds = FALSE)
  

# MUNGE -------------------------------------------------------------------

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
    

# EXPORT ------------------------------------------------------------------

  write_csv(df_hts, "2020-03-16/FY20_MilkyWay_Testing.csv", na = "")  
    