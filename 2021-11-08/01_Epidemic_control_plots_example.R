# PURPOSE: Munge and Analysis of UNAIDS Data for coRps
# AUTHOR: Tim Essam | SI
# LICENSE: MIT
# DATE: 2021-11-08
# NOTES: 

# LOCALS & SETUP ============================================================================

  # Libraries
    library(glitr)
    library(glamr)
    library(gisr)
    library(tidyverse)
    library(gophr)
    library(scales)
    library(sf)
    library(extrafont)
    library(tidytext)


# SETUP ============================================================================  

  load_secrets()

  remotes::install_github("https://github.com/USAID-OHA-SI/mindthegap", ref = "unaids-data")
  library(mindthegap)

  # What am I looking for again?
  ls('package:mindthegap')

  ?munge_unaids
  


# FETCH DATA ============================================================================
  #start_time <- Sys.time()
  df <- munge_unaids("HIV Estimates", "Integer")
  #end_time <- Sys.time()

  
# MUNGE DATA ============================================================================

  glimpse(df)
  
  df %>% count(indicator)
  df %>% count(pepfar)
  df %>% count(age, sex, year, stat)
  
  
  # Want to keep only Epi control indicators
  df_viz <- 
    df %>% 
    filter(str_detect(indicator, "(AIDS|HIV Infections)"),
           age == "all", 
           sex == "all", 
           stat == "est")
  
  
  # Check if Global numbers are included or do we need to aggregate?
  df_viz %>% 
    filter(str_detect(country, "Global")) %>% 
    count(country, indicator, age, sex, stat, year)
  
  # Let's go ahead and make the global data frame from the df_viz one for ease
  df_viz_glbl <- 
    df_viz %>% 
    filter(str_detect(country, "Global"))
  
  
  # Let's make a PEPFAR total as well for comparison.
  df_viz_pepfar <-  
    df_viz %>% 
    filter(pepfar == "PEPFAR") %>% 
    group_by(indicator, year, stat, sex, age) %>% 
    summarise(value = sum(value, na.rm = T)) %>% 
    ungroup()
    
  # So now we have 3 datasets we can use to make differnt types of graphs.
  # df_viz contains all countries in the UNAIDS database + regions
  # df_viz_glbl is df_viz filtered to just the global data
  # df_viz_pepfar is df_viz filtered to PEPFAR countries, aggregated.
  
  # Let's Plot
  

