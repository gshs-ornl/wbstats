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

``` r
library(tidyverse)
library(wbstats)

wb_data(
  c(life_exp = "SP.DYN.LE00.IN", 
    gdp_capita ="NY.GDP.PCAP.CD", 
    pop = "SP.POP.TOTL"), 
  start_date = 2016
  ) %>%
  left_join(wb_countries(), "iso3c") %>%
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

![](README-readme-chart-1.png)

[1] <a href="http://www.worldbank.org/" class="uri">http://www.worldbank.org/</a>

[2] <a href="http://data.worldbank.org/developers" class="uri">http://data.worldbank.org/developers</a>
