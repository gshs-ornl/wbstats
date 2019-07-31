.onLoad <- function(libname, pkgname) {

  op.wbstats <- list(
    wbstats.lang = "en",
    wbstats.cache_dir = NULL,
    wbstats.refresh_cache_on_load = FALSE,
    wbstats.cache_life = as.difftime(7, units = "days"),
    wbstats.cache_timestamp = NULL
  )

  # if the options are there, set them
  op_to_set <- !(names(op.wbstats) %in% names(options()))
  if(any(op_to_set)) options(op.wbstats[op_to_set])

 # check_refresh_on_load()

}
