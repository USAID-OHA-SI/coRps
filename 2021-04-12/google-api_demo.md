Google API Demo
================
A.Chafetz
4/12/2021

## Overview

We work with the GSuite for a lot of our work at USAID. We can take
advantage of the Google API improve the automation and collaboration of
our workflows, from pushing ggplot outputs to a Google Drive folder or
reading directly in a Google Sheet.

The two main packages we use are part of the Tidyverse - `googledrive`
and `googlesheets4` - and maintain by the RStudio team. The underlying
package that allows for authentication is `gargle` and only the older
version of the package is whitelisted for use by USAID at the momement.
You will need to install an older version of both `gargle` and
`googlesheets4` using the code below.

``` r
install.packages("devtools")
install.packages("googledrive")
devtools::install_version("gargle", version = "0.5.0", repos = "http://cran.us.r-project.org")
devtools::install_version("googlesheets4", version = "0.2.0", repos = "http://cran.us.r-project.org")
```

Let’s check that we have the older versions of both.

``` r
packageVersion("gargle") == "0.5.0"
```

    ## [1] TRUE

``` r
packageVersion("googlesheets4") == "0.2.0"
```

    ## [1] TRUE

## Providing authentication

To start connecting with the Google API, you need to provide your USAID
email. The very first time it will launch your internet browser and ask
you to confirm approval. You can enter your email or have it prompt you
to write in your email if you don’t write it (safer if your code is
public). To use each package you will have to authenticate with each one
(and have to do this every time to start a new session).

``` r
library(googledrive)
library(googlesheets4)

drive_auth()
gs4_auth()
```

We have a nice function to make loading your email (and other
credentials into a session) as part of the `glamr` package. You can view
the instructions from the vignette, `credential-management`.

``` r
devtools::install_github("USAID-OHA-SI/glamr", build_vignettes = TRUE)
vignette("credential-management", package = "glamr") #launch the vignette
```

Basically, though you have set your email and it stored is in your
Options so its ready to use.

``` r
library(glamr)
set_email("rshah@usaid.gov") #just need to set this one time

load_secrets()
```

## Problem to solve

Now we’re ready to rock and roll. For the demo we’re going to try to
solve a problem I had to deal with the other day. For HFR, we import any
sheet from the Excel submission that has “HFR” in the sheet name. This
includes hidden sheets and we realized we were importing and duplicating
values for Eswatini since they had a sheet called “HFR v1” that was
hidden. We needed to check to see if any of their previous submissions
had these extra tabs.

## Workflow

Okay, let’s load the packages we need and load our email for use with
`googledrive` and `googlesheets4`.

``` r
library(tidyverse)
library(glamr)
library(googledrive)
library(googlesheets4)
library(fs)
library(readxl)
library(lubridate)
library(glue)

load_secrets()
```

For HFR, country teams submit their submissions each period via a Google
Form. So we have a Google Sheet that stores all the information entered
as well as the hyperlink (and id) of the submission.

With `googledrive` and `googlesheets4` we want to specify the file or
folder id which is found at the end of the url. If your provide the file
name, the packages search through the thousands of files on your GDrive
which takes a ton of time and expends a lot of resources.
**Always,always use the Google file id!**

Let’s start by looking at the Google Sheet itself that contains all the
information about the submissions. We have the ID we can store as an ID,
`as_id()` (or `as_sheets_id()`)

``` r
hfr_submissions <- as_id("1gQvY1KnjreRO3jl2wzuVCKmKjUUgZDwByVK1c-bzpYI")
```

And we can open this file in our browser with
`googledrive::drive_browse()`.

``` r
drive_browse(hfr_submissions)
```

Now that we have a sense of the sheet structure, let’s read it in
directly to our R session using `googlesheets4::read_sheet()`.

