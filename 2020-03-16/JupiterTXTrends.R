
library(tidyverse)
library(ICPIutilities)
library(scales)
library(extrafont)


df_tx %>% 
  mutate(primepartner = fct_reorder(primepartner, latest, sum, .desc = TRUE)) %>% 
  ggplot(aes(period, val, fill = primepartner)) +
  geom_col() +
  geom_hline(aes(yintercept = 0)) +
  facet_wrap(~ primepartner) +
  scale_y_continuous(label = comma) +
  scale_x_discrete(breaks = c("FY18Q1", "FY18Q3", "FY19Q1", "FY19Q3", "FY20Q1")) +
  scale_fill_brewer(type = "qual") +
  labs(x = NULL, y = NULL,
       title = "ORION SCALING UP TREATMENT",
       subtitle = "Jupiter | TX__NEW",
       caption = "FY20Q1i Training MSD") +
  theme_minimal() +
  theme(strip.text = element_text(face = "bold", size = 12),
        text = element_text(family = "Source Sans Pro"),
        title = element_text(face = "bold"),
        legend.position = "none",
        panel.grid.major.x = element_blank())

ggsave("2020-03-16/JupiterTXTrends.png", dpi = 300,
       height = 5.6, width = 7)
