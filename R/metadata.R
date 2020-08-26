#!/usr/bin/env Rscript
# -*- codingt: utf-8 -*-
#' @title       Retrieve metadata for a specific indicator
#' @description Retrieves the metadata unnested from the World Bank metadata
#'              indicator endpoint
#' @param       indicator the indicator to retrieve metadata from, can be a 
#'              character vector
#' @export
wb_metadata <- function(indicator) {
  inds <- wb_indicators()
  metadata_url_str <- 
    'http://api.worldbank.org/v2/sources/%d/indicators/%s/metadata?format=JSON'
  df <- data.frame()
  for (i in inidicator) {
    src <- inds[indicator_id == i, 'source_id']
    murl <- sprintf(metadata_url_str, src, i)
    res <- jsonlite::fromJSON(murl)$source
    res1 <- res$concept[[1]]
    res2 <- res2$variable[[1]]$metatype[[1]]
    res3 <- dcast(res2, . ~ id)[, -c('.')]
    df <- rbind(df, res3, fill = TRUE)
  }
  return(df)
}
