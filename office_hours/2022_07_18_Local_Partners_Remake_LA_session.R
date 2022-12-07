# PROJECT: coRps Office Hours
# PURPOSE: Demonstrate how to remake local partners graphics in R and PPT to edit SVG
# AUTHOR: Tim Essam | SI
# REF ID:   f60f60ec
# LICENSE: MIT
# DATE: 2022-07-18
# NOTES: Tim Essam | SI


# BUDGET REMAKE -----------------------------------------------------------

  library(glitr)
  library(glamr)
  library(gisr)
  library(gophr)
  library(tidyverse)
  library(scales)
  library(extrafont)
  library(tidytext)
  library(googlesheets4)

  # Load google drive credentials
  load_secrets()


# LOAD THE DATA -----------------------------------------------------------

  wb_id <- "1vYtjZaLfOiahKFaV21eEgRZ_Q-U25Vz4JJAQaXjf1Pg"
  
  budget <- read_sheet(ss = wb_id, sheet = "budget")
  budget_tbd <- read_sheet(ss = wb_id, sheet = "budget_tbd")

# PLOT BUDGET -------------------------------------------------------------

  budget %>%
    mutate(
      type_order = factor(type),
      type_order = fct_reorder(type_order, order, .desc = T)
    ) %>%
    ggplot(aes(x = value, y = time, group = (type_order), fill = color)) +
    geom_col() +
    geom_vline(xintercept = c(500, 1000, 1500), color = "white", linetype = "dotted") +
    geom_vline(xintercept = c(1061), color = "black", linetype = "dotted") +
    geom_text(aes(label = percent(share, 1)),
      family = "Source Sans Pro",
      position = position_stack(),
      hjust = 1
    ) +
    scale_fill_identity() +
    scale_x_continuous(labels = unit_format(unit = "M"), position = "top") +
    si_style_nolines() +
    coord_cartesian(expand = F) +
    labs(x = NULL, y = NULL, title = "")
  
  ggsave("../../My Pictures/FY21Q1_budget_tbds_remake_part1.png",
    width = 10,
    height = 2.625,
    dpi = "retina"
  )



# PLOT BUDGET TBD ---------------------------------------------------------

  # add in example to show how to order manually
  
  budget_tbd %>%
    mutate(time = fct_reorder(time, order)) %>%
    ggplot(aes(x = time, y = value)) +
    geom_col(fill = scooter_med) +
    geom_text(aes(label = label_number(prefix = "$", suffix = " M")(value)),
      vjust = 1,
      family = "Source Sans Pro",
      color = "white",
      size = 10 / .pt
    ) +
    si_style_xline() +
    coord_cartesian(expand = F) +
    theme(axis.text.y = element_blank()) +
    labs(x = NULL, y = NULL)
  
  ggsave("../../My Pictures/FY21Q1_budget_tbds_remake_part2.svg",
    width = 10,
    height = 3.4,
    dpi = "retina"
  )
  

# EDIT SVGS IN POWERPOINT -------------------------------------------------

  # https://blogs.articulate.com/rapid-elearning/edit-svg-graphics-powerpoint/
