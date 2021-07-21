This new version should stop the error messages on Windows checks.
See here for details of the issue that is due to updates in the `readr` dependency that we were made aware of after submission of v. 1.4.2. to CRAN: https://github.com/ropensci/stats19/issues/205

This second patch should also address other issues raised.


## Test environments
* local R installation, R 4.1.0
* ubuntu 16.04 (on travis-ci), R 4.1.0
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
