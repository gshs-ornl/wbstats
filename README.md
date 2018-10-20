<!-- README.md is generated from README.Rmd. Please edit that file -->
wbstats: An R package for searching and downloading data from the World Bank API.
=================================================================================

You can install:

The latest release version from CRAN with

``` r
install.packages("wbstats")
```

or

The latest development version from github with

``` r
devtools::install_github("GIST-ORNL/wbstats")
```

Introduction
============

The World Bank[1] is a tremendous source of global socio-economic data; spanning several decades and dozens of topics, it has the potential to shed light on numerous global issues. To help provide access to this rich source of information, The World Bank themselves, provide a well structured RESTful API[2]. While this API is very useful for integration into web services and other high-level applications, it becomes quickly overwhelming for researchers who have neither the time nor the expertise to develop software to interface with the API. This leaves the researcher to rely on manual bulk downloads of spreadsheets of the data they are interested in. This too is can quickly become overwhelming, as the work is manual, time consuming, and not easily reproducible. The goal of the `wbstats` R-package is to provide a bridge between these alternatives and allow researchers to focus on their research questions and not the question of accessing the data. The `wbstats` R-package allows researchers to quickly search and download the data of their particular interest in a programmatic and reproducible fashion; this facilitates a seamless integration into their workflow and allows analysis to be quickly rerun on different areas of interest and with realtime access to the latest available data.

### Highlighted features of the `wbstats` R-package:

-   Uses version 2 of the World Bank API that provides access to more indicators and metadata than the previous API version
-   Access to all annual, quarterly, and monthly data available in the API
-   Support for searching and downloading data in multiple languages
-   Access to the World Bank Data Catalog Metadata, providing among other information; update schedules and supported languages
-   Ability to return `POSIXct` dates for easy integration into plotting and time-series analysis techniques
-   Returns data in either long (default) or wide format for direct integration with packages like `ggplot2` and `dplyr`
-   Support for Most Recent Value queries
-   Support for `grep` style searching for data descriptions and names
-   Ability to download data not only by country, but by aggregates as well, such as High Income or South Asia
-   Ability to specify `countries_only` or `aggregates` when querying data

Getting Started
===============

Unless you know the country and indicator codes that you want to download the first step would be searching for the data you are interested in. `wbsearch()` provides `grep` style searching of all available indicators from the World Bank API and returns the indicator information that matches your query.

To access what countries or regions are available you can use the `countries` data frame from either `wb_cachelist` or the saved return from `wbcache()`. This data frame contains relevant information regarding each country or region. More information on how to use this for downloading data is covered later.

Finding available data with `wb_cachelist`
------------------------------------------

For performance and ease of use, a cached version of useful information is provided with the `wbstats` R-package. This data is called `wb_cachelist` and provides a snapshot of available countries, indicators, and other relevant information. `wb_cachelist` is by default the the source from which `wbsearch()` and `wb()` uses to find matching information. The structure of `wb_cachelist` is as follows

``` r
library(wbstats)

str(wb_cachelist, max.level = 1)
#> List of 7
#>  $ countries  :'data.frame': 304 obs. of  18 variables:
#>  $ indicators :'data.frame': 16978 obs. of  7 variables:
#>  $ sources    :'data.frame': 43 obs. of  8 variables:
#>  $ datacatalog:'data.frame': 238 obs. of  29 variables:
#>  $ topics     :'data.frame': 21 obs. of  3 variables:
#>  $ income     :'data.frame': 7 obs. of  3 variables:
#>  $ lending    :'data.frame': 4 obs. of  3 variables:
```

Accessing updated available data with `wbcache()`
-------------------------------------------------

For the most recent information on available data from the World Bank API `wbcache()` downloads an updated version of the information stored in `wb_cachelist`. `wb_cachelist` is simply a saved return of `wbcache(lang = "en")`. To use this updated information in `wbsearch()` or `wb()`, set the `cache` parameter to the saved `list` returned from `wbcache()`. It is always a good idea to use this updated information to insure that you have access to the latest available information, such as newly added indicators or data sources.