``` r
df_form <- read_sheet(hfr_submissions) 

names(df_form)
```

    ##  [1] "Timestamp"                                                                                                                                                                                                    
    ##  [2] "Email Address"                                                                                                                                                                                                
    ##  [3] "Operating Unit/Country"                                                                                                                                                                                       
    ##  [4] "HFR FY and Period"                                                                                                                                                                                            
    ##  [5] "What type of submission is this?"                                                                                                                                                                             
    ##  [6] "Is the data being submitted monthly totals or weekly disaggregates?"                                                                                                                                          
    ##  [7] "Which HFR Template(s) are you submitting?"                                                                                                                                                                    
    ##  [8] "Have the following HFR submission requirements been met? [Are you using the v1.04 FY21 HFR template?]"                                                                                                        
    ##  [9] "Have the following HFR submission requirements been met? [Is the meta tab still included in your submission(s)]"                                                                                              
    ## [10] "Have the following HFR submission requirements been met? [Are the \"Operating Unit/Country\" & \"HFR FY and Period\" fields on the meta tab complete?]"                                                       
    ## [11] "Have the following HFR submission requirements been met? [Do the tabs with your HFR data include \"HFR\" in the tab name?]"                                                                                   
    ## [12] "Have the following HFR submission requirements been met? [Do the dates in your submission follow the YYYY-MM-DD format]"                                                                                      
    ## [13] "Have the following HFR submission requirements been met? [Have columns A-G of the HFR tab been filled out?]"                                                                                                  
    ## [14] "Have the following HFR submission requirements been met? [Does your submission files adhere to the following name convention \"HFR_FY[YY]_[Period]_[OU]_[PARTNER IF NEEDED]_[DATE SUBMITTED as YYYYMMDD]\" ?]"
    ## [15] "Is there any additional information you would like included with your submission?"                                                                                                                            
    ## [16] "Who should the HFRG email concerning this submission (names & emails)"                                                                                                                                        
    ## [17] "Upload your HFR file(s) here"                                                                                                                                                                                 
    ## [18] "File(s) Rejected or Accepted"                                                                                                                                                                                 
    ## [19] "HFRG Notes"                                                                                                                                                                                                   
    ## [20] "Feedback sent back to Mission & CC's"                                                                                                                                                                         
    ## [21] "HFRG Assigned"                                                                                                                                                                                                
    ## [22] "Sent to DDC for Processing?"                                                                                                                                                                                  
    ## [23] "Processed by HFRG (Wavelength)?"

We only need the country and hyperlink to the file, so let’s filter and
limit our varaibles.

``` r
df_swz <- df_form %>% 
  select(country = `Operating Unit/Country`, 
         period = `HFR FY and Period`,
         type = `What type of submission is this?`,
         file = `Upload your HFR file(s) here`) %>% 
  filter(country == "Eswatini")

df_swz
```

    ## # A tibble: 6 x 4
    ##   country  period   type      file                                              
    ##   <chr>    <chr>    <chr>     <chr>                                             
    ## 1 Eswatini FY21 Nov Initial   https://drive.google.com/open?id=1eo04wabgAC9KQtM~
    ## 2 Eswatini FY21 Dec Initial   https://drive.google.com/open?id=1zi1gHwYWTPZHkzV~
    ## 3 Eswatini FY21 Jan Initial   https://drive.google.com/open?id=1wvfAzuOAc0Wl3eV~
    ## 4 Eswatini FY21 Feb Initial   https://drive.google.com/open?id=1MNn_W1xHgA8Ko3J~
    ## 5 Eswatini FY21 Feb Re-submi~ https://drive.google.com/open?id=1GN-Q3ioc6yY_PYU~
    ## 6 Eswatini FY21 Mar Initial   https://drive.google.com/open?id=1_FrwNlc4yeSrkdf~

For most countries, they are only submitting one file per submission,
but Eswatini uploades multiple files per submission, one for each
partner (you can’t see it in the preview above because it gets cut off,
but there are three urls in each cell). In order to use the id from the
files’ hyperlinks, we have to breakout the list of hyperlinks in each
cell into a data frame that has one hyperlink per row. The `tidyr`
package has just the tool we need for this `separate_rows()`.

