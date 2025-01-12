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
