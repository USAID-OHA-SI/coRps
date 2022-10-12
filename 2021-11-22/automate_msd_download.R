# PROJECT:  coRps
# AUTHOR:   A.Chafetz | USAID
# PURPOSE:  quarterly MSD update
# LICENSE:  MIT
# DATE:     2021-11-22
# UPDATED:  2022-08-22

# DEPENDENCIES ------------------------------------------------------------

  library(tidyverse)
  library(gagglr)
  library(grabr)

# GLOBAL VARIABLES --------------------------------------------------------

  #store Pano creds
  # set_pano()

  #establish session
  sess <- pano_session(username = pano_user(), password = pano_pwd())

  # #downloads address
  # url <- "https://pepfar-panorama.org/forms/downloads/"


# IDENTIFY CURRENT PERIOD -------------------------------------------------

   # recent_fldr <- url %>%
   #  pano_content(session = sess) %>%
   #  pano_elements() %>%
   #  filter(str_detect(item, "^MER")) %>%
   #  pull(item)

  # curr_status <- ifelse(str_detect(recent_fldr, "Post"), "clean", "initial")
  # curr_fy <- str_extract(recent_fldr, "[:digit:]{4}") %>% as.numeric()
  # curr_qtr <- str_extract(recent_fldr, "(?<=Q)[:digit:]") %>% as.numeric()


# IDENTIFY FILES ----------------------------------------------------------

  #extract files to download
  items <- map2_dfr(c("mer", "mer", "financial"),
                    c(TRUE, FALSE, FALSE),
                   ~ pano_extract(item = .x,
                                  unpack = .y))


# DOWNLOAD ----------------------------------------------------------------

  #download MSDs to data folder
  items %>%
    filter(str_detect(item, "PSNU_IM_FY20.*[:digit:]\\.zip|NAT_SUBNAT|OU_IM|Financial.*\\.zip")) %>%
    distinct(path) %>%
    pull(path) %>%
    walk(~pano_download(item_url = .x,
                        session = sess,
                        dest = si_path()))


# CONVERT TO RDS ----------------------------------------------------------

  # #remove old files
  # list.files(si_path(), "rds", full.names = TRUE) %>%
  #   unlink()
  # 
  # #identify new files to unzip
  # files <- list.files(si_path(), "zip", full.names = TRUE)
  # 
  # #unzip and store as rds
  # walk(files,
  #      ~read_msd(.x, save_rds = TRUE, remove_txt = TRUE))