``` r
df_swz <- separate_rows(df_swz, file, sep = ", ")

df_swz
```

    ## # A tibble: 18 x 4
    ##    country  period   type       file                                            
    ##    <chr>    <chr>    <chr>      <chr>                                           
    ##  1 Eswatini FY21 Nov Initial    https://drive.google.com/open?id=1eo04wabgAC9KQ~
    ##  2 Eswatini FY21 Nov Initial    https://drive.google.com/open?id=1RqECc5RNjE9UU~
    ##  3 Eswatini FY21 Nov Initial    https://drive.google.com/open?id=111WhmmY8WK3RZ~
    ##  4 Eswatini FY21 Dec Initial    https://drive.google.com/open?id=1zi1gHwYWTPZHk~
    ##  5 Eswatini FY21 Dec Initial    https://drive.google.com/open?id=1Uz11s7DyrnrFC~
    ##  6 Eswatini FY21 Dec Initial    https://drive.google.com/open?id=1XJSB7hO8A3vtO~
    ##  7 Eswatini FY21 Jan Initial    https://drive.google.com/open?id=1wvfAzuOAc0Wl3~
    ##  8 Eswatini FY21 Jan Initial    https://drive.google.com/open?id=1fFWqm9HkD71RT~
    ##  9 Eswatini FY21 Jan Initial    https://drive.google.com/open?id=1_NLTRUz4rKSFb~
    ## 10 Eswatini FY21 Feb Initial    https://drive.google.com/open?id=1MNn_W1xHgA8Ko~
    ## 11 Eswatini FY21 Feb Initial    https://drive.google.com/open?id=17S_YtplSvt4Kn~
    ## 12 Eswatini FY21 Feb Initial    https://drive.google.com/open?id=1XzxW2qXzklGja~
    ## 13 Eswatini FY21 Feb Re-submis~ https://drive.google.com/open?id=1GN-Q3ioc6yY_P~
    ## 14 Eswatini FY21 Feb Re-submis~ https://drive.google.com/open?id=16V4C0SAblrfPb~
    ## 15 Eswatini FY21 Feb Re-submis~ https://drive.google.com/open?id=18mcGHW5LhB0nh~
    ## 16 Eswatini FY21 Mar Initial    https://drive.google.com/open?id=1_FrwNlc4yeSrk~
    ## 17 Eswatini FY21 Mar Initial    https://drive.google.com/open?id=1ZgTKfvZA7bkMc~
    ## 18 Eswatini FY21 Mar Initial    https://drive.google.com/open?id=1wDm3k582XzlVM~

Great. Now we have each of the files in their own row. We need to
extract the id from the url so that we can use it for downloading. We
can use a regular expression to extract this, since all follow the same
pattern of coming after “id=” in the url.

``` r
ids <- df_swz %>% 
  mutate(id = str_extract(file, "(?<=id=).*")) %>% 
  pull()

ids
```

    ##  [1] "1eo04wabgAC9KQtMnVUafqUexfX2cyE5S" "1RqECc5RNjE9UUKa36vW2tR_yXHB0Q6Pl"
    ##  [3] "111WhmmY8WK3RZQtj-TD2_jc67X2yzl0_" "1zi1gHwYWTPZHkzVwvLKJ-628VvqcFFB4"
    ##  [5] "1Uz11s7DyrnrFCDCHgBOctLHc_oxmXaw0" "1XJSB7hO8A3vtOKFHKUmuBquDYWRgd8r4"
    ##  [7] "1wvfAzuOAc0Wl3eVXGANsh0b0z55c87op" "1fFWqm9HkD71RTutWzUaInt2Fw2s0yTOZ"
    ##  [9] "1_NLTRUz4rKSFb_t-Dgr4-lXwiNzeno7l" "1MNn_W1xHgA8Ko3JsErWI0k_gfRAeZoSj"
    ## [11] "17S_YtplSvt4KnR6jMK6BJLVEWPio0le3" "1XzxW2qXzklGjaMfyoRICs8sBNTbT0weB"
    ## [13] "1GN-Q3ioc6yY_PYUwzzk-QidTnZALbpy2" "16V4C0SAblrfPb20pmvX5yd6KFtJFnVmq"
    ## [15] "18mcGHW5LhB0nhmS7clpiX9YqBG8ZVN_i" "1_FrwNlc4yeSrkdf2TLptfBUcw0UsZ3ZS"
    ## [17] "1ZgTKfvZA7bkMcAlTTuEXJhLQxwnPf0yh" "1wDm3k582XzlVMpSZyW_XE_LLcqCuDk4m"

