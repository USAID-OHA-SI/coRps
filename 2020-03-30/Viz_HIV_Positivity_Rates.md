PEPFAR - HIV Testing Services - Positivity Rates
---

![STOP HIV - Get Tested!](https://dhcontent.org/sites/default/files/styles/568/public/2019-06/HIV-get-web.jpg?itok=APEOU31D)

Load R Packages
```{r message=FALSE}
library(tidyverse)
library(readxl)
library(scales)
library(lubridate)
library(RColorBrewer)
```

Read data

```{r}
data <- read_csv("https://raw.githubusercontent.com/USAID-OHA-SI/coRps/master/2020-03-30/FY20_MilkyWay_Testing.csv")
```

Explore the content of data

```{r}
str(data)
```

```{r}
head(data)
```

```{r}
data %>% distinct(fiscal_year)
```

```{r}
# Geography: Where are the testing being done?
data %>% 
  distinct(operatingunit, psnu)

# Number of PSNUs by OU
data %>% 
  distinct(operatingunit, psnu) %>% 
  group_by(operatingunit) %>% 
  tally()
```

```{r}
# What are the different testing modalities? 16 modalities in total
data %>% 
  distinct(modality)

# Are the same modalities being useed accross all OUs?
data %>% 
  group_by(operatingunit) %>% 
  summarise(
    n_modalities = n_distinct(modality)
  ) %>% 
  arrange(n_modalities)


# Are the same modalities being useed accross all PSNUs?
data %>% 
  group_by(operatingunit, psnu) %>% 
  summarise(
    n_modalities = n_distinct(modality),
    modalities = paste0(modality, collapse = ", ")
  ) %>% 
  arrange(operatingunit, n_modalities)
```

```{r}
# Aggregate TX_** accross HTS Modalities
data %>% 
  group_by(operatingunit, psnu) %>% 
  summarise(
    HTS_TST = sum(HTS_TST),
    HTS_TST_POS = sum(HTS_TST_POS),
    Positivity = round((HTS_TST_POS / HTS_TST * 100), 2)
  ) %>% 
  arrange(operatingunit, desc(Positivity))
```


```{r}
# Visualize Positivity by OU
data %>% 
  group_by(operatingunit, psnu) %>% 
  summarise(
    HTS_TST = sum(HTS_TST),
    HTS_TST_POS = sum(HTS_TST_POS),
    Positivity = round((HTS_TST_POS / HTS_TST * 100), 2)
  ) %>% 
  arrange(operatingunit, desc(Positivity)) %>% 
  ggplot(aes(x=reorder(psnu, desc(Positivity)), y=Positivity)) +
  geom_col(aes(fill = operatingunit), width = .8, show.legend = F) +
  geom_hline(yintercept = 0) +
  scale_fill_brewer(palette = "Accent") +
  facet_grid(. ~ operatingunit, 
             scales = "free_x", 
             space = "free") +
  labs(title = "HIV TESTING SERVICES (HTS)",
       subtitle = "Posivity Rates in Southern Atmosphere",
       caption = paste0("USAID's Office of HIV/AIDS (OHA), ", today()),
       x = "", y = "Positivity (%)") +
  theme_minimal() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    strip.text.x = element_text(face = "bold"),
    strip.placement = "outside",
    axis.text.x = element_text(angle = 30),
    title = element_text(face = "bold")
  )

#ggsave("HIV_PositivityRates.png")
  
```

![HIV Positivity Rates](HIV_PositivityRates.png)