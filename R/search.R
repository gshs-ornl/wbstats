#' Search indicator information available through the World Bank API
#'
#' This function allows finds indicators that match a search term and returns
#' a data frame of matching results
#'
#' @param pattern Character string or regular expression to be matched
#' @param fields Character vector of column names through which to search
#' @param extra if FALSE, only the indicator ID and short name are returned,
#' if `TRUE`, all columns of the `cache` parameter's indicators data frame
#' are returned. Default is `FALSE`
#' @param ignore.case if `FALSE`, the pattern matching is case sensitive and
#' if `TRUE`, case is ignored during matching. Default is `TRUE`
#' @param cache List of data frames returned from [wb_cache()]. If omitted,
#' [wb_cachelist] is used
#' @param ... Any additional [grep()] agruments you which to pass
#' @return a [tibble][tibble::tibble-package] with indicators that match the search pattern.
#' @md
#' @examples
#' \donttest{d <- wb_search(pattern = "education")}
#'
#' \donttest{d <- wb_search(pattern = "Food and Agriculture Organization", fields = "source_org")}
#'
#' # with regular expression operators
#' # 'poverty' OR 'unemployment' OR 'employment'
#' \donttest{d <- wb_search(pattern = "poverty|unemployment|employment")}
#'
#' # pass any other grep argument along as well
#' # everything without 'education'
#' \donttest{d <- wb_search(pattern = "education", invert = TRUE)}
#'
#' # contains "gdp" AND "trade"
#' \donttest{d <- wb_search("^(?=.*gdp)(?=.*trade).*", perl = TRUE)}
#'
#' # contains "gdp" and NOT "trade"
#' \donttest{d <- wb_search("^(?=.*gdp)(?!.*trade).*", perl = TRUE)}
#' @export
wb_search <- function(pattern, fields = c("indicator_id", "indicator", "indicator_desc"),
                      extra = FALSE, cache, ignore.case = TRUE, ...){

  if (missing(cache)) cache <- wbstats::wb_cachelist
  ind_cache <- as.data.frame(cache$indicators)

  match_index <- sort(unique(unlist(sapply(fields, FUN = function(i)
    grep(pattern, ind_cache[, i], ignore.case = ignore.case, ...), USE.NAMES = FALSE)
  )))

  if (length(match_index) == 0) warning(paste0("no matches were found for the search term ", pattern,
                                               ". Returning an empty data frame."))

  if (extra) {
    match_df <-  cache$indicators[match_index, ]
  } else {
    match_df <- cache$indicators[match_index, c("indicator_id", "indicator", "indicator_desc")]
  }

  tibble::as_tibble(match_df)
}
