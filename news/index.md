# Changelog

## stats19 4.0.0 (development version)

CRAN release: 2026-03-18

### Major Refactor and Performance Improvements

- **Zero-Warning Data Loading**: The `read_stats19()` function now
  intelligently filters column parsers based on the actual CSV header,
  eliminating extensive warnings about unmatched parsers
  ([\#302](https://github.com/ropensci/stats19/issues/302)).
- **Modernized `readr` Engine**: The package now defaults to `readr`
  Edition 2 globally for faster, multi-threaded parsing, while removing
  legacy platform-specific overrides
  ([\#302](https://github.com/ropensci/stats19/issues/302)).
- **Optional `duckdb` Engine**: Added a new `engine = "duckdb"` option
  to
  [`get_stats19()`](https://docs.ropensci.org/stats19/reference/get_stats19.md).
  This allows for extremely fast, database-level filtering before
  loading data into R, yielding up to a **75x speed-up** when querying
  the full historical (1.5GB) dataset.
- **Code Simplification**: Removed ~300 lines of redundant code from the
  `R/` directory while expanding overall functionality
  ([\#302](https://github.com/ropensci/stats19/issues/302)).

### Data Quality and Schema Unification

- **Unified Longitudinal Schema**: Columns like `accident_*` and
  `collision_*` are now automatically unified during formatting. This
  ensures multi-year joins (e.g., 2023 vs 2024) work seamlessly without
  duplicate columns.
- **Unified Longitudinal Schema**: Historic columns (e.g., `*_historic`)
  are now automatically merged into their modern counterparts and
  dropped, providing a consistent interface across different data years
  ([\#302](https://github.com/ropensci/stats19/issues/302)).
- **Fixed Coordinate Precision**: Corrected a bug where 2024
  Latitude/Longitude were parsed as integers, restoring full
  floating-point precision
  ([\#302](https://github.com/ropensci/stats19/issues/302)).
- **Aggressive Label Standardization**: Global standardization of
  missing value codes (e.g., `-1`, `Code deprecated`, `Data missing`) to
  `NA` after formatting
  ([\#302](https://github.com/ropensci/stats19/issues/302)).
- **Smart E-scooter Unification**: Added logic to automatically identify
  and flag e-scooter riders in casualty data by cross-referencing
  vehicle information
  ([\#302](https://github.com/ropensci/stats19/issues/302),
  [\#299](https://github.com/ropensci/stats19/issues/299)).

### New Features

- **Intelligent Multi-Year Support**: Requesting year ranges (e.g.,
  `year = 2011:2012`) now automatically identifies the bulk historic
  files, downloads them once, and filters requested years efficiently
  ([\#302](https://github.com/ropensci/stats19/issues/302)).
- **Cost Estimation**: Added
  [`match_tag()`](https://docs.ropensci.org/stats19/reference/match_tag.md)
  function to join government TAG (Transport Analysis Guidance) cost
  estimates (RAS4001) to collision data
  ([\#287](https://github.com/ropensci/stats19/issues/287),
  [\#288](https://github.com/ropensci/stats19/issues/288),
  [\#289](https://github.com/ropensci/stats19/issues/289),
  [\#290](https://github.com/ropensci/stats19/issues/290)).
- **Vehicle Cleaning**: New functions
  [`clean_make()`](https://docs.ropensci.org/stats19/reference/clean_make.md),
  [`clean_model()`](https://docs.ropensci.org/stats19/reference/clean_model.md),
  and
  [`clean_make_model()`](https://docs.ropensci.org/stats19/reference/clean_make_model.md)
  for standardizing vehicle data, supported by a mapping of over 2,400
  unique raw strings
  ([\#294](https://github.com/ropensci/stats19/issues/294)).

### Minor Changes and Fixes

- Fixed issue where `year = 1979` incorrectly returned all years; it now
  correctly returns 1979 data only
  ([\#282](https://github.com/ropensci/stats19/issues/282)).
- Updated lookup tables using a new reproducible `schema_new.R` workflow
  ([\#291](https://github.com/ropensci/stats19/issues/291)).
- Included ‘Other Junction’ in the schema table
  ([\#271](https://github.com/ropensci/stats19/issues/271)).
- Moved the `%||%` operator to `utils.R` for package-wide availability
  ([\#302](https://github.com/ropensci/stats19/issues/302)).

## stats19 3.4.0 2025-10

CRAN release: 2025-10-09

- Major updates to deal with new file names and column names in updated
  files hosted by the Department for Transport
  ([\#268](https://github.com/ropensci/stats19/issues/268))
- Refactored download logic to no longer use .zip files, which are no
  longer served by the DfT. The package now downloads .csv files
  directly.
- Switched from
  [`download.file()`](https://rdrr.io/r/utils/download.file.html) to
  [`curl::curl_download()`](https://jeroen.r-universe.dev/curl/reference/curl_download.html)
  for more robust downloads
  ([\#258](https://github.com/ropensci/stats19/issues/258)).
- Improved documentation around setting a permanent download directory
  using the `STATS19_DOWNLOAD_DIRECTORY` environment variable
  ([\#211](https://github.com/ropensci/stats19/issues/211)).
- Promoted essential packages for data download and formatting (`dplyr`,
  `lubridate`, `jsonlite`) from `Suggests` to `Imports`.
- Replaced `reshape2` with `tidyr` for data manipulation
  ([\#276](https://github.com/ropensci/stats19/issues/276)).
- Added support for downloading the last 5 years of data using
  `year = "5 years"`
  ([\#261](https://github.com/ropensci/stats19/issues/261)).
- The
  [`get_stats19_adjustments()`](https://docs.ropensci.org/stats19/reference/get_stats19_adjustments.md)
  function now returns a message explaining that adjustments are
  included in the main casualty dataset, as the separate adjustments
  file is no longer provided by the DfT
  ([\#266](https://github.com/ropensci/stats19/issues/266)).
- Added a new vignette that reproduces the DfT’s pedestrian factsheet
  ([\#240](https://github.com/ropensci/stats19/issues/240),
  [\#277](https://github.com/ropensci/stats19/issues/277)).

## stats19 3.3.1 2025-01

CRAN release: 2025-01-15

- Downloads now work when you are on networks with firewalls
  ([\#255](https://github.com/ropensci/stats19/issues/255))

## stats19 3.3.0 2025-01

CRAN release: 2025-01-12

- Support for 2023 data
  ([\#251](https://github.com/ropensci/stats19/issues/251))
- Another round of updates to the schema files thanks to updates from
  the DfT

## stats19 3.2.0 2024-10

CRAN release: 2024-10-24

- Updates so package functions fail gracefully when input data is not as
  expected, e.g. due to URL changes
  ([\#252](https://github.com/ropensci/stats19/issues/252))

## stats19 3.1.0 2024-07

CRAN release: 2024-08-01

- stats19 now relies on the `stats19_variables` object to format the
  different tables columns
  ([\#245](https://github.com/ropensci/stats19/issues/245)) (credit
  [@layik](https://github.com/layik)), fixing an issue in which ages
  were removed from the `casualties` table, fixing
  ([\#235](https://github.com/ropensci/stats19/issues/235))
- If `year` is less than 2018 the package auto-downloads the full
  dataset ([\#239](https://github.com/ropensci/stats19/issues/239))

## stats19 3.0.3 2024-02

CRAN release: 2024-02-08

- Update documentation to account for the shift in table names,
  replacing `accidents` with `collisions` and `casualty` with
  `casualties` ([\#232](https://github.com/ropensci/stats19/issues/232))

## stats19 3.0.2 2023-11

CRAN release: 2023-11-04

- Fix issue with coordinates as characters
  ([\#228](https://github.com/ropensci/stats19/issues/228))

## stats19 3.0.1 2023-10

- Minor update to increase default `timeout` in
  [`get_stats19()`](https://docs.ropensci.org/stats19/reference/get_stats19.md)
  to 10 minutes
  ([\#226](https://github.com/ropensci/stats19/issues/226))

## stats19 3.0.0 2023-10

CRAN release: 2023-10-12

- Major update so the package works with the new csv files (up to 2022)
- Deprecation of `read_accidents` in favour of `read_collisions` and
  using consistent `collision` instead of `accidents`.
- Other minor improvements

## stats19 2.0.1 2022-11

CRAN release: 2022-11-17

- Changes spatstat.core related code
  ([\#217](https://github.com/ropensci/stats19/issues/217))

## stats19 2.0.0 2020-10

CRAN release: 2021-10-29

- Major changes to the datasets provided by the DfT have led to major
  changes to the package. See
  ([\#212](https://github.com/ropensci/stats19/issues/212)) for details.
- To reduce code complexity the package no longer supports reading in
  multiple years
- This puts the onus on the user of the package to understand the input
  data, rather than relying on clever coding to join everything
  together. Note: you can easily join different years, e.g. with the
  command
  [`purrr::map_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html).

## stats19 1.5.0 2021-10

- Support new https download links
  ([\#208](https://github.com/ropensci/stats19/issues/208))
- Package tests now pass when wifi is turned off
- URLs have been fixed

## stats19 1.4.3 2021-07-21

CRAN release: 2021-07-21

- Use 1st edition of `readr` on Windows to prevent errors on reading
  data ([\#205](https://github.com/ropensci/stats19/issues/205))

## stats19 1.4.2 2021-07

- Fix CRAN checks associated with access to online resources
  ([\#204](https://github.com/ropensci/stats19/issues/204))
- [Fix](https://github.com/ropensci/stats19/commit/826a1d0ed3b9fbcf80675b64fd5731ae8b7b0498)
  issues associated with
  [`get_ULEZ()`](https://docs.ropensci.org/stats19/reference/get_ULEZ.md)
  and
  [`get_MOT()`](https://docs.ropensci.org/stats19/reference/get_MOT.md)
  functions

## stats19 1.4.1

CRAN release: 2021-03-28

- New function
  [`get_ULEZ()`](https://docs.ropensci.org/stats19/reference/get_ULEZ.md)
  to get data on vehicles from a number plate (thanks to Ivo Wengraf)
- Added a test to prevent rare failures in
  [`get_stats19()`](https://docs.ropensci.org/stats19/reference/get_stats19.md)
  when `data_dir` points to the working directory

## stats19 1.4.0

CRAN release: 2021-03-15

- Add
  [`get_stats19_adjustments()`](https://docs.ropensci.org/stats19/reference/get_stats19_adjustments.md)
  function
- Use GH Actions for CI
  ([\#177](https://github.com/ropensci/stats19/issues/177))
- Fixed a problem with
  [`get_stats19()`](https://docs.ropensci.org/stats19/reference/get_stats19.md)
  and multiple years that could be linked with the same data file
  ([\#168](https://github.com/ropensci/stats19/issues/168))
- Fix issues with vignettes for CRAN
  ([\#190](https://github.com/ropensci/stats19/issues/190))

## stats19 1.3.0

CRAN release: 2020-10-01

- Support for 2019 data
  ([\#171](https://github.com/ropensci/stats19/issues/171))

## stats19 1.2.0

CRAN release: 2020-03-03

- Tests now pass on the development version of R (4.0.0)
- The package now has a hex sticker! See
  <https://github.com/ropensci/stats19/issues/132> for discussion
- The output of formatted crash datasets gains a new column, `datetime`
  that is a properly formatted date-time (`POSIXct`) object in the
  correct timezone (`Europe/London`)
  ([\#146](https://github.com/ropensci/stats19/issues/146))
- Enables the download of multiple years as per
  <https://github.com/ropensci/stats19/issues/99>, thanks to Layik Hama
- Users can now set the default data download directory with
  STATS19_DOWNLOAD_DIRECTORY=/path/to/data in your .Renviron file:
  <https://github.com/ropensci/stats19/issues/141>
- [`get_stats19()`](https://docs.ropensci.org/stats19/reference/get_stats19.md)
  gains a new argument `output_format()` that enables results to be
  returned as an `sf` object or a `ppp` object for use the the
  `spatstat` package thanks to work by Andrea Gilardi
  <https://github.com/ropensci/stats19/pull/136>

## stats19 1.1.0

CRAN release: 2019-10-15

- Now enables the download of 2018 data
- Various bug fixes, see <https://github.com/ropensci/stats19/issues>
- Update website link: <https://docs.ropensci.org/stats19/>
- New work-in-progress vignette on vehicles data:
  <https://docs.ropensci.org/stats19/articles/stats19-vehicles.html>

## stats19 1.0.0

CRAN release: 2019-07-28

- Major change to
  [`dl_stats19()`](https://docs.ropensci.org/stats19/reference/dl_stats19.md):
  it is now much easier to download STATS19 data. By default
  `ask = FALSE` in
  [`get_stats19()`](https://docs.ropensci.org/stats19/reference/get_stats19.md)
  and
  [`dl_stats19()`](https://docs.ropensci.org/stats19/reference/dl_stats19.md).

## stats19 0.2.1

CRAN release: 2019-04-03

- Fixed issue with column labels not being there - see
  [\#82](https://github.com/ropensci/stats19/issues/92)

## stats19 0.2.0

CRAN release: 2019-02-15

- [`get_stats19()`](https://docs.ropensci.org/stats19/reference/get_stats19.md)
  gains an `ask` argument (`TRUE` by default, set as `FALSE` to make
  road crash data access even more automated!)
- The `date` column now is of the correct class after formatting
  `POSIXct`. See [\#86](https://github.com/ropensci/stats19/issues/86)
- Added a `NEWS.md` file to track changes to the package.
