
#' Download Data from the World Bank API
#'
#' This function downloads the requested information using the World Bank API
#'
#' @param indicator Character vector of indicator codes. These codes correspond
#' to the `indicator_id` column from the `indicators` tibble of [wb_cache()], [wb_cachelist], or
#'  the result of running [wb_indicators()] directly
#' @param country Character vector of country, region, or special value codes for the
#' locations you want to return data for. Permissible values can be found in the countries tibble in [wb_cachelist]
#' or by running [wb_countries()] directly. Specifically, values listed in the following fields
#' `iso3c`, `iso2c`, `country`, `region`, `admin_region`, `income_level` and all of the `region_*`, `admin_region_*`, `income_level_*`,
#' columns. As well as the following special values
#' * `"countries_only"` (Default)
#' * `"regions_only"`
#' * `"admin_regions_only"`
#' * `"income_levels_only"`
#' * `"aggregates_only"`
#' * `"all"`
#' @param start_date Numeric or character. If numeric it must be in `%Y`` form (i.e. four digit year).
#'  For data at the subannual granularity the API supports a format as follows: for monthly data, "2016M01"
#'  and for quarterly data, "2016Q1". This also accepts a special value of "YTD", useful for more frequently
#'  updated subannual indicators.
#' @param end_date Numeric or character. If numeric it must be in `%Y`` form (i.e. four digit year).
#'  For data at the subannual granularity the API supports a format as follows: for monthly data, "2016M01"
#'  and for quarterly data, "2016Q1".
#' @param return_wide Logical. If `TRUE` data is returned in a wide format instead of long,
#' with a column named for each `indicator_id` or if the `indicator` argument is a named vector,
#' the [names()] given to the indicator will be the column names. To necessitate this transformation,
#' the `indicator` column that provides the human readable description is dropped, but provided as a column label.
#' Default is `TRUE`
#' @param mrv Numeric. The number of Most Recent Values to return. A replacement
#' of `start_date` and `end_date`, this number represents the number of observations
#' you which to return starting from the most recent date of collection. This may include missing values.
#' Useful in conjuction with `freq`
#' @param mrnev Numeric. The number of Most Recent Non Empty Values to return. A replacement
#' of `start_date` and `end_date`, similar in behavior as `mrv` but excludes locations with missing values.
#' Useful in conjuction with `freq`
#' @param cache List of tibbles returned from [wb_cache()]. If omitted, [wb_cachelist] is used
#' @param freq Character String. For fetching quarterly ("Q"), monthly("M") or yearly ("Y") values.
#' Useful for querying high frequency data.
#' @param gapfill Logical. If `TRUE` fills in missing values by carrying forward the last
#' available value until the next available period (max number of periods back tracked will be limited by `mrv` number).
#' Default is `FALSE`
#' @inheritParams wb_cache
#'
#' @return A [tibble][tibble::tbl_df] of all available requested data.
#'
#' @details
#' ## `obs_status` column
#' Indicates the observation status for location, indicator and date combination.
#' For example `"F"` in the response indicates that the observation status for that data point is "forecast".
#'
#' @export
#' @md
#'
#' @examples
#' # GDP (current US$) for countries only for all available dates
#' \donttest{wb_data("NY.GDP.MKTP.CD")}
#'
#' # Population, GDP, Unemployment Rate, Birth Rate (per 1000 people)
#' my_indicators <- c("SP.POP.TOTL", "NY.GDP.MKTP.CD", "SL.UEM.TOTL.ZS", "SP.DYN.CBRT.IN")
#' \donttest{wb_data(my_indicators)}
#'
#'
#' # you can mix the country ids
#' # Albania (iso2c), Georgia (iso3c), and Mongolia
#' my_countries <- c("al", "geo", "mongolia")
#' wb_data(my_indicators, country = my_countries, start_date = 2005, end_date = 2007)
#'
#' # same data as above, but in long format
#' wb_data(my_indicators, country = my_countries, start_date = 2005, end_date = 2007, return_wide = FALSE)
#'
#'
#' # regional population totals
#' # regions correspond to the region column in wb_cachelist$countries
#' wb_data("SP.POP.TOTL", country = "regions_only", start_date = 2010, end_date = 2014)
#'
#'
#' # a specific region
#' wb_data("SP.POP.TOTL", country = "world", start_date = 2010, end_date = 2014)
#'
#'
#' # if the indicator is part of a named vector the name will be the column name
#' names(my_indicators) <- c("population", "gdp", "unemployment_rate", "birth_rate")
#' wb_data(my_indicators, country = "world", start_date = 2010, end_date = 2014)
#'
#'
#' # custom names are ignored if returning in long format
#' wb_data(my_indicators, country = "world", start_date = 2010, end_date = 2014, return_wide = FALSE)
#'
#' # same as above but in Bulgarian
#' # note that not all indicators have translations for all languages
#' wb_data(my_indicators, country = "world", start_date = 2010, end_date = 2014, return_wide = FALSE, lang = "bg")
#'
#'
#' # if you do not know when the latest time an indicator is avaiable mrv can help
#' # unenployment rate
#' wb_data("SL.UEM.TOTL.ZS", mrv = 1)
#'
#' # note the difference in mrv and mrnev
#' wb_data("SL.UEM.TOTL.ZS", mrnev = 1)
#'
#'
#' # without the freq parameter the deafult temporal granularity search is yearly
#' # should return the 12 most recent years of data
#' wb_data(country = c("CHN", "IND"), indicator = "DPANUSSPF", mrv = 12)
#'
#'
#' # if another frequency is available for that indicator it can be accessed using the freq parameter
#' # should return the 12 most recent months of data
#' wb_data(country = c("CHN", "IND"), indicator = "DPANUSSPF", mrv = 12, freq = "M")
wb_data <- function(indicator, country = "countries_only", start_date, end_date,
                    return_wide = TRUE, mrv, mrnev, cache, freq, gapfill = FALSE,
                    lang) {

  if (missing(cache)) cache <- wbstats::wb_cachelist

  # TODO: 1. add deperated warning to old functions
  #       2. what about the search function?
  #       2. function for formatting time
  #       3. check query options
  #       4. Do the cache
  #
  base_url <- wbstats:::wb_api_parameters$base_url

  # format country ----------------------------------------------------------
  country_param <- format_wb_country(country, cache = cache)
  country_path <- paste0(wbstats:::wb_api_parameters$country, "/", country_param)


  # check dates ----------
  date_query <- NULL
  if (missing(start_date) !=  missing(end_date))
    stop("Using either startdate or enddate requries supplying both. Please provide both if a date range is wanted")

  if (!(missing(start_date) & missing(end_date))) {

    date_query <- paste0(start_date, ":", end_date)
  }

  # check freq ----------
  freq_query <- NULL
  if (!missing(freq)) {

    if (!freq %in% c("Y", "Q", "M"))
      stop("If supplied, values for freq must be one of the following 'Y' (yearly), 'Q' (Quarterly), or 'M' (Monthly)")

    freq_query <- freq
  }

  # check mrv ----------
  mrv_query <- NULL
  if (!missing(mrv)) {
    if (!is.numeric(mrv)) stop("If supplied, mrv must be numeric")

    mrv_query <- paste0(round(mrv, digits = 0)) # just to make sure its a whole number
  }

  # check mrnev ----------
  mrnev_query <- NULL
  if (!missing(mrnev)) {
    if (!is.numeric(mrnev)) stop("If supplied, mrnev must be numeric")
    mrnev_query <- paste0(round(mrnev, digits = 0)) # just to make sure its a whole number
  }

  # check gapfill ----------
  gapfill_query <- NULL
  if (!missing(gapfill)) {
    if (!is.logical(gapfill)) stop("If supplied, values for gapfill must be TRUE or FALSE")
    if (missing(mrv)) stop("mrv must be supplied for gapfill to be used")

    gapfill_query <- ifelse(gapfill, "Y", "N")
  }

  # check scale ----------
  scale_query <- NULL
  # remove support for scale parameter, it causes more problems that in solves
  # if (!missing(scale)) {
  #   if (!is.logical(scale)) stop("Values for scale must be TRUE or FALSE")
  #
  #   scale_query <- ifelse(scale, "Y", "N")
  # }

  # country should be part of the path list b/c other endpoint don't require it or need more things
  path_list <- list(
    version = wbstats:::wb_api_parameters$version,
    lang    = if_missing(lang, wb_default_lang(), lang),
    country = country_path
  )

  # what is NULL just gets dropped in the build url step
  query_list <- list(
    date     = date_query,
    scale    = scale_query,
    freq     = freq_query,
    mrv      = mrv_query,
    mrnev    = mrnev_query,
    gapfill  = gapfill_query,
    footnote = "y",
    cntrycode = "y",
    per_page = wbstats:::wb_api_parameters$per_page,
    format   = wbstats:::wb_api_parameters$format
  )

  # be able to return this for debugging
  ind_url <- wbstats:::build_wb_url(
      base_url  = base_url,  indicator  = indicator,
      path_list = path_list, query_list = query_list
    )

  d_list <- lapply(ind_url, fetch_wb_url)
  d <- do.call(rbind, d_list)
  if(!is.data.frame(d)) {
    warning("No data was returned for your query. Returning an empty tibble")
    return(tibble::tibble())
  }

  d <- format_wb_data(d, end_point = "data")

  if (return_wide) {
    context_cols <- c("iso2c", "iso3c", "country", "date")
    extra_cols <- c("unit", "obs_status", "decimal", "footnote", "last_updated")

    ind_names <- as.data.frame(unique(d[, c("indicator", "indicator_id")]))

    cols_to_keep <- setdiff(names(d), "indicator")
    if (length(unique(ind_names$indicator_id)) > 1) {
      cols_to_keep <- setdiff(cols_to_keep, extra_cols)
    }

    d <- d[, cols_to_keep]
    d <- tidyr::spread(d, key = "indicator_id", value = "value")

    # column labels
    for (i in 1:nrow(ind_names)) {
      d_col_name <- ind_names$indicator_id[i]
      d_col_label <- ind_names$indicator[i]

      attr(d[[d_col_name]], "label") <- d_col_label
    }

    # named vector for indicators
    if (!is.null(names(indicator))) {
      for (i in 1:nrow(ind_names)) {
        d_col_old_name <- ind_names$indicator_id[i]
        d_col_new_name <- names(indicator[indicator == d_col_old_name])
        if(! (d_col_new_name == "" || is.null(d_col_new_name)) )
          names(d)[which(names(d) == d_col_old_name)] <- d_col_new_name
      }
    }

    indicator_cols <- setdiff(names(d), c(context_cols, extra_cols))
    d <- dplyr::select(d,
            context_cols,
            indicator_cols,
            dplyr::everything()
          )

  } # end return_wide
  else {
    d <- dplyr::select(d,
            "indicator_id", "indicator", "iso2c", "iso3c", "country", "date",
            "value", "unit", "obs_status", "decimal", "footnote", "last_updated"
          )
  }

 d
}
