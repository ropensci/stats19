# stats19 (development version)

*   **`junction_status()` added**: `junction_detail` code 0 ("Not at junction or within 20 metres") also covers roundabouts, mini-roundabouts and slip roads, so filtering on `junction_detail` alone puts about 113,000 junction collisions (2015 to 2023) in the non-junction group. `junction_status()` gives a clean junction/not junction classification, using `junction_detail_historic` where it is known and falling back to `junction_detail` and `road_type` where it is not (fixes #328).
*   `format_stats19()` no longer merges `junction_detail_historic` into `junction_detail` and drops it: it is kept as its own column so `junction_status()` can use it after formatting too.

# stats19 4.2.0

## Major Features and Improvements
*   **Native Parquet Support**: Added `stats19_to_parquet()` to convert raw STATS19 CSV archives into compressed, typed, columnar Parquet files using DuckDB (#325).
*   **One schema for every engine**: `engine = "duckdb"`, the Parquet cache and `engine = "readr"` now parse CSV columns with the same types and missing values, then share `format_stats19()`, so they return identical data. Parquet caches written before this change are ignored with a warning: rebuild them with `stats19_to_parquet()`.
*   **DuckDB and Parquet Query Engine**:
    *   Added `engine = "parquet"` and `output_format = "duckdb"` to `get_stats19()`, `read_collisions()`, `read_casualties()`, and `read_vehicles()`.
    *   `output_format = "duckdb"` returns a lazy `tbl` connection via `dbplyr`, enabling zero-memory out-of-core filtering and aggregation across millions of records (#325).
*   **Intelligent Parquet Year Coverage Check**: Reading functions inspect Parquet metadata to verify requested years are covered, warning or falling back gracefully to CSV if data is missing (#325).
*   **Severity Adjustments Helper**: Added `summarise_adjusted_severities()` to calculate both raw and DfT-recommended adjusted casualty and collision counts, handling police force transitions to CRASH/COPA seamlessly (#325).
*   **Parquet Directory Management**: Added `STATS19_PARQUET_DIRECTORY` environment variable support alongside `get_parquet_directory()` and `set_parquet_directory()` (#325).

## Minor Changes, Codebase Simplification and Cleanup
*   **DfT schema updated**: `schema_new.R` updated to use the official DfT version (fixes #319).
*   **Documentation Streamlined**:
    *   Added dedicated `vignettes/schema-evolution.Rmd` documenting historical file naming, column changes, and reporting methodology from 1979 to 2025.
    *   Added longitudinal time-series adjustment example to `vignettes/stats19.Rmd`.
    *   Updated `blog.Rmd` as a live reference document integrating recent architectural updates (v4.0–v4.2), DuckDB/Parquet documentation, and links to external articles. Removed redundant `blog-v4.Rmd`.
    *   Pruned `stats19-training.Rmd` to focus on core external resources (such as [Geocomputation with R](https://r.geocompx.org/) and the RAC Foundation workbook), and removed obsolete `stats19-training-setup.Rmd`.
*   **Codebase and Repo Cleanup**:
    *   Consolidated adjustments logic into `R/adjustments.R`.
    *   Vectorized VRM validation in `get_ULEZ()` and `get_MOT()`.
    *   Removed legacy unreferenced datasets (`schema_original.rda`, `file_names_old.rda`).
    *   Removed historical review responses (`responses1.Rmd`, `responses2.Rmd`) and deprecated `azure-pipelines.yml`.

# stats19 4.1.0

*   **Support for 2025 Data**: Full support for the newly published 2025 STATS19 casualty, vehicle, and collision dataset from the Department for Transport (fixes #315).
*   **Documentation and Dataset Updates**: Updated dataset list, documentation, examples, and metadata for 1979-2025 coverage (fixes #315).
*   **Citation Prompt on Attach**: Added package citation details (Lovelace et al. 2019) and `citation("stats19")` instructions to the package startup message.
*   **Bug Fixes & Data Quality Improvements**:
    *   Preserved character class for alphanumeric collision indices, avoiding `NA` coercions (fixes #231).
    *   Eliminated unmatched parser warnings during dataset loading (fixes #257).
    *   Ensured valid POSIXct `datetime` creation for midnight `00:00` timestamps (fixes #236).
    *   Enhanced vehicle make cleaning rules for `Freight Rover` and `Austin Morris` (fixes #296).

# stats19 4.0.0

## Major Refactor and Performance Improvements
*   **Zero-Warning Data Loading**: The `read_stats19()` function now intelligently filters column parsers based on the actual CSV header, eliminating extensive warnings about unmatched parsers (#302).
*   **Modernized `readr` Engine**: The package now defaults to `readr` Edition 2 globally for faster, multi-threaded parsing, while removing legacy platform-specific overrides (#302).
*   **Optional `duckdb` Engine**: Added a new `engine = "duckdb"` option to `get_stats19()`. This allows for extremely fast, database-level filtering before loading data into R, yielding up to a **75x speed-up** when querying the full historical (1.5GB) dataset.
*   **Code Simplification**: Removed ~300 lines of redundant code from the `R/` directory while expanding overall functionality (#302).

## Data Quality and Schema Unification
*   **Unified Longitudinal Schema**: Columns like `accident_*` and `collision_*` are now automatically unified during formatting. This ensures multi-year joins (e.g., 2023 vs 2024) work seamlessly without duplicate columns.
*   **Unified Longitudinal Schema**: Historic columns (e.g., `*_historic`) are now automatically merged into their modern counterparts and dropped, providing a consistent interface across different data years (#302).
*   **Fixed Coordinate Precision**: Corrected a bug where 2024 Latitude/Longitude were parsed as integers, restoring full floating-point precision (#302).
*   **Aggressive Label Standardization**: Global standardization of missing value codes (e.g., `-1`, `Code deprecated`, `Data missing`) to `NA` after formatting (#302).
*   **Smart E-scooter Unification**: Added logic to automatically identify and flag e-scooter riders in casualty data by cross-referencing vehicle information (#302, #299).

## New Features
*   **Intelligent Multi-Year Support**: Requesting year ranges (e.g., `year = 2011:2012`) now automatically identifies the bulk historic files, downloads them once, and filters requested years efficiently (#302).
*   **Cost Estimation**: Added `match_tag()` function to join government TAG (Transport Analysis Guidance) cost estimates (RAS4001) to collision data (#287, #288, #289, #290).
*   **Vehicle Cleaning**: New functions `clean_make()`, `clean_model()`, and `clean_make_model()` for standardizing vehicle data, supported by a mapping of over 2,400 unique raw strings (#294).

## Minor Changes and Fixes
*   Fixed issue where `year = 1979` incorrectly returned all years; it now correctly returns 1979 data only (#282).
*   Updated lookup tables using a new reproducible `schema_new.R` workflow (#291).
*   Included 'Other Junction' in the schema table (#271).
*   Moved the `%||%` operator to `utils.R` for package-wide availability (#302).

# stats19 3.4.0 2025-10

* Major updates to deal with new file names and column names in updated files hosted by the Department for Transport (#268)
* Refactored download logic to no longer use .zip files, which are no longer served by the DfT. The package now downloads .csv files directly.
* Switched from `download.file()` to `curl::curl_download()` for more robust downloads (#258).
* Improved documentation around setting a permanent download directory using the `STATS19_DOWNLOAD_DIRECTORY` environment variable (#211).
* Promoted essential packages for data download and formatting (`dplyr`, `lubridate`, `jsonlite`) from `Suggests` to `Imports`.
* Replaced `reshape2` with `tidyr` for data manipulation (#276).
* Added support for downloading the last 5 years of data using `year = "5 years"` (#261).
* The `get_stats19_adjustments()` function now returns a message explaining that adjustments are included in the main casualty dataset, as the separate adjustments file is no longer provided by the DfT (#266).
* Added a new vignette that reproduces the DfT's pedestrian factsheet (#240, #277).

# stats19 3.3.1 2025-01

* Downloads now work when you are on networks with firewalls (#255)

# stats19 3.3.0 2025-01

* Support for 2023 data (#251)
* Another round of updates to the schema files thanks to updates from the DfT

# stats19 3.2.0 2024-10

* Updates so package functions fail gracefully when input data is not as expected, e.g. due to URL changes (#252)

# stats19 3.1.0 2024-07

* stats19 now relies on the `stats19_variables` object to format the different tables columns (#245) (credit @layik), fixing an issue in which ages were removed from the `casualties` table, fixing (#235)
* If `year` is less than 2018 the package auto-downloads the full dataset (#239)

# stats19 3.0.3 2024-02

* Update documentation to account for the shift in table names, replacing `accidents` with `collisions` and `casualty` with `casualties` (#232)

# stats19 3.0.2 2023-11

* Fix issue with coordinates as characters (#228)

# stats19 3.0.1 2023-10

* Minor update to increase default `timeout` in `get_stats19()` to 10 minutes (#226)

# stats19 3.0.0 2023-10

* Major update so the package works with the new csv files (up to 2022)
* Deprecation of `read_accidents` in favour of `read_collisions` and using consistent `collision` instead of `accidents`.
* Other minor improvements

# stats19 2.0.1 2022-11

* Changes spatstat.core related code (#217)

# stats19 2.0.0 2020-10

* Major changes to the datasets provided by the DfT have led to major changes to the package. See (#212) for details.
* To reduce code complexity the package no longer supports reading in multiple years
* This puts the onus on the user of the package to understand the input data, rather than relying on clever coding to join everything together. Note: you can easily join different years, e.g. with the command `purrr::map_dfr()`.


# stats19 1.5.0 2021-10

* Support new https download links (#208)
* Package tests now pass when wifi is turned off
* URLs have been fixed

# stats19 1.4.3 2021-07-21

* Use 1st edition of `readr` on Windows to prevent errors on reading data (#205)

# stats19 1.4.2 2021-07

* Fix CRAN checks associated with access to online resources (#204)
* [Fix](https://github.com/ropensci/stats19/commit/826a1d0ed3b9fbcf80675b64fd5731ae8b7b0498) issues associated with `get_ULEZ()` and `get_MOT()` functions


# stats19 1.4.1

* New function `get_ULEZ()` to get data on vehicles from a number plate (thanks to Ivo Wengraf)
* Added a test to prevent rare failures in `get_stats19()` when `data_dir` points to the working directory


# stats19 1.4.0

* Add `get_stats19_adjustments()` function
* Use GH Actions for CI (#177)
* Fixed a problem with `get_stats19()` and multiple years that could be linked with the same data file (#168)
* Fix issues with vignettes for CRAN (#190)

# stats19 1.3.0

* Support for 2019 data (#171)

# stats19 1.2.0

* Tests now pass on the development version of R (4.0.0)
* The package now has a hex sticker! See https://github.com/ropensci/stats19/issues/132 for discussion
* The output of formatted crash datasets gains a new column, `datetime` that is a properly formatted date-time (`POSIXct`) object in the correct timezone (`Europe/London`) (#146)
* Enables the download of multiple years as per https://github.com/ropensci/stats19/issues/99, thanks to Layik Hama
* Users can now set the default data download directory with STATS19_DOWNLOAD_DIRECTORY=/path/to/data in your .Renviron file: https://github.com/ropensci/stats19/issues/141
* `get_stats19()` gains a new argument `output_format()` that enables results to be returned as an `sf` object or a `ppp` object for use the the `spatstat` package thanks to work by Andrea Gilardi https://github.com/ropensci/stats19/pull/136

# stats19 1.1.0

* Now enables the download of 2018 data
* Various bug fixes, see https://github.com/ropensci/stats19/issues
* Update website link: https://docs.ropensci.org/stats19/
* New work-in-progress vignette on vehicles data: https://docs.ropensci.org/stats19/articles/stats19-vehicles.html

# stats19 1.0.0

* Major change to `dl_stats19()`: it is now much easier to download STATS19 data. By default `ask = FALSE` in `get_stats19()` and `dl_stats19()`.

# stats19 0.2.1

* Fixed issue with column labels not being there - see [#82](https://github.com/ropensci/stats19/issues/92)

# stats19 0.2.0

* `get_stats19()` gains an `ask` argument (`TRUE` by default, set as `FALSE` to make road crash data access even more automated!)
* The `date` column now is of the correct class after formatting `POSIXct`. See [#86](https://github.com/ropensci/stats19/issues/86)
* Added a `NEWS.md` file to track changes to the package.