The other piece of information we need that we didn’t have from the
original form, is the file name. If we saved the file to the working
directory, this wouldn’t be an issue; but to use the
`googldrive::drive_download` and save to a particular folder, you have
to provide the full path, so we need the filename. We can use the
`googledrive::drive_get()` function to provide additional information
about the file. We’ll use a function from `purrr()` to map over each id
and get the information we need and combine it back into a data frame.

``` r
files <- map_dfr(.x = ids,
                 .f = ~drive_get(as_id(.x))) %>% 
  mutate(name = str_remove(name, " -.*(?=\\.xlsx)")) #removing the submitter's name

files
```

    ## # A tibble: 18 x 3
    ##    name                              id                         drive_resource  
    ##  * <chr>                             <chr>                      <list>          
    ##  1 HFR_FY21_Nov_Eswatini_EGPAF_2020~ 1eo04wabgAC9KQtMnVUafqUex~ <named list [39~
    ##  2 HFR_FY21_Nov_FHI360_2020-12-14.x~ 1RqECc5RNjE9UUKa36vW2tR_y~ <named list [39~
    ##  3 HFR_FY21_PD2_Eswatini_TLC_202012~ 111WhmmY8WK3RZQtj-TD2_jc6~ <named list [39~
    ##  4 HFR_FY21_Dec_Eswatini_EGPAF_2021~ 1zi1gHwYWTPZHkzVwvLKJ-628~ <named list [39~
    ##  5 HFR_FY21_Dec_FHI360_2021-01-12.x~ 1Uz11s7DyrnrFCDCHgBOctLHc~ <named list [39~
    ##  6 HFR_FY21_PD3_Eswatini_TLC_202001~ 1XJSB7hO8A3vtOKFHKUmuBquD~ <named list [39~
    ##  7 HFR_FY21 PD4_Eswatini_TLC_202102~ 1wvfAzuOAc0Wl3eVXGANsh0b0~ <named list [40~
    ##  8 HFR_FY21_Jan_Eswatini_EGPAF_2021~ 1fFWqm9HkD71RTutWzUaInt2F~ <named list [39~
    ##  9 HFR_FY21_Jan_FHI360_2021-02-11.x~ 1_NLTRUz4rKSFb_t-Dgr4-lXw~ <named list [39~
    ## 10 HFR_FY21_Feb_Eswatini_EGPAF_2021~ 1MNn_W1xHgA8Ko3JsErWI0k_g~ <named list [41~
    ## 11 HFR_FY21_Feb_Eswatini_FHI360_202~ 17S_YtplSvt4KnR6jMK6BJLVE~ <named list [40~
    ## 12 HFR_FY21_Feb_Eswatini_TLC_202103~ 1XzxW2qXzklGjaMfyoRICs8sB~ <named list [40~
    ## 13 HFR_FY21_Feb_Eswatini_EGPAF_2021~ 1GN-Q3ioc6yY_PYUwzzk-QidT~ <named list [40~
    ## 14 HFR_FY21_Feb_Eswatini_FHI360_202~ 16V4C0SAblrfPb20pmvX5yd6K~ <named list [39~
    ## 15 HFR_FY21_Feb_Eswatini_TLC_202103~ 18mcGHW5LhB0nhmS7clpiX9Yq~ <named list [40~
    ## 16 HFR_FY21_Mar_Eswatini_EGPAF_2021~ 1_FrwNlc4yeSrkdf2TLptfBUc~ <named list [39~
    ## 17 HFR_FY21_Mar_Eswatini_FHI360_202~ 1ZgTKfvZA7bkMcAlTTuEXJhLQ~ <named list [39~
    ## 18 HFR_FY21_Mar_Eswatini_TLC_202104~ 1wDm3k582XzlVMpSZyW_XE_LL~ <named list [39~

