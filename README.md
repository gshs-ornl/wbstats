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
devtools::install_github("nset-ornl/wbstats")
```

Introduction
============

The World Bank[1] is a tremendous source of global socio-economic data;
spanning several decades and dozens of topics, it has the potential to
shed light on numerous global issues. To help provide access to this
rich source of information, The World Bank themselves, provide a well
structured RESTful API[2]. While this API is very useful for integration
into web services and other high-level applications, it becomes quickly
overwhelming for researchers who have neither the time nor the expertise
to develop software to interface with the API. This leaves the
researcher to rely on manual bulk downloads of spreadsheets of the data
they are interested in. This too is can quickly become overwhelming, as
the work is manual, time consuming, and not easily reproducible. The
goal of the `wbstats` R-package is to provide a bridge between these
alternatives and allow researchers to focus on their research questions
and not the question of accessing the data. The `wbstats` R-package
allows researchers to quickly search and download the data of their
particular interest in a programmatic and reproducible fashion; this
facilitates a seamless integration into their workflow and allows
analysis to be quickly rerun on different areas of interest and with
realtime access to the latest available data.

### Highlighted features of the `wbstats` R-package:

-   Uses version 2 of the World Bank API that provides access to more
    indicators and metadata than the previous API version
-   Access to all annual, quarterly, and monthly data available in the
    API
-   Support for searching and downloading data in multiple languages
-   Access to the World Bank Data Catalog Metadata, providing among
    other information; update schedules and supported languages
-   Returns data in either wide (default) or long format
-   Support for Most Recent Value queries
-   Support for `grep` style searching for data descriptions and names
-   Ability to download data not only by country, but by aggregates as
    well, such as High Income or South Asia

Getting Started
===============

Unless you know the country and indicator codes that you want to
download the first step would be searching for the data you are
interested in. `wb_search()` provides `grep` style searching of all
available indicators from the World Bank API and returns the indicator
information that matches your query.

To access what countries or regions are available you can use the
`countries` data frame from either `wb_cachelist` or the saved return
from `wb_cache()`. This data frame contains relevant information
regarding each country or region. More information on how to use this
for downloading data is covered later.

Finding available data with `wb_cachelist`
------------------------------------------

For performance and ease of use, a cached version of useful information
is provided with the `wbstats` R-package. This data is called
`wb_cachelist` and provides a snapshot of available countries,
indicators, and other relevant information. `wb_cachelist` is by default
the the source from which `wb_search()` and `wb_data()` uses to find
matching information. The structure of `wb_cachelist` is as follows

``` r
library(wbstats)

str(wb_cachelist, max.level = 1)
#> List of 8
#>  $ countries    :Classes 'tbl_df', 'tbl' and 'data.frame':   304 obs. of  18 variables:
#>  $ indicators   :Classes 'tbl_df', 'tbl' and 'data.frame':   16466 obs. of  8 variables:
#>  $ sources      :Classes 'tbl_df', 'tbl' and 'data.frame':   57 obs. of  9 variables:
#>  $ topics       :Classes 'tbl_df', 'tbl' and 'data.frame':   21 obs. of  3 variables:
#>  $ regions      :Classes 'tbl_df', 'tbl' and 'data.frame':   48 obs. of  4 variables:
#>  $ income_levels:Classes 'tbl_df', 'tbl' and 'data.frame':   7 obs. of  3 variables:
#>  $ lending_types:Classes 'tbl_df', 'tbl' and 'data.frame':   4 obs. of  3 variables:
#>  $ languages    :Classes 'tbl_df', 'tbl' and 'data.frame':   23 obs. of  3 variables:
```

Accessing updated available data with `wb_cache()`
--------------------------------------------------

For the most recent information on available data from the World Bank
API `wb_cache()` downloads an updated version of the information stored
in `wb_cachelist`. `wb_cachelist` is simply a saved return of
`wb_cache(lang = "en")`. To use this updated information in
`wb_search()` or `wb_data()`, set the `cache` parameter to the saved
`list` returned from `wb_cache()`. It is always a good idea to use this
updated information to insure that you have access to the latest
available information, such as newly added indicators or data sources.
There are also cases in which indicators that were previously available
from the API have been removed or deprecated.

``` r
library(wbstats)

