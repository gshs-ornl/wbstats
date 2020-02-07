#' @noRd
wb_default_lang <- function(lang) {
  if (missing(lang)) {
    env_lang <- options()$wbstats.lang
    if (!is.null(env_lang)) default_lang <- env_lang
    else default_lang <- wb_api_parameters$default_lang
  }
  else {
    # here is where you would set the environ var
    # do we check against available defaults?
    options(wbstats.lang = lang)
    message(paste("Setting default wbstats language to", lang,
                "\nTo change this run wb_default_lang(lang = value).",
                "The default value is 'en' (english)"))
   default_lang <- wb_default_lang()
  }

  default_lang
}
