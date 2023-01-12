---
editor_options: 
  markdown: 
    wrap: 72
---

# Extracting Targets Using tameDP

1/9/2023

-   [tameDP package overview](#tamedp-package-overview)

    -   [Set up](#set-up)
    -   [Extracting Targets](#extracting-targets)

-   [Other Data Options](#other-data-options)

-   [Iterating over multiple files](#iterating-over-multiple-files)

-   [SGAC alternative package](#sgac-alternative-package)

## tameDP package overview {#tamedp-package-overview}

Over the last few years, the SI team has maintained a package for
working with the Data Pack called
[`tameDP`](https://github.com/USAID-OHA-SI/tameDP).

The main function of `tameDP` is to import a COP Data Pack into R and
make it tidy. The function aggregates the fiscal year targets up to the
mechanism level, imports the mechanism information from DATIM, and
breaks out the data elements to make the dataset more usable. There are
a number of useful features including adding in the additional HTS
modalities (from VMMC, PMTCT, TB, and index), breaking out the
`indicatorcode` column into discrete usable/filterable pieces, providing
mechanism/partner info, and creating a HTS_TST_POS indicator.

### Set up {#set-up}

Our package is hosted on a site called GitHub rather than CRAN, R's
central software repository. As a result, we will need to utilize a
function from the `remotes` package to install `tameDP` rather than
repeating the `install.packages()`. Copy and paste the line below to
install `tameDP` from GitHub. If your console asks you to install
updates, you can skip this by simply hitting return/enter.

``` r
#install
#install.packages("remotes")
remotes::install_github("USAID-OHA-SI/tameDP")
```

Then, you can load the package:

``` r
#load library
library(tameDP)
library(tidyverse)
```

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.2 --
    ## v ggplot2 3.4.0.9000     v purrr   1.0.1     
    ## v tibble  3.1.8          v dplyr   1.0.10    
    ## v tidyr   1.2.1          v stringr 1.5.0     
    ## v readr   2.1.3          v forcats 0.5.2     
    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

### Extracting Targets {#extracting-targets}

The first thing you will want to do after your load `tameDP` is to tell
R where your Data Pack is located on your computer. Copy your file path
to your clipboard and paste the copied path into your R script to store
the path as an object in R.

We will call the object, dp_filepath. It is important to note that
Windows filepaths have their slash in the wrong direction. You will need
to replace all backslashes ("/") in your filepath with forward slashes
("/"). The command to store the file path object will look like the code
below, where you have replaced the file path with the path to your own
file.

``` r
dp_filepath <- "2023-01-11/tools/DataPack_Jupiter_20500101.xlsx"
```

The main function is pretty easy to run, providing just the file path to
the data pack you're working with.

The first is extracting all the targets from their relevant tabs. The
data here will be at the PSNU level, broken out by the relevant
disaggregate (e.g. Age/Sex/HIVStatus). In the function below, we have
used the filepath we stored above to pass that into the function. This
function will take a few seconds or minutes to run depending on the size
of your data pack.

``` r
df_sat <- tame_dp(dp_filepath)

head(df_sat)
```

    ## # A tibble: 6 x 17
    ##   operatin~1 country snu1  psnu  psnuuid snupr~2 fisca~3 indic~4 stand~5 numer~6
    ##   <chr>      <chr>   <chr> <chr> <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
    ## 1 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 CXCA_S~ Age/Se~ N      
    ## 2 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 CXCA_S~ Age/Se~ N      
    ## 3 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 CXCA_S~ Age/Se~ N      
    ## 4 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 CXCA_S~ Age/Se~ N      
    ## 5 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 TX_CURR Age/Se~ N      
    ## 6 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 TX_CURR Age/Se~ N      
    ## # ... with 7 more variables: ageasentered <chr>, sex <chr>, modality <chr>,
    ## #   statushiv <chr>, otherdisaggregate <chr>, cumulative <dbl>, targets <dbl>,
    ## #   and abbreviated variable names 1: operatingunit, 2: snuprioritization,
    ## #   3: fiscal_year, 4: indicator, 5: standardizeddisaggregate,
    ## #   6: numeratordenom

When we view our data, you'll see the structure is very similar to a MER
Structured Dataset (MSD). You have the following columns:
`operatingunit`, `countryname`, `snu1`, `psnu`, `psnuuid`,
`fiscal_year`, `indicator`, `standardizeddisaggregate`,
`numeratordenom`, `ageasentered`, `sex`, `modality`, `statushiv`,
`otherdisaggregate`, `targets.` The output is a bit more manageable to
work with than using it in the Data Pack.

## Other Data Options {#other-data-options}

In the function above, we provided the filepath and the function
returned the the data frame of targets from the Data Pack. Function in R
often have multiple parameters. Take a minute to look at the help file
for `tame_dp()`. You'll notice there are few parameters.

``` r
?tame_dp
```

In `tame_dp()`, there is a parameter called `type` which allows us to
return different tabs of the data pack.

For example, you can return the `PLHIV` tab like this:

``` r
#return PLHIV data
df_plhiv <- tame_dp(dp_filepath, type = "PLHIV")
```

If you wanted to get all the targets from all of the tabs, you can use
`type = "ALL"`

``` r
#return PLHIV data
df_all <- tame_dp(dp_filepath, type = "ALL")
```

Finally, to get the data from the PSNUxIM tab of the data pack, use
`type = "PSNUxIM"`. This will pull the data at the PSNU and mechanism
level, with `mech_code` included.

``` r
df_dp_mech <- tame_dp(dp_filepath, type = "PSNUxIM")

str(df_dp_mech)
```

    ## tibble [42,460 x 22] (S3: tbl_df/tbl/data.frame)
    ##  $ operatingunit           : chr [1:42460] "Jupiter" "Jupiter" "Jupiter" "Jupiter" ...
    ##  $ country                 : chr [1:42460] "Jupiter" "Jupiter" "Jupiter" "Jupiter" ...
    ##  $ snu1                    : chr [1:42460] "_Military Jupiter" "_Military Jupiter" "_Military Jupiter" "_Military Jupiter" ...
    ##  $ psnu                    : chr [1:42460] "_Military Jupiter" "_Military Jupiter" "_Military Jupiter" "_Military Jupiter" ...
    ##  $ psnuuid                 : chr [1:42460] "PQZgU9dagaH" "PQZgU9dagaH" "PQZgU9dagaH" "PQZgU9dagaH" ...
    ##  $ snuprioritization       : chr [1:42460] "97 - Above PSNU level" "97 - Above PSNU level" "97 - Above PSNU level" "97 - Above PSNU level" ...
    ##  $ funding_agency          : chr [1:42460] NA NA NA NA ...
    ##  $ mech_code               : chr [1:42460] "00000" "00000" "00000" "00000" ...
    ##  $ prime_partner_name      : chr [1:42460] NA NA NA NA ...
    ##  $ mech_name               : chr [1:42460] NA NA NA NA ...
    ##  $ fiscal_year             : num [1:42460] 2050 2050 2050 2050 2050 2050 2050 2050 2050 2050 ...
    ##  $ indicatortype           : chr [1:42460] NA NA NA NA ...
    ##  $ indicator               : chr [1:42460] "HTS_RECENT" "HTS_RECENT" "HTS_RECENT" "HTS_RECENT" ...
    ##  $ standardizeddisaggregate: chr [1:42460] "Modality/Age/Sex/HIVStatus" "Modality/Age/Sex/HIVStatus" "Modality/Age/Sex/HIVStatus" "Modality/Age/Sex/HIVStatus" ...
    ##  $ numeratordenom          : chr [1:42460] "N" "N" "N" "N" ...
    ##  $ ageasentered            : chr [1:42460] "15-19" "15-19" "20-24" "20-24" ...
    ##  $ sex                     : chr [1:42460] "Female" "Male" "Female" "Male" ...
    ##  $ modality                : chr [1:42460] NA NA NA NA ...
    ##  $ statushiv               : chr [1:42460] NA NA NA NA ...
    ##  $ otherdisaggregate       : chr [1:42460] NA NA NA NA ...
    ##  $ cumulative              : num [1:42460] NA NA NA NA NA NA NA NA NA NA ...
    ##  $ targets                 : num [1:42460] -1 -1 -1 -3 -3 -4 -3 -5 -5 -6 ...

Let's look at the PSNUxIM output more closely. Notice that the mechanism
data is missing from the dataframe. This is because the DataPack doesnt
include mechanism level or prime partner data so these columns are left
blank.

As such, `tame_dp()` has a parameter called `map_names` which will pull
down mechanism level data from DATIM using your DATIM username and
password.

``` r
df_dp_mech <- tame_dp(dp_filepath, type = "PSNUxIM", map_names = TRUE)
```

Lastly, we can use the `psnu_lvl` parameter to aggregate the data up to
the PSNU level if you are working with the PSNUxIM data.

``` r
df_dp_psnu <- tame_dp(dp_filepath, type = "PSNUxIM", psnu_lvl = TRUE)
```

## Iterating over multiple files {#iterating-over-multiple-files}

To iterate over multiple Data Packs at once, you can use one of the
`map()` functions from the `purrr` package to read in multiple files and
combine them, rather than working one by one. First, let's get a list of
files we would like to iterate over. We can do this using the
`list.files()` command. We will use the `full.names = TRUE` setting
because the files live outside of our repo. The `pattern = "P|pack"`
argument tells the function to only look for files that contain the word
"Pack or pack" in the the file name.

``` r
# Identify all Data Pack files
  files <- list.files(path = "../../../Documents/DataPacks/", pattern = "P|pack", full.names = TRUE)
  
# List the contents of the object files
  files
```

    ## [1] "../../../Documents/DataPacks/Data Pack_Malawi_20211118115407.xlsx" 
    ## [2] "../../../Documents/DataPacks/Data Pack_Zambia_20211118122255.xlsx" 
    ## [3] "../../../Documents/DataPacks/DataPack_Jupiter_20500101 - Copy.xlsx"

Next, we can use the `map()` function combined with `list_rbind()` to
read in all of the datapacks and combine them, by row, into a single
data frame.

``` r
# Read in all Data Packs and combine them into one data frame -- New guidance from purrr update
# There is a new argument in the map() function that shows progress. This can be useful if iterating over many files.
  df_all <-
    map(
      .x = files,
      .f = ~ tame_dp(.x, map_names = FALSE),
      .progress = TRUE
    ) %>%
    list_rbind()
```

    ##  ==========>--------------------   33% |  ETA:  7s

    ##  ====================>----------   67% |  ETA:  5s

``` r
# Above is equivalent to running the old purrr syntax
  # df_all <- map_dfr(.x = files,
  #                  .f = ~ tame_dp(.x, map_names = FALSE))
```

To check if all the operating units made it into the data frame, we can
use the `count()` function (or you could visually inspect the resulting
data frame).

``` r
  df_all %>% count(operatingunit, fiscal_year)
```

    ## # A tibble: 9 x 3
    ##   operatingunit fiscal_year     n
    ##   <chr>               <dbl> <int>
    ## 1 Jupiter              2048  1744
    ## 2 Jupiter              2049  4676
    ## 3 Jupiter              2050 21059
    ## 4 Malawi               2021  3068
    ## 5 Malawi               2022  6696
    ## 6 Malawi               2023 15337
    ## 7 Zambia               2021 13288
    ## 8 Zambia               2022 24080
    ## 9 Zambia               2023 49401

What if you wanted to loop over all the Data Packs and pull out the
PLHIV numbers? You could do this by modifying the code chunk above,
setting `type = "PLHIV")`.

``` r
  df_plhiv_all <-
    map(
      .x = files,
      .f = ~ tame_dp(.x, map_names = FALSE, type = "PLHIV"),
      .progress = TRUE
    ) %>%
    list_rbind()
```

## SGAC alternative package {#sgac-alternative-package}

An SGAC alternative to tameDP is `datapackr`.. You can read more about
steps for installing and running the package on the package github
[repo](https://github.com/pepfar-datim/datapackr). To run this package,
you will need to have your DATIM credentials handy or stored in the
`keyring` package via `glamr` ([full
instructions](https://usaid-oha-si.github.io/glamr/articles/credential-management.html)
here).

    ## Loading required package: usethis

    ## Loading required package: datimutils

    ## -- Attaching packages --------------------------------------- OHA tools 0.1.0 --

    ## v gisr  0.2.2 
    ## v glamr 1.1.0 
    ## v glitr 0.1.1 
    ## v gophr 3.1.1

Once you have the package installed and loaded, you can run
`load_secrets()` to populate your DATIM credentials. We can then use
arguments from `glamr` to pass to the `loginToDATIM()` function that is
part of `datimutils`.

``` r
  glamr::load_secrets()

  # populate the arguments below with appropriate values
  datimutils::loginToDATIM(base_url = base_url, username = datim_username, password = datim_pw)
```

Click on the `d2_default_session()` object to check your credentials (or
type it in the Console). With authentication complete, we can move
forward with loading a Data Pack. Similar to above, we'll establish an
object that points at where the file lives. We then use the
`loadDataPack()` function to load the file into R.

``` r
# Set the filepath
  dp_filepath2 <- "../../../Documents/DataPacks/Data Pack_Zambia_20211118122255.xlsx"

# Load the datapack
  d <- loadDataPack(dp_filepath2)
```

![](datapackr_congrats_message.PNG "Congratulations message printed from successfully loading a data pack."")

The next step is to unpack everything. This step takes a bit of time to
run. The end result is a large list of datasets from the Data Pack.

``` r
  dp_zmb <- unPackDataPack(d = d)
```

![](upack_output.PNG "Summary of actions conducted by datapackr when unpacking a datapack.")

To view a summary of what is in each element of the list use a `map()`
function with `names()`.

``` r
  # Return a summary of the elements in the list
  map(dp_zmb, ~names(.x))
```

![](datapackr_list_elements_output.PNG "List of element names stored from running datapackr.")

View the analytics dataset stored in the the list object.

``` r
  # Data of interest
  View(dp_zmb$data$analytics)
```