# default language is english
new_cache <- wb_cache()
```

Search available data with `wb_search()`
----------------------------------------

`wb_search()` searches through the `indicators` data frame to find
indicators that match a search pattern. An example of the structure of
this data frame is below

| indicator\_id  | indicator         | unit | indicator\_desc                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | source\_org                                                                                                                                                                                                                                                                                                                                                                                                                                           | topics                                                         |  source\_id| source                       |
|:---------------|:------------------|:-----|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------------------------------|-----------:|:-----------------------------|
| NY.GDP.MKTP.CD | GDP (current US$) | NA   | GDP at purchaser’s prices is the sum of gross value added by all resident producers in the economy plus any product taxes and minus any subsidies not included in the value of the products. It is calculated without making deductions for depreciation of fabricated assets or for depletion and degradation of natural resources. Data are in current U.S. dollars. Dollar figures for GDP are converted from domestic currencies using single year official exchange rates. For a few countries where the official exchange rate does not reflect the rate effectively applied to actual foreign exchange transactions, an alternative conversion factor is used. | World Bank national accounts data, and OECD National Accounts data files.                                                                                                                                                                                                                                                                                                                                                                             | list(id = “3”, value = “Economy & Growth”)                     |           2| World Development Indicators |
| SP.POP.TOTL    | Population, total | NA   | Total population is based on the de facto definition of population, which counts all residents regardless of legal status or citizenship. The values shown are midyear estimates.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | (1) United Nations Population Division. World Population Prospects: 2019 Revision. (2) Census reports and other statistical publications from national statistical offices, (3) Eurostat: Demographic Statistics, (4) United Nations Statistical Division. Population and Vital Statistics Reprot (various years), (5) U.S. Census Bureau: International Database, and (6) Secretariat of the Pacific Community: Statistics and Demography Programme. | list(id = c(“19”, “8”), value = c(“Climate Change”, “Health”)) |           2| World Development Indicators |

By default the search is done over the `indicator_id`, `indicator`, and
`indicator_desc` fields and returns the those 3 columns of the matching
rows. The `indicator_id` values are inputs into `wb_data()`, the
function for downloading the data. To return all columns for the
`indicators` data frame, you can set `extra = TRUE`.

``` r
library(wbstats)

unemploy_inds<- wb_search("unemployment")
head(unemploy_inds)
#> # A tibble: 6 x 3
#>   indicator_id indicator                    indicator_desc                 
#>   <chr>        <chr>                        <chr>                          
#> 1 fin37.t.a    Received government transfe~ The percentage of respondents ~
#> 2 fin37.t.a.1  Received government transfe~ The percentage of respondents ~
#> 3 fin37.t.a.10 Received government transfe~ The percentage of respondents ~
#> 4 fin37.t.a.11 Received government transfe~ The percentage of respondents ~
#> 5 fin37.t.a.2  Received government transfe~ The percentage of respondents ~
#> 6 fin37.t.a.3  Received government transfe~ The percentage of respondents ~
```

Other fields can be searched by simply changing the `fields` parameter.
For example

``` r
library(wbstats)

blmbrg_vars <- wb_search("Bloomberg", fields = "source_org")
head(blmbrg_vars)
#> # A tibble: 2 x 3
#>   indicator_id indicator             indicator_desc                        
#>   <chr>        <chr>                 <chr>                                 
#> 1 GFDD.OM.02   Stock market return ~ Stock market return is the growth rat~
#> 2 GFDD.SM.01   Stock price volatili~ Stock price volatility is the average~
```

Regular expressions are also supported

``` r
library(wbstats)

