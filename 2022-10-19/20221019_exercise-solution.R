# PROJECT:  coRps
# AUTHOR:   A.Chafetz | USAID
# PURPOSE:  exercise solution
# REF ID:   95e52f73 
# LICENSE:  MIT
# DATE:     2022-10-12
# UPDATED: 

# DEPENDENCIES ------------------------------------------------------------
  
  library(tidyverse)
  library(gagglr)
  library(glue)
  # library(scales)
  # library(extrafont)
  # library(tidytext)
  # library(patchwork)
  # library(ggtext)
  library(googlesheets4)
  library(lubridate)
  

# EXERCISE LINK -----------------------------------------------------------

# https://docs.google.com/document/d/1SkaIBz7sg6MYnkFc1CsG8oyiU7FPzT_k_ywdTM9_vQs/edit

# GLOBAL VARIABLES --------------------------------------------------------
  
  ref_id <- "95e52f73"
  
  load_secrets("email")
  
  gdrive_id <- as_sheets_id("1IOlSO1j8tzVIKMPWeERNa7O0Ren-28BEw5WiDjzpfGI")

  get_metadata()
  
# IMPORT ------------------------------------------------------------------
  
  #read opm holiday from GDrive, need to treat as string b/c issue reading date
  df_opm <- read_sheet(gdrive_id, col_types = "c")  
  

# MUNGE -------------------------------------------------------------------

  #list of months to find in the date column
  month.list <- month.name %>%
    paste(collapse = "|") %>%
    paste0("(", ., ")")
  
  #extact dates as actual date
  opm_holiday <- df_opm %>%
    rename_all(tolower) %>%
    mutate(month = date %>%
             str_extract(month.list) %>%
             match(month.name),
           day = str_extract(date, "[:digit:]{2}"),
           date_holiday_obs = make_date(year, month, day),
           holiday = str_replace(holiday, "\x92", "'")) %>%
    select(date_holiday_obs, holiday)
  
  #create a sequence of dates for the whole fiscal calendar year
  fy_date <- seq.Date(make_date(metadata$curr_fy-1, 11, 1), 
                      make_date(metadata$curr_fy, 10, 30), 
                      by = 1)
  
  #determine which dates business days 
  df_cal <- tibble(date = fy_date) %>%
    mutate(is.weekend = wday(date, week_start = 1) > 5,
           is.holiday = date %in% opm_holiday$date_holiday_obs,
           is.businessday = is.weekend == FALSE & is.holiday == FALSE,
           month = month(date),
           day = day(date))
  
  #group by month and filter for business days that are at least the 15th & slice first day
  df_subm <- df_cal %>%
    group_by(month) %>%
    filter(is.businessday,
           day >= 15) %>%
    slice_head() %>%
    ungroup() %>%
    arrange(date)
  
  #pull list of dates
  df_subm %>% 
    pull(date)
  