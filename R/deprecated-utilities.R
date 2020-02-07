#' @noRd
wburls <- function() {

  base_url <- "http://api.worldbank.org/v2/"
  utils_url <- "per_page=20000&format=json"

  url_list <- list(base_url = base_url, utils_url = utils_url)

  url_list
}


#' @noRd
wbformatcols <- function(df, col_names, blank2NA = TRUE) {

  col_align <- match(names(col_names), names(df))
  col_match <- col_names[!is.na(col_align)]

  if (length(col_match) != 0) names(df)[match(names(col_match), names(df))] <- col_match

  if (blank2NA & (nrow(df) != 0)) df[df == ""] <- NA

  df
}


#' @noRd
wbdate2POSIXct <- function(df, date_col) {

  if (requireNamespace("lubridate", versionCheck = list(op = ">=", version = "1.5.0"),
                       quietly = TRUE)) {

    if (nrow(df) == 0) {

      # hackish way to support the POSIXct parameter with 0 rows returned
      df_ct <- as.data.frame(matrix(nrow = 0, ncol = 2), stringsAsFactors = FALSE)
      names(df_ct) <- c("date_ct", "granularity")

      df <- cbind(df, df_ct)

      return(df)
    }

    # lastUpdated field
    df$lastUpdated <- lubridate::as_date(df$lastUpdated)

    # add new columns
    df$date_ct <- as.Date.POSIXct(NA)
    df$granularity <- NA

    date_vec <- df[ , date_col]

    # annual ----------
    annual_obs_index <- grep("[M|Q|D]", date_vec, invert = TRUE)

    if (length(annual_obs_index) > 0) {

    annual_posix <- as.Date(date_vec[annual_obs_index], "%Y")
    annual_posix_values <- lubridate::floor_date(annual_posix, unit = "year")

    df$date_ct[annual_obs_index] <- annual_posix_values
    df$granularity[annual_obs_index] <- "annual"

    }


    # monthly ----------
    monthly_obs_index <- grep("M", date_vec)

    if (length(monthly_obs_index) > 0) {

    monthly_posix <- lubridate::ydm(gsub("M", "01", date_vec[monthly_obs_index]))
    monthly_posix_values <- lubridate::floor_date(monthly_posix, unit = "month")

    df$date_ct[monthly_obs_index] <- monthly_posix_values
    df$granularity[monthly_obs_index] <- "monthly"

    }


    # quarterly ----------
    quarterly_obs_index <- grep("Q", date_vec)

    if (length(quarterly_obs_index) > 0) {

    # takes a little more work
    qtr_obs <- strsplit(date_vec[quarterly_obs_index], "Q")
    qtr_df <- as.data.frame(matrix(unlist(qtr_obs), ncol = 2, byrow = TRUE), stringsAsFactors = FALSE)
    names(qtr_df) <- c("year", "qtr")
    qtr_df$month <- as.numeric(qtr_df$qtr) * 3 # to turn into the max month
    qtr_format_vec <- paste0(qtr_df$year, "01", qtr_df$month) # 01 acts as a dummy day

    quarterly_posix <- lubridate::ydm(qtr_format_vec)
    quarterly_posix_values <- lubridate::floor_date(quarterly_posix, unit = "quarter")

    df$date_ct[quarterly_obs_index] <- quarterly_posix_values
    df$granularity[quarterly_obs_index] <- "quarterly"

    }

  } else {

    warning("Required Namespace 'lubridate (>= 1.5.0)' not available. This option is being ignored")

  }

  df
}


#' @noRd
call_api <- function(url_string, indicator) {

  # move this to data-raw eventually
  ua <- httr::user_agent("https://github.com/GIST-ORNL/wbstats")

  # add api_token here if/when that is supported

  get_return <- httr::GET(url_string, ua)

  if (httr::http_error(get_return)) {

    error_status<- httr::http_status(get_return)

    stop(sprintf("World Bank API request failed for indicator %s\nmessage: %s\ncategory: %s\nreason: %s \nurl: %s",
                 indicator,
                 error_status$message,
                 error_status$category,
                 error_status$reason,
                 url_string),
         call. = FALSE)
  }

  if (httr::http_type(get_return) != "application/json") {
    stop("API call executed successfully, but did not return expected json format", call. = FALSE)
  }

  return_json <- httr::content(get_return, as = "text")

  return_json
}



#' @noRd
wbget <- function(url_string, indicator) {

  return_json <- call_api(url_string = url_string, indicator = indicator)

  return_list <- jsonlite::fromJSON(return_json, simplifyVector = FALSE)

  if ("message" %in% names(return_list[[1]])) {

    message_list <- return_list[[1]]$message[[1]]

    stop(sprintf("World Bank API request failed for indicator %s The following message was returned from the server\nid: %s\nkey: %s\nvalue: %s",
                 indicator,
                 message_list$id,
                 message_list$key,
                 message_list$value),
         call. = FALSE)

  }

  n_pages <- return_list[[1]]$pages

  if (n_pages == 0) return(NA) # a blank data frame will be returned to the user

  return_list <- jsonlite::fromJSON(return_json,  flatten = TRUE)

  lastUpdated <- return_list[[1]]$lastupdated

  if (n_pages > 1) {

    page_list <- lapply(1:n_pages, FUN = function(page) {

      if (page == 1) {

        return_list[[2]]

      } else {

        page_url <- paste0(url_string, "&page=", page)

        # page_return <- wbget.raw(page_url)
        page_return_json <- call_api(url_string = page_url)
        page_return_list <- jsonlite::fromJSON(page_return_json,  flatten = TRUE)
        page_df <- page_return_list[[2]]

      }
    }
    ) # end lapply

    return_df <- do.call("rbind", page_list)

  } else { # only one page

    return_df <- return_list[[2]]

  }

  return_df$lastUpdated <- lastUpdated
  return_df

}


#' @noRd
wbget_dc <- function(url_string) {

  return_json <- call_api(url_string = url_string, indicator = "Data Catalog")
  return_list <- jsonlite::fromJSON(return_json,  flatten = TRUE)

  n_pages <- return_list$pages

  if (n_pages > 1) {

    page_list <- lapply(1:n_pages, FUN = function(page) {

      if (page == 1) {

        return_list$datacatalog$metatype

      } else {

        page_url <- paste0(url_string, "&page=", page)

        page_return_json <- call_api(url_string = page_url)
        page_return_list <- jsonlite::fromJSON(page_return_json,  flatten = TRUE)
        page_metadata_list <- page_return_list$datacatalog$metatype

      }
    }
    ) # end lapply

    page_list <- unlist(x = page_list, recursive = FALSE)

  } else { # only one page

    page_list <- return_list$datacatalog$metatype

  }

  page_list

}
