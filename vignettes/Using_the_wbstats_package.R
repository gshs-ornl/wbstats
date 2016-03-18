## ------------------------------------------------------------------------
library(worldbank)

str(wb_cachelist, max.level = 1)

## ------------------------------------------------------------------------
library(worldbank)

# default language is english
new_cache <- wbcache()

## ---- echo=FALSE, results='asis'-----------------------------------------
knitr::kable(head(worldbank::wb_cachelist$indicators[4310:4311, ]))

## ------------------------------------------------------------------------
library(worldbank)

unemploy_vars <- wbsearch(pattern = "unemployment")
head(unemploy_vars)


## ------------------------------------------------------------------------
library(worldbank)

blmbrg_vars <- wbsearch(pattern = "Bloomberg", fields = "sourceOrg")
head(blmbrg_vars)


## ------------------------------------------------------------------------
library(worldbank)

# 'poverty' OR 'unemployment' OR 'employment'
povemply_vars <- wbsearch(pattern = "poverty|unemployment|employment")

head(povemply_vars)


## ------------------------------------------------------------------------
library(worldbank)

# download wbcache in spanish
wb_cachelist_es <- wbcache(lang = "es")

gini_vars <- wbsearch(pattern = "Coeficiente de Gini", cache = wb_cachelist_es)

head(gini_vars)


## ------------------------------------------------------------------------
library(worldbank)

# Population, total
pop_data <- wb(indicator = "SP.POP.TOTL", startdate = 2000, enddate = 2002)

head(pop_data)

## ------------------------------------------------------------------------
library(worldbank)

# Population, total
# country values: iso3c, iso2c, regionID, adminID, incomeID
pop_data <- wb(country = c("ABW","AF", "SSF", "ECA", "NOC"),
               indicator = "SP.POP.TOTL", startdate = 2012, enddate = 2012)

head(pop_data)

## ------------------------------------------------------------------------
library(worldbank)

pop_gdp_data <- wb(country = c("US", "NO"), indicator = c("SP.POP.TOTL", "NY.GDP.MKTP.CD"),
               startdate = 1971, enddate = 1971)

head(pop_gdp_data)

## ------------------------------------------------------------------------
library(worldbank)

eg_data <- wb(country = c("IN"), indicator = 'EG.ELC.ACCS.ZS', mrv = 1)

eg_data

## ------------------------------------------------------------------------
library(worldbank)

eg_data <- wb(country = c("IN"), indicator = 'EG.ELC.ACCS.ZS', mrv = 10)

eg_data

## ------------------------------------------------------------------------
library(worldbank)

eg_data <- wb(country = c("IN"), indicator = 'EG.ELC.ACCS.ZS', mrv = 10, gapfill = TRUE)

eg_data

## ------------------------------------------------------------------------
library(worldbank)

oil_data <- wb(indicator = "CRUDE_BRENT", mrv = 10, freq = "M", POSIXct = TRUE)

head(oil_data)

## ---- fig.height = 4, fig.width = 7.5------------------------------------
library(worldbank)
library(ggplot2)

oil_data <- wb(indicator = c("CRUDE_DUBAI", "CRUDE_BRENT", "CRUDE_WTI", "CRUDE_PETRO"),
               startdate = "2012M01", enddate = "2014M12", freq = "M", POSIXct = TRUE)

ggplot(oil_data, aes(x = date_ct, y = value, colour = indicator)) + geom_line(size = 1) +
  labs(title = "Crude Oil Price Comparisons", x = "Date", y = "US Dollars")

## ---- fig.height = 4, fig.width = 7.5------------------------------------
library(worldbank)
library(ggplot2)

# querying seperate for differing time coverage example
gold_data <- wb(indicator = "GOLD", mrv = 120, freq = "M", POSIXct = TRUE)
plat_data <- wb(indicator = "PLATINUM", mrv = 60, freq = "M", POSIXct = TRUE)

metal_data <- rbind(gold_data, plat_data)

ggplot(metal_data, aes(x = date_ct, y = value, colour = indicator)) + geom_line(size = 1) +
  labs(title = "Precious Metal Prices", x = "Date", y = "US Dollars")

## ------------------------------------------------------------------------
library(worldbank)

pop_data <- wb(country = "US", indicator = "SP.POP.TOTL", 
               startdate = 1800, enddate = 1805, POSIXct = TRUE)

nrow(pop_data)
max(pop_data$date_ct)
min(pop_data$date_ct)

## ------------------------------------------------------------------------
library(worldbank)

eg_data_1 <- wb(country = c("IN", "AF"), indicator = 'EG.FEC.RNEW.ZS', mrv = 1)
eg_data_1

eg_data_2 <- wb(country = c("IN", "AF"), indicator = 'EG.FEC.RNEW.ZS', mrv = 2)
eg_data_2


## ------------------------------------------------------------------------

library(worldbank)

# english
cache_en <- wbcache()
sum(is.na(cache_en$indicators$indicator))

# spanish
cache_es <- wbcache(lang = "es")
sum(is.na(cache_es$indicators$indicator))

