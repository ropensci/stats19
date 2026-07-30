# Clean vehicle model

This function cleans the model of the vehicle. It extracts the make
using `extract_make_stats19` and removes it from the string, returning
the remaining text as the model in title case.

## Usage

``` r
clean_model(model)
```

## Arguments

- model:

  A character vector of generic make/model strings

## Examples

``` r
clean_model(c("FORD FIESTA", "BMW 3 SERIES"))
#> [1] "Fiesta"   "3 Series"
```
