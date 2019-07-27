# stats19 1.0.0

* Major change to `dl_stats19()`: it is now much easier to download STATS19 data. By default `ask = FALSE` in `get_stats19()` and `dl_stats19()`.

# stats19 0.2.1

* Fixed issue with column labels not being there - see [#82](https://github.com/ropensci/stats19/issues/92)

# stats19 0.2.0

* `get_stats19()` gains an `ask` argument (`TRUE` by default, set as `FALSE` to make road crash data access even more automated!)
* The `date` column now is of the correct class after formatting `POSIXct`. See [#86](https://github.com/ropensci/stats19/issues/86)
* Added a `NEWS.md` file to track changes to the package.
