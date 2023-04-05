Combining tameDP targets with MSD Historical Results/Targets
================
4/5/2023

- <a href="#introduction" id="toc-introduction">Introduction</a>
- <a href="#setup" id="toc-setup">Setup</a>
- <a href="#aligning-msd-with-dp-extract"
  id="toc-aligning-msd-with-dp-extract">Aligning MSD with DP extract</a>
- <a href="#aligning-age-bands" id="toc-aligning-age-bands">Aligning age
  bands</a>

### Introduction

This vignette provides an overview for utilizing your `tame_dp()` output
by combining them with previous targets from the MER Structured Dataset
(MSD). Joining the tameDP output with the MSD allows you to perform
analytics and validations across time across historic results/targets
during the Target Setting Process.

### Setup

If you haven’t installed R or `tameDP`, you should first refer to the
[Setup
vignette](https://usaid-oha-si.github.io/tameDP/articles/setup.html) or
if you want to know more about the options for `tame_dp()`, see
[Extracting
Targets](https://usaid-oha-si.github.io/tameDP/articles/extracting-targets.html).

In addition to loading `tameDP`, we’re also going to need to
install/load a couple others. We’ll be working with some of the other
packages we installed as dependencies for `tameDP`, but we will need to
use two other packages: `here` and another custom OHA package called
`gagglr` which loads all the standard OHA packages, like `glamr`,
`glitr`, and `gophr`. Let’s install both now.

``` r
#install OHA packages
remotes::install_github("USAID-OHA-SI/gagglr", build_vignettes = TRUE)
remotes::install_github("USAID-OHA-SI/glamr", build_vignettes = TRUE)
remotes::install_github("USAID-OHA-SI/gophr", build_vignettes = TRUE)
remotes::install_github("USAID-OHA-SI/tameDP", ref="dev_msd_join", build_vignettes = TRUE)

#install packages from CRAN
  install.packages("tidyverse")
  install.packages("glue")
  install.packages("here")
```

Alright, with `gophr` installed to work with the MSD, let’s get going.

``` r
library(tameDP)
library(gophr)
library(tidyverse)
library(here)
library(glamr)
```

Please also ensure that you have your `si_paths` set up, as the R
scripts rely on this logic. If you do not have these set up, please
follow the following steps:

1.  Load the `glamr` package and run the function `si_setup()`.
    Documentation can be found
    [here](https://usaid-oha-si.github.io/glamr/articles/project-workflow.html).
2.  Load the `glamr` package and follow the steps outlined
    [here](https://usaid-oha-si.github.io/glamr/articles/project-workflow.html)
    to set up your `si_path()` using `glamr::set_paths()`

The first step is reading in the from the Data Pack target. We are going
to work with the targets out the target tabs, assuming the PSNUxIM is
not yet populated. **Remember, Windows filepaths have their slash in the
wrong direction. You will need to replace all backslashes (“/") in your
filepath with forward slashes (”/“).**

``` r
#data pack file path
dp_filepath <- here("tools/Target Setting Tool_Mozambique_MAR24_PREP.xlsx")

#process the data pack to extract the targets
df_dp <- tame_dp(dp_filepath)
```

We now have all the targets extracted from the Data Pack and stored in a
tidy dataframe called `df_dp`. We want to combine this with the MSD. You
will need to download your country’s MSD from [PEPFAR
Panorama](https://www.pepfar-panorama.org/). For our analysis, let’s
look across PSNUs so we will want to download the PSNUxIM dataset. Once
you have it downloaded, you will want to use `gophr::read_psd()` to open
the MSD.

``` r
#msd file path
msd_filepath <- glamr::si_path() %>%
  glamr::return_latest("MER_Structured_Datasets_PSNU_IM_FY21-23_20230210_v1_1_Mozambique")
#read in MSD
df_msd <- read_psd(msd_filepath)
```

### Aligning MSD with DP extract

The PSNUxIM columns has a few more columns that we need, and the tameDP
extract has one extra column: `source_processed`.

``` r
#extra column names in the MSD
setdiff(names(df_msd), names(df_dp))
```

    ##  [1] "operatingunituid"        "snu1"                   
    ##  [3] "snu1uid"                 "typemilitary"           
    ##  [5] "dreams"                  "prime_partner_name"     
    ##  [7] "funding_agency"          "mech_code"              
    ##  [9] "mech_name"               "prime_partner_duns"     
    ## [11] "prime_partner_uei"       "award_number"           
    ## [13] "indicatortype"           "disaggregate"           
    ## [15] "categoryoptioncomboname" "age_2018"               
    ## [17] "age_2019"                "trendscoarse"           
    ## [19] "statustb"                "statuscx"               
    ## [21] "hiv_treatment_status"    "otherdisaggregate_sub"  
    ## [23] "qtr1"                    "qtr2"                   
    ## [25] "qtr3"                    "qtr4"

``` r
#no exta columns in the Data Pack
setdiff(names(df_dp), names(df_msd))
```

    ## [1] "source_processed"

Additionally, the MSD has more indicators and disaggregates that aren’t
in the Data Pack. To simplify matters, we can subset, or limit, the
dataset to what we have to work with. Luckily we have a table stored in
this packaged called `msd_historic_disagg_mapping` that contains all the
indicators and their disaggregates for COP23 targets in DATIM, as well
as historic results/targets disaggs from FY21 to FY23. We can use this
mapping file to filter down the MSD.

``` r
tameDP::msd_historic_disagg_mapping
```

    ## # A tibble: 163 × 5
    ##    indicator numeratordenom standardizeddisaggregate      fiscal_year kp_disagg
    ##    <chr>     <chr>          <chr>                               <dbl> <lgl>    
    ##  1 AGYW_PREV D              Age/Sex/DREAMSBegun                  2022 FALSE    
    ##  2 AGYW_PREV D              Age/Sex/DREAMSBegun                  2023 FALSE    
    ##  3 AGYW_PREV N              Age/Sex/DREAMSPrimaryComplete        2022 FALSE    
    ##  4 AGYW_PREV N              Age/Sex/DREAMSPrimaryComplete        2023 FALSE    
    ##  5 AGYW_PREV N              Age/Sex/Time/Complete                2021 FALSE    
    ##  6 AGYW_PREV D              Age/Sex/Time/Complete                2021 FALSE    
    ##  7 AGYW_PREV N              Age/Sex/Time/Complete                2022 FALSE    
    ##  8 AGYW_PREV D              Age/Sex/Time/Complete                2022 FALSE    
    ##  9 AGYW_PREV N              Age/Sex/Time/Complete+               2021 FALSE    
    ## 10 AGYW_PREV D              Age/Sex/Time/Complete+               2021 FALSE    
    ## # … with 153 more rows

We have also created a function called `align_msd_disagg` in `tameDP`
that processes the MSD into an extract that aligns with the datapack
extract. Let’s peek behind the curtain to see how this function works:

The `align_msd_disagg()` function:

1.  Imports your PSNUxIM MSD using the `msd_filepath` and the datapack
    using the `dp_filepath`.
2.  Filters the MSD down to the column names in the `tameDP` extract
3.  Performs a `semi_join()` on the `msd_historic_disagg_mapping`
    crosswalk to filter to the correct indicator/disagg combinations by
    indicator & fiscal year.
4.  Refines the alignment with datapack depending on whether or not the
    OU sets targets at the `psnu` level or at a raised prioritization
    with a `raised_prioritization` parameter.

Here’s the basic code for what the `align_msd_disagg()` function does:
note that the function requires that we pass in the filepaths for the
MSD and datapack, and that the default `raised_prioritization` parameter
is set to FALSE.

``` r
align_msd_disagg <- function(msd_path, dp_path, raised_prioritization = FALSE) {

  #import MSD
  df_msd <- gophr::read_psd(msd_path) %>%
  gophr::resolve_knownissues()

  #run tameDP
  dp_cols <- tameDP::tame_dp(dp_path) %>%
    names()

  #if targets set at SNU1 level, grab the SNu1 and SNU1uid from MSD
  if (raised_prioritization == TRUE) {
    dp_cols <- replace(dp_cols, c(3,4), c("snu1", "snu1uid"))
  }

  #semi join with MSD mapping to limit to MSD disaggs
  df_align <- df_msd %>%
    dplyr::select(tidyr::any_of(dp_cols),funding_agency, mech_code) %>%
    dplyr::semi_join(msd_historic_disagg_mapping, by = c("indicator", "numeratordenom", "standardizeddisaggregate")) %>%
    gophr::clean_indicator()

  #if targets set at SNU1 level, rename SNU columsn back to psnu for join with dp
  if (raised_prioritization == TRUE) {
    df_align <- df_align %>%
      dplyr::rename(psnu = snu1,
                    psnuuid = snu1uid)
  }

  return(df_align)

}
```

If `raised_prioritization = TRUE`, the function will manipulate the
`dp_cols` vector that stores the column names from the datapack output
and change `psnu` and `psnuuid` to `snu1` and `snu1uid` respectively.

``` r
  #regular dp_cols
  dp_cols <- tameDP::tame_dp(dp_filepath) %>%
    names()
  dp_cols
```

    ##  [1] "operatingunit"            "country"                 
    ##  [3] "psnu"                     "psnuuid"                 
    ##  [5] "snuprioritization"        "fiscal_year"             
    ##  [7] "indicator"                "standardizeddisaggregate"
    ##  [9] "numeratordenom"           "ageasentered"            
    ## [11] "sex"                      "modality"                
    ## [13] "statushiv"                "otherdisaggregate"       
    ## [15] "cumulative"               "targets"                 
    ## [17] "source_name"              "source_processed"

``` r
  #raised prioritization
  dp_cols_raised <- replace(dp_cols, c(3,4), c("snu1", "snu1uid"))
  dp_cols_raised
```

    ##  [1] "operatingunit"            "country"                 
    ##  [3] "snu1"                     "snu1uid"                 
    ##  [5] "snuprioritization"        "fiscal_year"             
    ##  [7] "indicator"                "standardizeddisaggregate"
    ##  [9] "numeratordenom"           "ageasentered"            
    ## [11] "sex"                      "modality"                
    ## [13] "statushiv"                "otherdisaggregate"       
    ## [15] "cumulative"               "targets"                 
    ## [17] "source_name"              "source_processed"

Putting it all together, here’s how you would run the function on your
datapack extract and MSD. Since we are looking at Mozambique, an OU that
did raise their prioritization, we will set
`raised_prioritization = TRUE`.

``` r
df_align <- align_msd_disagg(msd_path = msd_filepath, dp_path = dp_filepath, raised_prioritization = TRUE) 
```

### Aligning age bands

Because the new Target Setting Tool has collapsed age bands, we will
want to adjust the age bands in the MSD in order to perform any
analytics across age. To do this, we can leverage the
`age_band_crosswalk` in the `tameDP` package, which is a data frame
containing a crosswalk of age bands from the MSD and what groups they
collapse to in the datapack.

``` r
tameDP::age_band_crosswalk
```

    ## # A tibble: 18 × 2
    ##    age_msd     age_dp
    ##    <chr>       <chr> 
    ##  1 01-04       01-09 
    ##  2 05-09       01-09 
    ##  3 10-14       10-14 
    ##  4 15-19       15-24 
    ##  5 20-24       15-24 
    ##  6 25-29       25-34 
    ##  7 30-34       25-34 
    ##  8 35-39       35-49 
    ##  9 40-44       35-49 
    ## 10 45-49       35-49 
    ## 11 50+         50+   
    ## 12 50-54       50+   
    ## 13 55-59       50+   
    ## 14 60-64       50+   
    ## 15 65+         50+   
    ## 16 <01         <01   
    ## 17 <10         <NA>  
    ## 18 Unknown Age <NA>

We also created a function in `tameDP` called `align_ageband()` which
maps in the age bands from the `age_band_crosswalk` and collapses the
ages if desired. It also fixes some intricacies of the age mapping for
specific indicators.

The basic idea is to `left_join()` the `age_band_crosswalk` to your
collapsed MSD output from `align_msd_disagg`.

``` r
 df %>%
    dplyr::left_join(tameDP::age_band_crosswalk, by = c("ageasentered" = "age_msd")) 
```

To use the `align_ageband()` function, you will need to pass the MSD
dataframe and a logical parameter `collapse`. If `collapse = TRUE`, the
function will collapse the age bands after mapping them in, by doing a
`summarise()` call on the entire dataframe. If false, multiple
observations with same age bands will occur. Note: if you set
`collapse = TRUE`, it will take a **significant** amount of time to run
(this is normal because we are doing a summary call over a MASSIVE
dataset!)

Putting it all together, your output would look something like this:

``` r
msd_final <- align_msd_disagg(msd_path = msd_filepath, dp_path = dp_filepath, raised_prioritization = TRUE) %>% 
  align_ageband(collapse = FALSE)

names(msd_final)
```

    ##  [1] "operatingunit"            "country"                 
    ##  [3] "psnu"                     "psnuuid"                 
    ##  [5] "snuprioritization"        "fiscal_year"             
    ##  [7] "indicator"                "standardizeddisaggregate"
    ##  [9] "numeratordenom"           "ageasentered"            
    ## [11] "sex"                      "modality"                
    ## [13] "statushiv"                "cumulative"              
    ## [15] "targets"                  "otherdisaggregate"       
    ## [17] "source_name"

``` r
names(df_dp)
```

    ##  [1] "operatingunit"            "country"                 
    ##  [3] "psnu"                     "psnuuid"                 
    ##  [5] "snuprioritization"        "fiscal_year"             
    ##  [7] "indicator"                "standardizeddisaggregate"
    ##  [9] "numeratordenom"           "ageasentered"            
    ## [11] "sex"                      "modality"                
    ## [13] "statushiv"                "otherdisaggregate"       
    ## [15] "cumulative"               "targets"                 
    ## [17] "source_name"              "source_processed"

Now that we have an MSD output that aligns with the DP, we can then
append or bind this with onto the MSD data frame.

``` r
df_msd_dp <- msd_final %>% 
  bind_rows(df_dp)

df_msd_dp %>% glimpse()
```

We now have a joined data frame that we can use to compare indicator
trends over time. For instance, we can compare how this year’s TX_NEW
targets compare with previous few years’ targets across ages.

``` r
df_msd_dp <- msd_final %>% 
  bind_rows(df_dp)

df_tx_trend <- df_msd_dp %>% 
  filter(indicator == "TX_CURR",
         standardizeddisaggregate == "Age/Sex/HIVStatus") %>% 
  count(fiscal_year, indicator, ageasentered, wt = targets, name = "targets") 
```

Finally, we can reshape the data to get it into an easy table to view
the trends.

``` r
df_tx_trend %>%
  filter(fiscal_year >= 2023) %>% 
  pivot_wider(names_from = fiscal_year,
              values_from = targets)
```
