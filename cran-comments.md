This patch is designed to prevent warnings on CRAN as documented here https://cran.r-project.org/web/checks/check_results_stats19.html .
I'm not sure why the tests were only failing on one system but believe this should fix the issue.


## Test environments
* local R installation, R 4.1.0
* ubuntu 16.04 (on travis-ci), R 4.1.0
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
