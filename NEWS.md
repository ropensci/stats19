# stats19 1.2.0

* Enables the download of multiple years https://github.com/ropensci/stats19/issues/99
* Users can now set the default data download directory with STATS19_DOWNLOAD_DIRECTORY=/path/to/data https://github.com/ropensci/stats19/issues/141

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
