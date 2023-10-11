# stats19 3.0.0 2023-10

* Major update so the package works with the new csv files

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
