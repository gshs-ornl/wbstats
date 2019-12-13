
#' Title
#'
#' @param base_url
#' @param indicator
#' @param path_list
#' @param query_list
#'
#' @return
#'
#' @noRd
build_wb_url <- function(base_url, indicator, path_list, query_list) {

  url_path <- unlist(path_list)
  url_path <- url_path[!is.na(url_path)]

  query_list <- query_list[!is.na(query_list)]

  if(missing(indicator)) {
    out_url <- httr::modify_url(base_url, path = url_path, query = query_list)
    return(out_url)
  }

  indicator_path <- wb_api_parameters$indicator
  indicator_path <- paste0(indicator_path, "/", indicator)

  if(is.null(names(indicator))) names(indicator_path) <- indicator
  else names(indicator_path) <- names(indicator)

  out_url <- sapply(indicator_path, FUN = function(ind) {
    url_path <- c(url_path, ind)
    httr::modify_url(base_url, path = url_path, query = query_list)
  }
  )

  out_url
}


#' Title
#'
#' @param end_point
#' @param lang
#'
#' @return
#'
#' @noRd
build_get_url <- function(end_point, lang) {

  base_url <- wb_api_parameters$base_url

  path_list <- list(
    version = wb_api_parameters$version,
    lang    = if_missing(lang, options()$wbstats.lang, lang),
    path    = wb_api_parameters[[end_point]]
  )

  query_list <- list(
    per_page = wb_api_parameters$per_page,
    format   = wb_api_parameters$format
  )


  wb_url <- build_wb_url(
    base_url   = base_url,
    path_list  = path_list,
    query_list = query_list
  )

  wb_url
}


#' Title
#'
#' @param url_string
#' @param indicator
#'
#' @return
#'
#' @noRd
fetch_wb_url <- function(url_string, indicator) {

  return_json <- fetch_wb_url_content(url_string = url_string, indicator = indicator)

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

        page_return_json <- fetch_wb_url_content(url_string = page_url)
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




#' Title
#'
#' @param url_string
#' @param indicator
#'
#' @return
#'
#' @noRd
fetch_wb_url_content <- function(url_string, indicator) {

  indicator <- if_missing(indicator)

  # move this to data-raw eventually
  ua <- httr::user_agent("https://github.com/jpiburn/wbstats")

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


