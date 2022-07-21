---
title: "RBBS - 4 Tidy Data"
author: "Karishma Srikanth"
date: '2022-03-07'
layout: post
categories:
- corps
- rbbs
tags: r
thumbnail: 20220307_rbbs_4-tidy.png
---

Part 4 of the coRps R Building Blocks Series (RBBS). All content can be found on this blog under the `rbbs` category as well as on the [USAID-OHA-SI/coRps GitHub repo](https://github.com/USAID-OHA-SI/coRps).


## RBBS 4 - Tidy Data

For our R Building Blocks session today, we will focus on understanding
what tidy data is, why it matters, and how to use `tidyr` in R to
wrangle data on your own. This session is modeled after [Chapter 12 of R
for Data Science](https://r4ds.had.co.nz/data-visualisation.html).

### Learning Objectives

    - Learn what tidy data is and the importance of tidy data
    - Learn how to recognize tidy vs. untidy data
    - Use `tidyr` to wrangle data in R

### Recording

You can use [this
link](https://drive.google.com/file/d/1i_zg4QpgtcxvK-w1QttSZzFHxp-pvuNA/view?usp=sharing)
to access today’s recording.

### Materials

<iframe src="https://docs.google.com/presentation/d/e/2PACX-1vQEUv1LwmSMkvpE5G-fRBbrLOykd2fNe7OVblF0u-m2GVr7ExYFZwh8OUPAG-JUh6rDZQX1jaWPflQ1/embed?start=false&loop=false&delayms=3000" frameborder="0" width="960" height="569" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>

### Setup

For these sessions, we’ll be using RStudio which is an IDE, “Integrated
development environment” that makes it easier to work with R. For help
on getting setup and installing packages, please reference [this
guide](https://usaid-oha-si.github.io/corps/rbbs/2022/01/28/rbbs-0-setup.html).

### Load Packages

Let’s get started by loading some important packages. When we load the
`tidyverse`, you’ll notice that a couple other packages are being loaded
as well, including `tidyr()`, the main set of tools to tidy data. We’ll
focus more in depth on how to use the `tidyverse` toolkit in next week’s
session.

``` r
library(tidyverse) #install.packages("tidyverse")
```

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --

    ## v ggplot2 3.3.5     v purrr   0.3.4
    ## v tibble  3.1.6     v dplyr   1.0.8
    ## v tidyr   1.2.0     v stringr 1.4.0
    ## v readr   2.1.2     v forcats 0.5.1

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(scales) #install.packages("scales")
library(glitr) #remotes::install_github("USAID-OHA-SI/glitr", build_vignettes = TRUE)
library(glamr)
library(here)
library(readxl)
```

### Basics of Tidy Data

In this session, we’ll talk about organizing data in an efficient,
reproducible, and collaborative way, known as Tidy Data. While this
process takes some upfront work and deliberate thought about data
structure, this work pays off today and in the long-run. By having data
in a tidy format and utilizing the tool in the `tidyverse`, you’ll spend
less time working on and munging messy data and have more time to focus
on the analytic questions.

So what is tidy data?

**Tidy data** is a standard way of mapping the meaning of a dataset to
its structure. There are 3 central components to tidy data.

1.  Each variable forms a column
2.  Each observation forms a row
3.  Each cell is a measurement

Let’s take a look at this visually using sample data from the `glitr`
package with `glimpse()`, `head()`, and `View()`.

``` r
#load the dataset in your Global Environment
data(hts)
```

``` r
#prints out a preview of your data; indicators run vertically (with type) and data runs horizontally
glimpse(hts)
```

    ## Rows: 1,695
    ## Columns: 7
    ## $ operatingunit <chr> "Saturn", "Saturn", "Saturn", "Saturn", "Saturn", "Satur~
    ## $ primepartner  <chr> "Auriga", "Auriga", "Auriga", "Auriga", "Auriga", "Aurig~
    ## $ indicator     <chr> "HTS_TST", "HTS_TST", "HTS_TST", "HTS_TST", "HTS_TST", "~
    ## $ modality      <chr> "Index", "Index", "IndexMod", "IndexMod", "Inpat", "Inpa~
    ## $ period        <chr> "FY49", "FY50", "FY49", "FY50", "FY49", "FY50", "FY49", ~
    ## $ period_type   <chr> "targets", "targets", "targets", "targets", "targets", "~
    ## $ value         <dbl> 3080, 6880, 890, 780, 6550, 2170, 870, 2900, 1200, 1690,~

``` r
head(hts)
```

    ## # A tibble: 6 x 7
    ##   operatingunit primepartner indicator modality period period_type value
    ##   <chr>         <chr>        <chr>     <chr>    <chr>  <chr>       <dbl>
    ## 1 Saturn        Auriga       HTS_TST   Index    FY49   targets      3080
    ## 2 Saturn        Auriga       HTS_TST   Index    FY50   targets      6880
    ## 3 Saturn        Auriga       HTS_TST   IndexMod FY49   targets       890
    ## 4 Saturn        Auriga       HTS_TST   IndexMod FY50   targets       780
    ## 5 Saturn        Auriga       HTS_TST   Inpat    FY49   targets      6550
    ## 6 Saturn        Auriga       HTS_TST   Inpat    FY50   targets      2170

``` r
#your traditional tabular view
View(hts)
```

This is an example of a tidy dataset. Each row is a distinct reporting
period (contained in the variable `period`) with information on where
the data were reported (in `operatingunit`) and by whom
(`primepartner`). Each column is a variable, showing testing indicators
across the Modality/Age/Sex/Result disaggregations and the value in the
`value` column. For more information on the dataset, we can use the `?`
to see the documentation through a “help” file. The `?` is extremely
useful for getting help files across all functions.

### Data Structure

Once we have the value, observation, and variable defined, we can start
to talk more about how these elements are physically structured in the
dataset. Dataset structure refers to the physical layout of the data,
both in how it is physically structured and how it appears in the sheet
when you open it.

Data CAN be structured in many ways, but ideally it is structured as
either long or wide.

**Long (stacked/panel)** data stacks the data. For example, the
measurement (period) in this dataset have been stored in a cell rather
than a column name for `FY49` an `FY50`. Value refers to the number of
individuals tested.

``` r
#prints out a preview of your data; indicators run vertically (with type) and data runs horizontally

head(hts)
```

    ## # A tibble: 6 x 7
    ##   operatingunit primepartner indicator modality period period_type value
    ##   <chr>         <chr>        <chr>     <chr>    <chr>  <chr>       <dbl>
    ## 1 Saturn        Auriga       HTS_TST   Index    FY49   targets      3080
    ## 2 Saturn        Auriga       HTS_TST   Index    FY50   targets      6880
    ## 3 Saturn        Auriga       HTS_TST   IndexMod FY49   targets       890
    ## 4 Saturn        Auriga       HTS_TST   IndexMod FY50   targets       780
    ## 5 Saturn        Auriga       HTS_TST   Inpat    FY49   targets      6550
    ## 6 Saturn        Auriga       HTS_TST   Inpat    FY50   targets      2170

**Wide** spreads the data out to the right with many columns. Here, each
observation is based on a OU + primepartner + indicator + modality +
period\_type. Unit of measurement is the number of individuals tested in
each quarter. We can use `tidyr::pivot_wider` to pivot this HTS data
wide.

``` r
#Pivot data wide

hts_wide <- hts %>% 
  pivot_wider(names_from= period, values_from = value)

head(hts_wide)
```

    ## # A tibble: 6 x 12
    ##   operatingunit primepartner indicator modality   period_type  FY49  FY50 FY49Q1
    ##   <chr>         <chr>        <chr>     <chr>      <chr>       <dbl> <dbl>  <dbl>
    ## 1 Saturn        Auriga       HTS_TST   Index      targets      3080  6880     NA
    ## 2 Saturn        Auriga       HTS_TST   IndexMod   targets       890   780     NA
    ## 3 Saturn        Auriga       HTS_TST   Inpat      targets      6550  2170     NA
    ## 4 Saturn        Auriga       HTS_TST   Malnutrit~ targets       870    NA     NA
    ## 5 Saturn        Auriga       HTS_TST   MobileMod  targets      2900  1200     NA
    ## 6 Saturn        Auriga       HTS_TST   OtherMod   targets      1690   780     NA
    ## # ... with 4 more variables: FY50Q1 <dbl>, FY49Q2 <dbl>, FY49Q3 <dbl>,
    ## #   FY49Q4 <dbl>

What are the advantages of working with **long data**? First, most
visualization/statistical software/Excel is designed to work with long
data. Long data can easily be filtered, pivoted, or analyzed. Row
optimization facilitates analysis.

As a rule of thumb, if a column name contains data on which you wish to
sort, then it should likely be stored in a cell instead of a column
name.

Sometimes, you’ll see a mixture of these two styles which is not ideal.

#### Pivoting Data

When you are pivoting a dataset, you are restructuring the physical
layout into an manner. Stacking columns into new rows and creating new
columns to collect the values that have been transposed.

The column headers are transposed into one column and the values are all
stored in one column now, making the data tidy and easier to work with.

The process of physically altering the layout of a dataset by stacking
columns into new rows and creating new columns to collect the values
that have been transposed.

NOTICE: once the date are pivoted to a long format, you can easily
filter by the primepartner + period. In the WIDE data, if you are
“filtering” on the quarter, you will be turning columns on and off.
This is cumbersome if you have many columns and not always transparent.

To perform pivots in R, there are two primary functions:

1.  `pivot_longer()` - pivots your data long (stacked)
2.  `pivot_wider()` - pivots your data wide (columns)

### What about the MSDs?

The MSDs are semi-tidy datasets rather than tidy. This was a conscious
decision to strike a balance between row length and a full-long dataset.
To play around with it, load the most recent OUxIM dataset.You can
manually download it from [PEPFAR
Panorama](https://www.pepfar-panorama.org/) or follow the steps in the
`glamr` vignette, called [“Data Extraction from
Panorama”](https://usaid-oha-si.github.io/glamr/articles/data-extraction-from-panorama.html).

Two features that are not tidy were (1) periods, which each their own
column (qtr1, qtr2, qtr3, qtr4), and (2) categoryoptioncombos, which
combined all the useful information like disaggregation, age, sex,
status, etc.

As such, if you were performing analytics on the MSD, you may find
yourself having to pivot and reshape the data accordingly. Another
helpful function built by SI is the `glamr::reshape_msd()` function in
the `glamr` package, that transforms the MSD into a tidy format.

### Working with Messy Data in R

Now that we know what a tidy dataset looks like, let’s dive deeper into
some messy data to see if we can identify some key threats to tidy data.
The goal of this exercise is not to learn all the ways to tidy the data
in R just yet, but rather to give you an intuition about what the
barriers to tidyness are and how we could think through fixing these.

#### UNAIDS Data

Let’s start with the UNAIDS 2020 Estimate data, which we often use
within our office to answer analytic questions about epidemic control
and progress to the 90’s/95’s goals. Our team munged and tidied this
data this year and a detailed understanding of the dataset and data
cleaning process can be found on the the [MindTheGap
website](https://usaid-oha-si.github.io/mindthegap/).

We’ll read in the data in the same format as how it exists on our Google
Drive (feel free to download as an .xlsx file and use
`readxl::read_xlsx()` or pull directly from Google Drive with
`googlesheets4::read_sheet()`), and use the `View()` function to see how
the data are imported in R.

``` r
file_name <- "HIV_estimates_from_1990-to-present.xlsx"

df <-  readxl::read_xlsx(
      path = here("2022-03-07",file_name),
      sheet = 1)

view(df)

head(df, n = 15L)
```

    ## # A tibble: 15 x 51
    ##    `HIV estimates ~` ...2  ...3  ...4  ...5  ...6  ...7  ...8  ...9  ...10 ...11
    ##    <chr>             <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
    ##  1 1990-2020         <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ##  2 Source: UNAIDS 2~ <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ##  3 <NA>              <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ##  4 <NA>              <NA>  <NA>  Adul~ <NA>  <NA>  Youn~ <NA>  <NA>  Youn~ <NA> 
    ##  5 <NA>              <NA>  <NA>  Esti~ Low   High  Esti~ Low   High  Esti~ Low  
    ##  6 1990.0            <NA>  Glob~ 0.3   0.2   0.3   0.2   0.1   0.4   0.1   <0.1 
    ##  7 1990.0            <NA>  Asia~ <0.1  <0.1  <0.1  <0.1  <0.1  <0.1  <0.1  <0.1 
    ##  8 1990.0            AFG   Afgh~ <0.1  <0.1  <0.1  <0.1  <0.1  <0.1  <0.1  <0.1 
    ##  9 1990.0            AUS   Aust~ <0.1  <0.1  0.1   <0.1  <0.1  <0.1  <0.1  <0.1 
    ## 10 1990.0            BGD   Bang~ ...   ...   ...   ...   ...   ...   ...   ...  
    ## 11 1990.0            BTN   Bhut~ <0.1  <0.1  <0.1  <0.1  <0.1  <0.1  <0.1  <0.1 
    ## 12 1990.0            BRN   Brun~ ...   ...   ...   ...   ...   ...   ...   ...  
    ## 13 1990.0            KHM   Camb~ <0.1  <0.1  <0.1  <0.1  <0.1  <0.1  <0.1  <0.1 
    ## 14 1990.0            CHN   China ...   ...   ...   ...   ...   ...   ...   ...  
    ## 15 1990.0            PRK   Demo~ ...   ...   ...   ...   ...   ...   ...   ...  
    ## # ... with 40 more variables: ...12 <chr>, ...13 <chr>, ...14 <chr>,
    ## #   ...15 <chr>, ...16 <chr>, ...17 <chr>, ...18 <chr>, ...19 <chr>,
    ## #   ...20 <chr>, ...21 <chr>, ...22 <chr>, ...23 <chr>, ...24 <chr>,
    ## #   ...25 <chr>, ...26 <chr>, ...27 <chr>, ...28 <chr>, ...29 <chr>,
    ## #   ...30 <chr>, ...31 <chr>, ...32 <chr>, ...33 <chr>, ...34 <chr>,
    ## #   ...35 <chr>, ...36 <chr>, ...37 <chr>, ...38 <chr>, ...39 <chr>,
    ## #   ...40 <chr>, ...41 <chr>, ...42 <chr>, ...43 <chr>, ...44 <chr>, ...

We need to skip quite a few rows, 5 to be exact, since our table header
start on row 6. However, we have another issue here, where the indicator
is encoded in row 5 (Adults (15-49) prevalence (%)) but the breakdown in
estimate and confidence interval is on row 6. As such, if we skip 5 rows
with `readxl::read_xlsx(path = here("2022-03-07",file_name), sheet = 1,
skip = 5)`, we will lose the meaning of the indicators.

To circumvent this, our team created a indicator names cross walk when
we began tidying up this data. For the purpose of this session, the
detailed process of how we renamed and joined these elements is less
important - for now, let’s just take a look at the dataset after
addressing the indicator name issue and identify what is left to address
to make this data tidy.

``` r
file_name <- "unaids-semi-clean.csv"


df_semi <-  read_csv(
      file = here("2022-03-07",file_name))


view(df_semi)

head(df_semi, n = 15L)
```

    ## # A tibble: 15 x 51
    ##     year iso   country        `prev_15-49_al~` `prev_15-49_al~` `prev_15-49_al~`
    ##    <dbl> <chr> <chr>          <chr>            <chr>            <chr>           
    ##  1  1990 <NA>  Global         0.3              0.2              0.3             
    ##  2  1990 <NA>  Asia and the ~ <0.1             <0.1             <0.1            
    ##  3  1990 AFG   Afghanistan    <0.1             <0.1             <0.1            
    ##  4  1990 AUS   Australia      <0.1             <0.1             0.1             
    ##  5  1990 BGD   Bangladesh     ...              ...              ...             
    ##  6  1990 BTN   Bhutan         <0.1             <0.1             <0.1            
    ##  7  1990 BRN   Brunei Daruss~ ...              ...              ...             
    ##  8  1990 KHM   Cambodia       <0.1             <0.1             <0.1            
    ##  9  1990 CHN   China          ...              ...              ...             
    ## 10  1990 PRK   Democratic Pe~ ...              ...              ...             
    ## 11  1990 FJI   Fiji           <0.1             <0.1             <0.1            
    ## 12  1990 IND   India          ...              ...              ...             
    ## 13  1990 IDN   Indonesia      <0.1             <0.1             <0.1            
    ## 14  1990 JPN   Japan          <0.1             <0.1             <0.1            
    ## 15  1990 LAO   Lao People De~ <0.1             <0.1             <0.1            
    ## # ... with 45 more variables: `prev_15-24_female_est` <chr>,
    ## #   `prev_15-24_female_low` <chr>, `prev_15-24_female_high` <chr>,
    ## #   `prev_15-24_male_est` <chr>, `prev_15-24_male_low` <chr>,
    ## #   `prev_15-24_male_high` <chr>, deaths_all_all_est <chr>,
    ## #   deaths_all_all_low <chr>, deaths_all_all_high <chr>,
    ## #   `deaths_0-14_all_est` <chr>, `deaths_0-14_all_low` <chr>,
    ## #   `deaths_0-14_all_high` <chr>, `deaths_15+_all_est` <chr>, ...

#### Exercises

1.  Using `View()`, what are some of the elements of this dataset that
    make it un-tidy?
2.  How would you begin to think through addressing some of these
    elements to make the data tidy?

Another useful function in the `tidyr` package is the `separate`
function. As you can see, our UNAIDS data has the age, sex, and
statistic type encoded into the indicator name. We can first pivot the
data long to have one stacked column for the indicator using
`pivot_longer()` and then use the `separate` function to split the
variables by the underscore into multiple different columns (indicator,
age, sex, and stat)

``` r
df_semi %>% 
  tidyr::pivot_longer(-c(year, iso, country),
                        names_to = c("indicator")) %>%
    tidyr::separate(indicator, sep = "_", into = c("indicator", "age", "sex", "stat")) %>% 
  head()
```

    ## # A tibble: 6 x 8
    ##    year iso   country indicator age   sex    stat  value
    ##   <dbl> <chr> <chr>   <chr>     <chr> <chr>  <chr> <chr>
    ## 1  1990 <NA>  Global  prev      15-49 all    est   0.3  
    ## 2  1990 <NA>  Global  prev      15-49 all    low   0.2  
    ## 3  1990 <NA>  Global  prev      15-49 all    high  0.3  
    ## 4  1990 <NA>  Global  prev      15-24 female est   0.2  
    ## 5  1990 <NA>  Global  prev      15-24 female low   0.1  
    ## 6  1990 <NA>  Global  prev      15-24 female high  0.4

While this is not perfectly tidy, we are getting closer. There are still
a couple other elements to address to tidy this up in its entirety,
including:

1.  Encoding the regions as their own variable rather than a row
2.  Addressing special characters (\< or \>)
3.  Addressing missing values
4.  Breaking down nested columns for stat type

For a more in-depth dive in how to tidy the UNAIDS data, check out our
[CoRps
session](https://drive.google.com/file/d/1DhtpDU3mTXZlLhb5yqyzjupOGJ_7rhhf/view)
about `munge_unaids`, the cleaning and tidying function that we built to
tidy this data.

### Additional Resources

For more practice with Tidy Datasets, check out our CoRps session on
[Working with Messy
Datasets](https://usaid-oha-si.github.io/corps/2021/03/15/Working-with-Messy-Spreadsheets.html).

For a good guide on how to use the `tidyr` functions, see [this
cheatsheet](https://github.com/rstudio/cheatsheets/blob/main/tidyr.pdf).

For some additional reading about tidy data, check out [Hadley Wickham’s
journal article about tidy
data](https://www.jstatsoft.org/article/view/v059i10) and [Data
Organization in Spreadsheets- Karl W. Broman & Kara H. Woo
(2018)](https://www.tandfonline.com/doi/full/10.1080/00031305.2017.1375989).

### Next Up

This session, we covered the foundational elements of tidy data from
Chapter 12 of R for Data Science. While this session offers a glimpse of
how to tidy data in R, we’ll dive deeper next week into learning the ins
and outs of Base R and the TidyVerse.