# 'poverty' OR 'unemployment' OR 'employment'
povemply_inds <- wb_search(pattern = "poverty|unemployment|employment")
head(povemply_inds)
#> # A tibble: 6 x 3
#>   indicator_id    indicator             indicator_desc                     
#>   <chr>           <chr>                 <chr>                              
#> 1 1.0.HCount.1.9~ Poverty Headcount ($~ The poverty headcount index measur~
#> 2 1.0.HCount.2.5~ Poverty Headcount ($~ The poverty headcount index measur~
#> 3 1.0.HCount.Mid~ Middle Class ($10-50~ The poverty headcount index measur~
#> 4 1.0.HCount.Ofcl Official Moderate Po~ The poverty headcount index measur~
#> 5 1.0.HCount.Poo~ Poverty Headcount ($~ The poverty headcount index measur~
#> 6 1.0.HCount.Vul~ Vulnerable ($4-10 a ~ The poverty headcount index measur~
```

As well as any `grep` function argument

``` r
library(wbstats)

# contains "gdp" and NOT "trade"
gdp_no_trade_inds <- wb_search("^(?=.*gdp)(?!.*trade).*", perl = TRUE)
head(gdp_no_trade_inds)
#> # A tibble: 6 x 3
#>   indicator_id    indicator               indicator_desc                   
#>   <chr>           <chr>                   <chr>                            
#> 1 5.51.01.10.gdp  Per capita GDP growth   GDP per capita is the sum of gro~
#> 2 6.0.GDP_current GDP (current $)         GDP is the sum of gross value ad~
#> 3 6.0.GDP_growth  GDP growth (annual %)   Annual percentage growth rate of~
#> 4 6.0.GDP_usd     GDP (constant 2005 $)   GDP is the sum of gross value ad~
#> 5 6.0.GDPpc_cons~ GDP per capita, PPP (c~ GDP per capita based on purchasi~
#> 6 BI.WAG.TOTL.GD~ Wage bill as a percent~ <NA>
```

The default cached data in `wb_cachelist` is in English. To search
indicators in a different language, you can download an updated copy of
`wb_cachelist` using `wb_cache()`, with the `lang` parameter set to the
language of interest and then set this as the `cache` parameter in
`wb_search()`. Other languages are supported in so far as they are
supported by the original data sources. Some sources provide full
support for other languages, while some have very limited support. If
the data source does not have a translation for a certain field or
indicator then the result is `NA`, this may result in a varying number
matches depending upon the language you select.

``` r
library(wbstats)

# download wb_cache in spanish
wb_cachelist_es <- wb_cache(lang = "es")

gini_inds <- wb_search(pattern = "Coeficiente de Gini", cache = wb_cachelist_es)

head(gini_inds)
#> # A tibble: 6 x 3
#>   indicator_id   indicator              indicator_desc                     
#>   <chr>          <chr>                  <chr>                              
#> 1 3.0.Gini       Coeficiente de Gini    El coeficiente de Gini es la medid~
#> 2 3.0.Gini_noze~ Coeficiente de Gini (~ El coeficiente de Gini es la medid~
#> 3 3.0.TheilInd1  Índice de Theil, GE(1) El Índice de Theil es parte de una~
#> 4 3.1.Gini       Gini, Rural            El coeficiente de Gini es la medid~
#> 5 3.1.TheilInd1  Índice de Theil, GE(1~ El Índice de Theil es parte de una~
#> 6 3.2.Gini       Gini, Urbano           El coeficiente de Gini es la medid~
```

Downloading data with `wb_data()`
---------------------------------

Once you have found the set of indicators that you would like to explore
further, the next step is downloading the data with `wb_data()`. The
following examples are meant to highlight the different ways in which
`wb_data()` can be used and demonstrate the major optional parameters.

The default value for the `country` parameter is a special value of
`"countries_only"`, which as you might expect, returns data on the
selected `indicator` for only countries. This is in contrast to
`country = "all"` or `country = "regions_only"` which would return data
for countries and regional aggregates together, or only regional
aggregates, respectively

``` r
library(wbstats)

# Population, total
pop_data <- wb_data("SP.POP.TOTL", start_date = 2000, end_date = 2002)

