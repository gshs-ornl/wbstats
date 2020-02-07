#' Download updated country and region information from World Bank API
#'
#' Download updated information on available countries and regions
#' from the World Bank API
#'
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#' english is the default.
#'
#' @return A data frame of available countries and regions with related information
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#' does not support your requested language by default it will return \code{NA}. For an enumeration of
#' supported languages by data source please see \code{\link{wbdatacatalog}}.
#' The options for \code{lang} are:
#' \itemize{
#' \item \code{en}: English
#' \item \code{es}: Spanish
#' \item \code{fr}: French
#' \item \code{ar}: Arabic
#' \item \code{zh}: Mandarin
#' }
#'
#' @export
wbcountries <- function(lang = c("en", "es", "fr", "ar", "zh")) {


  lifecycle::deprecate_warn("1.0.0", "wbstats::wbcountries()", "wbstats::wb_countries()")

  # if none supplied english is default
  lang <- match.arg(lang)

  url_list <- wburls()
  base_url <- url_list$base_url
  utils_url <- url_list$utils_url

  countries_url <- paste0(base_url, lang, "/countries?", utils_url)
  countries_df <- wbget(countries_url)

  # "defaultName" = "newName"
  countries_cols <- c("id" = "iso3c",
                      "iso2Code" = "iso2c",
                      "name" = "country",
                      "capitalCity" = "capital",
                      "longitude" = "long",
                      "latitude" = "lat",
                      "region.id" = "regionID",
                      "region.value" = "region",
                      "region.iso2code" = "region_iso2c",
                      "adminregion.id" = "adminID",
                      "adminregion.value" = "admin",
                      "adminregion.iso2code" = "admin_iso2c",
                      "incomeLevel.id" = "incomeID",
                      "incomeLevel.value" = "income",
                      "incomeLevel.iso2code" = "income_iso2c",
                      "lendingType.id" = "lendingID",
                      "lendingType.value" = "lending",
                      "lendingType.iso2code" = "lending_iso2c")

  countries_df <- wbformatcols(countries_df, countries_cols)

  # regionID and incomeID have "NA" for some results
  # do not do replace all for the df because Namibia's iso2c code is "NA"
  if ("regionID" %in% names(countries_df)) countries_df[countries_df$regionID == "NA", "regionID"] <- NA
  if ("incomeID" %in% names(countries_df)) countries_df[countries_df$incomeID == "NA", "incomeID"] <- NA
  if ("region_iso2c" %in% names(countries_df)) countries_df[countries_df$region_iso2c == "NA", "region_iso2c"] <- NA
  if ("income_iso2c" %in% names(countries_df)) countries_df[countries_df$income_iso2c == "NA", "income_iso2c"] <- NA

  countries_df
}


#' Download updated indicator information from World Bank API
#'
#' Download updated information on available indicators
#' from the World Bank API
#'
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#' english is the default.
#'
#' @return A data frame of available indicators with related information
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#' does not support your requested language by default it will return \code{NA}. For an enumeration of
#' supported languages by data source please see \code{\link{wbdatacatalog}}.
#' The options for \code{lang} are:
#' \itemize{
#' \item \code{en}: English
#' \item \code{es}: Spanish
#' \item \code{fr}: French
#' \item \code{ar}: Arabic
#' \item \code{zh}: Mandarin
#' }
#'
#' @export
wbindicators <- function(lang = c("en", "es", "fr", "ar", "zh")) {

  lifecycle::deprecate_warn("1.0.0", "wbstats::wbindicators()", "wbstats::wb_indicators()")

  # if none supplied english is default
  lang <- match.arg(lang)

  url_list <- wburls()
  base_url <- url_list$base_url
  utils_url <- url_list$utils_url

  indicators_url <- paste0(base_url, lang, "/indicators?", utils_url)
  indicators_df <- wbget(indicators_url)

  # the topics return is not in the correct format for a df. topics can be
  # retrieved with wbtopics()
  indicators_df$topics <- NULL

  # "defaultName" = "newName"
  indicators_cols <- c("id" = "indicatorID",
                       "name" = "indicator",
                       "unit" = "unit",
                       "sourceNote" = "indicatorDesc",
                       "sourceOrganization" = "sourceOrg",
                       "source.id" = "sourceID",
                       "source.value" = "source")

  indicators_df <- wbformatcols(indicators_df, indicators_cols)

  indicators_df
}



