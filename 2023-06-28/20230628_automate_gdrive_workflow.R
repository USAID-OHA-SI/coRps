# PROJECT:  coRps
# AUTHOR:   K. Srikanth | USAID
# PURPOSE:  Tutorial on automating push to gdrive
# LICENSE:  MIT
# DATE:     2023-06-28
# UPDATED: 

# DEPENDENCIES ------------------------------------------------------------

#Load Googledrive, glamr and Tidyverse
library(googledrive)
library(glamr)
library(tidyverse)

#Load secrets
load_secrets()

# STEP 1: LIST CONTENTS IN MASTER --------------------------------------

#store parent folder ID
parent_folder_id <- as_id("1ftrtBqBCC8AqAtME21-0EiW2xlgD5k6w")

#read in parent folder and list contents
master_folder <- drive_ls(path = parent_folder_id)

#Get unique list of OU folder ids
id_list <- master_folder$id


# STEP 2: CREATE FUNCTION -----------------------------------------------

# Create function to recursively list folders in each OU folder
list_folders <- function(folder_id) {
  
  #look within OU folder and filter to COP23 folder
  folders <- drive_ls(folder_id) %>% 
    filter(name %in% c("COP23 / FY24", "COP23/FY24"))
  
  # add check here if folders is null, create folder
  if(nrow(folders) == 0) {
    drive_mkdir("COP23 / FY24",
                path = as_id(folder_id))
    
    folders <- drive_ls(folder_id) %>% 
      filter(name %in% c("COP23 / FY24", "COP23/FY24"))
  } else {
    print("COP23 / FY24 Folder exists")
  }
  
  #grab subfolder ids
  cop23_ids <- folders$id
  
  #pass in subfolder IDs to list IM target table folders
  sub_folders <- drive_ls(cop23_ids) %>% 
    filter(name %in% c("IM Target Tables")) 
  
  # add check here if folders is null, create folder
  if(nrow(sub_folders) == 0) {
    drive_mkdir("IM Target Tables",
                path = as_id(cop23_ids))
    
    sub_folders <- drive_ls(cop23_ids) %>% 
      filter(name %in% c("IM Target Tables"))
  } else {
    print("IM Target Tables exists")
  }
  
  #filter df to IM target tables and add back OU ID
  sub_folders <- sub_folders %>% 
    filter(name %in% c("IM Target Tables")) %>% 
    mutate(parent_folder_id = folder_id)
  
  return(sub_folders)
  
}

# STEP 3: APPLY FUNCTION ---------------------------------------------------

#apply function
df_sub <- map_dfr(id_list, list_folders)

#left join back the OU folder info
df_folder <- df_sub %>% 
  left_join(master_folder %>% rename(ou_name = name), by = c("parent_folder_id" = "id"))

df_folder %>% 
  select(name, id, ou_name) %>% 
  write_csv("Dataout/COP_workplan_upload_crosswalk.csv")

# STEP 4: UPLOAD TO DRIVE --------------------------------------------------

#import Gdrive id mapping table & align to target table names
df_xwalk <- read_csv("Dataout/COP_workplan_upload_crosswalk.csv") %>% 
  mutate(ou_name = ou_name %>% 
           str_remove_all(" ") %>% 
           str_remove("'") %>% 
           str_remove("al$"))

#identify exported target files and assoicate with GDrive folder  
local_files <- list.files(folderpath_tmp, full.names = TRUE) %>% 
  tibble(filepath = .) %>% 
  mutate(basename = basename(filepath),
         ou_name = basename %>% 
           str_extract("(?<=_).*(?=_)") %>% 
           str_remove("-.*")) %>% 
  left_join(df_xwalk) %>%
  select(filepath, id, basename)

#push to target tables to Gdrive
tic()
local_files %>% 
  pwalk(~ drive_upload(..1,
                       path = as_id(..2),
                       name = basename(.x),
                       type = "spreadsheet",
                       overwrite = TRUE))
toc()