head(pop_data)
#> # A tibble: 6 x 10
#>   iso2c iso3c country date       SP.POP.TOTL unit  obs_status footnote
#>   <chr> <chr> <chr>   <date>           <dbl> <chr> <chr>      <chr>   
#> 1 AW    ABW   Aruba   2000-01-01       90853 <NA>  <NA>       <NA>    
#> 2 AW    ABW   Aruba   2001-01-01       92898 <NA>  <NA>       <NA>    
#> 3 AW    ABW   Aruba   2002-01-01       94992 <NA>  <NA>       <NA>    
#> 4 AF    AFG   Afghan~ 2000-01-01    20779953 <NA>  <NA>       <NA>    
#> 5 AF    AFG   Afghan~ 2001-01-01    21606988 <NA>  <NA>       <NA>    
#> 6 AF    AFG   Afghan~ 2002-01-01    22600770 <NA>  <NA>       <NA>    
#> # ... with 2 more variables: last_updated <date>, obs_resolution <chr>
```

If you are interested in only some subset of countries or regions you
can pass along the specific codes to the `country` parameter. The
country and region codes and names that can be passed to the `country`
parameter as well, most prominently the coded values from the `iso2c`
and `iso3c` from the `countries` data frame in `wb_cachelist` or the
return of `wb_cache()`. Any values from the above columns can mixed
together and passed to the same call

``` r
library(wbstats)

# you can mix different ids and they are case insensitive
# you can even use SpOnGeBoB CaSe if that's the kind of thing you're into
# iso3c, iso2c, country, region_iso3c, admin_region_iso3c, admin_region, income_level
example_geos <- c("ABW","AF", "albania", "SSF", "eca", "South Asia", "HiGh InComE")
pop_data <- wb_data("SP.POP.TOTL", country = example_geos,
                    start_date = 2012, end_date = 2012)

pop_data
#> # A tibble: 7 x 10
#>   iso2c iso3c country date       SP.POP.TOTL unit  obs_status footnote
#>   <chr> <chr> <chr>   <date>           <dbl> <chr> <chr>      <chr>   
#> 1 AW    ABW   Aruba   2012-01-01      102560 <NA>  <NA>       <NA>    
#> 2 AF    AFG   Afghan~ 2012-01-01    31161376 <NA>  <NA>       <NA>    
#> 3 AL    ALB   Albania 2012-01-01     2900401 <NA>  <NA>       <NA>    
#> 4 7E    ECA   Europe~ 2012-01-01   403265869 <NA>  <NA>       <NA>    
#> 5 8S    SAS   South ~ 2012-01-01  1683747130 <NA>  <NA>       <NA>    
#> 6 ZG    SSF   Sub-Sa~ 2012-01-01   917726973 <NA>  <NA>       <NA>    
#> 7 XD    <NA>  High i~ 2012-01-01  1170223344 <NA>  <NA>       <NA>    
#> # ... with 2 more variables: last_updated <date>, obs_resolution <chr>
```

As of `wbstats 1.0` queries are now returned in wide format. This was a
request made by multiple users and is in line with the principles of
[tidy data](https://www.jstatsoft.org/article/view/v059i10). If you
would like to return the data in a long format, you can set
`return_wide = FALSE`

Now that each indicator is it’s own column, we can implement a great
suggestion by
[vincentarelbundock](https://github.com/vincentarelbundock) to allow
custom names for the indicators

``` r
library(wbstats)

my_indicators = c("pop" = "SP.POP.TOTL", 
                  "gdp" = "NY.GDP.MKTP.CD")

pop_gdp <- wb_data(my_indicators, start_date = 2010, end_date = 2012)

