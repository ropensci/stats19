# Format STATS19 vehicles data

Format STATS19 vehicles data

## Usage

``` r
format_vehicles(x)
```

## Arguments

- x:

  Data frame created with
  [`read_vehicles()`](https://docs.ropensci.org/stats19/reference/read_vehicles.md)

## Details

This function formats raw STATS19 data

## Examples

``` r
# \donttest{
if(curl::has_internet()) {
dl_stats19(year = 2022, type = "vehicle", ask = FALSE)
x = read_vehicles(year = 2022, format = FALSE)
vehicles = format_vehicles(x)
}
#> Files identified: dft-road-casualty-statistics-vehicle-2022.csv
#> Data already exists in data_dir, not downloading: dft-road-casualty-statistics-vehicle-2022.csv
# }
```
