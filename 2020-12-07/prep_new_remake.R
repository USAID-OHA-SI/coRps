# Purpose: Show the process of making the PrEP_NEW plot
# Author: Tim Essam | SIEI
# Date: 2020-12-07
# Notes: coRps Session


# GLOBALS -----------------------------------------------------------------

  library(tidyverse)
  library(glitr)
  library(glamr)
  library(gisr)
  library(here)
  library(extrafontdb)
  library(scales)

  data_path <- "../Zambezi/Data/"
  graphics <- "../Zambezi/Graphics"

  # Link to graphic and slide deck
  #https://docs.google.com/presentation/d/1rMVUigEPQpiLlJFEUBLmLwQw6WWGwVGui-b030MbVpg/edit?usp=sharing

# LOAD & MUNGE DATA ---------------------------------------------------------------
  
  prep19 <- readxl::read_excel(file.path(data_path, "DISCOVER-Health OHA PrEP Template FY19.xlsx"))  
  prep20 <- readxl::read_excel(file.path(data_path, "DISCOVER-Health OHA PrEP Template FY20.xlsx")) 
  
  # PrEP_NEW is the indictor we are looking for to plot over time
  prep19_long <-
    prep19 %>%
    pivot_longer(cols = fy19_Oct:fy19_Sept,
                 # names_pattern  = "(....)_(.*)",
                 names_to = c("period"),
                 values_to = "val") %>%
    mutate(period = str_replace_all(period, "fy", "FY"),
           period = fct_inorder(period))
  
  prep19_long %>%
    filter(indicator == "PrEP_NEW") %>%
    group_by(period, Sex_KP) %>%
    summarise(val = sum(val, na.rm = T)) %>%
    spread(Sex_KP, val) %>%
    prinf()
  
  
  prep20_long <- 
    prep20 %>% select(-c(fy19_Oct:fy19_Sept))%>% 
    pivot_longer(cols = FY20_Oct:FY20_Sept,
                 #names_pattern  = "(....)_(.*)",
                 names_to = ("period"),
                 values_to = "val") %>% 
    mutate(period = fct_inorder(period))
  
  # Combine data frames
  prep_all_long <-
    bind_rows(prep19_long, prep20_long) 
  
  # Create a dataframe with dates so plot is easy to make w/ a date x-var
  start_date <- as.Date("2018/10/1")
  end_date <- as.Date("2020/09/01")
  dates_fy <- data.frame(date = seq(start_date, end_date, "months")) %>% 
    mutate(date_order = row_number(),
           fy = if_else(date < "2019/10/1", "fy19", "fy20"))
  
  # Create a filtered and collapsed data frame of only PrEP_NEW for plot
  # Grouping by male and female for the final plot
  # Flagging significant dates for where scaling
  prep_new <- 
    prep_all_long %>% 
    filter(indicator == "PrEP_NEW",
           Sex_KP != "kvp") %>% 
    group_by(period, Sex_KP) %>% 
    summarise(val = sum(val, na.rm = T)) %>% 
    spread(Sex_KP, val) %>% 
    ungroup()  %>% 
    mutate(total = female + male,
           date_order = row_number(),
           period = str_replace_all(period, "_", "-"),
           n = 1,
           events = if_else(date_order %in% c(6, 9, 11, 13, 15),
                            total, 0),
           period = fct_inorder(period)) %>%  
    left_join(., dates_fy, by = c("date_order"))
  
  # First Iteration
  prep_new %>% 
    ggplot(aes(x = date, y = total)) +
    geom_line()

  # Second Iteration - add in events
  prep_new %>% 
    #filter(date_order != 24) %>% 
    mutate(bar = if_else(events == scooter, total, 0)) %>% 
    ggplot(aes(x = date)) + 
    geom_col(aes(y = events), fill = grey10k, alpha = 0.5, width = 10) +
    geom_line(aes(y = total), alpha = 0.75, size = 1) +
    si_style()
  
  # Third Iteration - what about COVID-19? Let's add that in as well as that seem important
  prep_new %>% 
    #filter(date_order != 24) %>% 
    mutate(bar = if_else(events == scooter, total, 0)) %>% 
    ggplot(aes(x = date)) + 
    geom_col(aes(y = events), fill = grey10k) +
    geom_area(data = . %>% filter(date_order >= 18), aes(y = total), fill = grey10k) +
    geom_line(aes(y = total), alpha = 0.75, size = 1) +
    si_style()
  
  # Things to fix: Bars are too wide, time series plots is a bit bland. Let's add dots, color and fix bars
  prep_new %>% 
    #filter(date_order != 24) %>% 
    mutate(bar = if_else(events == scooter, total, 0)) %>% 
    ggplot(aes(x = date)) + 
    geom_col(aes(y = events), fill = grey10k, alpha = 0.5, width = 10) +
    geom_area(data = . %>% filter(date_order >= 18), aes(y = total), fill = grey10k) +
    geom_line(aes(y = total), color = scooter, alpha = 0.75, size = 1) +
    geom_point(aes(y = total), fill = scooter, shape = 21, size = 4, color = "white") +
    si_style()
  
  # Bars look distracting, let's remove and add in male / female lines. Lighten the fill on the COVID part
  
  # Spent a fair amount of time figuring out what colors to use too -- lighter so as not to distract from main point.
  si_rampr("burnt_siennas") %>% show_col()
  si_rampr("moody_blues") %>% show_col()
  
  prep_new %>% 
    #filter(date_order != 24) %>% 
    mutate(bar = if_else(events == scooter, total, 0)) %>% 
    ggplot(aes(x = date)) + 
    #geom_col(aes(y = events), fill = grey10k, alpha = 0.5, width = 10) +
    geom_area(data = . %>% filter(date_order >= 18), aes(y = total), fill = grey10k) +
    geom_line(aes(y = total), color = scooter, alpha = 0.75, size = 1) +
    geom_line(aes(y = male), color = "#ffd4ac") +
    geom_line(aes(y = female), color = "#e9ddff") +
    geom_point(aes(y = total), fill = scooter, shape = 21, size = 4, color = "white") +
    si_style()

  
  # Still feels bland. Time to add in labels to the points, fix the x-axis, lighten the COVID-19 fill area and touch up
  # Add in title and source
  prep_new %>% 
    #filter(date_order != 24) %>% 
    mutate(bar = if_else(events == scooter, total, 0)) %>% 
    ggplot(aes(x = date)) + 
    #geom_col(aes(y = events), fill = grey10k, alpha = 0.5, width = 10) +
    geom_area(data = . %>% filter(date_order >= 18), aes(y = total), fill = grey10k, alpha = 0.25) +
    geom_line(aes(y = total), color = scooter, alpha = 0.75, size = 1) +
    geom_line(aes(y = male), color = "#ffd4ac", size = 0.5) +
    geom_line(aes(y = female), color = "#e9ddff", size = 0.5) +
    geom_point(aes(y = total), fill = scooter, shape = 21, size = 4, color = "white") +
    ggrepel::geom_label_repel(aes(y = total, label = scales::comma(total, accuracy = 1), color = scooter),
                              segment.size = 0,
                              point.padding = 0.25,
                              nudge_y = 10,
                              family = "Source Sans Pro",
                              label.size = NA) +
    scale_fill_identity() +
    scale_color_identity() +
    #3200 or 1500 depending on filter above
    scale_y_continuous(limits = c(0, 3200), expand = c(0, 0)) +
    scale_x_date(date_breaks = "1 month", date_labels = "%b %y", 
                 limits = as.Date(c("2018-09-15", "2020-09-15")), 
                 expand = c(0,0)) +
    si_style_xline() +
    labs(x = NULL, y = NULL,
         title = "FY2018 - 2020: DEMAND CREATION FOR PREP YIELDS RESULTS",
         caption = "Source: FY19 & FY20 DISCOVER PrEP Database") +
    theme(axis.text.y = element_blank())

  # NOW -- Export to png and insert in Google Slides. Annotate within slides.
  si_save(here(graphics, "FY20_PrEP_demand_creation_REMAKE.png"),
          width = 13,
          height = 6, 
          dpi = "retina")
  
  
  
  