#' Download updated indicator topic information from World Bank API
#'
#' Download updated information on available indicator topics
#' from the World Bank API
#'
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#' english is the default.
#'
#' @return A data frame of available indicator topics with related information
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#' does not support your requested language by default it will return \code{NA}. For an enumeration of
#' supported languages by data source please see \code{\link{wbdatacatalog}}.
#' The options for \code{lang} are:
#' \itemize{
#' \item \code{en}: English
#' \item \code{es}: Spanish
#' \item \code{fr}: French
#' \item \code{ar}: Arabic
#' \item \code{zh}: Mandarin
#' }
#'
#' @export
wbtopics <- function(lang = c("en", "es", "fr", "ar", "zh")) {

  lifecycle::deprecate_warn("1.0.0", "wbstats::wbtopics()", "wbstats::wb_topics()")
  # if none supplied english is default
  lang <- match.arg(lang)

  url_list <- wburls()
  base_url <- url_list$base_url
  utils_url <- url_list$utils_url

  topics_url <- paste0(base_url, lang, "/topics?", utils_url)
  topics_df <- wbget(topics_url)

  # "defaultName" = "newName"
  topics_cols <- c("id" = "topicID",
                   "value" = "topic",
                   "sourceNote" = "topicDesc")

  topics_df <- wbformatcols(topics_df, topics_cols)

  topics_df
}


#' Download updated lending type information from World Bank API
#'
#' Download updated information on available lending types
#' from the World Bank API
#'
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#' english is the default.
#'
#' @return A data frame of available lending types with related information
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#' does notsupport your requested language by default it will return \code{NA}. For an enumeration of
#' supported languages by data source please see \code{\link{wbdatacatalog}}.
#' The options for \code{lang} are:
#' \itemize{
#' \item \code{en}: English
#' \item \code{es}: Spanish
#' \item \code{fr}: French
#' \item \code{ar}: Arabic
#' \item \code{zh}: Mandarin
#' }
#'
#' @export
wblending <- function(lang = c("en", "es", "fr", "ar", "zh")) {

  lifecycle::deprecate_warn("1.0.0", "wbstats::wblending()", "wbstats::wb_lending_types()")
  # if none supplied english is default
  lang <- match.arg(lang)

  url_list <- wburls()
  base_url <- url_list$base_url
  utils_url <- url_list$utils_url

  lending_url <- paste0(base_url, lang, "/lendingTypes?", utils_url)
  lending_df <- wbget(lending_url)

  # "defaultName" = "newName"
  lending_cols <- c("id" = "lendingID",
                    "value" = "lending",
                    "iso2code" = "iso2c")

  lending_df <- wbformatcols(lending_df, lending_cols)

  lending_df
}



#' Download updated income type information from World Bank API
#'
#' Download updated information on available income types
#' from the World Bank API
#'
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#' english is the default.
#'
#' @return A data frame of available income types with related information
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#' does not support your requested language by default it will return \code{NA}. For an enumeration of
#' supported languages by data source please see \code{\link{wbdatacatalog}}.
#' The options for \code{lang} are:
#' \itemize{
#' \item \code{en}: English
#' \item \code{es}: Spanish
#' \item \code{fr}: French
#' \item \code{ar}: Arabic
#' \item \code{zh}: Mandarin
#' }
#'
#' @export
wbincome <- function(lang = c("en", "es", "fr", "ar", "zh")) {

  lifecycle::deprecate_warn("1.0.0", "wbstats::wbincome()", "wbstats::wb_income_levels()")

  # if none supplied english is default
  lang <- match.arg(lang)

  url_list <- wburls()
  base_url <- url_list$base_url
  utils_url <- url_list$utils_url

  income_url <- paste0(base_url, lang, "/incomelevels?", utils_url)
  income_df <- wbget(income_url)

  # "defaultName" = "newName"
  income_cols <- c("id" = "incomeID",
                   "value" = "income",
                   "iso2code" = "iso2c")

  income_df <- wbformatcols(income_df, income_cols)

  income_df
}



#' Download updated data source information from World Bank API
#'
#' Download updated information on available data sources
#' from the World Bank API
#'
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#' english is the default.
#'
#' @return A data frame of available data scources with related information
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#' does not support your requested language by default it will return \code{NA}. For an enumeration of
#' supported languages by data source please see \code{\link{wbdatacatalog}}.
#' The options for \code{lang} are:
#' \itemize{
#' \item \code{en}: English
#' \item \code{es}: Spanish
#' \item \code{fr}: French
#' \item \code{ar}: Arabic
#' \item \code{zh}: Mandarin
#' }
#' @export
wbsources <- function(lang = c("en", "es", "fr", "ar", "zh")) {

  lifecycle::deprecate_warn("1.0.0", "wbstats::wbsources()", "wbstats::wb_sources()")

  # if none supplied english is default
  lang <- match.arg(lang)

  url_list <- wburls()
  base_url <- url_list$base_url
  utils_url <- url_list$utils_url

  sources_url <- paste0(base_url, lang, "/sources?", utils_url)
  sources_df <- wbget(sources_url)

  # "defaultName" = "newName"
  sources_cols <- c("id" = "sourceID",
                    "name" = "source",
                    "description" = "sourceDesc",
                    "url" = "sourceURL",
                    "code" = "sourceAbbr",
                    "lastupdated" = "lastUpdated",
                    "dataavailability" = "dataAvail",
                    "metadataavailability" = "metadataAvail")

  sources_df <- wbformatcols(sources_df, sources_cols)

  sources_df
}