``` r
library(wbstats)

# default language is english
new_cache <- wbcache()
```

Search available data with `wbsearch()`
---------------------------------------

`wbsearch()` searches through the `indicators` data frame to find indicators that match a search pattern. An example of the structure of this data frame is below

|      | indicatorID  | indicator                                                                                | unit | indicatorDesc                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | sourceOrg                       | sourceID | source               |
|------|:-------------|:-----------------------------------------------------------------------------------------|:-----|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------|:---------|:---------------------|
| 4310 | UIS.E.5.B    | Enrolment in tertiary education, ISCED 5 programmes, both sexes (number)                 | NA   | Total number of students enrolled in public and private short-cycle tertiary education programmes (ISCED 5).                                                                                                                                                                                                                                                                                                                                                                             | UNESCO Institute for Statistics | 12       | Education Statistics |
| 4311 | UIS.E.4.PU.F | Enrolment in post-secondary non-tertiary education, public institutions, female (number) | NA   | Total number of females enrolled in public post-secondary non-tertiary education institutions regardless of age. Public education Institutions are controlled and managed directly by a public education authority or agency of the country where it is located or by a government agency directly or by a governing body (council, committee etc.), most of whose members are either appointed by a public authority of the country where it is located or elected by public franchise. | UNESCO Institute for Statistics | 12       | Education Statistics |

By default the search is done over the `indicator` and `indicatorDesc` fields and returns the columns `indicatorID` and `indicator` of the matching rows. The `indicatorID` values are inputs into `wb()`, the function for downloading the data. To return all columns for the `indicators` data frame, you can set `extra = TRUE`.

``` r
library(wbstats)

unemploy_vars <- wbsearch(pattern = "unemployment")
head(unemploy_vars)
#>    indicatorID
#> 35   WP15177.9
#> 36   WP15177.8
#> 37   WP15177.7
#> 38   WP15177.6
#> 39   WP15177.5
#> 40   WP15177.4
#>                                                                                        indicator
#> 35         Received government transfers in the past year, income, richest 60% (% ages 15+) [w2]
#> 36         Received government transfers in the past year, income, poorest 40% (% ages 15+) [w2]
#> 37 Received government transfers in the past year, secondary education or more (% ages 15+) [w2]
#> 38   Received government transfers in the past year, primary education or less (% ages 15+) [w2]
#> 39                Received government transfers in the past year, older adults (% ages 25+) [w2]
#> 40              Received government transfers in the past year, young adults (% ages 15-24) [w2]
```

Other fields can be searched by simply changing the `fields` parameter. For example

``` r
library(wbstats)

blmbrg_vars <- wbsearch(pattern = "Bloomberg", fields = "sourceOrg")
head(blmbrg_vars)
#>        indicatorID                             indicator
#> 262   WHEAT_US_HRW        Wheat, US, HRW, $/mt, current$
#> 766       SUGAR_US         Sugar, US, cents/kg, current$
#> 2563  RUBBER1_MYSG Rubber, Singapore, cents/kg, current$
#> 9488    GFDD.SM.01                Stock price volatility
#> 9496    GFDD.OM.02 Stock market return (%, year-on-year)
#> 12003       BARLEY                Barley, $/mt, current$
```

Regular expressions are also supported.

``` r
library(wbstats)

# 'poverty' OR 'unemployment' OR 'employment'
povemply_vars <- wbsearch(pattern = "poverty|unemployment|employment")

head(povemply_vars)
#>    indicatorID
#> 35   WP15177.9
#> 36   WP15177.8
#> 37   WP15177.7
#> 38   WP15177.6
#> 39   WP15177.5
#> 40   WP15177.4
#>                                                                                        indicator
#> 35         Received government transfers in the past year, income, richest 60% (% ages 15+) [w2]
#> 36         Received government transfers in the past year, income, poorest 40% (% ages 15+) [w2]
#> 37 Received government transfers in the past year, secondary education or more (% ages 15+) [w2]
#> 38   Received government transfers in the past year, primary education or less (% ages 15+) [w2]
#> 39                Received government transfers in the past year, older adults (% ages 25+) [w2]
#> 40              Received government transfers in the past year, young adults (% ages 15-24) [w2]
```

