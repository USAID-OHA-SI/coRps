# PROJECT:  agitprop
# AUTHOR:   A.Chafetz | USAID
# PURPOSE:  COVID Stringency Index + MER Trends
# LICENSE:  MIT
# DATE:     2021-05-14
# UPDATED:  2021-06-29
# NOTE:     based on code from agitrpop/17b_stringency_mer

# DEPENDENCIES ------------------------------------------------------------

  library(tidyverse)
  library(glitr)
  library(glamr)
  library(ICPIutilities)
  library(extrafont)
  library(scales)
  library(tidytext)
  library(patchwork)
  library(ggtext)
  library(glue)
  library(countrycode)
  library(ISOcodes)
  library(lubridate)
  library(COVIDutilities)
  library(jsonlite)
  library(zoo)
  library(usethis)


# GLOBAL VARIABLES --------------------------------------------------------


  authors <- c("Aaron Chafetz")
  
  load_secrets()
  
  #Stringency Index API url - start/end date 
  ox_start <- "2020-01-01"
  ox_end <- "2021-04-01"
  url_ox <- paste("https://covidtrackerapi.bsg.ox.ac.uk/api/v2/stringency/date-range",
                  ox_start, ox_end, sep = "/")
  
  #quarter starts (for viz)
  qtrs <- seq.Date(as.Date("2019-01-01"), as.Date(ox_end), by = "3 months")
  
  rm(ox_end, ox_start)
  
  msd_source <- "FY21Q2c"
  
# IMPORT ------------------------------------------------------------------
  
  #MER data
  df <- si_path() %>% 
    return_latest("OU_IM") %>% 
    read_rds() 
  
  #MER country iso codes
  df_meta <- get_outable(datim_user(), datim_pwd()) %>%
    select(countryname, countryname_iso)
  
  #Government Response (Oxford - https://covidtracker.bsg.ox.ac.uk/about-api)
  json <- url_ox %>%
    jsonlite::fromJSON(flatten = TRUE)
  
  #COVID cases (JHU)
  df_covid <- pull_jhu_covid()
  
# MUNGE OXFORD DATA -------------------------------------------------------
  
  #covert from json to dataframe
  df_stringency <- json %>%
    unlist() %>%
    enframe()
  
  #clean up table
  df_stringency <- df_stringency %>% 
    rowwise() %>%
    mutate(
      parts = length(unlist(str_split(name, "[.]"))),
      tbl = first(unlist(str_split(name, "[.]"))),
      tbl = gsub("\\d", "", tbl)
    ) %>%
    filter(parts == 4) %>%    # Keep the data, section with the longest parts
    separate(name,
             into = c("name", "date", "iso", "variable"),
             sep = "[.]") %>%                   # Separate column into multiple parts
    select(date:value) %>%               # Get rid of extra columns
    filter(date != value, iso != value) %>%     # Exclude repetition
    mutate(date = ymd(date), value = as.numeric(value)) %>% 
    spread(variable, value) %>% 
    select(-contains("legacy"))
  
  #add colors from FT - https://ig.ft.com/coronavirus-lockdowns/)
  df_stringency <- df_stringency %>% 
    mutate(bins = case_when(is.na(stringency)  ~ "NA",
                            stringency < 1     ~ "<1",
                            stringency < 25    ~ "1-24",
                            stringency < 50    ~ "25-49",
                            stringency < 75    ~ "50-74",
                            stringency < 85    ~ "75-84",
                            TRUE               ~ "85-100"),
           color = case_when(is.na(stringency) ~ "#D9CDC3",
                             stringency < 1    ~ "#D3E8F0",
                             stringency < 25   ~ "#FAE1AF",
                             stringency < 50   ~ "#FDAC7A",
                             stringency < 75   ~ "#F6736B",
                             stringency < 85   ~ "#DA3C6A",
                             TRUE              ~ "#A90773"
           ))
  
  #filter to PEPFAR countries
  df_stringency <- df_stringency %>% 
    filter(iso %in% df_meta$countryname_iso)
  
  #add country name
  df_stringency <- df_stringency %>% 
    left_join(df_meta, by = c("iso" = "countryname_iso"))
  
  #order colors
  df_stringency <- df_stringency %>% 
    mutate(bins = factor(bins, c("NA","<1", "1-24", "25-49", "50-74", "75-84", "85-100")),
           color = factor(color, c("#D9CDC3", "#D3E8F0","#FAE1AF", "#FDAC7A", "#F6736B", "#DA3C6A", "#A90773")))
  
  #order vars
  df_stringency <- df_stringency %>% 
    select(-c(confirmed, deaths, stringency_actual)) %>% 
    select(date, countryname, iso, everything())
  
  rm(json)
  
