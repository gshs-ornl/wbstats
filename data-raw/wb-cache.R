# cached results of World Bank API information ----------------------

library(wbstats)


# deprecated cache ----------
wb_cachelist_dep <- wbcache(lang = "en")
save(wb_cachelist_dep, file = "data/wb_cachelist_dep.RData", compress = "xz")



# new cache ----------
wb_cachelist <- wb_cache(lang = "en")
save(wb_cachelist, file = "data/wb_cachelist.RData", compress = "xz")

