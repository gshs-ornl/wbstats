# cached results of World Bank API information ----------------------

library(wbstats)

wb_cachelist <- wbcache(lang = "en")

save(wb_cachelist, file = "data/wb_cachelist.RData", compress = "xz")



