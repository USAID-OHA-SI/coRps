
# Libraries
library(tidyverse)
library(glitr)
#library(datamodelr)
library(dm)
library(nycflights13)


# NYC ----

# Datasets
flights %>% glimpse()
airlines %>% glimpse()
airports %>% glimpse()
planes %>% glimpse()
weather %>% glimpse()


# Create Data Model from data frames
df_m <- dm_from_data_frames(flights, airlines, weather, airports, planes)

# Create graph - for individual tables
graph1 <- dm_create_graph(df_m, rankdir = 'BT', col_attr = c("column", "type"))

dm_render_graph(graph = graph1)

# Create graph - related table
df_m_ref <- dm_add_references(
  dm = df_m,
  flights$carrier == airlines$carrier,
  flights$origin == airports$faa,
  flights$dest == airports$faa,
  flights$tailnum == planes$tailnum,
  weather$origin == airports$faa
)

# colors <- list(
#   denim = c("flights"),
#   scooter = c("planes", "airlines"),
#   moody = c("aiports", "weather")
# )

colors <- list(
  accent1 = c("flights"),
  accent2 = c("planes", "airlines"),
  accent3 = c("airports", "weather")
)

graph2 <- dm_create_graph(df_m_ref, 
                          rankdir = 'BT', 
                          col_attr = c("column", "type"),
                          view_type = "keys_only")

graph2 <- dm_create_graph(df_m_ref, 
                          rankdir = 'LR', 
                          col_attr = c("column", "type"),
                          view_type = "all")

graph2 <- dm_create_graph(dm_set_display(df_m_ref, colors), 
                          rankdir = 'LR', 
                          col_attr = c("column", "type"),
                          view_type = "all")

graph2 <- dm_create_graph(dm_set_display(df_m_ref, colors), 
                          #rankdir = 'LR', 
                          graph_attrs = "rankdir = LR, background = '#F4F0EF'",
                          node_attrs = "dir = both, arrow_tail = crow, arrow_head = odiamond",
                          col_attr = c("column", "type"),
                          view_type = "all")

dm_render_graph(graph = graph2)

## DM Packages ----

dm <- dm_nycflights13()

dm

dm %>% names()

dm %>% dm_draw()

dm_flatten_to_tbl(flights)

# MSD ----

dm_msd <- dm(periods = df_periods, 
             orgs = df_orgs, 
             mechanisms = df_mechs, 
             indicators = df_inds, 
             disaggregations = df_disaggs, 
             report_wide = df_report_wide, 
             report_long = df_report_long)

dm_msd

dm_msd %>% names()

dm_msd$orgs

dm_msd[c("orgs", "mechanisms")]

# Check for possible primary keys
dm_enum_pk_candidates(dm = dm_msd, table = periods)
dm_enum_pk_candidates(dm = dm_msd, table = orgs)
dm_enum_pk_candidates(dm = dm_msd, table = mechanisms)
dm_enum_pk_candidates(dm = dm_msd, table = indicators)
dm_enum_pk_candidates(dm = dm_msd, table = disaggregations)
dm_enum_pk_candidates(dm = dm_msd, table = report_wide)
dm_enum_pk_candidates(dm = dm_msd, table = report_long)

# Check uniqueness

# dm_msd$indicators %>% 
#   count(indicator, numeratordenom, indicatortype) %>% 
#   filter(n > 1)
# 
# dm_msd$disaggregations %>% 
#   count(disaggregate, standardizeddisaggregate, categoryoptioncomboname) %>% 
#   filter(n > 1)
# 
# dm_msd$report_long %>% 
#   count(period, orgunituid, mech_code, indicator, 
#         numeratordenom, indicatortype, 
#         disaggregate, standardizeddisaggregate, 
#         categoryoptioncomboname, value_type) %>% 
#   filter(n > 1)

# Assign primary keys
dm_msd_pkeys <- dm_msd %>% 
  dm_add_pk(table = periods, columns = period) %>% 
  dm_add_pk(table = orgs, columns = orgunituid) %>% 
  dm_add_pk(table = mechanisms, columns = mech_code) %>% 
  dm_add_pk(table = indicators, 
            columns = c(indicator, numeratordenom, indicatortype)) %>% 
  dm_add_pk(table = disaggregations, 
            columns = c(disaggregate, standardizeddisaggregate, 
                        categoryoptioncomboname)) 


  # dm_add_pk(table = report_wide, 
  #           columns = c(fiscal_year, orgunituid, mech_code, 
  #                       indicator, numeratordenom, indicatortype, 
  #                       disaggregate, standardizeddisaggregate, 
  #                       categoryoptioncomboname)) %>% 
  # dm_add_pk(table = report_long, 
  #           columns = c(period, orgunituid, mech_code, indicator,
  #                       numeratordenom, indicatortype, disaggregate, 
  #                       standardizeddisaggregate, categoryoptioncomboname, 
  #                       value_type)) 

dm_msd_pkeys

