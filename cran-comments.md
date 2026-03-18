This submission includes several updates and fixes:

* Added optional `duckdb` engine for faster querying of large datasets.
* Unified `accident_*` and `collision_*` columns for multi-year compatibility.
* Fixed 301 redirect for tidyverse.org URL in documentation and vignettes.
* Moved non-standard top-level files to `inst/` as requested.
* Shortened long lines in `match_tag.Rd` by splitting URLs in the source.
* Synchronized documentation with function arguments to resolve Rd warnings.
* Removed `submit_cran.R`.

## R CMD check results

0 errors | 0 warnings | 2 notes

* Found the following hidden files and directories: .git
* unable to verify current time (future file timestamps)
