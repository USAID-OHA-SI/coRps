# PROJECT:  coRps
# AUTHOR:   A.Chafetz | USAID
# PURPOSE:  download files from GDrive
# REF ID:   5a683752 
# LICENSE:  MIT
# DATE:     2022-11-02
# UPDATED: 

# DEPENDENCIES ------------------------------------------------------------
  
  library(tidyverse)
  library(gagglr)
  library(glue)
  library(googledrive)
  library(lubridate)
  

# GLOBAL VARIABLES --------------------------------------------------------
  
  load_secrets("email")
  
  set_email("achafetz@usaid.gov")

  gs_id <- as_id("1TlE2dLSAY5fCQtgwkGc8luyPl5g85wPmuawCykTNzLQhpKfs7_KHZKZBYbH5oaF9cRVq1jCu")


# MUNGE -------------------------------------------------------------------

  df_drive_files <- drive_ls(gs_id)

  glimpse(df_drive_files)  
  
  df_drive_files_time <- df_drive_files %>% 
    mutate(created_time = purrr::map_chr(drive_resource, "createdTime") %>%
             ymd_hms(tz = "EST"))

  glimpse(df_drive_files_time)  
  
  temp_folder(TRUE)
  
  latest_file <- df_drive_files_time %>% 
    slice_max(order_by = created_time, n = 3) %>% 
    select(id, name) 
  
  latest_file %>% 
    pmap(~drive_download(file = ..1,
                          path = file.path(folderpath_tmp, ..2),
                          overwrite = TRUE)) 
    
  
  
  drive_download(file = latest_file$id[3], 
                 path = file.path(folderpath_tmp, latest_file$name),
                 overwrite = TRUE)
  
  test <- function(x){
    list.files(x)
  }

  
  walk(.x = c(...),
       .f = test) 
  walk(.x = c(...),
       .f = ~test(.x, "MER|FSD=")) 
  
  
  