#' Download Indicator Data from World Bank
#'
#' @param indicator
#' @param country
#' @param start_date
#' @param end_date
#' @param mrv
#' @param mrnev
#' @param freq
#' @param scale
#'
#' @return
#' @export
#'
#' @examples
wb_data <- function(indicator = "SP.POP.TOTL", country = "AFG", start_date,
                    end_date, return_wide = TRUE, mrv, freq, mrnev, gapfill, scale, cache) {

  if (missing(cache)) cache <- wbstats::wb_cachelist



  # TODO:
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

  # # check footnote ----------
  # footnote_query <- NULL
  # if (!missing(footnote)) {
  #   if (!is.logical(footnote)) stop("Values for footnote must be TRUE or FALSE")
  #
  #   footnote_query <- ifelse(footnote, "Y", "N")
  # }

  # check scale ----------
  scale_query <- NULL
  if (!missing(scale)) {
    if (!is.logical(scale)) stop("Values for scale must be TRUE or FALSE")

    scale_query <- ifelse(scale, "Y", "N")
  }

  # country should be part of the path list b/c other endpoint don't require it or need more things
  path_list <- list(
    version = wbstats:::wb_api_parameters$version,
    lang    = if_missing(lang,
                         options()$wbstats.lang,
                         wbstats:::wb_api_parameters$default_lang
                         ),
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
    footnote = "y",  #footnote_query,
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