head(pop_gdp)
#> # A tibble: 6 x 7
#>   iso2c iso3c country     date                gdp      pop obs_resolution
#>   <chr> <chr> <chr>       <date>            <dbl>    <dbl> <chr>         
#> 1 AW    ABW   Aruba       2010-01-01  2390502793.   101669 annual        
#> 2 AW    ABW   Aruba       2011-01-01  2549720670.   102046 annual        
#> 3 AW    ABW   Aruba       2012-01-01  2534636872.   102560 annual        
#> 4 AF    AFG   Afghanistan 2010-01-01 15856574731. 29185507 annual        
#> 5 AF    AFG   Afghanistan 2011-01-01 17804280538. 30117413 annual        
#> 6 AF    AFG   Afghanistan 2012-01-01 20001615789. 31161376 annual
```

You’ll notice that when you query only one indicator, as in the first
two examples above, it returns the extra fields `unit`, `obs_status`,
`footnote`, and `last_updated`, but when we queried multiple indicators
at once, as in our last example, they are dropped. This is because those
extra fields are tied to a specific observation of a single indicator
and when we have multiple indciator values in a single row, they are no
longer consistent with the tidy data format. If you would like that
information for multiple indicators, you can use `return_wide = FALSE`

``` r
library(wbstats)

my_indicators = c("pop" = "SP.POP.TOTL", 
                  "gdp" = "NY.GDP.MKTP.CD")

pop_gdp_long <- wb_data(my_indicators, start_date = 2010, end_date = 2012, return_wide = FALSE)

head(pop_gdp_long)
#> # A tibble: 6 x 12
#>   indicator_id indicator iso2c iso3c country date        value unit 
#>   <chr>        <chr>     <chr> <chr> <chr>   <date>      <dbl> <chr>
#> 1 SP.POP.TOTL  Populati~ AW    ABW   Aruba   2012-01-01 1.03e5 <NA> 
#> 2 SP.POP.TOTL  Populati~ AW    ABW   Aruba   2011-01-01 1.02e5 <NA> 
#> 3 SP.POP.TOTL  Populati~ AW    ABW   Aruba   2010-01-01 1.02e5 <NA> 
#> 4 SP.POP.TOTL  Populati~ AF    AFG   Afghan~ 2012-01-01 3.12e7 <NA> 
#> 5 SP.POP.TOTL  Populati~ AF    AFG   Afghan~ 2011-01-01 3.01e7 <NA> 
#> 6 SP.POP.TOTL  Populati~ AF    AFG   Afghan~ 2010-01-01 2.92e7 <NA> 
#> # ... with 4 more variables: obs_status <chr>, footnote <chr>,
#> #   last_updated <date>, obs_resolution <chr>
```

### Using `mrv` and `mrnev`

If you do not know the latest date an indicator you are interested in is
available for you country you can use the `mrv` instead of `start_date`
and `end_date`. `mrv` stands for most recent value and takes a `integer`
corresponding to the number of most recent values you wish to return

``` r
library(wbstats)

# most recent gdp per captia estimates
gdp_capita <- wb_data("NY.GDP.PCAP.CD", mrv = 1)

head(gdp_capita)
#> # A tibble: 6 x 10
#>   iso2c iso3c country date       NY.GDP.PCAP.CD unit  obs_status footnote
#>   <chr> <chr> <chr>   <date>              <dbl> <chr> <chr>      <chr>   
#> 1 AW    ABW   Aruba   2018-01-01            NA  <NA>  <NA>       <NA>    
#> 2 AF    AFG   Afghan~ 2018-01-01           521. <NA>  <NA>       <NA>    
#> 3 AO    AGO   Angola  2018-01-01          3432. <NA>  <NA>       <NA>    
#> 4 AL    ALB   Albania 2018-01-01          5269. <NA>  <NA>       <NA>    
#> 5 AD    AND   Andorra 2018-01-01         42030. <NA>  <NA>       <NA>    
#> 6 AE    ARE   United~ 2018-01-01         43005. <NA>  <NA>       <NA>    
#> # ... with 2 more variables: last_updated <date>, obs_resolution <chr>
```

Often it is the case that the latest available data is different from
country to country. There may be 2020 estimates for one location, while
another only has estimates up to 2019. This is especially true for
survey data. When you would like to return the latest avialble data for
each country regardless of its temporal misalignment, you can use the
`mrnev` instead of `mrnev`. `mrnev` stands for most recent non empty
value.

``` r
library(wbstats)

gdp_capita <- wb_data("NY.GDP.PCAP.CD", mrnev = 1)

