## Resubmission

This is a resubmission. In this version I have:

* fixed figure storage issue
* added new package features
* fixed misc bugs


## Test environments
* local win install, R 3.4.0
* win-builder (devel and release)

## R CMD check results
R CMD check results
0 errors | 0 warnings | 0 notes

R CMD check succeeded

## Comment on example timing

I have reduced the number of examples one each for functions wbcache and wbindicators.
These functions are calling an external API and waiting for the response. This is the source of the timing issues. As these examples 
are part of the core functionality of the package I feel that they are important and have decided to include them although they often
take longer than 5 seconds to return.

