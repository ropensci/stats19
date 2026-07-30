# Extract vehicle make from generic make/model string

This function extracts the make from a generic make/model string,
handling multi-word makes.

## Usage

``` r
extract_make_stats19(generic_make_model)
```

## Arguments

- generic_make_model:

  A character vector of generic make/model strings

## Examples

``` r
extract_make_stats19(c("FORD FIESTA", "LAND ROVER DISCOVERY"))
#> [1] "FORD"       "LAND ROVER"
```
