library(tidyverse)
library(TrainingDataset) #remotes::install_github("ICPI/TrainingDataset")
library(Wavelength)
library(readxl)
library(glamr)
library(googlesheets4)
library(googledrive)

# SIMPLE IMPORT -----------------------------------------------------------

l <- 27

dates <- seq.Date(as.Date("2050-01-01"), by  = "2 weeks", length.out = l)


set.seed(42)
v <-  runif(l, 21, 49) %>% round()
sitename <- gen_sitename()

df_simple <- tibble(operatingunit = "Jupiter",
       site = sitename, 
       mech_code = "54321",
       date = dates,
       indicator = "HTS_TST",
       value = v
       )

write_csv(df_simple, "2022-03-28/simple.csv")


read_csv("2022-03-28/simple.csv", col_types = cols(mech_code = col_character()))

read_csv("2022-03-28/simple.csv", col_types = cols(.default = "c"))


df_missing <- df_simple %>% 
  mutate(value = ifelse(row_number() %in% c(12:15, 20:22), value, NA_integer_))

write_csv(df_missing, "2022-03-28/missing.csv")

read_csv("2022-03-28/missing.csv",
         guess_max = 5)


# EXCEL/HFR ---------------------------------------------------------------

l <- 10

set.seed(42)
df_hfr <- tibble(date = as.Date("2050-01-01"),
       orgunit = replicate(10, gen_sitename()),
       orgunituid = replicate(10, generateUID()),
       mech_code = "54321",
       partner = planets_primepartners$primepartner_mw[1],
       operatingunit = "Jupiter",
       psnu = planets_geo$psnu_mw[9],
       hts_tst.u15.f = runif(l, 4, 19) %>% round(),
       hts_tst.u15.m = runif(l, 0, 12) %>% round(),
       hts_tst.o15.f = runif(l, 14, 62) %>% round(),
       hts_tst.o15.m = runif(l, 8, 32) %>% round()) %>% 
  mutate(hts_tst_pos.u15.f = round(.05 * hts_tst.u15.f),
         hts_tst_pos.u15.m = round(.05 * hts_tst.u15.m),
         hts_tst_pos.o15.f = round(.09 * hts_tst.o15.f),
         hts_tst_pos.o15.m = round(.09 * hts_tst.o15.m)
         )

clipr::write_clip(df_hfr)

set.seed(40)
df_hfr2 <- tibble(date = as.Date("2050-01-01"),
                 orgunit = replicate(10, gen_sitename()),
                 orgunituid = replicate(10, generateUID()),
                 mech_code = "54320",
                 partner = planets_primepartners$primepartner_mw[3],
                 operatingunit = "Jupiter",
                 psnu = planets_geo$psnu_mw[7],
                 hts_tst.u15.f = runif(l, 4, 19) %>% round(),
                 hts_tst.u15.m = runif(l, 0, 12) %>% round(),
                 hts_tst.o15.f = runif(l, 14, 62) %>% round(),
                 hts_tst.o15.m = runif(l, 8, 32) %>% round()) %>% 
  mutate(hts_tst_pos.u15.f = round(.05 * hts_tst.u15.f),
         hts_tst_pos.u15.m = round(.05 * hts_tst.u15.m),
         hts_tst_pos.o15.f = round(.09 * hts_tst.o15.f),
         hts_tst_pos.o15.m = round(.09 * hts_tst.o15.m)
  )


clipr::write_clip(df_hfr2)


read_excel("2022-03-28/hfr.xlsx")

excel_sheets("2022-03-28/hfr.xlsx")
read_excel("2022-03-28/hfr.xlsx", sheet = "HFR", skip = 1) %>% 
  select(date:hts_tst_pos.o15.m) %>% 
  glimpse()

excel_sheets("2022-03-28/hfr.xlsx") %>% 
  stringr::str_subset("HFR") %>% 
  purrr::map_dfr(~read_excel("2022-03-28/hfr.xlsx", sheet = .x, skip = 1))


# GOOGLE SHEET ------------------------------------------------------------

load_secrets()

data_folder <- as_id("1D6MyD-3yHYqswXDqOPpCQiN19P4jrjAE")
drive_upload("2022-03-28/simple.csv",
             path = data_folder,
             name = "simple_gs",
             type = "spreadsheet")

data_folder %>% 
  drive_ls(pattern = "simple") %>% 
  drive_share(role = "reader",
            type = "domain", domain = "usaid.gov")

gs4_auth()

read_sheet(as_sheets_id("1B_DcG1WqZv6xo_eBBye-Q31tMGq_DjCBcjlWs3xINOw"))



# MSD ---------------------------------------------------------------------

filepath_msd <- "2022-03-28/MER_Structured_Datasets_OU_IM_FY20-22_20220211_v1_1.zip"
vroom::vroom(filepath_msd) %>% 
  glimpse()

gophr::read_msd(filepath_msd)
