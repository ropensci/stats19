# Format STATS19 casualties

Format STATS19 casualties

## Usage

``` r
format_casualties(x)
```

## Arguments

- x:

  Data frame created with
  [`read_casualties()`](https://docs.ropensci.org/stats19/reference/read_casualties.md)

## Details

This function formats raw STATS19 data

## Examples

``` r
# \donttest{
if(curl::has_internet()) {
dl_stats19(year = 2022, type = "casualty")
x = read_casualties(year = 2022)
casualties = format_casualties(x)
}
#> Files identified: dft-road-casualty-statistics-casualty-2022.csv
#> Data already exists in data_dir, not downloading: dft-road-casualty-statistics-casualty-2022.csv
# }
```