The default cached data in `wb_cachelist` is in English. To search indicators in a different language, you can download an updated copy of `wb_cachelist` using `wbcache()`, with the `lang` parameter set to the language of interest and then set this as the `cache` parameter in `wbsearch()`. Other languages are supported in so far as they are supported by the original data sources. Some sources provide full support for other languages, while some have very limited support. If the data source does not have a translation for a certain field or indicator then the result is `NA`, this may result in a varying number matches depending upon the language you select.

``` r
library(wbstats)

# download wbcache in spanish
wb_cachelist_es <- wbcache(lang = "es")

gini_vars <- wbsearch(pattern = "Coeficiente de Gini", cache = wb_cachelist_es)

head(gini_vars)
#>           indicatorID                                       indicator
#> 6567         3.1.Gini                                     Gini, Rural
#> 6570    3.0.TheilInd1                          Índice de Theil, GE(1)
#> 6579  3.0.Gini_nozero Coeficiente de Gini (Ingreso diferente de cero)
#> 6580         3.0.Gini                             Coeficiente de Gini
#> 16725   3.2.TheilInd1                   Índice de Theil, GE(1),Urbano
#> 16727        3.2.Gini                                    Gini, Urbano
```

Downloading data with `wb()`
----------------------------

Once you have found the set of indicators that you would like to explore further, the next step is downloading the data with `wb()`. The following examples are meant to highlight the different ways in which `wb()` can be used and demonstrate the major optional parameters.

The default value for the `country` parameter is a special value of `all` which as you might expect, returns data on the selected `indicator` for every available country or region.

``` r
library(wbstats)

# Population, total
pop_data <- wb(indicator = "SP.POP.TOTL", startdate = 2000, enddate = 2002)

head(pop_data)
#>   iso3c date     value indicatorID         indicator iso2c
#> 1   ARB 2002 296026575 SP.POP.TOTL Population, total    1A
#> 2   ARB 2001 289850357 SP.POP.TOTL Population, total    1A
#> 3   ARB 2000 283832016 SP.POP.TOTL Population, total    1A
#> 4   CSS 2002   6623792 SP.POP.TOTL Population, total    S3
#> 5   CSS 2001   6577216 SP.POP.TOTL Population, total    S3
#> 6   CSS 2000   6530691 SP.POP.TOTL Population, total    S3
#>                  country
#> 1             Arab World
#> 2             Arab World
#> 3             Arab World
#> 4 Caribbean small states
#> 5 Caribbean small states
#> 6 Caribbean small states
```

If you are interested in only some subset of countries or regions you can pass along the specific codes to the `country` parameter. The country and region codes that can be passed to the `country` parameter correspond to the coded values from the `iso2c`, `iso3c`, `regionID`, `adminID`, and `incomeID` from the `countries` data frame in `wb_cachelist` or the return of `wbcache()`. Any values from the above columns can mixed together and passed to the same call

``` r
library(wbstats)

# Population, total
# country values: iso3c, iso2c, regionID, adminID, incomeID
pop_data <- wb(country = c("ABW","AF", "SSF", "ECA", "NOC"),
               indicator = "SP.POP.TOTL", startdate = 2012, enddate = 2012)
#> Warning in wb(country = c("ABW", "AF", "SSF", "ECA", "NOC"), indicator =
#> "SP.POP.TOTL", : The following country values are not valid and are being
#> excluded from the request: NOC

head(pop_data)
#>   iso3c date     value indicatorID         indicator iso2c
#> 1   ABW 2012    102577 SP.POP.TOTL Population, total    AW
#> 2   AFG 2012  30696958 SP.POP.TOTL Population, total    AF
#> 3   ECA 2012 403439691 SP.POP.TOTL Population, total    7E
#> 4   SSF 2012 927039875 SP.POP.TOTL Population, total    ZG
#>                                         country
#> 1                                         Aruba
#> 2                                   Afghanistan
#> 3 Europe & Central Asia (excluding high income)
#> 4                            Sub-Saharan Africa
```

