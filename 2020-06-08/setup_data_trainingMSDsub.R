## PROJECT:  coRps
## AUTHOR:   G. Sarfaty | USAID
## PURPOSE:  create dataset for use in import, merge, append
## DATE:     2020-05-29


library(tidyverse)
library(ICPIutilities)


# IMPORT TRAINING DATASET --------------------------------------------

df <- read_msd("MER_Structured_TRAINING_Datasets_PSNU_IM_FY18-20_20200214_v1_1.txt", save_rds = FALSE)


# FILTER TO MAKE SMALLER ---------------------------------------------

df<-df %>% 
  filter(indicator %in% c("TX_CURR", "TX_NEW", "TX_NET_NEW", "HTS_TST","HTS_TST_POS","HTS_TST_NEG"),
         operatingunit %in% c("Saturn"))



# EXPORT -------------------------------------------------------------
write_tsv(df, "MSD_Training_subset_Saturn_PSNU_IM_FY18-20_20200214_v1_1.txt", na="")