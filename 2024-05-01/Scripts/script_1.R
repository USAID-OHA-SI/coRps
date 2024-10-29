required_packages <- c("tidyverse", "here", "janitor", "glamr")

missing_packages <- required_packages[!(required_packages %in% installed.packages()
                                        [,"Package"])]

if( length(missing_packages) > 0){
    install.packages(missing_packages, repos =  c("https://usaid-oha-si.r-universe.dev",
                                                  "https://cloud.r-project.org"))
}


library(tidyverse)
library(here)
library(janitor)
library(glamr)

folder_setup(folder_list = list("Dataout"))

# Define the output file path relative to the location of the script
#change this to whenever you want your outputs saved and ensure that folder exists

output_file <- here::here("2024-05-01/Dataout", "script_1.csv")

# Generate the CSV file
starwars_df <- starwars %>% 
    select(name, species, homeworld) %>% 
    clean_names() %>% 
    write_csv(output_file)
