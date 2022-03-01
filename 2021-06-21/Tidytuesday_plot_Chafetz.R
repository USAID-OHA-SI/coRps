# PROJECT:  coRps
# AUTHOR:   A.Chafetz | USAID
# PURPOSE:  TidyTuesday Session - 2021-05-04
# LICENSE:  MIT
# DATE:     2021-06-18
# UPDATED: 

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
  library(vroom)
  library(lubridate)
  library(rnaturalearth)
  library(sf)
  library(RColorBrewer)
  library(ggridges)

# GLOBAL VARIABLES --------------------------------------------------------
  
  data_url <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-05-04/water.csv"
  
  pal <- brewer.pal(8, "Set3")
  
# IMPORT ------------------------------------------------------------------
  
  df_water <- vroom(data_url)

  glimpse(water)
  
# MUNGE -------------------------------------------------------------------

  #filter for country of interest - TZA
  df_water_tza <- df_water %>% 
    filter(country_name == "Tanzania")

  #convert to dates and make ages
  df_water_tza <- df_water_tza %>% 
    mutate(report_date = mdy(report_date),
           report_year = year(report_date),
           age = report_year - install_year,
           age = ifelse(age < 0, NA, age))

  # water_tza %>% distinct(facility_type)
  # 
  # df %>% 
  #   group_by(facility_type) %>% 
  #   mutate(max_value_label = case_when(n = max(n, na.rm = TRUE) ~ n)) %>% 
  #   ungroup()
  # 
  # 
  # geom_label(aes(label = max_value_label), na.rm = TRUE)
  # 
  # 
  # water %>% 
  #   distinct(status)
  # 
  # 
  # water_tza %>% 
  #   # filter(status_id == "y") %>% 
  #   sample_n(100) %>% 
  #   pull()
  # 
  # df_water_tza %>% 
  #   count(install_year) %>% 
  #   filter(install_year >= 1960) %>% 
  #   ggplot(aes(install_year, n)) + 
  #   geom_col()
  # 
  # skimr::skim(df_water_tza, install_year)
  # 
  # 
  # df_water_tza %>% 
  #   distinct(lat_deg, lon_deg) %>% 
  #   nrow()
  # 
  # df_dup <- df_water_tza %>% 
  #   select(lat_deg, lon_deg) %>%
  #   mutate(dup = duplicated(lat_deg, lon_deg))
  # 
  # df_water_tza %>% 
  #   bind_rows(df_dup) %>% 
  #   filter(dup == TRUE) %>% 
  #   arrange(lat_deg)
  # 
  # duplicated(df_water_tza, lat_deg, lon_deg)
  # 
  # 
  # df_water_tza %>% 
  #   filter(install_year > 1950,
  #          status_id %in% c("y", "n")) %>% 
  #   ggplot(aes(age,water_source, color = status_id)) + 
  #   geom_jitter()
  # 
  # 
  # df_water_tza %>% 
  #   filter(age <0) %>% 
  #   View()
  # 
  # 
  # 
  # df_status <- df_water_tza %>% 
  #   filter(install_year >= 1960,
  #          age > 0,
  #          status_id %in% c("y", "n")) %>% 
  #   mutate(end_year = ifelse(status_id == "n", report_year, year(today()))) %>% 
  #   select(row_id, water_source, status_id, install_year, end_year) %>% 
  #   mutate(year = year(today()))
  #   # pivot_longer(ends_with("year"), 
  #   #              names_to = c("type", NA), 
  #   #              # names_prefix = "_year", 
  #   #              names_sep = "_",
  #   #              values_to = "year")
  # 
  # 
  # df_status <- df_status %>% 
  #   bind_rows(tibble(year = 1960:year(today()))) %>% 
  #   complete(year, nesting(row_id, water_source,  status_id, install_year, end_year)) %>%
  #   group_by(row_id) %>%
  #   filter(year >= install_year,
  #          year <= end_year) %>% 
  #   ungroup() %>% 
  #   arrange(row_id) %>% 
  #   filter(!is.na(row_id))
  # 
  # 
  # df_status %>% 
  #   count(year, water_source, status_id) %>% 
  #   filter(year < 2010) %>% 
  #   mutate(n = ifelse(status_id == "n", -n, n)) %>% 
  #   ggplot(aes(year, n, fill = status_id)) +
  #   geom_col() +
  #   facet_wrap(~water_source)
  # 
  # 
  # df_poor <- df_water_tza %>% 
  #   filter(#status_id == "n",
  #     status_id %in% c('y','n'),
  #          report_year >= 2005,
  #          report_year <=2010)
  # df_poor <- df_poor %>% 
  #   st_as_sf(coords = c("lon_deg", "lat_deg"),
  #            crs = st_crs(4326)) %>% 
  #   st_transform(crs = st_crs(3857))
  # 
  # ctry_adm1 <- ne_states(country = "United Republic of Tanzania", returnclass = 'sf') %>% 
  #   st_transform(crs = st_crs(3857))
  # ctry_adm0 <- summarise(ctry_adm1, placeholder = max(min_zoom))
  # 
  # ctry_hex <- ctry_adm0 %>% 
  #   st_make_grid(what = 'polygons', cellsize = 30000, square = F) %>% 
  #   st_as_sf() 
  # 
  # #create id for merging
  # ctry_hex <- mutate(ctry_hex, id = row_number())
  # 
  # df_map <- st_join(df_poor, ctry_hex, join = st_intersects)
  # 
  # 
  # #clip hexes to country border
  # suppressWarnings(
  #   ctry_hex <- st_intersection(ctry_hex, ctry_adm0) 
  # )
  # 
  # df_map <- df_map %>% 
  #   select(-geometry) %>% 
  #   as_tibble() %>% 
  #   count(id, status_id, water_source) %>% 
  #   group_by(id, water_source) %>% 
  #   mutate(share = n/sum(n)) %>% 
  #   ungroup()
  # 
  # #join aggregated data to hex
  # df_map <- left_join(ctry_hex, df_map, by = "id")
  # 
  # df_map %>% 
  #   filter(status_id == "n") %>% 
  #   ggplot() +
  #   geom_sf(data = ctry_adm1, fill = NA, size = 1, color = "gray60") +
  #   geom_sf(aes(fill = share), alpha = .4) +
  #   # geom_sf(aes(color = status_id), alpha = .4) +
  #   facet_grid(status_id ~ water_source) +
  #   theme_void()