If you look at these file names, you’ll see there are a few duplicates
from resubmissions with the same names being uploaded.

``` r
duplicated(files$name)
```

    ##  [1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
    ## [13]  TRUE  TRUE  TRUE FALSE FALSE FALSE

To resolve this issue, we can add the creation time, which we can
extract from nested list of drive\_resources to the file name.

``` r
files <- files %>% 
  mutate(created_time = purrr::map_chr(drive_resource, "createdTime") %>%
                     ymd_hms(tz = "EST"),
                created_time = created_time %>% 
                  str_remove(":[:digit:]+\\.[:digit:]+Z") %>% 
                  str_remove_all("-|:") %>%
                  str_replace(" ", "-"), 
                name_new = str_replace(name, "\\.xlsx", glue("_{created_time}\\.xlsx")))

files$name_new
```

    ##  [1] "HFR_FY21_Nov_Eswatini_EGPAF_20201214_20201215-071811.xlsx" 
    ##  [2] "HFR_FY21_Nov_FHI360_2020-12-14_20201215-071813.xlsx"       
    ##  [3] "HFR_FY21_PD2_Eswatini_TLC_20201214_20201215-071814.xlsx"   
    ##  [4] "HFR_FY21_Dec_Eswatini_EGPAF_20210115 _20210115-094622.xlsx"
    ##  [5] "HFR_FY21_Dec_FHI360_2021-01-12_20210115-094625.xlsx"       
    ##  [6] "HFR_FY21_PD3_Eswatini_TLC_20200114_20210115-094627.xlsx"   
    ##  [7] "HFR_FY21 PD4_Eswatini_TLC_20210212_20210215-025822.xlsx"   
    ##  [8] "HFR_FY21_Jan_Eswatini_EGPAF_20210212_20210215-025826.xlsx" 
    ##  [9] "HFR_FY21_Jan_FHI360_2021-02-11_20210215-025828.xlsx"       
    ## [10] "HFR_FY21_Feb_Eswatini_EGPAF_20210312_20210315-054234.xlsx" 
    ## [11] "HFR_FY21_Feb_Eswatini_FHI360_20210310_20210315-054238.xlsx"
    ## [12] "HFR_FY21_Feb_Eswatini_TLC_20210312_20210315-054240.xlsx"   
    ## [13] "HFR_FY21_Feb_Eswatini_EGPAF_20210312_20210412-031253.xlsx" 
    ## [14] "HFR_FY21_Feb_Eswatini_FHI360_20210310_20210412-031257.xlsx"
    ## [15] "HFR_FY21_Feb_Eswatini_TLC_20210312_20210412-031259.xlsx"   
    ## [16] "HFR_FY21_Mar_Eswatini_EGPAF_20210415_20210415-080403.xlsx" 
    ## [17] "HFR_FY21_Mar_Eswatini_FHI360_20210413_20210415-080405.xlsx"
    ## [18] "HFR_FY21_Mar_Eswatini_TLC_20210415_20210415-080408.xlsx"

``` r
duplicated(files$name_new)
```

    ##  [1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
    ## [13] FALSE FALSE FALSE FALSE FALSE FALSE

With that, we have all the information we need to download the files -
we have the id and the file name. We’ll create a temporary folder to
store these in and then download them to that folder (one at a time).

``` r
folderpath <- dir_create(file_temp())

walk2(.x = files$id,
      .y = files$name_new,
      .f = ~drive_download(as_id(.x),
                           file.path(folderpath, .y)))
```