head(gdp_capita)
#> # A tibble: 6 x 9
#>   iso2c iso3c country date       NY.GDP.PCAP.CD obs_status footnote
#>   <chr> <chr> <chr>   <date>              <dbl> <chr>      <chr>   
#> 1 AW    ABW   Aruba   2017-01-01         25630. <NA>       <NA>    
#> 2 AF    AFG   Afghan~ 2018-01-01           521. <NA>       <NA>    
#> 3 AO    AGO   Angola  2018-01-01          3432. <NA>       <NA>    
#> 4 AL    ALB   Albania 2018-01-01          5269. <NA>       <NA>    
#> 5 AD    AND   Andorra 2018-01-01         42030. <NA>       <NA>    
#> 6 AE    ARE   United~ 2018-01-01         43005. <NA>       <NA>    
#> # ... with 2 more variables: last_updated <date>, obs_resolution <chr>
```

### Dates

Currently all dates are returned as

Some Sharp Corners
==================

There are a few behaviors of the World Bank API that being aware of
could help explain some potentially unexpected results. These results
are known but no special actions are taken to mitigate them as they are
the result of the API itself and artifically limiting the inputs or
results could potentially causes problems or create unnecessary
rescrictions in the future.

Most Recent Values
------------------

If you use the `mrv` parameter in `wb()` with mutliple countries or
regions, it searches for the most recent dates for which any country or
region in your selection has data and then returns the data for those
dates. In other words the `mrv` value is not determined on a country by
country basis, rather it is determined across the entire selection.

``` r
library(wbstats)

per_data_1 <- wb(country = "all", indicator = 'per_lm_ac.cov_pop_tot', mrv = 1)
per_data_1
#>    iso3c date value           indicatorID
#> 48   ECU 2016     0 per_lm_ac.cov_pop_tot
#> 80   LBR 2016     0 per_lm_ac.cov_pop_tot
#>                             indicator iso2c country
#> 48 Coverage (%) - Active Labor Market    EC Ecuador
#> 80 Coverage (%) - Active Labor Market    LR Liberia

per_data_2 <- wb(country = "all", indicator = 'per_lm_ac.cov_pop_tot', mrv = 2)
per_data_2
#>     iso3c date     value           indicatorID
#> 36    AZE 2015  3.613943 per_lm_ac.cov_pop_tot
#> 72    CHL 2015 24.275833 per_lm_ac.cov_pop_tot
#> 86    CIV 2015  0.000000 per_lm_ac.cov_pop_tot
#> 95    ECU 2016  0.000000 per_lm_ac.cov_pop_tot
#> 132   IDN 2015  5.443194 per_lm_ac.cov_pop_tot
#> 159   LBR 2016  0.000000 per_lm_ac.cov_pop_tot
#>                              indicator iso2c       country
#> 36  Coverage (%) - Active Labor Market    AZ    Azerbaijan
#> 72  Coverage (%) - Active Labor Market    CL         Chile
#> 86  Coverage (%) - Active Labor Market    CI Cote D'Ivoire
#> 95  Coverage (%) - Active Labor Market    EC       Ecuador
#> 132 Coverage (%) - Active Labor Market    ID     Indonesia
#> 159 Coverage (%) - Active Labor Market    LR       Liberia
```

Searching in other languages
----------------------------

Not all data sources support all languages. If an indicator does not
have a translation for a particular language, the non-supported fields
will return as `NA`. This could potentially result in a differing number
of matching indicators from `wbsearch()`

``` r

library(wbstats)

# english
cache_en <- wbcache()
sum(is.na(cache_en$indicators$indicator))
#> [1] 0

# spanish
cache_es <- wbcache(lang = "es")
sum(is.na(cache_es$indicators$indicator))
#> [1] 15365
```

Legal
=====

The World Bank Group, or any of its member instutions, do not support or
endorse this software and are not libable for any findings or
conclusions that come from the use of this software.

[1] <a href="http://www.worldbank.org/" class="uri">http://www.worldbank.org/</a>

[2] <a href="http://data.worldbank.org/developers" class="uri">http://data.worldbank.org/developers</a>