# Distro ------------------------------------------------------------------

df_med_age <- df_water_tza %>% 
  filter(status_id == "n") %>% 
  mutate(water_source = case_when(is.na(water_source) ~ "Unknown", 
                                  water_source == "Surface Water (River/Stream/Lake/Pond/Dam)" ~ "Surface Water",
                                  TRUE ~ water_source)) %>% 
  group_by(water_source) %>% 
  summarise(med_age = median(age, na.rm = TRUE)) %>% 
  ungroup() %>% 
  arrange(med_age) %>% 
  bind_cols(source_pal = pal)

v1 <- df_water_tza %>% 
  filter(status_id == "n") %>% 
  mutate(water_source = case_when(is.na(water_source) ~ "Unknown", 
                                  water_source == "Surface Water (River/Stream/Lake/Pond/Dam)" ~ "Surface Water",
                                  TRUE ~ water_source)) %>% 
  left_join(df_med_age, by = "water_source") %>% 
  ggplot(aes(age, fct_reorder(water_source, age, na.rm = TRUE, .desc = TRUE), color = source_pal)) +
  geom_point(alpha = .1, position = "jitter", na.rm = TRUE) +
  geom_boxplot(fill = NA, na.rm = TRUE, size = 1.2, outlier.colour = NA) +
  # scale_color_brewer(type = "qual", palette = "Set3") +
  scale_color_identity() +
  labs(x = " Age When Issue Identified", y = NULL) +
  si_style(font_plot = "Oswald") +
  theme(legend.position = "none")