Wonderful so we have all the Eswatini Excel submissions on our local
computer. We can now check if any additional submissions had more than
one HFR labeled tab. We’ll use `readxl::excel_sheets()` to provide us
with the list of tab names and filter out anything that won’t be
imported (ie anything without HFR in the name.)

``` r
local_files <- list.files(folderpath, full.names = TRUE)

local_files %>% 
  set_names() %>% #names the vector (1,2,3...) to be the name of the file
  map_df(~ excel_sheets(.x) %>% as_tibble(),
         .id = "file") %>% 
  mutate(file = basename(file),
         value = str_trim(value)) %>% 
  filter(str_detect(value, "HFR")) %>% 
  group_by(file) %>% 
  mutate(file_id = cur_group_id(), .before = 1) %>%
  mutate(extra = value != "HFR") %>% 
  ungroup() %>% 
  rename(sheet = value) %>% 
  prinf()
```

    ## # A tibble: 19 x 4
    ##    file_id file                                                      sheet extra
    ##      <int> <chr>                                                     <chr> <lgl>
    ##  1       1 HFR_FY21 PD4_Eswatini_TLC_20210212_20210215-025822.xlsx   HFR   FALSE
    ##  2       2 HFR_FY21_Dec_Eswatini_EGPAF_20210115 _20210115-094622.xl~ HFR   FALSE
    ##  3       3 HFR_FY21_Dec_FHI360_2021-01-12_20210115-094625.xlsx       HFR   FALSE
    ##  4       4 HFR_FY21_Feb_Eswatini_EGPAF_20210312_20210315-054234.xlsx HFR   FALSE
    ##  5       5 HFR_FY21_Feb_Eswatini_EGPAF_20210312_20210412-031253.xlsx HFR   FALSE
    ##  6       6 HFR_FY21_Feb_Eswatini_FHI360_20210310_20210315-054238.xl~ HFR   FALSE
    ##  7       6 HFR_FY21_Feb_Eswatini_FHI360_20210310_20210315-054238.xl~ HFR ~ TRUE 
    ##  8       7 HFR_FY21_Feb_Eswatini_FHI360_20210310_20210412-031257.xl~ HFR   FALSE
    ##  9       8 HFR_FY21_Feb_Eswatini_TLC_20210312_20210315-054240.xlsx   HFR   FALSE
    ## 10       9 HFR_FY21_Feb_Eswatini_TLC_20210312_20210412-031259.xlsx   HFR   FALSE
    ## 11      10 HFR_FY21_Jan_Eswatini_EGPAF_20210212_20210215-025826.xlsx HFR   FALSE
    ## 12      11 HFR_FY21_Jan_FHI360_2021-02-11_20210215-025828.xlsx       HFR   FALSE
    ## 13      12 HFR_FY21_Mar_Eswatini_EGPAF_20210415_20210415-080403.xlsx HFR   FALSE
    ## 14      13 HFR_FY21_Mar_Eswatini_FHI360_20210413_20210415-080405.xl~ HFR   FALSE
    ## 15      14 HFR_FY21_Mar_Eswatini_TLC_20210415_20210415-080408.xlsx   HFR   FALSE
    ## 16      15 HFR_FY21_Nov_Eswatini_EGPAF_20201214_20201215-071811.xlsx HFR   FALSE
    ## 17      16 HFR_FY21_Nov_FHI360_2020-12-14_20201215-071813.xlsx       HFR   FALSE
    ## 18      17 HFR_FY21_PD2_Eswatini_TLC_20201214_20201215-071814.xlsx   HFR   FALSE
    ## 19      18 HFR_FY21_PD3_Eswatini_TLC_20200114_20210115-094627.xlsx   HFR   FALSE

We can now see that there was only 1 file (`file_id` = 6) that has two
tabs being read in. Phew.

We could done all this manually - copying and pasting each of the 18
urls into our browser from the form, downloading them, opening each, and
check each one for hidden tabs. But this workflow takes a bit to think
through the first time you do it, but you have the script if you need to
repeat this agian.
