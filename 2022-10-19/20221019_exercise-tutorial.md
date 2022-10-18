2022-10-19: Reporting Calendar Exercise Solution
================

## Introduction

A large part of coding is just figuring out how to apply business
rules/conditions to return the data you need. And coding helps in lots
of ways, not just working with large datasets; it can be super useful in
solving manual work (and reduces errors). I’ll give you an example. Last
week, we had to update the reporting calendar for HFR and we were able
to code out the solution rather than manually flipping through a
calendar. It definitely took more work to set up, but it means next
year, I can just swap out the year and be done.

I thought this would be an excellent exercise for you all to get your
hands dirty with and we will review in our next session, Wednesday, Oct
19.

**Problem** HFR submissions are due on the 15th of every month unless
the date falls on a weekend or holiday, then it’s the next closest
business day. For example submissions for FY22 Dec were due last January
18, 2022 because Jan 15 fell on a Saturday and then Monday, Jan 17 was a
federal holiday. What days should submissions be due for each month in
FY23?

**Hints**

  - HFR reports are due on the 15th of the following month unless the
    15th falls on a weekend or federal holiday and then it is due on the
    next closest business day
  - A fiscal year runs from Oct - Sept; reportings will then occur from
    Nov - Oct
  - Suggested libraries - base R, `dplyr`, `lubridate`, `tibble`,
    `googlesheets4`
  - Figure out how to create a sequence of dates for the whole fiscal
    year
  - Identify if a date is a business day
  - Identify weekends vs weekday based on `lubridate::wday()`
  - Exclude federal holidays (read in using
    `googlesheets4::read_sheet()` and extract months and days from the
    date column and combine with the year in order to use
    `lubridate::makedate()`)
  - Group by months and use dplyr::slice\_head() for the first
    observation

-----

Let’s break this problem down step by step.

### Step 1: Load necessary libraries

For this exercise, we will be heavily relying on the `tidyverse`
functions for our data wrangling and `lubridate` for working with dates.
We will also load `gagglr` to load all the OHA packages and `glue` to
make it easier to glue strings together in R. Lastly, we’ll use
`googlesheets4` to read in the federal holiday data from Google Drive.

``` r
  library(tidyverse)
  library(gagglr)
  library(glue)
  library(googlesheets4)
  library(lubridate)
```

### Step 2: Set up some global variables

Before starting your script, we want to be thinking about information
that we can store in the beginning of our workflow that we will call on
later - not only does this save time, but it also reduces the amount of
repetition you have in your code.

For example, we know we need to read in data from Google Drive for the
federal holiday calendar. We can store the google ID credentials for the
data using `googlesheets4::as_sheets_id()`. This global object will be
called on when we are reading in the data.

Similarly, we are likely going to be referencing the current year
multiple times throughout our script, so it makes sense to save this as
a global object as well. In this example, we are using a new function in
the `gophr` package called `get_metadata()` that stores various pieces
of metadata information from a given file. In our case, we will be using
this function to store the current year.

``` r
gdrive_id <- as_sheets_id("1IOlSO1j8tzVIKMPWeERNa7O0Ren-28BEw5WiDjzpfGI")
gophr::get_metadata()
```

``` r
metadata$curr_fy
```

    ## [1] 2022

Lastly, to read in the data from google drive, you’ll want to load your
google drive credentials into your R session using
`glamr::load_secrets()`. If you do not have your credentials stored,
please see this
[vignette](https://usaid-oha-si.github.io/glamr/articles/credential-management.html)
to walk you through credential management in R.

``` r
glamr::load_secrets("email")
```

### Step 3: Import OPM Data

*explain why we are specifying col\_type*

``` r
#read opm holiday from GDrive, need to treat as string b/c issue reading date
  df_opm <- read_sheet(gdrive_id, col_types = "c")
```

### Step 4: Transform OPM data so dates are in a date format

*quick run through of differences between base R date functions and
lubridate* *str\_extract and mutating the holidays - why these functions
and how to use them*

``` r
#list of months to find in the date column
  month.list <- month.name %>%
    paste(collapse = "|") %>%
    paste0("(", ., ")")
  
  #extact dates as actual date
  opm_holiday <- df_opm %>%
    rename_all(tolower) %>%
    mutate(month = date %>%
             str_extract(month.list) %>%
             match(month.name),
           day = str_extract(date, "[:digit:]{2}"),
           date_holiday_obs = make_date(year, month, day),
           holiday = str_replace(holiday, "\x92", "'")) %>%
    select(date_holiday_obs, holiday)
```

### Step 5: Create a sequence for fiscal year calendar

*explain seq.date and use case for it here*

``` r
  #create a sequence of dates for the whole fiscal calendar year
  fy_date <- seq.Date(make_date(metadata$curr_fy-1, 11, 1), 
                      make_date(metadata$curr_fy, 10, 30), 
                      by = 1)
```

### Step 6: Determine what days are business days

*explain why we are creating a tibble* *run through wday function and
how you can call variables with $*

``` r
#determine which dates business days 
  df_cal <- tibble(date = fy_date) %>%
    mutate(is.weekend = wday(date, week_start = 1) > 5,
           is.holiday = date %in% opm_holiday$date_holiday_obs,
           is.businessday = is.weekend == FALSE & is.holiday == FALSE,
           month = month(date),
           day = day(date))
```

### Step 7: Filter for business days that are at least the 15th to identify reporting date

*explain the group\_by and slice logic*

``` r
#group by month and filter for business days that are at least the 15th & slice first day
  df_subm <- df_cal %>%
    group_by(month) %>%
    filter(is.businessday,
           day >= 15) %>%
    slice_head() %>%
    ungroup() %>%
    arrange(date)
  
  #pull list of dates
  df_subm %>% 
    pull(date)
```

    ##  [1] "2021-11-15" "2021-12-15" "2022-01-18" "2022-02-15" "2022-03-15"
    ##  [6] "2022-04-15" "2022-05-16" "2022-06-15" "2022-07-15" "2022-08-15"
    ## [11] "2022-09-15" "2022-10-17"
