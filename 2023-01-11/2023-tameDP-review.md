Extracting Targets Using tameDP
================
1/9/2023

- <a href="#tamedp-package-overview"
  id="toc-tamedp-package-overview">tameDP package overview</a>
  - <a href="#set-up" id="toc-set-up">Set up</a>
  - <a href="#extracting-targets" id="toc-extracting-targets">Extracting
    Targets</a>
- <a href="#other-data-options" id="toc-other-data-options">Other Data
  Options</a>
- <a href="#iterating-over-multiple-files"
  id="toc-iterating-over-multiple-files">Iterating over multiple files</a>
- <a href="#example-how-to-work-with-the-datapack-in-a-tidy-format"
  id="toc-example-how-to-work-with-the-datapack-in-a-tidy-format">Example:
  How to work with the DataPack in a tidy format</a>
- <a href="#exporting-data" id="toc-exporting-data">Exporting Data</a>
- <a href="#sgac-alternative-package"
  id="toc-sgac-alternative-package">SGAC alternative package</a>

## tameDP package overview

Over the last few years, the SI team has maintained a package for
working with the Data Pack called
[`tameDP`](https://github.com/USAID-OHA-SI/tameDP).

The main function of `tameDP` is to bring import a COP Data Pack into R
and make it tidy. The function aggregates the fiscal year targets up to
the mechanism level, imports the mechanism information from DATIM, and
breaks out the data elements to make the dataset more usable. There are
a number of useful features including adding in the additional HTS
modalities (from VMMC, PMTCT, TB, and index), breaking out the
`indicatorcode` column into discrete usable/filterable pieces, providing
mechanism/partner info, and creating a HTS_TST_POS indicator.

### Set up

Our package is hosted on a site called GitHub rather than CRAN, R’s
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
    ## v ggplot2 3.3.6     v purrr   0.3.4
    ## v tibble  3.1.8     v dplyr   1.0.9
    ## v tidyr   1.2.0     v stringr 1.5.0
    ## v readr   2.1.2     v forcats 0.5.1
    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

### Extracting Targets

The first thing you will want to do after your load `tameDP` is to tell
R where your Data Pack is located on your computer. Copy your file path
to your clipboard and paste the copied path into your R script to store
the path as an object in R.

We will call the object, dp_filepath. It is important to note that
Windows filepaths have their slash in the wrong direction. You will need
to replace all backslashes (“/”) in your filepath with forward slashes
(”/“). The command to store the file path object will look like the code
below, where you have replaced the file path with the path to your own
file.

``` r
dp_filepath <- "C:/Users/ksrikanth/Documents/Github/coRps/2023-01-11/tools/DataPack_Jupiter_20500101.xlsx"
```

The main function is pretty easy to run, providing just the file path to
the data pack you’re working with.

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
    ##   operatin~1 count~2 snu1  psnu  psnuuid snupr~3 fisca~4 indic~5 stand~6 numer~7
    ##   <chr>      <chr>   <chr> <chr> <chr>   <chr>     <dbl> <chr>   <chr>   <chr>  
    ## 1 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 CXCA_S~ Age/Se~ N      
    ## 2 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 CXCA_S~ Age/Se~ N      
    ## 3 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 CXCA_S~ Age/Se~ N      
    ## 4 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 CXCA_S~ Age/Se~ N      
    ## 5 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 TX_CURR Age/Se~ N      
    ## 6 Jupiter    Jupiter _Mil~ _Mil~ PQZgU9~ 97 - A~    2048 TX_CURR Age/Se~ N      
    ## # ... with 7 more variables: ageasentered <chr>, sex <chr>, modality <chr>,
    ## #   statushiv <chr>, otherdisaggregate <chr>, cumulative <dbl>, targets <dbl>,
    ## #   and abbreviated variable names 1: operatingunit, 2: countryname,
    ## #   3: snuprioritization, 4: fiscal_year, 5: indicator,
    ## #   6: standardizeddisaggregate, 7: numeratordenom

When we view our data, you’ll see the structure is very similar to a MER
Structured Dataset (MSD). You have the following columns:
`operatingunit`, `countryname`, `snu1`, `psnu`, `psnuuid`,
`fiscal_year`, `indicator`, `standardizeddisaggregate`,
`numeratordenom`, `ageasentered`, `sex`, `modality`, `statushiv`,
`otherdisaggregate`, `targets.` The output is a bit more manageable to
work with than using it in the Data Pack.

## Other Data Options

In the function above, we provided the filepath and the function
returned the the data frame of targets from the Data Pack. Function in R
often have multiple parameters. Take a minute to look at the help file
for `tame_dp()`. You’ll notice there are few parameters.

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

    ## tibble [62,372 x 22] (S3: tbl_df/tbl/data.frame)
    ##  $ operatingunit           : chr [1:62372] "Jupiter" "Jupiter" "Jupiter" "Jupiter" ...
    ##  $ countryname             : chr [1:62372] "Jupiter" "Jupiter" "Jupiter" "Jupiter" ...
    ##  $ snu1                    : chr [1:62372] NA NA NA NA ...
    ##  $ psnu                    : chr [1:62372] "_Military Jupiter" "_Military Jupiter" "_Military Jupiter" "_Military Jupiter" ...
    ##  $ psnuuid                 : chr [1:62372] "PQZgU9dagaH" "PQZgU9dagaH" "PQZgU9dagaH" "PQZgU9dagaH" ...
    ##  $ snuprioritization       : chr [1:62372] "97 - Above PSNU level" "97 - Above PSNU level" "97 - Above PSNU level" "97 - Above PSNU level" ...
    ##  $ fundingagency           : chr [1:62372] NA NA NA NA ...
    ##  $ mech_code               : chr [1:62372] "00000" "00000" "00000" "00000" ...
    ##  $ primepartner            : chr [1:62372] NA NA NA NA ...
    ##  $ mech_name               : chr [1:62372] NA NA NA NA ...
    ##  $ fiscal_year             : num [1:62372] 2050 2050 2050 2050 2050 2050 2050 2050 2050 2050 ...
    ##  $ indicatortype           : chr [1:62372] "DSD" "DSD" "DSD" "DSD" ...
    ##  $ indicator               : chr [1:62372] "HTS_INDEX" "HTS_INDEX" "HTS_INDEX" "HTS_INDEX" ...
    ##  $ standardizeddisaggregate: chr [1:62372] "Age/Sex/Result" "Age/Sex/Result" "Age/Sex/Result" "Age/Sex/Result" ...
    ##  $ numeratordenom          : chr [1:62372] "N" "N" "N" "N" ...
    ##  $ ageasentered            : chr [1:62372] "10-14" "10-14" "15-19" "15-19" ...
    ##  $ sex                     : chr [1:62372] "Female" "Male" "Female" "Male" ...
    ##  $ modality                : chr [1:62372] NA NA NA NA ...
    ##  $ statushiv               : chr [1:62372] "Negative" "Negative" "Negative" "Negative" ...
    ##  $ otherdisaggregate       : chr [1:62372] "NewNeg" "NewNeg" "NewNeg" "NewNeg" ...
    ##  $ cumulative              : num [1:62372] NA NA NA NA NA NA NA NA NA NA ...
    ##  $ targets                 : num [1:62372] -34 -40 -32 -44 -44 -100 -92 -176 -148 -224 ...

Let’s look at the PSNUxIM output more closely. Notice that the mechanism
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

## Iterating over multiple files

To iterate over multiple DataPacks at once, you can use one of the
`map()` functions from the `purrr` package to read in multiple DataPacks
and combine them, rather than working one by one.

## Example: How to work with the DataPack in a tidy format

## Exporting Data

## SGAC alternative package
