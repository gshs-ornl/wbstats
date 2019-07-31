#' Title
#'
#' @param x
#' @param end_point
#'
#' @return
#'
#' @noRd
format_wb_tidy_names <- function(x, end_point) {

  global_patterns <- wb_api_name_patterns$global_patterns
  local_patterns <- wb_api_name_patterns[[end_point]]
  all_patterns <- c(global_patterns, local_patterns)


  # this can all be replaces by janitor::clean_names
  x_trim    <- stringr::str_trim(x)
  x_lower   <- stringr::str_to_lower(x_trim)
  x_replace <- stringr::str_replace_all(x_lower, all_patterns)
  x_tidy    <- tibble::tidy_names(x_replace, quiet = TRUE)

  x_tidy
}


#' Title
#'
#' @param x
#' @param end_point
#'
#' @return
#'
#' @noRd
format_wb_data <- function(x, end_point) {

  x_field_types <- format_wb_get_col_type(x)
  col_index <- which(x_field_types %in% "character")

  x <- format_wb_func(x, readr::parse_guess,
                      col_index = col_index)

  # still need to make sure that blanks are turned to NAs
  if (end_point == "data") {

    x_names <- format_wb_tidy_names(names(x), end_point = end_point)
    names(x) <- x_names

    x$value <- as.numeric(x$value)
    x$unit <- as.character(x$unit)
    x$obs_status <- as.character(x$obs_status)
    x$footnote <- as.character(x$obs_status)
  }

  if (end_point == "query")

  if (end_point == "country") x[x$iso3c == "NAM", "iso2c"] <- "NA"

  if (end_point == "source") {

    log_fields <- c("data_available", "metadata_available")
    col_index <- which(names(x) %in% log_fields)

    x <- format_wb_func(x, format_wb_func_as_logical,
                        true_pattern  = "Yes|yes|Y|y",
                        false_pattern = "No|no|N|n",
                        col_index = col_index)
  }

  tibble::as_tibble(x)
}



#' Title
#'
#' @param x
#' @param ...
#'
#' @return
#'
#' @noRd
format_wb_get_col_type <- function(x, ...) {
  x_type <- sapply(seq(ncol(x)), FUN = function(i) typeof(x[ ,i]))
  names(x_type) <- names(x)
  x_type
}


#' Title
#'
#' @param x
#' @param current_value
#' @param replacement
#' @param ...
#'
#' @return
#'
#' @noRd
format_wb_func_replace_value <- function(x, current_value, replacement, ...) {
  x[x == current_value] <- replacement
  x
}

#' Title
#'
#' @param x
#' @param true_pattern
#' @param false_pattern
#' @param ...
#'
#' @return
#'
#' @noRd
format_wb_func_as_logical <- function(x, true_pattern, false_pattern, ...) {
  true_index <- grep(true_pattern, x = x, ...)
  false_index <- grep(false_pattern, x = x, ...)

  index_in_both <- base::intersect(true_index, false_index)

  if(length(index_in_both) != 0)
    warning("Patterns provided match both `TRUE` and `FALSE`.")

  x[true_index]  <- TRUE
  x[false_index] <- FALSE

  as.logical(x, ...)
}


#' Title
#'
#' @param df
#' @param func
#' @param col_index
#' @param ...
#'
#' @return
#'
#' @noRd
format_wb_func <- function(df, func, col_index,  ...) {

  if(missing(col_index)) col_index <- seq_len(ncol(df))

  df[, col_index] <- lapply(col_index, FUN = function(i) {
    x<- df[, i]
    func(x, ...)
  })

  df
}

format_wb_country <- function(x) {

  # check and make sure everything is correct
  paste0(x, collapse = ";")
}

