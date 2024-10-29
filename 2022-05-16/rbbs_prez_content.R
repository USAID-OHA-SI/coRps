library(tidyverse)
library(TrainingDataset) #remotes::install_github("ICPI/TrainingDataset")
library(glamr)
library(scales)
library(package)
library(glue)

set.seed(42)
df_sect1 <- tibble(facility = replicate(10, gen_sitename()),
       targets = sample(20:80, 10, replace = TRUE),
       cumulative = round(targets * runif(10, min = .77, max = 1.1)))

df_sect2 <- tibble(facility = replicate(5, gen_sitename()),
             targets = sample(300:600, 5, replace = TRUE),
             cumulative = round(targets * runif(5, min = .77, max = 1.1)))

df_sect1 %>% 
  mutate(achievement = cumulative / targets,
         achv_disp = percent(achievement, 1))

achv <- function(df){
  df %>% 
    mutate(achievement = cumulative / targets,
           achv_disp = percent(achievement, 1)) %>% 
    arrange(desc(targets))
}

agg_achv <- function(df, low_lvl = .75){
  sect_achv <- df %>% 
    summarise(cumulative = sum(cumulative),
              achievement = sum(cumulative) / sum(targets))
  
  if(sect_achv < low_lvl){
    usethis::ui_warn("Sector only achieved {comma(sect_achv$cumulative)} results, only {percent(sect_achv$achievement,1)} of target achievement")
  } else {
    usethis::ui_info("{percent(sect_achv$achievement,1)} of sector's targets achieved")
  }

}

achv(df_sect1)
achv(df_sect2)


map_dfr(.x = files,
        .f = ~ read_msd(.x) %>% 
          filter(indicator == "TX_CURR",
                 standardizeddisaggregate == "Total Numerator"))

agg_achv(df_sect1)


set.seed(42)
df_sect3 <- tibble(facility = replicate(10, gen_sitename()),
       hts_tst = sample(300:600, 10, replace = TRUE),
       hts_tst_pos = round(runif(10, .01, .18) * hts_tst, 0),
       tx_new = round(runif(10, .79, 1) * hts_tst_pos))

mean(df_sect3$hts_tst)
mean(df_sect3$hts_tst_pos)
mean(df_sect3$tx_new)

#remove the facility (character) column
df_sect3 <- df_sect3[-1]

output <- vector("double", ncol(df_sect3))  # 1. output
for (i in seq_along(df_sect3)) {            # 2. sequence
  output[[i]] <- mean(df_sect3[[i]])            # 3. body
}
output
      

map_dbl(.x = df_sect3, .f = mean)

ls(package:purrr)


map2_chr(.x = pepfar_country_list$operatingunit,
         .y = pepfar_country_list$country,
         .f = ~ ifelse(.x == .y, .x, glue("{.x}/{.y}")))



list.files(si_path())

count(country, orgunituid, wt = cumulative) %>% 
  pivot_wider(names_from = indicator,
              values_from = n)
         