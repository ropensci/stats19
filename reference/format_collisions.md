# Format STATS19 'collisions' data

Format STATS19 'collisions' data

## Usage

``` r
format_collisions(x)
```

## Arguments

- x:

  Data frame created with
  [`read_collisions()`](https://docs.ropensci.org/stats19/reference/read_collisions.md)

## Details

This is a helper function to format raw STATS19 data

## Examples

``` r
# \donttest{
  if(curl::has_internet()) {
    dl_stats19(year = 2022, type = "collision")
  }
#> Files identified: dft-road-casualty-statistics-collision-2022.csv
#> Data already exists in data_dir, not downloading: dft-road-casualty-statistics-collision-2022.csv
#> NULL
# }
```
