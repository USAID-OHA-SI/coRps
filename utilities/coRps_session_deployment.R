# PROJECT:  coRps
# AUTHOR:   B.Kagniniwa | USAID
# PURPOSE:  Automate deployment of coRps Sessions
# LICENSE:  MIT
# DATE:     2022-03-01

# Libs ----
library(magrittr)
library(purrr)
library(stringr)
library(fs)
#library(git2r)

# Inputs ----
input_dir <- "2022-06-06"
corps_session <- "rbbs-mapping_with_r.Rmd"

# Config / Files ---
input_file <- paste0(input_dir, "/", corps_session)

output_file <- input_file %>% 
  str_replace("Rmd$", "md") %>% 
  str_replace("\\/", "-")

output_dir_repo <- "../usaid-oha-si.github.io/"
output_dir_posts <- "_posts/"
output_dir_images <- "assets/img/posts/"

output_file <- paste0(output_dir_repo, output_dir_posts, output_file)

# Generate md file ----
rmarkdown::render(
  input = input_file,
  clean = TRUE,
  run_pandoc = FALSE
)

# rename and move md file to github page repo
input_file %>% 
  str_replace(".Rmd", ".knit.md") %>% 
  file_move(path = ., new_path = output_file)

# Rename and copy images
input_dir %>% 
  list.files(path = .) %>% 
  walk(function(.x) {

    # process images only
    if (str_detect(str_to_lower(.x), "png$|jpeg$|jpg$|tif$|jfif$")) {
      
      # rename image filename
      img_name <- input_file %>% 
        basename() %>% 
        str_remove(".Rmd$") %>% 
        paste0(str_remove_all(input_dir, "-"), "-rbbs-", ., "-", .x)
      
      output_image <- paste0(output_dir_repo, output_dir_images, img_name)
      output_image_link <- paste0("/", output_dir_images, img_name)
      
      # move file to github pages assets/img/posts
      file_copy(path = paste0(input_dir, "/", .x), new_path = output_image)
                
      # update images paths
      xfun::gsub_file(file = output_file, .x, output_image_link)
    }
  })

## TODO - Automate commit / push

# repo <- repository(output_dir_repo)
# 
# git2r::add(repo = repo, path = paste0(output_dir_repo, "*"))
# 
# git2r::commit(repo = repo,
#               message = paste0("coRps session ",
#                                input_dir,
#                                " - automated deployments"))



