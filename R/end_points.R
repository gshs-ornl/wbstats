#' Title
#'
#' @param end_point
#' @param lang
#' @param ...
#'
#' @return
#'
#' @noRd
wb_end_point <- function(end_point, lang, ...) {

  get_url <- build_get_url(end_point, lang = lang)

  d <- fetch_wb_url(get_url)
  d_names <- format_wb_tidy_names(names(d), end_point = end_point)
  names(d) <- d_names

  format_wb_data(d, end_point = end_point)
}

#' Title
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
wb_countries <- function(...) {
  wb_end_point("country", ...)
}


#' Title
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
wb_topics <- function(...) {
  wb_end_point("topic", ...)
}

#' Title
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
wb_sources <- function(...) {
  wb_end_point("source",...)
}

#' Title
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
wb_regions <- function(...) {
  wb_end_point("region", ...)
}

#' Title
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
wb_income_levels <- function(...) {
  wb_end_point("income_level", ...)
}

#' Title
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
wb_lending_types <- function(...) {
  wb_end_point("lending_type", ...)
}

#' Title
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
wb_languages <- function(...) {
  wb_end_point("language", lang = NA)
}

#' Title
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
wb_indicators <- function(...) {
  # source 57 are archived indicators that WB no longer supports and aren't
  # avaialble through the standard API requests. After coorisponding with
  # WB API developers, they suggested the best way forward for now was to
  # simply exclude those indicators from being returned and available
  # Date: 2019-10-31 (Happy Halloween!)

  df <- wb_end_point("indicator", ...)
  df <- df[df$source_id != 57, ]

  # TODO: unlist topics column

  df
}

#' Title
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
wb_cache <- function(...) {
  list(
    countries     = wb_countries(...),
    indicators    = wb_indicators(...),
    sources       = wb_sources(...),
    topics        = wb_topics(...),
    regions       = wb_regions(...),
    income_levels = wb_income_levels(...),
    lending_types = wb_lending_types(...),
    languages     = wb_languages(...)
  )
}
