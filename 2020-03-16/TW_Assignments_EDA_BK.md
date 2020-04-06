## PROJECT:  coRps
## AUTHOR:   B.Kagniniwa | USAID
## PURPOSE:  Respond to March 16th TW Assignment
## DATE:     2020-04-06

## Load R Packages


### Read data

### Examine datasets

```r
head(jupiter_data)
```

```
## # A tibble: 6 x 6
##   operatingunit indicator primepartner period   val latest
##   <chr>         <chr>     <chr>        <chr>  <dbl>  <dbl>
## 1 Jupiter       TX_NEW    Capricornus  FY18Q1   580      0
## 2 Jupiter       TX_NEW    Capricornus  FY18Q2   570      0
## 3 Jupiter       TX_NEW    Capricornus  FY18Q3   590      0
## 4 Jupiter       TX_NEW    Capricornus  FY18Q4   540      0
## 5 Jupiter       TX_NEW    Capricornus  FY19Q1   540      0
## 6 Jupiter       TX_NEW    Capricornus  FY19Q2   530      0
```


```r
glimpse(jupiter_data)
```

```
## Rows: 27
## Columns: 6
## $ operatingunit <chr> "Jupiter", "Jupiter", "Jupiter", "Jupiter", "Jupiter", "Jup...
## $ indicator     <chr> "TX_NEW", "TX_NEW", "TX_NEW", "TX_NEW", "TX_NEW", "TX_NEW",...
## $ primepartner  <chr> "Capricornus", "Capricornus", "Capricornus", "Capricornus",...
## $ period        <chr> "FY18Q1", "FY18Q2", "FY18Q3", "FY18Q4", "FY19Q1", "FY19Q2",...
## $ val           <dbl> 580, 570, 590, 540, 540, 530, 560, 550, 490, 4150, 4210, 41...
## $ latest        <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 490, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
```

How many partners are we dealing with?

```r
jupiter_data %>% 
  distinct(primepartner)
```

```
## # A tibble: 4 x 1
##   primepartner    
##   <chr>           
## 1 Capricornus     
## 2 Corona Australis
## 3 Cygnus          
## 4 Orion
```

What are the reporting periods?

```r
jupiter_data %>% 
  distinct(period)
```

```
## # A tibble: 9 x 1
##   period
##   <chr> 
## 1 FY18Q1
## 2 FY18Q2
## 3 FY18Q3
## 4 FY18Q4
## 5 FY19Q1
## 6 FY19Q2
## 7 FY19Q3
## 8 FY19Q4
## 9 FY20Q1
```

### Split period into FY & Quaters

```r
jupiter_data <- jupiter_data %>% 
  separate(period, into=c("fiscal_year", "rep_qtr"), sep = 4, remove = FALSE)
```



```r
jupiter_data %>% head()
```

```
## # A tibble: 6 x 8
##   operatingunit indicator primepartner period fiscal_year rep_qtr   val latest
##   <chr>         <chr>     <chr>        <chr>  <chr>       <chr>   <dbl>  <dbl>
## 1 Jupiter       TX_NEW    Capricornus  FY18Q1 FY18        Q1        580      0
## 2 Jupiter       TX_NEW    Capricornus  FY18Q2 FY18        Q2        570      0
## 3 Jupiter       TX_NEW    Capricornus  FY18Q3 FY18        Q3        590      0
## 4 Jupiter       TX_NEW    Capricornus  FY18Q4 FY18        Q4        540      0
## 5 Jupiter       TX_NEW    Capricornus  FY19Q1 FY19        Q1        540      0
## 6 Jupiter       TX_NEW    Capricornus  FY19Q2 FY19        Q2        530      0
```



```r
jupiter_data %>% 
  distinct(fiscal_year)
```

```
## # A tibble: 3 x 1
##   fiscal_year
##   <chr>      
## 1 FY18       
## 2 FY19       
## 3 FY20
```


```r
jupiter_data %>% 
  distinct(rep_qtr)
```

```
## # A tibble: 4 x 1
##   rep_qtr
##   <chr>  
## 1 Q1     
## 2 Q2     
## 3 Q3     
## 4 Q4
```



```r
jupiter_data %>% 
  group_by(primepartner, fiscal_year, rep_qtr) %>% 
  tally() %>% 
  filter(n < 1)
```

```
## # A tibble: 0 x 4
## # Groups:   primepartner, fiscal_year [0]
## # ... with 4 variables: primepartner <chr>, fiscal_year <chr>, rep_qtr <chr>, n <int>
```

### Visualize TX_NEW data

```r
jupiter_data %>% 
  arrange(primepartner) %>% 
  ggplot(aes(x=period, y=val)) +
  geom_col(aes(fill=primepartner), show.legend = FALSE) +
  scale_x_discrete(labels = function(labels) {
    fixedLabels <- c()
    for (l in 1:length(labels)) {
      fixedLabels[l] <- paste0(ifelse(l %% 2 == 0, '', '\n'), labels[l])
    }
    return(fixedLabels)
  }) +
  scale_y_continuous(labels = comma) +
  scale_fill_brewer(palette = "Accent") +
  geom_hline(yintercept = 0, size = .5) +
  facet_wrap(~ factor(primepartner, levels = c("Orion","Capricornus","Cygnus","Corona Australis")), nrow = 2) +
  labs(title = "ORION IS SCALING UP TESTING", 
       subtitle = "Jupiter | TX_NEW",
       caption = paste0("USAID's Office of HIV/AIDS (OHA), ", today()),
       x = NULL, 
       y = NULL) +
  theme_minimal() +
  theme(panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        strip.text.x = element_text(face = "bold"),
        title = element_text(face = "bold"))
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12-1.png)


```r
jupiter_data %>% 
  ggplot(aes(x=rep_qtr, y=val)) +
  geom_col(aes(fill=primepartner), show.legend = FALSE) +
  geom_hline(yintercept = 0, size = .5) +
  scale_y_continuous(labels = comma) +
  scale_fill_brewer(palette = "Accent") +
  facet_grid(factor(fiscal_year, levels = c("FY20", "FY19", "FY18")) ~ factor(primepartner, levels = c("Orion","Capricornus","Cygnus","Corona Australis"))) +
  labs(title = "SCALING UP TREATMENT", 
       subtitle = "Jupiter | TX_NEW",
       caption = paste0("USAID's Office of HIV/AIDS (OHA), ", today()),
       x = NULL, 
       y = NULL) +
  theme_minimal() +
  theme(panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        strip.text = element_text(face = "bold"),
        title = element_text(face = "bold"))
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13-1.png)
