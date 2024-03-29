2022-10-19: coRps Reporting Calendar Exercise Solution
================

  - [Introduction](#introduction)
  - [Step 1: Load necessary libraries](#step-1-load-necessary-libraries)
  - [Step 2: Set up some global
    variables](#step-2-set-up-some-global-variables)
  - [Step 3: Import OPM Data](#step-3-import-opm-data)
  - [Step 4: Transform OPM data so dates are in a date
    format](#step-4-transform-opm-data-so-dates-are-in-a-date-format)
  - [Step 5: Create a sequence for fiscal year
    calendar](#step-5-create-a-sequence-for-fiscal-year-calendar)
  - [Step 6: Determine what days are business
    days](#step-6-determine-what-days-are-business-days)
  - [Step 7: Filter for business days that are at least the 15th to
    identify reporting
    date](#step-7-filter-for-business-days-that-are-at-least-the-15th-to-identify-reporting-date)
  - [Review Materials](#review-materials)

### Introduction

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

When we read in the data, we are going to specify that the col_types are treated as characters. 
If we do not do this, you'll notice that the date field is quite jacked up. It becomes a mix
of POSIX dates and characters. 

``` r
#read opm holiday from GDrive, need to treat as string b/c issue reading date
  df_opm <- read_sheet(gdrive_id, col_types = "c")
```

### Step 4: Transform OPM data so dates are in a date format

Set up a vector of months we would like to extract from the OPM data -- (all of them!)
``` r
#list of months to find in the date column
  month.list <- month.name %>%
    paste(collapse = "|") %>%
    paste0("(", ., ")")
```

Base R is lovely in that it has a few built in objects that can make your life easier. The `month.name ` is one such object we can use to quickly generate a vector of months.

``` r
month.name

# What does this look like?
  month.list

```

Now that we have our months in an object, we can start to manipulate the OPM dataframe to build some dates.

``` r
  #extract dates as actual date
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

You may also notice the call to `lubridate::make_date()`. If we look at the documentation for this, we see that it takes a series of inputs and returns a date. For example, if we wanted to create today's date, we would do the following:

```r
# make_date -- what does it do -- produces objects of class Data
  make_date(year = 2022, month = 10, day = 19) %>% class()

# Not the same as above / above is a Date class
  "2022-10-19" %>% class()

# If we want to extract the months from the date column, we can do the following
# match() is a base 
  months <- df_opm$date %>% str_extract(month.list) %>% match(month.name)
  str(months)
```

As we move through the code chunk above, you'll see a a line that creates the day column. Similar to how we used `str_extract()` to pluck out the month, we are going to use a regular expression to pluck out the day of the month.

```r

# Two ways of extracting days
days <- df_opm$date %>% str_extract(., "\\d{2}")
days2 <- df_opm$date %>% str_extract(., "[:digit:]{2}")

days == days2

make_date(year = 2022, month = months, day = days) %>% str()

```




### Step 5: Create a sequence for fiscal year calendar

The next step is to build an object that contains every date from November 1, 2022 through October 30, 2023. Because the first HFR reporting period is not until November of each fiscal year, we start at November 1. 

The `seq.Date()` function is our friend here. It allows us to create a sequence of dates, much like we'd create a sequence of numbers using the base `seq()` function. Let's see this in action.

``` r
  # General idea is that we can build a vector quickly with base R functions. 
  seq(from = 0, to = 10, by = 2)
  seq(0, 100, 5)


  #create a sequence of dates for the whole fiscal calendar year
  fy_date <- seq.Date(make_date(metadata$curr_fy, 11, 1), 
                      make_date(metadata$curr_fy+1, 10, 30), 
                      by = 1)
```

### Step 6: Determine what days are business days

Now that we have the dates for the whole fiscal calendar year stored as
`fy_date`, we can start determining which of these days are business
days. Right now, `fy_date` is stored as a vector - to work with this
data as a dataframe, we need to use the `tibble()` function to construct
a data frame.

``` r
tibble(date = fy_date)
```

    ## # A tibble: 364 x 1
    ##    date      
    ##    <date>    
    ##  1 2021-11-01
    ##  2 2021-11-02
    ##  3 2021-11-03
    ##  4 2021-11-04
    ##  5 2021-11-05
    ##  6 2021-11-06
    ##  7 2021-11-07
    ##  8 2021-11-08
    ##  9 2021-11-09
    ## 10 2021-11-10
    ## # ... with 354 more rows

After we have our dataframe, we can begin to use helper functions in the
`lubridate` package to determine which days are weekends and holidays
(from the OPM code above), thus allowing us to filter down which dates
are business days.

We’ll use the `dplyr::mutate()` to create these flags, but let’s first
run through some helpful `lubridate` functions to solve this problem:

#### `wday()`

`wday` returns the day of the week as a number according to ISO
conventions, where 1 means Monday and 7 means Sunday.

We can pass the `date` through the `wday` function and use the
`week_start` parameter to specify what day of the week the week starts
on.

Let’s take today’s date for instance. If we call `wday` on today’s date
(Wednesday, October 19th 2022) and specify that the week begins on
Monday, the function will return the number `3`, as this is the 3rd day
in the week from Monday.

``` r
wday("2022-10-19", week_start = 1)
```

    ## [1] 3

We then know that Saturday will be equal to 6 and Sunday will be 7. As
such, we can create a conditional statement that returns `is.weekend =
TRUE` if the number from `wday` is greater than 5.

`is.weekend = wday(date, week_start = 1) > 5`

#### `month()` and `day()`

The `month()`and `day()` functions simply return the month and day
respectively for a given date input. We can use this metadata for each
date to group by the month later, to identify what the reporting date
will be for each month and filter the days to on or after the 15th of
every month.

``` r
month("2022-10-19")
```

    ## [1] 10

``` r
day("2022-10-19")
```

    ## [1] 19

Putting all these pieces together, using the `opm_holiday` dataframe we
created early, we can also create a flag that returns `is.holiday =
TRUE` if the date occurs in the OPM holiday dataframe.

Finally, we can identify which dates are business days using these 2
flags: where `is.weekend == FALSE & is.holiday == FALSE`.

Here’s what the code looks like with all of these steps together:

``` r
#determine which dates business days 
  df_cal <- tibble(date = fy_date) %>%
    mutate(is.weekend = wday(date, week_start = 1) > 5,
           is.holiday = date %in% opm_holiday$date_holiday_obs,
           is.businessday = is.weekend == FALSE & is.holiday == FALSE,
           month = month(date),
           day = day(date))

head(df_cal)
```

    ## # A tibble: 6 x 6
    ##   date       is.weekend is.holiday is.businessday month   day
    ##   <date>     <lgl>      <lgl>      <lgl>          <dbl> <int>
    ## 1 2021-11-01 FALSE      FALSE      TRUE              11     1
    ## 2 2021-11-02 FALSE      FALSE      TRUE              11     2
    ## 3 2021-11-03 FALSE      FALSE      TRUE              11     3
    ## 4 2021-11-04 FALSE      FALSE      TRUE              11     4
    ## 5 2021-11-05 FALSE      FALSE      TRUE              11     5
    ## 6 2021-11-06 TRUE       FALSE      FALSE             11     6

### Step 7: Filter for business days that are at least the 15th to identify reporting date

We’re almost there\! We know HFR submissions are due on the 15th of
every month, unless the date falls on a weekend or holiday - in those
cases, it’s the next closest business day.

By this logic, for each month we need to filter to only dates that are
business days (using the flag we created in Step 6) and dates that are
on or after the 15th of the month.

To achieve this, we will utilize `dplyr::group_by()` to group our filter
by the `month` and then filter to where `is.businessday == TRUE` and the
`day` variable we created in Step 6 is greater than or equal to 15.

``` r
df_cal %>%
    group_by(month) %>%
    filter(is.businessday,
           day >= 15)
```

    ## # A tibble: 134 x 6
    ## # Groups:   month [12]
    ##    date       is.weekend is.holiday is.businessday month   day
    ##    <date>     <lgl>      <lgl>      <lgl>          <dbl> <int>
    ##  1 2021-11-15 FALSE      FALSE      TRUE              11    15
    ##  2 2021-11-16 FALSE      FALSE      TRUE              11    16
    ##  3 2021-11-17 FALSE      FALSE      TRUE              11    17
    ##  4 2021-11-18 FALSE      FALSE      TRUE              11    18
    ##  5 2021-11-19 FALSE      FALSE      TRUE              11    19
    ##  6 2021-11-22 FALSE      FALSE      TRUE              11    22
    ##  7 2021-11-23 FALSE      FALSE      TRUE              11    23
    ##  8 2021-11-24 FALSE      FALSE      TRUE              11    24
    ##  9 2021-11-26 FALSE      FALSE      TRUE              11    26
    ## 10 2021-11-29 FALSE      FALSE      TRUE              11    29
    ## # ... with 124 more rows

You’ll notice that, for November, the first date that meets both of
those conditions is November 15, 2021. As such, the reporting date for
November 2021 will be November 15, 2021.

We want to grab the first date for each month that meets these
conditions. To do so, we can `slice_head()` from the `dplyr` package,
which allows you to select the first row of a dataframe. Since we are
still grouping by `month`, `slice_head()` will index the first row in
this dataframe by each month.

Once we are done with this step, we are ready to `ungroup()`. We’ll also
`arrange()` by the `date` to make it easier to see each reporting date
in chronological order.

Here’s what it all looks like put together:

``` r
#group by month and filter for business days that are at least the 15th & slice first day
  df_subm <- df_cal %>%
    group_by(month) %>%
    filter(is.businessday,
           day >= 15) %>%
    slice_head() %>%
    ungroup() %>%
    arrange(date)

  head(df_subm)
```

    ## # A tibble: 6 x 6
    ##   date       is.weekend is.holiday is.businessday month   day
    ##   <date>     <lgl>      <lgl>      <lgl>          <dbl> <int>
    ## 1 2021-11-15 FALSE      FALSE      TRUE              11    15
    ## 2 2021-12-15 FALSE      FALSE      TRUE              12    15
    ## 3 2022-01-18 FALSE      FALSE      TRUE               1    18
    ## 4 2022-02-15 FALSE      FALSE      TRUE               2    15
    ## 5 2022-03-15 FALSE      FALSE      TRUE               3    15
    ## 6 2022-04-15 FALSE      FALSE      TRUE               4    15

And there we have it\! We can pull the list of the all the reporting
dates using `pull()`.

``` r
  #pull list of dates
  df_subm %>% 
    pull(date)
```

    ##  [1] "2021-11-15" "2021-12-15" "2022-01-18" "2022-02-15" "2022-03-15"
    ##  [6] "2022-04-15" "2022-05-16" "2022-06-15" "2022-07-15" "2022-08-15"
    ## [11] "2022-09-15" "2022-10-17"

### Review Materials

  - [Lubridate
    Cheatsheet](https://github.com/rstudio/cheatsheets/blob/main/lubridate.pdf)
  - [dplyr
    Cheatsheet](chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://nyu-cdsc.github.io/learningr/assets/data-transformation.pdf)