# MUNGE COVID DATA --------------------------------------------------------
  
  #add ISO codes
  df_covid <- ISO_3166_1 %>% 
    select(Name, iso = Alpha_3) %>%
    mutate(Name = recode(Name, 
                         "Congo, The Democratic Republic of the" = "Congo (Kinshasa)",
                         "Myanmar" = "Burma",
                         "Lao People's Democratic Republic" = "Laos",
                         "Tanzania, United Republic of" = "Tanzania",
                         "Viet Nam" = "Vietnam"),
           Name = ifelse(str_detect(Name, "Ivoire"), "Cote d'Ivoire", Name)) %>% 
    left_join(df_covid, ., by = c("countryname" = "Name")) %>% 
    mutate(countryname = recode(countryname, 
                                "Congo (Kinshasa)" = "Democratic Republic of the Congo"))
  
  #filter to just PEPFAR countries
  df_covid_pepfar <- df_covid %>% 
    filter(iso %in% df_meta$countryname_iso)
  
  #create a rolling average
  df_covid_pepfar <- df_covid_pepfar %>% 
    arrange(date) %>% 
    group_by(countryname) %>% 
    mutate(rollingavg_7day = rollmean(daily_cases, 7, fill = NA, align = c("right"))) %>% 
    ungroup() 
  
  #10th case
  df_tenthcase_date <- df_covid_pepfar %>% 
    filter(tenth_case == 1) %>% 
    group_by(iso) %>% 
    filter(date == min(date)) %>% 
    ungroup() %>% 
    select(iso, date, tenth_case)   
  
  
  
# MUNGE MER ---------------------------------------------------------------
  
  #select indicator and reshape long
  df_mer <- df %>% 
    filter(indicator %in% c("HTS_TST", "HTS_TST_POS","TX_NEW", "TX_CURR", "TX_PVLS", "VMMC_CIRC"),
           standardizeddisaggregate %in% c("Total Numerator", "Total Denominator", "Age/Sex/ARVDispense/HIVStatus"),
           otherdisaggregate %in% c(NA, "ARV Dispensing Quantity - 3 to 5 months", "ARV Dispensing Quantity - 6 or more months"),
           fiscal_year >= 2019,
           mech_code != "16772") %>% 
    mutate(indicator = ifelse(standardizeddisaggregate == "Age/Sex/ARVDispense/HIVStatus", "TX_MMD_o3mo", indicator)) %>% 
    clean_indicator() %>% 
    group_by(fiscal_year, indicator, countryname) %>% 
    summarise(across(starts_with("qtr"), sum, na.rm = TRUE), .groups = "drop") %>% 
    reshape_msd() %>% 
    select(-period_type)
  
  #adjust quarters to dates for working with COVID data
  df_mer <- df_mer %>% 
    mutate(date = period %>% 
             str_remove("FY") %>% 
             yq(), .after = period)
  
  