Queries with multiple indicators return the data in a long data format by default

``` r
library(wbstats)

pop_gdp_long <- wb(country = c("US", "NO"), indicator = c("SP.POP.TOTL", "NY.GDP.MKTP.CD"),
                   startdate = 1971, enddate = 1971)

head(pop_gdp_long)
#>   iso3c date        value    indicatorID         indicator iso2c
#> 1   NOR 1971 3.903039e+06    SP.POP.TOTL Population, total    NO
#> 2   USA 1971 2.076610e+08    SP.POP.TOTL Population, total    US
#> 3   NOR 1971 1.458311e+10 NY.GDP.MKTP.CD GDP (current US$)    NO
#> 4   USA 1971 1.167770e+12 NY.GDP.MKTP.CD GDP (current US$)    US
#>         country
#> 1        Norway
#> 2 United States
#> 3        Norway
#> 4 United States
```

or a wide format if parameter `return_wide = TRUE`. Note that to necessitate a this transformation the `indicator` column is dropped.

``` r
library(wbstats)

pop_gdp_wide <- wb(country = c("US", "NO"), indicator = c("SP.POP.TOTL", "NY.GDP.MKTP.CD"),
                   startdate = 1971, enddate = 1971, return_wide = TRUE)

head(pop_gdp_wide)
#>   iso3c date iso2c       country NY.GDP.MKTP.CD SP.POP.TOTL
#> 1   NOR 1971    NO        Norway   1.458311e+10     3903039
#> 2   USA 1971    US United States   1.167770e+12   207661000
```

### Using `mrv`

If you do not know the latest date an indicator you are interested in is available for you country you can use the `mrv` instead of `startdate` and `enddate`. `mrv` stands for most recent value and takes a `integer` corresponding to the number of most recent values you wish to return

``` r
library(wbstats)

eg_data <- wb(country = c("IN"), indicator = 'EG.ELC.ACCS.ZS', mrv = 1)

eg_data
#>   iso3c date    value    indicatorID
#> 1   IND 2016 84.52682 EG.ELC.ACCS.ZS
#>                                 indicator iso2c country
#> 1 Access to electricity (% of population)    IN   India
```

You can increase this value and it will return no more than the `mrv` value. However, if `mrv` is greater than the number of available data it will return less

``` r
library(wbstats)

eg_data <- wb(country = c("IN"), indicator = 'EG.ELC.ACCS.ZS', mrv = 10)

eg_data
#>    iso3c date    value    indicatorID
#> 1    IND 2016 84.52682 EG.ELC.ACCS.ZS
#> 2    IND 2015 88.00000 EG.ELC.ACCS.ZS
#> 3    IND 2014 81.23951 EG.ELC.ACCS.ZS
#> 4    IND 2013 79.59911 EG.ELC.ACCS.ZS
#> 5    IND 2012 79.90000 EG.ELC.ACCS.ZS
#> 6    IND 2011 67.60000 EG.ELC.ACCS.ZS
#> 7    IND 2010 76.30000 EG.ELC.ACCS.ZS
#> 8    IND 2009 75.00000 EG.ELC.ACCS.ZS
#> 9    IND 2008 71.54732 EG.ELC.ACCS.ZS
#> 10   IND 2007 69.98802 EG.ELC.ACCS.ZS
#>                                  indicator iso2c country
#> 1  Access to electricity (% of population)    IN   India
#> 2  Access to electricity (% of population)    IN   India
#> 3  Access to electricity (% of population)    IN   India
#> 4  Access to electricity (% of population)    IN   India
#> 5  Access to electricity (% of population)    IN   India
#> 6  Access to electricity (% of population)    IN   India
#> 7  Access to electricity (% of population)    IN   India
#> 8  Access to electricity (% of population)    IN   India
#> 9  Access to electricity (% of population)    IN   India
#> 10 Access to electricity (% of population)    IN   India
```

