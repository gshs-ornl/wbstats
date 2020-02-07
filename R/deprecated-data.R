#' Cached information from the World Bank API
#'
#' This data is a cached result of the \code{\link{wbcache}} function.
#' By default functions \code{\link{wb}} and \code{\link{wbsearch}} use this
#' data for the \code{cache} parameter.
#'
#'
#' @format A list containing 7 data frames:
#' \itemize{
#' \item \code{countries}: A data frame. The result of calling \code{\link{wbcountries}}
#' \item \code{indicators}: A data frame.The result of calling \code{\link{wbindicators}}
#' \item \code{sources}: A data frame.The result of calling \code{\link{wbsources}}
#' \item \code{datacatalog}: A data frame.The result of calling \code{\link{wbdatacatalog}}
#' \item \code{topics}: A data frame.The result of calling \code{\link{wbtopics}}
#' \item \code{income}: A data frame.The result of calling \code{\link{wbincome}}
#' \item \code{lending}: A data frame.The result of calling \code{\link{wblending}}
#' }
"wb_cachelist_dep"