# PLOT ==================================================================================

  # First, we'll reproduce the standard epi curve graphs we often see in the ANNUAL REport to Congress
  #https://www.state.gov/wp-content/uploads/2021/02/PEPFAR2021AnnualReporttoCongress.pdf#page=13
  
  
  # I realized the metric they use is 15+, what would we need to do to recalculate these totals? 
  # (answer to be posted later in the week)
  df %>% count(age)
  
  # What do we need? 
  # Two line graphs, where the indictor is encoded with color. Arranged by time.
  
  df_viz_glbl %>% 
    mutate(indic_color = ifelse(indicator == "New HIV Infections", denim, burnt_sienna)) %>% 
    ggplot(aes(x = year, y = value, group = indicator)) +
    geom_line()

  
  # Let's add some color
  # Will this work? Why or why not?
  df_viz_glbl %>% 
    mutate(indic_color = ifelse(indicator == "New HIV Infections", denim, burnt_sienna)) %>% 
    ggplot(aes(x = year, y = value, group = indicator, color = indic_color)) +
    geom_line()
    
  # We need to tell ggplot to use the indic_color column as the color identity
  df_viz_glbl %>% 
    mutate(indic_color = ifelse(indicator == "New HIV Infections", denim, burnt_sienna)) %>% 
    ggplot(aes(x = year, y = value, group = indicator, color = indic_color)) +
    geom_line() +
    scale_color_identity()
  
  # Let's make the lines a tad bit bigger and use an si_theme
  # Need to fix y-axis too
  df_viz_glbl %>% 
    mutate(indic_color = ifelse(indicator == "New HIV Infections", denim, burnt_sienna)) %>% 
    ggplot(aes(x = year, y = value, group = indicator, color = indic_color)) +
    geom_line(size = 1) +
    scale_color_identity() +
    si_style_ygrid() +
    scale_y_continuous(labels = label_number_si(accuracy = 0.1), breaks = seq(0, 3e6, 0.5e6))

  # The plot is ok, nothing great. Let's add some filled circles at the beginning and end
  df_viz_glbl %>% 
    mutate(indic_color = ifelse(indicator == "New HIV Infections", denim, burnt_sienna)) %>% 
    ggplot(aes(x = year, y = value, group = indicator, color = indic_color)) +
    geom_line(size = 1) +
    geom_point(data = . %>% filter(year == min(year)), size = 5, shape = 16) +
    geom_point(data = . %>% filter(year == max(year)), aes(fill = "white"),
               size = 5, shape = 21) +
    geom_text(data = . %>% filter(year == max(year)), 
              aes(label = case_when(
      indicator == "New HIV Infections" ~ label_number_si(accuracy = 0.1)(value),
      TRUE ~ label_number_si()(value)
      )), 
               size = 10/.pt, hjust = -0.5) +
    scale_color_identity() +
    scale_fill_identity() +
    si_style_ygrid() +
    scale_y_continuous(labels = label_number_si()) +
    coord_cartesian(clip = "off")
  
  # What in the world is goign on here?
  # label_number_si(accuracy = 0.1)(value)
  str(scales::label_number_si)
  
  # So we can pass a value to the function to see what we get out
  scales::label_number_si()(1e6)
  scales::label_number_si(accuracy = 0.01)(1e6)
  scales::label_number_si(accuracy = 0.1)(1000)
  
  
  # What if we preferred a financial times version of this plot?
  #https://docs.google.com/presentation/d/1VYA1vJAB7UvdEuKt1anXGBYSTfrlEGJE1CmXDcudPUg/edit#slide=id.gfb3152f7cc_1_173
  
  # We'll need to make the deaths indicator negative to plot it in the "upside down world"
  df_viz_glbl %>% 
    mutate(indic_color = ifelse(indicator == "New HIV Infections", denim, burnt_sienna),
           indic_fill = ifelse(indicator == "New HIV Infections", denim_light, burnt_sienna_light),
           ft_value = ifelse(indicator == "New HIV Infections", value, -value)) %>% 
    ggplot(aes(x = year, y = ft_value, group = indicator, color = indic_color)) +
    geom_area(aes(fill = indic_fill)) +
    geom_line(size = 1) 
  
  
  # What do we need to do?
  # We'll need to make the deaths indicator negative to plot it in the "upside down world"
  df_viz_glbl %>% 
    mutate(indic_color = ifelse(indicator == "New HIV Infections", denim, burnt_sienna),
           indic_fill = ifelse(indicator == "New HIV Infections", denim_light, burnt_sienna_light),
           ft_value = ifelse(indicator == "New HIV Infections", value, -value)) %>% 
    ggplot(aes(x = year, y = ft_value, group = indicator, color = indic_color)) +
    geom_area(aes(fill = indic_fill)) +
    geom_line(size = 1) +
    geom_text(data = . %>% filter(year == max(year)), 
              aes(label = case_when(
                indicator == "New HIV Infections" ~ label_number_si(accuracy = 0.1)(value),
                TRUE ~ label_number_si()(value)
              )), 
              size = 10/.pt, hjust = -0.5) +
    scale_color_identity() +
    scale_fill_identity() +
    si_style_ygrid() +
    scale_y_continuous(labels = label_number_si()) +
    coord_cartesian(clip = "off")
  
  # What if we wanted to plot the epi gap?
  df_viz_glbl %>% 
    mutate(indic_color = ifelse(indicator == "New HIV Infections", denim, burnt_sienna),
           indic_fill = ifelse(indicator == "New HIV Infections", denim_light, burnt_sienna_light),
           ft_value = ifelse(indicator == "New HIV Infections", value, -value)) %>% 
    group_by(year) %>% 
    mutate(gap = value - lag(value)) %>% 
    ungroup() %>% 
    ggplot(aes(x = year, y = ft_value, group = indicator, color = indic_color)) +
    geom_area(aes(fill = indic_fill), alpha = 0.75) +
    geom_line(size = 1) +
    geom_line(aes(y = gap), color = "white", size = 0.75) +
    geom_hline(yintercept = 0, color = grey90k, size = 0.75)+
    geom_text(data = . %>% filter(year == max(year)), 
              aes(label = case_when(
                indicator == "New HIV Infections" ~ label_number_si(accuracy = 0.1)(value),
                TRUE ~ label_number_si()(value)
              )), 
              size = 12/.pt, hjust = -0.5, family = "Source Sans Pro SemiBold") +
    geom_text(data = . %>% filter(indicator == "New HIV Infections", year == max(year)), 
              aes(y = gap, label = paste("Epidemic Control Gap\n", label_number_si()(gap))),
              size = 12/.pt, hjust = 1, vjust = 1.25, color = grey50k,
              family = "Source Sans Pro SemiBold") +
    scale_color_identity() +
    scale_fill_identity() +
    si_style_ygrid() +
    scale_y_continuous(labels = label_number_si()) +
    scale_x_continuous(limits = c(1990, 2021))+
    coord_cartesian(clip = "on") +
    labs(title = "TO BE COMPLETED WITH TITLE INTEGRATING LEGEND", x = NULL, y = NULL)
  
  # Make it a function to take different data frames
  
    epi_plot <- function(df){
      df %>% 
        mutate(indic_color = ifelse(indicator == "New HIV Infections", denim, burnt_sienna),
               indic_fill = ifelse(indicator == "New HIV Infections", denim_light, burnt_sienna_light),
               ft_value = ifelse(indicator == "New HIV Infections", value, -value)) %>% 
        group_by(year) %>% 
        mutate(gap = value - lag(value)) %>% 
        ungroup() %>% 
        ggplot(aes(x = year, y = ft_value, group = indicator, color = indic_color)) +
        geom_area(aes(fill = indic_fill), alpha = 0.75) +
        geom_line(size = 1) +
        geom_line(aes(y = gap), color = "white", size = 0.75) +
        geom_hline(yintercept = 0, color = grey90k, size = 0.75)+
        geom_text(data = . %>% filter(year == max(year)), 
                  aes(label = case_when(
                    indicator == "New HIV Infections" ~ label_number_si(accuracy = 0.1)(value),
                    TRUE ~ label_number_si()(value)
                  )), 
                  size = 12/.pt, hjust = -0.5, family = "Source Sans Pro SemiBold") +
        geom_text(data = . %>% filter(indicator == "New HIV Infections", year == max(year)), 
                  aes(y = gap, label = paste("Epidemic Control Gap\n", label_number_si()(gap))),
                  size = 12/.pt, hjust = 1, vjust = 1.25, color = grey50k,
                  family = "Source Sans Pro SemiBold") +
        scale_color_identity() +
        scale_fill_identity() +
        si_style_ygrid() +
        scale_y_continuous(labels = label_number_si()) +
        coord_cartesian(clip = "off") +
        labs(title = "TO BE COMPLETED WITH TITLE INTEGRATING LEGEND", x = NULL, y = NULL)
    }

    epi_plot(df_viz_glbl)  

    epi_plot(df_viz_pepfar)    
    