### Using `gapfill = TRUE`

An additional parameter that can be used along with `mrv` is `gapfill`. `gapfill` allows you to "fill-in" the values between actual observations. The "filled-in" value for an otherwise missing date is the last observed value carried forward.The only difference in the data call below from the one directly above is `gapfill = TRUE` (the default is `FALSE`). Note the very important difference

``` r
library(wbstats)

eg_data <- wb(country = c("IN"), indicator = 'EG.ELC.ACCS.ZS', mrv = 10, gapfill = TRUE)

eg_data
#>    iso3c date    value    indicatorID
#> 1    IND 2017 84.52682 EG.ELC.ACCS.ZS
#> 2    IND 2016 84.52682 EG.ELC.ACCS.ZS
#> 3    IND 2015 88.00000 EG.ELC.ACCS.ZS
#> 4    IND 2014 81.23951 EG.ELC.ACCS.ZS
#> 5    IND 2013 79.59911 EG.ELC.ACCS.ZS
#> 6    IND 2012 79.90000 EG.ELC.ACCS.ZS
#> 7    IND 2011 67.60000 EG.ELC.ACCS.ZS
#> 8    IND 2010 76.30000 EG.ELC.ACCS.ZS
#> 9    IND 2009 75.00000 EG.ELC.ACCS.ZS
#> 10   IND 2008 71.54732 EG.ELC.ACCS.ZS
#>                                  indicator iso2c country
#> 1  Access to electricity (% of population)    IN   India
#> 2  Access to electricity (% of population)    IN   India
#> 3  Access to electricity (% of population)    IN   India
#> 4  Access to electricity (% of population)    IN   India
#> 5  Access to electricity (% of population)    IN   India
#> 6  Access to electricity (% of population)    IN   India
#> 7  Access to electricity (% of population)    IN   India
#> 8  Access to electricity (% of population)    IN   India
#> 9  Access to electricity (% of population)    IN   India
#> 10 Access to electricity (% of population)    IN   India
```

Because `gapfill` returns data that does reflect actual observed values, use this option with care.

### Using `POSIXct = TRUE`

The default format for the `date` column is not conducive to sorting or plotting, especially when downloading sub annual data, such as monthly or quarterly data. To address this, if `TRUE`, the `POSIXct` parameter adds the additional columns `date_ct` and `granularity`. `date_ct` converts the default date into a `POSIXct`. `granularity` denotes the time resolution that the date represents. This option requires the use of the package `lubridate (>= 1.5.0)`. If `POSIXct = TRUE` and `lubridate (>= 1.5.0)` is not available, a `warning` is produced and the option is ignored

#### NOTE: As of October 20, 2018 the GEM Commodities Database was temporarily unavailable on the World Bank API per the World Bank. Please see the GEM Commodities webpage[3]

This results in any indicators from that database returning a `(400) Bad Request` error. `wbstats` should report an error message but return an empty data frame.

``` r
library(wbstats)

oil_data <- wb(indicator = "CRUDE_BRENT", mrv = 10, freq = "M", POSIXct = TRUE)
#> Warning in wb(indicator = "CRUDE_BRENT", mrv = 10, freq = "M", POSIXct
#> = TRUE): No data was returned for any requested country and indicator.
#> Returning empty data frame
```

The two examples below will also produce the following errors

The `POSIXct = TRUE` option makes plotting and sorting dates much easier.

``` r
library(wbstats)
library(ggplot2)
#> Warning: package 'ggplot2' was built under R version 3.4.4

oil_data <- wb(indicator = c("CRUDE_DUBAI", "CRUDE_BRENT", "CRUDE_WTI", "CRUDE_PETRO"),
               startdate = "2012M01", enddate = "2014M12", freq = "M", POSIXct = TRUE)
#> Warning in wb(indicator = c("CRUDE_DUBAI", "CRUDE_BRENT", "CRUDE_WTI",
#> "CRUDE_PETRO"), : No data was returned for any requested country and
#> indicator. Returning empty data frame

ggplot(oil_data, aes(x = date_ct, y = value, colour = indicator)) + geom_line(size = 1) +
  labs(title = "Crude Oil Price Comparisons", x = "Date", y = "US Dollars")
```

