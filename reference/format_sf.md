# Format convert STATS19 data into spatial (sf) object

Format convert STATS19 data into spatial (sf) object

## Usage

``` r
format_sf(x, lonlat = FALSE)
```

## Arguments

- x:

  Data frame created with
  [`read_collisions()`](https://docs.ropensci.org/stats19/reference/read_collisions.md)

- lonlat:

  Should the results be returned in longitude/latitude? By default
  `FALSE`, meaning the British National Grid (EPSG code: 27700) is used.

## Examples

``` r
x_sf = format_sf(accidents_sample)
#> 0 rows removed with no coordinates
sf:::plot.sf(x_sf)
#> Warning: plotting the first 10 out of 35 attributes; use max.plot = 35 to plot all
#> Warning: no non-missing arguments to min; returning Inf
#> Warning: no non-missing arguments to max; returning -Inf
#> Warning: no non-missing arguments to min; returning Inf
#> Warning: no non-missing arguments to max; returning -Inf
```
