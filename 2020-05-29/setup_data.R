## PROJECT:  coRps
## AUTHOR:   G. Sarfaty | USAID
## PURPOSE:  create dataset for use in import, merge, append
## DATE:     2020-05-29


library(tidyverse)
library(ICPIutilities)


# IMPORT TRAINING DATASET --------------------------------------------

dataset_url <- "https://media.githubusercontent.com/media/ICPI/TrainingDataset/master/Output/MER_Structured_TRAINING_Datasets_PSNU_IM_FY18-20_20200214_v1_1.txt"


df <- read_msd(dataset_url, save_rds = FALSE)


# JUPITER POS  -------------------------------------------------------
jupiter_pos <- df %>% 
  filter(indicator == "HTS_TST_POS",
         standardizeddisaggregate == "Total Numerator",
         fiscal_year=="2020",
         operatingunit=="Jupiter") %>%
  group_by(fiscal_year, operatingunit, mech_code, indicator) %>% 
  summarise_at(vars(starts_with("qtr")), sum, na.rm = TRUE) %>% 
  ungroup() %>% 
  reshape_msd(clean = TRUE) %>% 
  select(operatingunit, indicator, mech_code, period, val) %>% 
  filter(!mech_code=="01620")


write_csv(jupiter_pos, "2020-05-29/FY20Q1_Jupiter_POS.csv", na = "")


# MECH PARTNER LIST  -------------------------------------------------

jupiter_mechs<-df %>% 
  filter(operatingunit=="Jupiter",
         fiscal_year=="2020") %>% 
  distinct(mech_code,mech_name,primepartner) %>% 
  filter(!mech_code=="01221")

write_csv(jupiter_mechs, "2020-05-29/FY20_Jupiter_mechs.csv")


# JUPITER TX_NEW -----------------------------------------------------

jupiter_new <- df %>% 
  filter(indicator == "TX_NEW",
         standardizeddisaggregate == "Total Numerator",
         fiscal_year=="2020",
         operatingunit=="Jupiter") %>%
  group_by(fiscal_year, operatingunit, mech_code, indicator) %>% 
  summarise_at(vars(starts_with("qtr")), sum, na.rm = TRUE) %>% 
  ungroup() %>% 
  reshape_msd(clean = TRUE) %>% 
  select(operatingunit, indicator, mech_code, period, val)

write_csv(jupiter_new, "2020-05-29/FY20Q1_NEW.csv", na="")


# EXERCISE DATA -----------------------------------------------------

jupiter_TX_results<-df %>% 
  filter(operatingunit=="Jupiter",
         fiscal_year=="2020",
         indicator=="TX_CURR") %>% 
  group_by(fiscal_year, operatingunit, mech_code, indicator) %>% 
  summarise_at(vars(starts_with("cum")), sum, na.rm = TRUE) %>% 
  ungroup() %>% 
  reshape_msd(clean = TRUE)

write_tsv(jupiter_TX_results, "2020-05-29/Jupiter_TX_FY20_Results.txt", na="")

  
jupiter_TX_targets<-df %>% 
  filter(operatingunit=="Jupiter",
         fiscal_year=="2020",
         indicator=="TX_CURR") %>% 
  group_by(fiscal_year, operatingunit, mech_code, indicator) %>% 
  summarise_at(vars(starts_with("tar")), sum, na.rm = TRUE) %>% 
  ungroup() %>% 
  reshape_msd(clean = TRUE)

write_tsv(jupiter_TX_targets, "2020-05-29/Jupiter_TX_FY20_Targets.txt", na="")
