##
## tidytuesdayR - Viz of the week
##

library(tidyverse)
library(janitor)
library(gisr)
library(glitr)
library(glamr)
library(scales)
library(ggflags)

# Setup ----

data_url <- 'https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-05-04/water.csv'

# Data ----

  df_water <- read_csv(data_url)

  df_water %>% glimpse()
  
  df_water %>% 
    #distinct(lat_deg)
    #distinct(lon_deg)
    distinct(lat_deg, lon_deg)
  
  df_water %>% distinct(water_source)
  
  df_water %>% distinct(water_tech)
  
  df_water %>% 
    filter(water_source == 'Borehole') %>% 
    distinct(water_tech)
  
  df_water %>% 
    filter(country_name == 'Nigeria') %>% 
    count(country_name, water_source, install_year) %>% 
    prinf()
  