
wb_api_parameters <- list(
  base_url     = "https://api.worldbank.org/",
  version      = "v2",
  default_lang = "en",
  country      = "country",
  indicator    = "indicator",
  region       = "region",
  income_level = "incomelevel",
  lending_type = "lendingtype",
  topic        = "topic",
  language     = "language",
  source       = "sources",
  metatypes    = "metatypes",
  concepts     = "concepts",
  metadata     = "metadata",
  # how should I add the series-time, country-series, etc. ?
  per_page     = 20000,
  format       = "json"
)
