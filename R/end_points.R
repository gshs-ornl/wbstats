#' @noRd
wb_end_point <- function(end_point, lang) {

  get_url <- build_get_url(end_point, lang = lang)

  d <- fetch_wb_url(get_url)
  d_names <- format_wb_tidy_names(names(d), end_point = end_point)
  names(d) <- d_names

  format_wb_data(d, end_point = end_point)
}


#' World Bank Information End Points
#'
#' These functions are simple wrappers around the various useful API end points
#' that are helpful for finding avaiable data and filtering the data you are
#' interested in when using [wb_data()]
#'
#' @inheritParams wb_cache
#' @return A `tibble` of information about the end point
#' @name wb_end_point_info
#' @seealso [wb_cache()]
#' @md
NULL

#' Download World Bank country information
#' @rdname wb_end_point_info
#' @export
wb_countries <- function(lang) {
  lang <- if_missing(lang, wb_default_lang(), lang)
  wb_end_point("country", lang)
}

#' Download World Bank indicator topic information
#' @rdname wb_end_point_info
#' @export
wb_topics <- function(lang) {
  lang <- if_missing(lang, wb_default_lang(), lang)
  wb_end_point("topic", lang)
}

#' Download World Bank indicator source information
#' @rdname wb_end_point_info
#' @export
wb_sources <- function(lang) {
  lang <- if_missing(lang, wb_default_lang(), lang)
  wb_end_point("source", lang)
}

#' Download World Bank region information
#' @rdname wb_end_point_info
#' @export
wb_regions <- function(lang) {
  lang <- if_missing(lang, wb_default_lang(), lang)
  wb_end_point("region", lang)
}

#' Download World Bank income level information
#' @rdname wb_end_point_info
#' @export
wb_income_levels <- function(lang) {
  lang <- if_missing(lang, wb_default_lang(), lang)
  wb_end_point("income_level", lang)
}

#' Download World Bank lending type information
#' @rdname wb_end_point_info
#' @export
wb_lending_types <- function(lang) {
  lang <- if_missing(lang, wb_default_lang(), lang)
  wb_end_point("lending_type", lang)
}

#' Download available languages supported by World Bank
#' @rdname wb_end_point_info
#' @export
wb_languages <- function() {
  wb_end_point("language", lang = NA)
}

#' Download Avialable Indicators from the World Bank
#'
#' This function returns a [tibble][tibble::tibble-package] of indicator IDs and related information
#' that are available for download from the World Bank API
#'
#' @inheritParams wb_cache
#' @param include_archive `logical`. If `TRUE` indicators that have been archived
#'        by the World Bank will be included in the return. Data for these additional
#'        indicators are not available through the standard API and querying them
#'        using [wb_data()] will not return data. Default is `FALSE`.
#'
#' @examples
#' # can get a new list of available indicators by downloading new cache
#' \donttest{fresh_cache <- wb_cache()}
#' \donttest{fresh_indicators <- fresh_cache$indicators}
#'
#' # or by running the wb_indicators() function directly
#' \donttest{fresh_indicators <- wb_indicators()}
#'
#' # include archived indicators
#' # see include_archive parameter description
#' \donttest{indicators_with_achrive <- wb_indicators(include_archive = TRUE)}
#' @export
#' @md
wb_indicators <- function(lang, include_archive = FALSE) {
  # source 57 are archived indicators that WB no longer supports and aren't
  # avaialble through the standard API requests. After coorisponding with
  # WB API developers, they suggested the best way forward for now was to
  # simply exclude those indicators from being returned and available
  # Date: 2019-10-31 (Happy Halloween!)
  lang <- if_missing(lang, wb_default_lang(), lang)
  df <- wb_end_point("indicator", lang)

  if (!include_archive) df <- df[df$source_id != 57, ]

  # TODO: unlist topics column

  df
}

#' Download an updated list of country, indicator, and source information
#'
#' Download an updated list of information regarding countries, indicators,
#' sources, regions, indicator topics, lending types, income levels, and
#' supported languages from the World Bank API
#'
#' @param lang Language in which to return the results. If `lang` is unspecified,
#' english is the default. For supported languages see [wb_languages()].
#' Possible values of `lang` are in the `iso2` column. A note of warning, not
#' all data returns have support for langauges other than english. If the specific
#' return does not support your requested language by default it will return `NA`.
#'
#' @return A list containing the following items:
#' * `countries`: The result of calling [wb_countries()]
#' * `indicators`: The result of calling [wb_indicators()]
#' * `sources`: The result of calling [wb_sources()]
#' * `topics`: The result of calling [wb_topics()]
#' * `regions`: The result of calling [wb_regions()]
#' * `income_levels`: The result of calling [wb_income_levels()]
#' * `lending_types`: The result of calling [wb_lending_types()]
#' * `languages`: The result of calling [wb_languages()]
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#' does not support your requested language by default it will return `NA`. For an enumeration of
#' supported languages by data source please see [wb_languages()]
#'
#' Saving this return and using it has the `cache` parameter in [wb_data()] and [wb_search()]
#' replaces the default cached version [wb_cachelist] that comes with the package itself
#'
#' @export
#' @md
wb_cache <- function(lang) {
  lang <- if_missing(lang, wb_default_lang(), lang)
  list(
    countries     = wb_countries(lang),
    indicators    = wb_indicators(lang),
    sources       = wb_sources(lang),
    topics        = wb_topics(lang),
    regions       = wb_regions(lang),
    income_levels = wb_income_levels(lang),
    lending_types = wb_lending_types(lang),
    languages     = wb_languages()
  )
}
