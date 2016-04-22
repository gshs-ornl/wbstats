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

These UTF-8 strings are kept because it is a cached version of the data from the API that is accessed.
Removing these would result in an invalid cache.

## Comment on example timing

I have reduced the number of examples one each for functions wbcache and wbindicators.
These functions are calling an external API and waiting for the response. This is the source of the timing issues. As these examples 
are part of the core functionality of the package I feel that they are important and have decided to include them although they often
take longer than 5 seconds to return.

