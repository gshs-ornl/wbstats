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

#' @noRd
unique_na <- function(x, na.rm = TRUE) {
  x_unique <- unique(x)
  if(na.rm) x_unique <- x_unique[!is.na(x_unique)]

  x_unique
}


#' @noRd
format_wb_dates <- function(df) {

  date_vec <- df$date
  new_date_vec <- as.Date(rep(NA, length(date_vec)))
  obs_resolution <- as.character(rep(NA, length(date_vec)))

  # annual ----------
  annual_obs_index <- grep("[M|Q]", date_vec, invert = TRUE, ignore.case = TRUE)

  if (length(annual_obs_index) > 0) {

    annual_date <- as.Date(date_vec[annual_obs_index], "%Y")
    annual_date_values <- lubridate::floor_date(annual_date, unit = "year")

    new_date_vec[annual_obs_index] <- annual_date_values
    obs_resolution[annual_obs_index] <- "annual"

  }


  # monthly ----------
  monthly_obs_index <- grep("M", date_vec, ignore.case = TRUE)

  if (length(monthly_obs_index) > 0) {

    monthly_date <- lubridate::ydm(gsub("M", "01", date_vec[monthly_obs_index]))
    monthly_date_values <- lubridate::floor_date(monthly_date, unit = "month")

    new_date_vec[monthly_obs_index] <- monthly_date_values
    obs_resolution[monthly_obs_index] <- "monthly"

  }


  # quarterly ----------
  quarterly_obs_index <- grep("Q", date_vec, ignore.case = TRUE)

  if (length(quarterly_obs_index) > 0) {

    # takes a little more work
    qtr_obs <- strsplit(date_vec[quarterly_obs_index], "Q")
    qtr_df <- as.data.frame(matrix(unlist(qtr_obs), ncol = 2, byrow = TRUE), stringsAsFactors = FALSE)
    names(qtr_df) <- c("year", "qtr")
    qtr_df$month <- as.numeric(qtr_df$qtr) * 3 # to turn into the max month
    qtr_format_vec <- paste0(qtr_df$year, "01", qtr_df$month) # 01 acts as a dummy day

    quarterly_date <- lubridate::ydm(qtr_format_vec)
    quarterly_date_values <- lubridate::floor_date(quarterly_date, unit = "quarter")

    new_date_vec[quarterly_obs_index] <- quarterly_date_values
    obs_resolution[quarterly_obs_index] <- "quarterly"

  }

  df$date <- new_date_vec
  df$obs_resolution <- obs_resolution

  df
}
