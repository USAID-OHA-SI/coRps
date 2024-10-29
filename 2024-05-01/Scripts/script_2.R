required_packages <- c("tidyverse", "here", "glamr")

missing_packages <- required_packages[!(required_packages %in% installed.packages()
                                         [, "Package"])]

if(length(missing_packages)>0){
    install.packages(missing_packages, repos = c("https://usaid-oha-si.r-universe.dev",
                                                 "https://cloud.r-project.org"))
}


library(tidyverse)
library(here)
library(glamr)

folder_setup(folder_list = list("Dataout"))

#change this to whenever you want your outputs saved and ensure that folder exists
output_file <- here::here("2024-05-01/Dataout", "script_2.csv")

world_bank_pop_df <- world_bank_pop %>% 
    select(country, indicator, "2017") %>% 
    pivot_wider(names_from = indicator, values_from = "2017") %>% 
    write_csv(output_file)


