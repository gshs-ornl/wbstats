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
remotes::install_github("nset-ornl/wbstats")
```

Downloading data from the World Bank
====================================

``` r
library(wbstats)

# Population for every country from 1960 until present
d <- wb(country = "all", "SP.POP.TOTL")
    
head(d)
#>   iso3c date     value indicatorID         indicator iso2c    country
#> 1   ARB 2019 427870270 SP.POP.TOTL Population, total    1A Arab World
#> 2   ARB 2018 419790591 SP.POP.TOTL Population, total    1A Arab World
#> 3   ARB 2017 411898967 SP.POP.TOTL Population, total    1A Arab World
#> 4   ARB 2016 404024435 SP.POP.TOTL Population, total    1A Arab World
#> 5   ARB 2015 396028278 SP.POP.TOTL Population, total    1A Arab World
#> 6   ARB 2014 387907747 SP.POP.TOTL Population, total    1A Arab World
```

Hans Rosling’s Gapminder using `wbstats`
----------------------------------------

``` r
library(tidyverse)
library(wbstats)

my_indicators <- c(
  "SP.DYN.LE00.IN", # Life Expectancy
  "NY.GDP.PCAP.CD", # GDP
  "SP.POP.TOTL" # Total Population
  )

## Extracting the data from world bank, using the restful api via the wb()
d <- wb(country = "all", my_indicators, startdate = 2016, enddate = 2016)

## data cleaning and rearranging
d <- d %>% 
  select(-indicator) %>% 
  spread(indicatorID, value) %>% 
  rename(life_exp = SP.DYN.LE00.IN, gdp_capita = NY.GDP.PCAP.CD, pop = SP.POP.TOTL) %>% 
  left_join(wbcountries(), "iso3c")


## Data visualization
d %>%
  ggplot() +
  geom_point(
    aes(
      x = gdp_capita, 
      y = life_exp, 
      size = pop, 
      color = region
      )
    ) +
  scale_x_continuous(
    labels = scales::dollar_format(),
    breaks = scales::log_breaks(n = 10)
    ) +
  coord_trans(x = 'log10') +
  scale_size_continuous(
    labels = scales::number_format(scale = 1/1e6, suffix = "m"),
    breaks = seq(1e8,1e9, 2e8),
    range = c(1,20)
    ) +
  theme_minimal() +
  labs(
    title = "An Example of Hans Rosling's Gapminder using wbstats",
    x = "GDP per Capita (log scale)",
    y = "Life Expectancy at Birth",
    size = "Population",
    color = NULL,
    caption = "Source: World Bank"
  ) 
```

![](man/figures/readme-chart-1.png)

Using `ggplot2` to map `wbstats` data
-------------------------------------

``` r
library(rnaturalearth)
library(tidyverse)
library(wbstats)

ind <- "SL.EMP.SELF.ZS"
indicator_info <- filter(wb_cachelist$indicators, indicatorID == ind)

ne_countries(returnclass = "sf") %>%
  left_join(
    wb(country = "all",
      ind
          ) %>% 
      select(-indicatorID, -indicator) %>% 
      rename(self_employed = value),
    c("iso_a3" = "iso3c")
  ) %>%
  filter(iso_a3 != "ATA") %>% # remove Antarctica
  ggplot(aes(fill = self_employed)) +
  geom_sf() +
  scale_fill_viridis_c(labels = scales::percent_format(scale = 1)) +
  theme(legend.position="bottom") +
  labs(
    title = indicator_info$indicator,
    fill = NULL,
    caption = paste("Source:", indicator_info$sourceOrg) 
  )
```

<img src="man/figures/ggplot2-1.png" style="display: block; margin: auto;" />
