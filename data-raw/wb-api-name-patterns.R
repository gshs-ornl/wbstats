
global_patterns <- c("\\." = "_",
                     "_value|\\.value"    = "",
                     "_name|\\.name"      = "",
                     "iso2code|iso2Code"  = "iso2c")

country_patterns <- c("^name" = "country",
                      "^id"   = "iso3c",
                      "_id"   = "_iso3c",
                      "capitalcity|capitalCity" = "capital_city",
                      "adminregion|adminRegion" = "admin_region",
                      "incomelevel|incomeLevel" = "income_level",
                      "lendingtype|lendingType" = "lending_type")

lending_type_patterns <- c("^id"    = "iso3c",
                           "^value" = "lending_type")

income_level_patterns <- c("^id"    = "iso3c",
                           "^value" = "income_level")

region_patterns <- c("^id"   = "region_id",
                     "^code" = "iso3c",
                     "^name" = "region")

language_patterns <- c("code" = "iso2",
                       "name" = "lang",
                       "nativeform" = "lang_native")

source_patterns <- c("^id"  = "source_id",
                     "name" = "source",
                     "code" = "source_code",
                     "url"  = "source_url",
                     "description" = "source_desc",
                     "lastupdated" = "last_updated",
                     "dataavailability"     = "data_available",
                     "metadataavailability" = "metadata_available")

topic_patterns <- c("^id"    = "topic_id",
                    "^value" = "topic",
                    "sourcenote|sourceNote|source_note" = "topic_desc")

indicator_patterns <- c("^id"   = "indicator_id",
                        "^name" = "indicator",
                        "sourceOrg" = "source_org",
                        "sourceorganization"  = "source_org",
                        "source_organization" = "source_org",
                        "sourceOrganization"  = "source_org",
                        "sourcenote|sourceNote|source_note" = "indicator_desc")

query_patterns <- c("^id"   = "indicator_id",
                    "^name" = "indicator",
                    "sourceOrg" = "source_org",
                   "sourceorganization"  = "source_org",
                    "source_organization" = "source_org",
                     "sourceOrganization"  = "source_org",
                       "sourcenote|sourceNote|source_note" = "indicator_desc")

data_patterns <-  c("^indicator_value"   = "indicator",
                    "^indicator_id" = "indicator_id",
                    "country_value" = "country",
                    "country_id"  = "iso2c",
                    "lastupdated" = "last_updated",
                    "countryiso3code" = "iso3c")

wb_api_name_patterns <- list(
  global_patterns = global_patterns,
  country         = country_patterns,
  lending_type    = lending_type_patterns,
  income_level    = income_level_patterns,
  region          = region_patterns,
  language        = language_patterns,
  source          = source_patterns,
  topic           = topic_patterns,
  indicator       = indicator_patterns,
  query           = query_patterns,
  data            = data_patterns
)

