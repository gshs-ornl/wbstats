#' Search indicator information available through the World Bank API
#'
#' This function allows finds indicators that match a search term and returns
#' a data frame of matching results
#'
#' @param pattern Character string or regular expression to be matched
#' @param fields Character vector of column names through which to search
#' @param extra if \code{FALSE}, only the indicator ID and short name are returned,
#' if \code{TRUE}, all columns of the \code{cache} parameter's indicator data frame
#' are returned
#' @param cache List of data frames returned from \code{\link{wb_cache}}. If omitted,
#' \code{\link{wb_cachelist}} is used
#' @return Data frame with indicators that match the search pattern.
#' @examples
#' wb_search(pattern = "education")
#'
#' wb_search(pattern = "Food and Agriculture Organization", fields = "source_org")
#'
#' # with regular expression operators
#' # 'poverty' OR 'unemployment' OR 'employment'
#' wb_search(pattern = "poverty|unemployment|employment")
#'
#'  # pass any other grep argument along as well
#'  # everything without 'education'
#'  wb_search(pattern = "education", invert = TRUE)
#' @export
wb_search <- function(pattern = "poverty", fields = c("indicator", "indicator_desc"),
                      extra = FALSE, cache, ...){

  if (missing(cache)) cache <- wbstats::wb_cachelist

  ind_cache <- as.data.frame(cache$indicators)

  match_index <- sort(unique(unlist(sapply(fields, FUN = function(i)
    grep(pattern, ind_cache[, i], ignore.case = TRUE, ...), USE.NAMES = FALSE)
  )))

  if (length(match_index) == 0) warning(paste0("no matches were found for the search term ", pattern,
                                               ". Returning an empty data frame."))

  if (extra) {
    match_df <-  cache$indicators[match_index, ]
  } else {
    match_df <- cache$indicators[match_index, c("indicator_id", "indicator")]
  }

  tibble::as_tibble(match_df)
}
