## PROJECT:  coRps
## AUTHOR:   Davis, Chafetz | USAID
## PURPOSE:  stucture dataset for use in dplyr exercises
## DATE:     2020-04-24
## UPDATED:  2020-04-27


# DEPENDENCIES ------------------------------------------------------------

library(tidyverse)
library(ICPIutilities)

# IMPORT MASKED DATASET ---------------------------------------------------

  dataset_url <- "https://media.githubusercontent.com/media/ICPI/TrainingDataset/master/Output/MER_Structured_TRAINING_Datasets_PSNU_IM_FY18-20_20200214_v1_1.txt"
  
  df <- read_msd(dataset_url, save_rds = FALSE)
  


# dplyr -----------------------------------------------------------------

  df_dplyr <- df %>% 
    filter(indicator %in% c("TX_CURR", "TX_NEW", "HTS_TST", "HTS_TST_POS"),
           operatingunit %in% c("Saturn", "Jupiter"),
           standardizeddisaggregate == "Total Numerator") %>% 
    select(operatingunit, psnu, fundingagency, mech_name, indicator, fiscal_year:cumulative)
  
  set.seed(42)
  
  extra_zeros <- df_dplyr %>% 
    sample_n(10) %>% 
    mutate_if(is.double, ~ 0)
  
  df_dplyr <- bind_rows(df_dplyr, extra_zeros)
  
  
  write_csv(df_dplyr, "2020-04-27/dplyr_exercise.csv", na = "")
  
