#' Download Indicator Data from World Bank
#'
#' @param indicator
#' @param country
#' @param start_date
#' @param end_date
#' @param mrv
#' @param mrnev
#' @param footnote
#' @param freq
#' @param scale
#'
#' @return
#' @export
#'
#' @examples
wb_data <- function(indicator = "SP.POP.TOTL", country = "AFG", start_date,
                    end_date, mrv, freq, mrnev, gapfill, footnote, scale, cache) {

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

  # check footnote ----------
  footnote_query <- NULL
  if (!missing(footnote)) {
    if (!is.logical(footnote)) stop("Values for footnote must be TRUE or FALSE")

    footnote_query <- ifelse(footnote, "Y", "N")
  }

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
    footnote = footnote_query,
    cntrycode = "y",
    per_page = wbstats:::wb_api_parameters$per_page,
    format   = wbstats:::wb_api_parameters$format
  )

  # be able to return this for debugging
  ind_url <- wbstats:::build_wb_url(base_url = base_url, indicator = indicator, path_list = path_list, query_list = query_list)

  d_list <- lapply(ind_url, fetch_wb_url)
  d <- do.call(rbind, d_list)
  d <- format_wb_data(d, end_point = "data")


  d


}
