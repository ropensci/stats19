# Clean vehicle make and model

This function returns a combined cleaned make and model string. It uses
`clean_make` and `clean_model` to standardize both parts.

## Usage

``` r
clean_make_model(generic_make_model)
```

## Arguments

- generic_make_model:

  A character vector of generic make/model strings

## Examples

``` r
clean_make_model(c("FORD FIESTA", "BMW 3 SERIES"))
#> [1] "Ford Fiesta"  "BMW 3 Series"
```
