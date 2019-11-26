#' Set the Value of a Missing Function Argument
#'
#' A simple wrapper around ifelse with the condition set to missing(x)
#'
#' @param x A function argument
#' @param true What to return if x is missing. Default is `NA`
#' @param false What to return if x is not missing. Default to return itself
#'
#' @noRd
if_missing <- function(x, true = NA, false = x) {
  ifelse(missing(x), true, false)
}

#' Title
#'
#' @return
#' @export
#'
#' @noRd
check_mark_text <- function() {
  if (
    requireNamespace("crayon", quietly = TRUE) &
    requireNamespace("clisymbols", quietly = TRUE)
  ) check_mark <- crayon::green(clisymbols::symbol$tick)
  else check_mark <- ""
}

unique_na <- function(x, na.rm = TRUE) {
  x_unique <- unique(x)
  if(na.rm) x_unique <- x_unique[!is.na(x_unique)]

  x_unique
}

