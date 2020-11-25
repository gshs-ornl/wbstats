# wbstats 1.0.3
* Fixes issues with examples taking too long to run

# wbstats 1.0.2

## Bug fixes:
* Now precomputes vignettes to better align with CRAN policies regarding internet access


# wbstats 1.0.1

Release `1.0.1` fixes a handful of minor issues

## Changes:
* Lowered the per_page limit on API requests to the indicators endpoint in functions
  `wb_indicators()` and `wb_cache()`. This should result in fewer timeouts.

## Bug fixes:
* Resolved error when `unit` field is missing in certain `wb_data()` calls


# wbstats 1.0.0

The `1.0.0` release represents a complete overhaul of the `wbstats` package to
hopefully be more consistent and easy to use.

## Changes:
* Data now returns in a wide format by default with each indicator being its own column
* Adoption of the "tidyverse" ecosystem.
* New naming convention, `wb_*()` for all `wbstats` functions. Relatedly,
* Older functions from previous versions are now deprecated and should produce a warning
* Support for custom indicator names by passing a named vector to `wb_data()`
* Includes support for most recent non-empty value queries. Basically quering the most recent
  `n` values from each location, regardless of the date.
* `wb_search()` now accepts any `grep()` argument passed through `...` 



# wbstats 0.2.1.9000

## Changes:
* add non-exported .wb_url function for debugging purposes


# wbstats 0.2.0
## Bug fixes:
* `wbdatacatalog()` now returns all catalog entries instead of first 10
* When only Namibia is queried the iso2c column now returns `"NA"` instead of logical `NA`
* For some indicators `wb()` queries would return iso3c IDs in the iso2c column. This is a behavior
  of the world bank API. This is now properly handled.
* Indicators from source `WDI Database Archives` are now accessible

## Changes:
* Now uses Version 2 of the World Bank API.

    This new version of the API returns some new columns the old version didn't. 
    Including data of last update for all available data sources
    This version also provides access to over 700 indicators that were moved to the `WDI Database Archives`.
    These indicators are not available using the older API

* added the parameter `return_wide` to `wb()` allowing data returns to be formatted
  in a wide format with each queried indicator being its own column named by its
  corresponding `indicatorID`.
  
    This added functionality was done by importing the `tidyr` package and using `tidyr::spread_`.
    While it is not ideal to add a dependency for one feature I believe the
    `tidyr` and other `tidyverse` packages are inline with future `wbstats` features and are now
    common enough that the added dependency is worth the addition.

* More explicit error messaging when encountering API call errors

* update cached data in `wb_cachelist`


# wbstats 0.1.1
## Changes:
* Add 'aggregates' and 'countries_only' options to `wb()` per bapfeld pr
* update cached data in `wb_cachelist`