v2 <- df_water_tza %>% 
  filter(status_id == "y") %>%
  mutate(water_source = case_when(is.na(water_source) ~ "Unknown", 
                                  water_source == "Surface Water (River/Stream/Lake/Pond/Dam)" ~ "Surface Water",
                                  TRUE ~ water_source),
         water_source = factor(water_source, df_med_age$water_source)) %>% 
  filter(!is.na(age),
         !is.na(water_source)) %>% 
  left_join(df_med_age, by = "water_source") %>% 
  ggplot(aes(x = age, y = water_source, fill = source_pal)) +
  geom_density_ridges(scale = 4, color = trolley_grey, alpha = .8) + 
  scale_y_discrete(expand = c(0, 0)) +     # will generally have to set the `expand` option
  scale_x_continuous(expand = c(0, 0)) +   # for both axes to remove unneeded padding
  coord_cartesian(clip = "off") + # to avoid clipping of the very top of the top ridgeline
  # scale_fill_brewer(type = "qual", palette = "Set3") +
  scale_color_identity() +
  si_style(font_plot = "Oswald") +
  theme(legend.position = "none")


v2 <- df_water_tza %>% 
  filter(status_id == "y") %>%
  count(water_source, age) %>% 
  mutate(water_source = case_when(is.na(water_source) ~ "Unknown", 
                                  water_source == "Surface Water (River/Stream/Lake/Pond/Dam)" ~ "Surface Water",
                                  TRUE ~ water_source)) %>% 
  left_join(df_med_age, by = "water_source") %>%
  mutate(water_source = factor(water_source, df_med_age$water_source),
         water_source = fct_rev(water_source),
         source_alpha = ifelse(age < med_age, .6, 1)) %>% 
  filter(!is.na(age),
         !is.na(water_source)) %>%
  ggplot(aes(x = age, y = n, fill = source_pal, alpha = source_alpha)) +
  geom_col() +
  facet_grid(fct_reorder(water_source, med_age) ~.) +
  # scale_fill_brewer(type = "qual", palette = "Set3") +
  scale_fill_identity() +
  scale_alpha_identity() +
  si_style(font_plot = "Oswald") +
  labs(x = "Age", y = "Number of Working Water Sources") +
  theme(legend.position = "none",
        panel.spacing.y = unit(.1, "line"),
        strip.text.y = element_blank())

v1 + v2 +plot_layout(widths = c(2, 1))


ctry_adm1 <- ne_states(country = "United Republic of Tanzania", returnclass = 'sf') %>% 
  st_transform(crs = st_crs(3857))

ctry_adm0 <- summarise(ctry_adm1, placeholder = max(min_zoom))

v3 <- df_water_tza %>% 
  filter(status_id == "y") %>% 
  left_join(df_med_age, by = "water_source") %>%
  mutate(water_source = factor(water_source, df_med_age$water_source),
         water_source = fct_rev(water_source),
         source_alpha = ifelse(age < med_age, .6, 1)) %>% 
  filter(!is.na(water_source)) %>% 
  st_as_sf(coords = c("lon_deg", "lat_deg"),
           crs = st_crs(4326)) %>% 
  st_transform(crs = st_crs(3857)) %>% 
  st_intersection(ctry_adm0) %>% 
  ggplot() +
  geom_sf(data = ctry_adm1, fill = NA, size = 1, color = "gray60") +
  geom_sf(aes(color = source_pal), alpha = .4) +
  facet_grid( ~ fct_reorder(water_source, med_age)) +
  scale_color_identity() +
  theme_void() +
  theme(legend.position = "none",
        strip.text.x = element_text(family = "Oswald"))

(v1 + v2)/ v3 + plot_layout(heights = c(2, 1)) +
  plot_annotation(
    title = 'POTENTIAL SOURCES OF TROUBLE',
    subtitle = "What aging water source points should Tanzania's Ministry of Water and Irrigation focus on replacing to avoid access water outages?",
    caption = 'Source: Tidy Tuesday (2021-05-04)'
  ) & theme(plot.title = element_text(family = "Oswald"),
            plot.subtitle = element_text(family = "Oswald"),
            plot.caption = element_text(family = "Oswald"))
