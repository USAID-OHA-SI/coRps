## PROJECT:  coRps
## AUTHOR:   Chafetz | USAID
## PURPOSE:  stucture dataset for use in ggplot explore
## DATE:     2020-03-16


library(tidyverse)
library(ICPIutilities)

dataset_url <- "https://media.githubusercontent.com/media/ICPI/TrainingDataset/master/Output/MER_Structured_TRAINING_Datasets_PSNU_IM_FY18-20_20200214_v1_1.txt"


df <- read_msd(dataset_url, save_rds = FALSE)

df_tx <- df %>% 
  filter(operatingunit == "Jupiter",
         indicator == "TX_NEW",
         standardizeddisaggregate == "Total Numerator") %>%
  group_by(fiscal_year, operatingunit, primepartner, indicator) %>% 
  summarise_at(vars(starts_with("qtr")), sum, na.rm = TRUE) %>% 
  ungroup() %>% 
  reshape_msd(clean = TRUE) %>% 
  select(operatingunit, indicator, primepartner, period, val) %>% 
  arrange(primepartner, period) %>% 
  filter(!primepartner %in% c("Cepheus", "Pisces")) %>% 
  mutate(latest = case_when(period == max(period) ~ val,
                            TRUE ~ 0))


write_csv("2020-03-16/FY20Q1_Jupiter_TXNEW.csv", na = "")