# Check for possible foreign keys
dm_enum_fk_candidates(dm = dm_msd, table = periods)
dm_enum_fk_candidates(dm = dm_msd, table = orgs)
dm_enum_fk_candidates(dm = dm_msd, table = mechanisms)
dm_enum_fk_candidates(dm = dm_msd, table = indicators)
dm_enum_fk_candidates(dm = dm_msd, table = disaggregations)

dm_enum_fk_candidates(dm = dm_msd_pkeys, table = report_wide, ref_table = periods)
dm_enum_fk_candidates(dm = dm_msd_pkeys, table = report_long, ref_table = periods)

dm_enum_fk_candidates(dm = dm_msd_pkeys, table = report_wide, ref_table = orgs)
dm_enum_fk_candidates(dm = dm_msd_pkeys, table = report_long, ref_table = orgs)

dm_enum_fk_candidates(dm = dm_msd_pkeys, table = report_wide, ref_table = mechanisms)
dm_enum_fk_candidates(dm = dm_msd_pkeys, table = report_long, ref_table = mechanisms)

dm_enum_fk_candidates(dm = dm_msd_pkeys, table = report_wide, ref_table = indicators)
dm_enum_fk_candidates(dm = dm_msd_pkeys, table = report_long, ref_table = indicators)

dm_enum_fk_candidates(dm = dm_msd_pkeys, table = report_wide, ref_table = disaggregations)
dm_enum_fk_candidates(dm = dm_msd_pkeys, table = report_long, ref_table = disaggregations)


# Add foreign keys
dm_msd_pfkeys <- dm_msd_pkeys %>% 
  dm_add_fk(table = report_long, columns = period, ref_table = periods) %>% 
  dm_add_fk(table = report_long, columns = orgunituid, ref_table = orgs) %>% 
  dm_add_fk(table = report_long, columns = mech_code, ref_table = mechanisms) %>% 
  dm_add_fk(table = report_long, 
            columns = c(indicator, numeratordenom, indicatortype), 
            ref_table = indicators) %>% 
  dm_add_fk(table = report_long, 
            columns = c(disaggregate, standardizeddisaggregate, 
                        categoryoptioncomboname), 
            ref_table = disaggregations)

# dm_msd_pfkeys <- dm_msd_pfkeys %>% 
#   dm_add_fk(table = report_wide, columns = fiscal_year, ref_table = periods) %>% 
#   dm_add_fk(table = report_wide, columns = orgunituid, ref_table = orgs) %>% 
#   dm_add_fk(table = report_wide, columns = mech_code, ref_table = mechanisms) %>% 
#   dm_add_fk(table = report_wide, 
#             columns = c(indicator, numeratordenom, indicatortype), 
#             ref_table = indicators) %>% 
#   dm_add_fk(table = report_wide, 
#             columns = c(disaggregate, standardizeddisaggregate, categoryoptioncomboname), 
#             ref_table = disaggregations)

dm_msd_pfkeys

# VIZ 

dm_viz0 <- dm_msd %>% 
  dm_draw(rankdir = "LR", column_types = T, view_type = "all")

dm_viz0

htmlwidgets::saveWidget(dm_viz0, file = "2022-05-09/dm_viz0.html")

webshot::webshot("2022-05-09/dm_viz0.html", 
                 file = "2022-05-09/DataModel - Tables.png",
                 zoom = 1)

dm_msd_pkeys %>% 
  dm_draw(rankdir = "LR", column_types = T, view_type = "keys_only")
 
dm_msd_pkeys %>% 
  dm_draw(rankdir = "LR", column_types = T, view_type = "all")

dm_viz1 <- dm_msd_pkeys[c("periods", "orgs", "mechanisms", "report_long")] %>% 
  dm_set_colors(
    "#1e87a5" = report_long,
    "#bfddff" = c(periods, orgs, mechanisms)
  ) %>% 
  dm_draw(rankdir = "TB", column_types = T, view_type = "all")

dm_viz1

htmlwidgets::saveWidget(dm_viz1, file = "2022-05-09/dm_viz1.html")

webshot::webshot("2022-05-09/dm_viz1.html", 
                 file = "2022-05-09/DataModel - All Tables.png",
                 vwidth = 300, vheight = 600, zoom =1)


dm_msd_pfkeys %>% 
  dm_draw(rankdir = "TB", column_types = T, view_type = "keys_only")

dm_msd_pfkeys %>% 
  dm_draw(rankdir = "TB", column_types = T, view_type = "all")

dm_viz2 <- dm_msd_pfkeys[c("periods", "orgs", "mechanisms", "report_long")] %>% 
  dm_set_colors(
    "#1e87a5" = report_long,
    "#bfddff" = c(periods, orgs, mechanisms)
  ) %>% 
  dm_draw(rankdir = "TB", column_types = T, view_type = "all") 

dm_viz2

htmlwidgets::saveWidget(dm_viz2, file = "2022-05-09/dm_viz2.html")

webshot::webshot("2022-05-09/dm_viz2.html", 
                 file = "2022-05-09/DataModel - ResultsLong to Reference Tables.png",
                 vwidth = 300, vheight = 600, zoom =1)
