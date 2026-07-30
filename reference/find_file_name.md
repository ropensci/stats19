# Find file names within stats19::file_names.

Find file names within stats19::file_names.

## Usage

``` r
find_file_name(years = NULL, type = NULL)
```

## Arguments

- years:

  Year for which data are to be found

- type:

  One of 'collisions', 'casualty' or 'vehicles' ignores case.

## Examples

``` r
find_file_name(2016)
#> [1] "dft-road-casualty-statistics-casualty-1979-latest-published-year.csv" 
#> [2] "dft-road-casualty-statistics-vehicle-1979-latest-published-year.csv"  
#> [3] "dft-road-casualty-statistics-collision-1979-latest-published-year.csv"
```