#' Download an updated list of the World Bank data catalog
#'
#' Download an updated list of the World Bank data catalog
#' from the World Bank API
#'
#' @return A data frame of the World Bank data catalog with related information
#'
#' @note This function does not support any languages other than english due to
#' the lack of support from the World Bank API
#' @export
wbdatacatalog <- function() {

  lifecycle::deprecate_warn("1.0.0", "wbstats::wbdatacatalog()",
                            details = paste("This function uses an out of date version of the Data Catalog API.",
                                            "wbstats does not currently have support for the latest API version.\n",
                                            "Please see https://datacatalog.worldbank.org/ for up to date information.")
                            )

  url_list <- wburls()
  base_url <- url_list$base_url

  catalog_url <- paste0(base_url, "datacatalog?format=json")
  catalog_return <- wbget_dc(catalog_url)

  # the return is not very nice
  # so we have to do some leg work

  catalog_list <- lapply(catalog_return, FUN = function(i) {

    i_vec <- i$value
    names(i_vec) <- i$id

    i_vec
  })

  # dplyr::rbind_list() would be more compact here but no need to add a dependency
  catalog_df <- as.data.frame(do.call(rbind,
                                      lapply(lapply(catalog_list, unlist),
                                             "[", unique(unlist(sapply(catalog_list, names)))
                                             )
                                      ), stringsAsFactors = FALSE)

  names(catalog_df) <- unique(unlist(sapply(catalog_list, names)))

  # "defaultName" = "newName"
  catalog_cols <- c("name" = "source",
                    "acronym" = "sourceAbbr",
                    "description" = "sourceDesc",
                    "url" = "url",
                    "type" = "type",
                    "languagesupported" = "langSupport",
                    "periodicity" = "periodicity",
                    "economycoverage" = "econCoverage",
                    "granularity" = "granularity",
                    "numberofeconomies" = "numEcons",
                    "topics" = "topics",
                    "updatefrequency" = "updateFreq",
                    "updateschedule" = "updateSched",
                    "lastrevisiondate" = "lastRevision",
                    "contactdetails" = "contactInfo",
                    "accessoption" = "accessOpt",
                    "bulkdownload" = "bulkDownload",
                    "cite" = "cite",
                    "detailpageurl" = "detailURL",
                    "coverage" = "coverage",
                    "api" = "api",
                    "apiaccessurl" = "apiURL",
                    "apisourceid" = "SourceID",
                    "mobileapp" = "mobileApp",
                    "datanotes" = "dataNotes",
                    "sourceurl" = "sourceURL",
                    "apilocation" = "apiLocation",
                    "listofcountriesregionssubnationaladmins" = "geoCoverage")

  catalog_df <- wbformatcols(catalog_df, catalog_cols)

  catalog_df
}


#' Download an updated list of country, indicator, and source information
#'
#' Download an updated list of information regarding countries, indicators,
#' sources, data catalog, indicator topics, lending types, and income levels
#' from the World Bank API
#'
#' @param lang Language in which to return the results. If \code{lang} is unspecified,
#' english is the default.
#'
#' @return A list containing the following items:
#' \itemize{
#' \item \code{countries}: A data frame. The result of calling \code{\link{wbcountries}}
#' \item \code{indicators}: A data frame.The result of calling \code{\link{wbindicators}}
#' \item \code{sources}: A data frame.The result of calling \code{\link{wbsources}}
#' \item \code{datacatalog}: A data frame.The result of calling \code{\link{wbdatacatalog}}
#' \item \code{topics}: A data frame.The result of calling \code{\link{wbtopics}}
#' \item \code{income}: A data frame.The result of calling \code{\link{wbincome}}
#' \item \code{lending}: A data frame.The result of calling \code{\link{wblending}}
#' }
#'
#' @note Not all data returns have support for langauges other than english. If the specific return
#' does not support your requested language by default it will return \code{NA}. For an enumeration of
#' supported languages by data source please see \code{\link{wbdatacatalog}}.
#' The options for \code{lang} are:
#' \itemize{
#' \item \code{en}: English
#' \item \code{es}: Spanish
#' \item \code{fr}: French
#' \item \code{ar}: Arabic
#' \item \code{zh}: Mandarin
#' }
#' List item \code{datacatalog} will always return in english, as the API does not support any
#' other langauges for that information.
#'
#' Saving this return and using it has the \code{cache} parameter in \code{\link{wb}} and \code{\link{wbsearch}}
#' replaces the default cached version \code{\link{wb_cachelist}} that comes with the package itself
#' @export
wbcache <- function(lang = c("en", "es", "fr", "ar", "zh")) {

  lifecycle::deprecate_warn("1.0.0", "wbstats::wbcache()", "wbstats::wb_cache()")
  # if none supplied english is default
  lang <- match.arg(lang)

  cache_list <- list("countries" = wbcountries(lang = lang),
                     "indicators" = wbindicators(lang = lang),
                     "sources" = wbsources(lang = lang),
                     "datacatalog" = wbdatacatalog(), # does not take lang input
                     "topics" = wbtopics(lang = lang),
                     "income" = wbincome(lang = lang),
                     "lending" = wblending(lang = lang))

  cache_list
}


