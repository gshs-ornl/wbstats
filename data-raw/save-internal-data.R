
source("data-raw/wb-api-name-patterns.R")
source("data-raw/wb-api-parameters.R")

usethis::use_data(wb_api_parameters, wb_api_name_patterns,
                  internal = TRUE, overwrite = TRUE)