# MERGE -------------------------------------------------------------------
  
  df_stringency_viz <- df_stringency %>% 
    left_join(df_tenthcase_date) %>% 
    select(date, countryname, stringency, bins, color, tenth_case)
  
  
  df_early <- expand.grid(countryname = unique(df_mer$countryname),
                          date = seq.Date(min(df_mer$date), (min(df_stringency_viz$date)- days(1)), by = "day"),
                          color = "#D9CDC3") %>%
    as_tibble() %>%
    mutate(across(c(countryname, color), as.character))
  
  
  df_viz <- df_stringency_viz %>% 
    bind_rows(df_early) %>%
    tidylog::full_join(df_mer %>%
                         pivot_wider(names_from = indicator)) %>% 
    mutate(countryname = recode(countryname, "Democratic Republic of the Congo" = "DRC"))
  
  df_viz <- df_viz %>% 
    mutate(VLS = TX_PVLS/TX_PVLS_D,
           TX_MMD_o3mo_share = TX_MMD_o3mo/TX_CURR)
  
  df_viz <- df_viz %>% 
    pivot_longer(-date:-period,
                 names_to = "indicator")
  
  df_dates <- df_mer %>% 
    distinct(period, date) %>% 
    arrange(date) %>% 
    mutate(fy = str_sub(period, end = -3)) %>% 
    filter(str_detect(period, "Q1"))
  
  lst_mmd_order <- df_viz %>% 
    filter(date == max(date),
           indicator == "TX_CURR",
           !countryname %in% c("South Africa", "Namibia")) %>% 
    arrange(desc(value)) %>% 
    pull(countryname)
  
  plot_mer_stringency <- function(ind_sel, n_countries = 16, save = FALSE){
    
    if(str_detect({ind_sel}, "MMD")){
      df_viz <-  filter(df_viz, date >= "2020-01-01")
      df_dates <- filter(df_dates, date >= "2020-01-01")
    }
    
    df_viz <- filter(df_viz, indicator == {ind_sel})
    
    
    #latest value for ordering
    lst_lrg <- df_viz %>% 
      filter(date == max(date)) %>% 
      slice_max(order_by = value, n = n_countries) %>% 
      pull(countryname)
    
    if(str_detect({ind_sel}, "MMD"))
      lst_lrg <- lst_mmd_order[1:n_countries]
    
    df_viz <- df_viz %>% 
      filter(countryname %in% lst_lrg) %>% 
      mutate(countryname = factor(countryname, lst_lrg)) 
    
    v <- df_viz %>% 
      ggplot(aes(date, value), na.rm = TRUE) +
      geom_area(alpha = .4, color = genoa, fill = genoa_light, na.rm = TRUE) +
      geom_vline(data = filter(df_viz, tenth_case ==1, countryname %in% lst_lrg),
                 aes(xintercept = date), color = "#909090", linetype = "dotted", na.rm = TRUE) +
      geom_vline(xintercept = df_dates$date, color = "white") +
      geom_rug(aes(color = color), sides="b", na.rm = TRUE) +
      facet_wrap(~countryname, nrow = 1) +
      scale_y_continuous(labels = comma) +
      scale_x_date(breaks = as.Date(df_dates$date), labels = df_dates$fy) +
      expand_limits(y = 1) +
      scale_color_identity() +
      labs(x = NULL, y = NULL,
           subtitle = glue("{ind_sel} in the largest {n_countries} countries + COVID Stringency")) +
      si_style_ygrid() +
      theme(panel.spacing.x = unit(.5, "lines"),
            panel.spacing.y = unit(.5, "lines"))
    
    if(save == TRUE){
      file_out <- glue("Graphics/17b_covid_{ind_sel}_trends.svg")
      usethis::ui_info("saving to {ui_field(file_out)}")
      si_save(file_out, plot = v)
    }
    
    return(v)
  }
  
  v_mer <- plot_mer_stringency("TX_NEW", n_countries = 5)
  
  
  lst_viz_ctry <- df_viz %>%
    filter(date == max(date),
           indicator == ind_sel) %>% 
    slice_max(order_by = value, n = n_countries) %>% 
    pull(countryname)
  
  df_viz_covid <- df_covid_pepfar %>% 
    select(countryname, date, daily_cases, rollingavg_7day) %>% 
    filter(countryname %in%  lst_viz_ctry) %>% 
    left_join(., df_stringency) %>% 
    mutate(countryname = factor(countryname, lst_viz_ctry))
    
  v_covid <- df_viz_covid %>% 
    filter(date >= "2020-03-01") %>%
    ggplot(aes(date, daily_cases)) +
    annotate(geom = "rect",
             xmin = as.Date("2021-01-01"),
             xmax = as.Date("2021-04-01"),
             ymin = 0,
             ymax = Inf,
             color = trolley_grey_light, alpha = .1) +
    geom_col(fill = burnt_sienna, alpha = .8, na.rm = TRUE) +
    geom_hline(aes(yintercept = 0), size = 0.5, color = grey20k) +
    geom_line(aes(y = rollingavg_7day), color = si_palettes$burnt_siennas[7], #size = 1,
              na.rm = TRUE) +
    facet_wrap(~countryname, scales = "free_y",
               nrow = 1) + 
    scale_y_continuous(label = comma) +
    scale_x_date(breaks = as.Date(df_dates$date), labels = df_dates$fy,
                 limits = c(min(df_viz$date), max(df_viz$date))) +
    labs(x = NULL, y = NULL, fill = "Stringency Index",
         subtitle = "Daily COVID cases",
         # caption = glue("Source: Source: JHU COVID-19 feed [{today()}]
         #              SI analytics: {paste(authors, collapse = '/')}
         #             US Agency for International Development")
         ) +
    si_style_ygrid() +
    theme(strip.text = element_blank(),
          panel.spacing.x = unit(.5, "line"),
          panel.spacing.y = unit(.5, "line"))

  v_mer/v_covid +
    plot_layout(heights = c(2, 1)) +
    plot_annotation(title = 'INTITIAL DECLINES IN NEWLY INITIATED IN MANY OF THE LARGEST PEPFAR COUNTRIES DURING COVID',
                    caption = glue("Source: Sources: {msd_source}, JHU COVID-19 feed, Stringency Index from  Oxford University [{today()}]
                       SI analytics: {paste(authors, collapse = '/')}
                       US Agency for International Development"),
                    theme = si_style())

  si_save("Graphics/FY21Q2_TXNEW_COVID_trends.svg")    
  
  
  