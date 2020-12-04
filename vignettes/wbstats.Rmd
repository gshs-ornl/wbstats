---
title: "wbstats"
output:
  md_document:
    variant: gfm
vignette: >
  %\VignetteIndexEntry{wbstats}
  %\VignetteEngine{knitr::knitr}
  %\VignetteEncoding{UTF-8}

---

<!-- README.md is generated from README.Rmd. Please edit that file -->





# wbstats: An R package for searching and downloading data from the World Bank API.

You can install:

The latest release version from CRAN with

```r
install.packages("wbstats")
```

or

The latest development version from github with

```r
devtools::install_github("nset-ornl/wbstats")
```

# Introduction

The World Bank^[<https://www.worldbank.org/>] is a tremendous source of global socio-economic data; spanning several decades and dozens of topics, it has the potential to shed light on numerous global issues. To help provide access to this rich source of information, The World Bank themselves, provide a well structured RESTful API. While this API is very useful for integration into web services and other high-level applications, it becomes quickly overwhelming for researchers who have neither the time nor the expertise to develop software to interface with the API. This leaves the researcher to rely on manual bulk downloads of spreadsheets of the data they are interested in. This too is can quickly become overwhelming, as the work is manual, time consuming, and not easily reproducible. The goal of the `wbstats` R-package is to provide a bridge between these alternatives and allow researchers to focus on their research questions and not the question of accessing the data. The `wbstats` R-package allows researchers to quickly search and download the data of their particular interest in a programmatic and reproducible fashion; this facilitates a seamless integration into their workflow and allows analysis to be quickly rerun on different areas of interest and with realtime access to the latest available data.

### Highlighted features of the `wbstats` R-package:

- Uses version 2 of the World Bank API that provides access to more indicators and metadata than the previous API version
- Access to all annual, quarterly, and monthly data available in the API
- Support for searching and downloading data in multiple languages
- Returns data in either wide (default) or long format
- Support for Most Recent Value queries
- Support for `grep` style searching for data descriptions and names
- Ability to download data not only by country, but by aggregates as well, such as High Income or South Asia

# Getting Started

Unless you know the country and indicator codes that you want to download the first step would be searching for the data you are interested in. `wb_search()` provides `grep` style searching of all available indicators from the World Bank API and returns the indicator information that matches your query.

To access what countries or regions are available you can use the `countries` data frame from either `wb_cachelist` or the saved return from `wb_cache()`. This data frame contains relevant information regarding each country or region. More information on how to use this for downloading data is covered later.

## Finding available data with `wb_cachelist`

For performance and ease of use, a cached version of useful information is provided with the `wbstats` R-package. This data is called `wb_cachelist` and provides a snapshot of available countries, indicators, and other relevant information. `wb_cachelist` is by default the the source from which `wb_search()` and `wb_data()` uses to find matching information. The structure of `wb_cachelist` is as follows

```r
library(wbstats)

str(wb_cachelist, max.level = 1)
#> List of 8
#>  $ countries    : tibble [304 x 18] (S3: tbl_df/tbl/data.frame)
#>  $ indicators   : tibble [16,649 x 8] (S3: tbl_df/tbl/data.frame)
#>  $ sources      : tibble [63 x 9] (S3: tbl_df/tbl/data.frame)
#>  $ topics       : tibble [21 x 3] (S3: tbl_df/tbl/data.frame)
#>  $ regions      : tibble [48 x 4] (S3: tbl_df/tbl/data.frame)
#>  $ income_levels: tibble [7 x 3] (S3: tbl_df/tbl/data.frame)
#>  $ lending_types: tibble [4 x 3] (S3: tbl_df/tbl/data.frame)
#>  $ languages    : tibble [23 x 3] (S3: tbl_df/tbl/data.frame)
```

## Accessing updated available data with `wb_cache()`

For the most recent information on available data from the World Bank API `wb_cache()` downloads an updated version of the information stored in `wb_cachelist`. `wb_cachelist` is simply a saved return of `wb_cache(lang = "en")`. To use this updated information in  `wb_search()` or `wb_data()`, set the `cache` parameter to the saved `list` returned from `wb_cache()`. It is always a good idea to use this updated information to insure that you have access to the latest available information, such as newly added indicators or data sources. There are also cases in which indicators that were previously available from the API have been removed or deprecated.


```r
library(wbstats)

# default language is english
new_cache <- wb_cache()
```

## Search available data with `wb_search()`

`wb_search()` searches through the `indicators` data frame to find indicators that match a search pattern. An example of the structure of this data frame is below

```
#> # A tibble: 2 x 8
#>   indicator_id  indicator   unit  indicator_desc                                    source_org                                   topics   source_id source     
#>   <chr>         <chr>       <lgl> <chr>                                             <chr>                                        <list>       <dbl> <chr>      
#> 1 NY.GDP.MKTP.~ GDP (curre~ NA    GDP at purchaser's prices is the sum of gross va~ World Bank national accounts data, and OECD~ <df[,2]~         2 World Deve~
#> 2 SP.POP.TOTL   Population~ NA    Total population is based on the de facto defini~ (1) United Nations Population Division. Wor~ <df[,2]~         2 World Deve~
```

By default the search is done over the `indicator_id`, `indicator`, and `indicator_desc` fields and returns the those 3 columns of the matching rows. The `indicator_id` values are inputs into `wb_data()`, the function for downloading the data. To return all columns for the `indicators` data frame, you can set `extra = TRUE`.

```r
library(wbstats)

unemploy_inds<- wb_search("unemployment")

head(unemploy_inds)
#> # A tibble: 6 x 3
#>   indicator_id indicator                                         indicator_desc                                                                                
#>   <chr>        <chr>                                             <chr>                                                                                         
#> 1 fin37.t.a    Received government transfers in the past year (~ The percentage of respondents who report personally receiving any financial support from the ~
#> 2 fin37.t.a.1  Received government transfers in the past year, ~ The percentage of respondents who report personally receiving any financial support from the ~
#> 3 fin37.t.a.10 Received government transfers in the past year, ~ The percentage of respondents who report personally receiving any financial support from the ~
#> 4 fin37.t.a.11 Received government transfers in the past year, ~ The percentage of respondents who report personally receiving any financial support from the ~
#> 5 fin37.t.a.2  Received government transfers in the past year, ~ The percentage of respondents who report personally receiving any financial support from the ~
#> 6 fin37.t.a.3  Received government transfers in the past year, ~ The percentage of respondents who report personally receiving any financial support from the ~
```

Other fields can be searched by simply changing the `fields` parameter. For example

```r
library(wbstats)

blmbrg_vars <- wb_search("Bloomberg", fields = "source_org")

head(blmbrg_vars)
#> # A tibble: 2 x 3
#>   indicator_id indicator                     indicator_desc                                                                                                    
#>   <chr>        <chr>                         <chr>                                                                                                             
#> 1 GFDD.OM.02   Stock market return (%, year~ Stock market return is the growth rate of annual average stock market index. Annual average stock market index is~
#> 2 GFDD.SM.01   Stock price volatility        Stock price volatility is the average of the 360-day volatility of the national stock market index.
```

Regular expressions are also supported

```r
library(wbstats)

# 'poverty' OR 'unemployment' OR 'employment'
povemply_inds <- wb_search(pattern = "poverty|unemployment|employment")

head(povemply_inds)
#> # A tibble: 6 x 3
#>   indicator_id       indicator                     indicator_desc                                                                                              
#>   <chr>              <chr>                         <chr>                                                                                                       
#> 1 1.0.HCount.1.90usd Poverty Headcount ($1.90 a d~ The poverty headcount index measures the proportion of the population with daily per capita income (in 2011~
#> 2 1.0.HCount.2.5usd  Poverty Headcount ($2.50 a d~ The poverty headcount index measures the proportion of the population with daily per capita income (in 2005~
#> 3 1.0.HCount.Mid10t~ Middle Class ($10-50 a day) ~ The poverty headcount index measures the proportion of the population with daily per capita income (in 2005~
#> 4 1.0.HCount.Ofcl    Official Moderate Poverty Ra~ The poverty headcount index measures the proportion of the population with daily per capita income below th~
#> 5 1.0.HCount.Poor4u~ Poverty Headcount ($4 a day)  The poverty headcount index measures the proportion of the population with daily per capita income (in 2005~
#> 6 1.0.HCount.Vul4to~ Vulnerable ($4-10 a day) Hea~ The poverty headcount index measures the proportion of the population with daily per capita income (in 2005~
```

As well as any `grep` function argument

```r
library(wbstats)

# contains "gdp" and NOT "trade"
gdp_no_trade_inds <- wb_search("^(?=.*gdp)(?!.*trade).*", perl = TRUE)

head(gdp_no_trade_inds)
#> # A tibble: 6 x 3
#>   indicator_id     indicator                            indicator_desc                                                                                         
#>   <chr>            <chr>                                <chr>                                                                                                  
#> 1 5.51.01.10.gdp   Per capita GDP growth                GDP per capita is the sum of gross value added by all resident producers in the economy plus any produ~
#> 2 6.0.GDP_current  GDP (current $)                      GDP is the sum of gross value added by all resident producers in the economy plus any product taxes an~
#> 3 6.0.GDP_growth   GDP growth (annual %)                Annual percentage growth rate of GDP at market prices based on constant local currency. Aggregates are~
#> 4 6.0.GDP_usd      GDP (constant 2005 $)                GDP is the sum of gross value added by all resident producers in the economy plus any product taxes an~
#> 5 6.0.GDPpc_const~ GDP per capita, PPP (constant 2011 ~ GDP per capita based on purchasing power parity (PPP). PPP GDP is gross domestic product converted to ~
#> 6 BI.WAG.TOTL.GD.~ Wage bill as a percentage of GDP     <NA>
```


The default cached data in `wb_cachelist` is in English. To search indicators in a different language, you can download an updated copy of `wb_cachelist` using `wb_cache()`, with the `lang` parameter set to the language of interest and then set this as the `cache` parameter in `wb_search()`. Other languages are supported in so far as they are supported by the original data sources. Some sources provide full support for other languages, while some have very limited support. If the data source does not have a translation for a certain field or indicator then the result is `NA`, this may result in a varying number matches depending upon the language you select. To see a list of availabe languages call `wb_languages()`

```r
library(wbstats)

wb_langs <- wb_languages()
```

## Downloading data with `wb_data()`

Once you have found the set of indicators that you would like to explore further, the next step is downloading the data with `wb_data()`. The following examples are meant to highlight the different ways in which `wb_data()` can be used and demonstrate the major optional parameters.

The default value for the `country` parameter is a special value of `"countries_only"`, which as you might expect, returns data on the selected `indicator` for only countries. This is in contrast to `country = "all"` or `country = "regions_only"` which would return data for countries and regional aggregates together, or only regional aggregates, respectively

```r
library(wbstats)

# Population, total
pop_data <- wb_data("SP.POP.TOTL", start_date = 2000, end_date = 2002)

head(pop_data)
#> # A tibble: 6 x 9
#>   iso2c iso3c country      date SP.POP.TOTL unit  obs_status footnote last_updated
#>   <chr> <chr> <chr>       <dbl>       <dbl> <chr> <chr>      <chr>    <date>      
#> 1 AW    ABW   Aruba        2000       90853 <NA>  <NA>       <NA>     2020-10-15  
#> 2 AW    ABW   Aruba        2001       92898 <NA>  <NA>       <NA>     2020-10-15  
#> 3 AW    ABW   Aruba        2002       94992 <NA>  <NA>       <NA>     2020-10-15  
#> 4 AF    AFG   Afghanistan  2000    20779953 <NA>  <NA>       <NA>     2020-10-15  
#> 5 AF    AFG   Afghanistan  2001    21606988 <NA>  <NA>       <NA>     2020-10-15  
#> 6 AF    AFG   Afghanistan  2002    22600770 <NA>  <NA>       <NA>     2020-10-15
```

If you are interested in only some subset of countries or regions you can pass along the specific codes to the `country` parameter. The country and region codes and names that can be passed to the `country` parameter as well, most prominently the coded values from the `iso2c` and `iso3c` from the `countries` data frame in `wb_cachelist` or the return of `wb_cache()`. Any values from the above columns can mixed together and passed to the same call

```r
library(wbstats)

# you can mix different ids and they are case insensitive
# you can even use SpOnGeBoB CaSe if that's the kind of thing you're into
# iso3c, iso2c, country, region_iso3c, admin_region_iso3c, admin_region, income_level
example_geos <- c("ABW","AF", "albania", "SSF", "eca", "South Asia", "HiGh InCoMe")
pop_data <- wb_data("SP.POP.TOTL", country = example_geos,
                    start_date = 2012, end_date = 2012)

pop_data
#> # A tibble: 7 x 9
#>   iso2c iso3c country                                        date SP.POP.TOTL unit  obs_status footnote last_updated
#>   <chr> <chr> <chr>                                         <dbl>       <dbl> <chr> <chr>      <chr>    <date>      
#> 1 AW    ABW   Aruba                                          2012      102560 <NA>  <NA>       <NA>     2020-10-15  
#> 2 AF    AFG   Afghanistan                                    2012    31161376 <NA>  <NA>       <NA>     2020-10-15  
#> 3 AL    ALB   Albania                                        2012     2900401 <NA>  <NA>       <NA>     2020-10-15  
#> 4 7E    ECA   Europe & Central Asia (excluding high income)  2012   382509766 <NA>  <NA>       <NA>     2020-10-15  
#> 5 8S    SAS   South Asia                                     2012  1683747130 <NA>  <NA>       <NA>     2020-10-15  
#> 6 ZG    SSF   Sub-Saharan Africa                             2012   917726973 <NA>  <NA>       <NA>     2020-10-15  
#> 7 <NA>  XD    High income                                    2012  1191504227 <NA>  <NA>       <NA>     2020-10-15
```

As of `wbstats 1.0` queries are now returned in wide format. This was a request made by multiple users and is in line with the principles of [tidy data](https://www.jstatsoft.org/article/view/v059i10). If you would like to return the data in a long format, you can set `return_wide = FALSE`

Now that each indicator is it's own column, we can allow custom names for the indicators

```r
library(wbstats)

my_indicators = c("pop" = "SP.POP.TOTL",
                  "gdp" = "NY.GDP.MKTP.CD")

pop_gdp <- wb_data(my_indicators, start_date = 2010, end_date = 2012)

head(pop_gdp)
#> # A tibble: 6 x 6
#>   iso2c iso3c country      date          gdp      pop
#>   <chr> <chr> <chr>       <dbl>        <dbl>    <dbl>
#> 1 AW    ABW   Aruba        2010  2390502793.   101669
#> 2 AW    ABW   Aruba        2011  2549720670.   102046
#> 3 AW    ABW   Aruba        2012  2534636872.   102560
#> 4 AF    AFG   Afghanistan  2010 15856574731. 29185507
#> 5 AF    AFG   Afghanistan  2011 17804292964. 30117413
#> 6 AF    AFG   Afghanistan  2012 20001598506. 31161376
```

You'll notice that when you query only one indicator, as in the first two examples above, it returns the extra fields `unit`, `obs_status`, `footnote`, and `last_updated`, but when we queried multiple indicators at once, as in our last example, they are dropped. This is because those extra fields are tied to a specific observation of a single indicator and when we have multiple indciator values in a single row, they are no longer consistent with the tidy data format. If you would like that information for multiple indicators, you can use `return_wide = FALSE`

```r
library(wbstats)

my_indicators = c("pop" = "SP.POP.TOTL",
                  "gdp" = "NY.GDP.MKTP.CD")

pop_gdp_long <- wb_data(my_indicators, start_date = 2010, end_date = 2012, return_wide = FALSE)

head(pop_gdp_long)
#> # A tibble: 6 x 11
#>   indicator_id indicator         iso2c iso3c country      date    value unit  obs_status footnote last_updated
#>   <chr>        <chr>             <chr> <chr> <chr>       <dbl>    <dbl> <chr> <chr>      <chr>    <date>      
#> 1 SP.POP.TOTL  Population, total AF    AFG   Afghanistan  2012 31161376 <NA>  <NA>       <NA>     2020-10-15  
#> 2 SP.POP.TOTL  Population, total AF    AFG   Afghanistan  2011 30117413 <NA>  <NA>       <NA>     2020-10-15  
#> 3 SP.POP.TOTL  Population, total AF    AFG   Afghanistan  2010 29185507 <NA>  <NA>       <NA>     2020-10-15  
#> 4 SP.POP.TOTL  Population, total AL    ALB   Albania      2012  2900401 <NA>  <NA>       <NA>     2020-10-15  
#> 5 SP.POP.TOTL  Population, total AL    ALB   Albania      2011  2905195 <NA>  <NA>       <NA>     2020-10-15  
#> 6 SP.POP.TOTL  Population, total AL    ALB   Albania      2010  2913021 <NA>  <NA>       <NA>     2020-10-15
```


### Using `mrv` and `mrnev`
If you do not know the latest date an indicator you are interested in is available for you country you can use the `mrv` instead of `start_date` and `end_date`. `mrv` stands for most recent value and takes a `integer` corresponding to the number of most recent values you wish to return

```r
library(wbstats)

# most recent gdp per captia estimates
gdp_capita <- wb_data("NY.GDP.PCAP.CD", mrv = 1)

head(gdp_capita)
#> # A tibble: 6 x 9
#>   iso2c iso3c country               date NY.GDP.PCAP.CD unit  obs_status footnote last_updated
#>   <chr> <chr> <chr>                <dbl>          <dbl> <chr> <chr>      <chr>    <date>      
#> 1 AW    ABW   Aruba                 2019            NA  <NA>  <NA>       <NA>     2020-10-15  
#> 2 AF    AFG   Afghanistan           2019           502. <NA>  <NA>       <NA>     2020-10-15  
#> 3 AO    AGO   Angola                2019          2974. <NA>  <NA>       <NA>     2020-10-15  
#> 4 AL    ALB   Albania               2019          5353. <NA>  <NA>       <NA>     2020-10-15  
#> 5 AD    AND   Andorra               2019         40886. <NA>  <NA>       <NA>     2020-10-15  
#> 6 AE    ARE   United Arab Emirates  2019         43103. <NA>  <NA>       <NA>     2020-10-15
```

Often it is the case that the latest available data is different from country to country. There may be 2020 estimates for one location, while another only has estimates up to 2019. This is especially true for survey data. When you would like to return the latest avialble data for each country regardless of its temporal misalignment, you can use the `mrnev` instead of `mrnev`. `mrnev` stands for most recent non empty value.

```r
library(wbstats)

gdp_capita <- wb_data("NY.GDP.PCAP.CD", mrnev = 1)

head(gdp_capita)
#> # A tibble: 6 x 8
#>   iso2c iso3c country               date NY.GDP.PCAP.CD obs_status footnote last_updated
#>   <chr> <chr> <chr>                <dbl>          <dbl> <chr>      <chr>    <date>      
#> 1 AW    ABW   Aruba                 2017         29008. <NA>       <NA>     2020-10-15  
#> 2 AF    AFG   Afghanistan           2019           502. <NA>       <NA>     2020-10-15  
#> 3 AO    AGO   Angola                2019          2974. <NA>       <NA>     2020-10-15  
#> 4 AL    ALB   Albania               2019          5353. <NA>       <NA>     2020-10-15  
#> 5 AD    AND   Andorra               2019         40886. <NA>       <NA>     2020-10-15  
#> 6 AE    ARE   United Arab Emirates  2019         43103. <NA>       <NA>     2020-10-15
```

### Dates
Because the majority of data available from the World Bank is at the annual resolution, by default dates in `wbstats` are returned as `numeric`s. This default makes common tasks like filtering easier. If you would like the date field to be of class `Date` you can set `date_as_class_date = TRUE`

# Some Sharp Corners
There are a few behaviors of the World Bank API that being aware of could help explain some potentially unexpected results. These results are known but no special actions are taken to mitigate them as they are the result of the API itself and artifically limiting the inputs or results could potentially causes problems or create unnecessary rescrictions in the future.


## Searching in other languages
Not all data sources support all languages. If an indicator does not have a translation for a particular language, the non-supported fields will return as `NA`. This could potentially result in a differing number of matching indicators from `wb_search()`

```r
library(wbstats)

# english
cache_en <- wb_cache()
sum(is.na(cache_en$indicators$indicator))
#> [1] 0

# spanish
cache_es <- wb_cache(lang = "es")
sum(is.na(cache_es$indicators$indicator))
#> [1] 14791
```


# Legal
The World Bank Group, or any of its member instutions, do not support or endorse this software and are not libable for any findings or conclusions that come from the use of this software.