![](tools/figures/read-me-ex-posixct-1-1.png)

The `POSIXct = TRUE` option also makes plotting time series with different time coverage seamless

``` r
library(wbstats)
library(ggplot2)

# querying seperate for differing time coverage example
gold_data <- wb(indicator = "GOLD", mrv = 120, freq = "M", POSIXct = TRUE)
#> Warning in wb(indicator = "GOLD", mrv = 120, freq = "M", POSIXct = TRUE):
#> No data was returned for any requested country and indicator. Returning
#> empty data frame
plat_data <- wb(indicator = "PLATINUM", mrv = 60, freq = "M", POSIXct = TRUE)
#> Warning in wb(indicator = "PLATINUM", mrv = 60, freq = "M", POSIXct =
#> TRUE): No data was returned for any requested country and indicator.
#> Returning empty data frame

metal_data <- rbind(gold_data, plat_data)

ggplot(metal_data, aes(x = date_ct, y = value, colour = indicator)) + geom_line(size = 1) +
  labs(title = "Precious Metal Prices", x = "Date", y = "US Dollars")
```

![](tools/figures/read-me-ex-posixct-2-1.png)

Some Sharp Corners
==================

There are a few behaviors of the World Bank API that being aware of could help explain some potentially unexpected results. These results are known but no special actions are taken to mitigate them as they are the result of the API itself and artifically limiting the inputs or results could potentially causes problems or create unnecessary rescrictions in the future.

Most Recent Values
------------------

If you use the `mrv` parameter in `wb()` with mutliple countries or regions, it searches for the most recent dates for which any country or region in your selection has data and then returns the data for those dates. In other words the `mrv` value is not determined on a country by country basis, rather it is determined across the entire selection.

``` r
library(wbstats)

per_data_1 <- wb(country = "all", indicator = 'per_lm_ac.cov_pop_tot', mrv = 1)
per_data_1
#>    iso3c date value           indicatorID
#> 51   ECU 2016     0 per_lm_ac.cov_pop_tot
#>                             indicator iso2c country
#> 51 Coverage (%) - Active Labor Market    EC Ecuador

per_data_2 <- wb(country = "all", indicator = 'per_lm_ac.cov_pop_tot', mrv = 2)
per_data_2
#>     iso3c date    value           indicatorID
#> 92    CIV 2015 0.000000 per_lm_ac.cov_pop_tot
#> 101   ECU 2016 0.000000 per_lm_ac.cov_pop_tot
#> 142   IDN 2015 5.443194 per_lm_ac.cov_pop_tot
#>                              indicator iso2c       country
#> 92  Coverage (%) - Active Labor Market    CI Cote D'Ivoire
#> 101 Coverage (%) - Active Labor Market    EC       Ecuador
#> 142 Coverage (%) - Active Labor Market    ID     Indonesia
```

Searching in other languages
----------------------------

Not all data sources support all languages. If an indicator does not have a translation for a particular language, the non-supported fields will return as `NA`. This could potentially result in a differing number of matching indicators from `wbsearch()`

``` r

library(wbstats)

# english
cache_en <- wbcache()
sum(is.na(cache_en$indicators$indicator))
#> [1] 0

# spanish
cache_es <- wbcache(lang = "es")
sum(is.na(cache_es$indicators$indicator))
#> [1] 14791
```

Legal
=====

The World Bank Group, or any of its member instutions, do not support or endorse this software and are not libable for any findings or conclusions that come from the use of this software.

[1] <http://www.worldbank.org/>

[2] <http://data.worldbank.org/developers>

[3] <http://data.worldbank.org/developers>
