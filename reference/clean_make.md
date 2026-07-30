# Clean vehicle make

This function cleans the make of the vehicle.

## Usage

``` r
clean_make(make, extract_make = TRUE)
```

## Arguments

- make:

  A character vector of vehicle makes. Can be raw generic make/model
  strings if extract_make is TRUE.

- extract_make:

  Logical, whether to extract the make from the input string using
  extract_make_stats19 first. Default is TRUE.

## Examples

``` r
clean_make(c("VW", "Mercedez"))
#> [1] "Volkswagen" "Mercedes"  
clean_make(c("FORD FIESTA", "LAND ROVER DISCOVERY"), extract_make = TRUE)
#> [1] "Ford"       "Land Rover"
```
