## Resubmission / Release 4.1.0

This release includes major data updates, bug fixes, and performance improvements:

* Added support for the newly published 2025 STATS19 casualty, vehicle, and collision datasets from the Department for Transport.
* Updated earliest individual dataset year threshold to 2021 (years 1979–2020 served via historical bulk dataset).
* Added package citation details (*Lovelace et al. 2019*) and `citation("stats19")` instructions to package startup message.
* Preserved character class for alphanumeric collision indices to prevent `NA` coercions.
* Ensured valid `POSIXct` `datetime` creation for midnight `00:00` timestamps.
* Added optional `duckdb` engine for fast SQL-filtered querying of large datasets.
* Unified `accident_*` and `collision_*` column names for seamless multi-year joins.

## R CMD check results

0 errors | 0 warnings | 1 note

* Found the following hidden files and directories: `.devcontainer` (development container config).
