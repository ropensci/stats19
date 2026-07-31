## Resubmission / Release 4.1.0

This is a resubmission addressing the NOTEs raised by the CRAN auto-check service:

* Corrected Roger Beecham's ORCID iD in `DESCRIPTION` (`0000-0001-8563-7251`).
* Updated RoadPeace URL to `https://www.roadpeace.org/working-for-change/` (resolving 404).
* Added `.claude`, `.devcontainer`, `README.html`, `_pkgdown.yml`, and `pkgdown` to `.Rbuildignore` to prevent non-standard/hidden files from entering the release build.

Major features in this release:
* Added support for 2025 STATS19 casualty, vehicle, and collision datasets from the Department for Transport.
* Updated earliest individual dataset year threshold to 2021 (years 1979–2020 served via historical bulk dataset).
* Added package citation details (*Lovelace et al. 2019*) and `citation("stats19")` instructions to package startup message.
* Preserved character class for alphanumeric collision indices to prevent `NA` coercions.
* Ensured valid `POSIXct` `datetime` creation for midnight `00:00` timestamps.
* Added optional `duckdb` engine for fast SQL-filtered querying of large datasets.
* Unified `accident_*` and `collision_*` column names for seamless multi-year joins.

## R CMD check results

0 errors | 0 warnings | 0 notes
