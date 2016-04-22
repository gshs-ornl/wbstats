## Resubmission

This is a resubmission. In this version I have:

* resolved NOTE on na.omit
* lowered the number of examples to limit their total time

## Test environments
* local win install, R 3.2.0
* win-builder (devel and release)

## R CMD check results
There were no ERRORs or WARNINGs. 

There was 1 NOTE:

* checking data for non-ASCII characters ... NOTE
  Note: found 1317 marked UTF-8 strings

These UTF-8 strings are kept because it is a cached version of
the data from the API that is accessed. Removing these would 
result in an invalid cache.
