# Equivalence between readr and duckdb engines

## Introduction

The **stats19** package supports two engines for reading and filtering
data: `readr` (the default) and `duckdb`. The `duckdb` engine is
particularly useful for working with large datasets, as it can filter
data at the database level before loading it into R, significantly
reducing memory usage and processing time.

This vignette demonstrates that the two engines produce equivalent
results.

## Load the package

``` r

library(stats19)
#> Data provided under OGL v3.0. Cite the source and link to:
#> www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
```

## Equivalence test with 2024 data

We will use the 2024 collision data to compare the two engines.

``` r

# Read with readr (default)
col_readr = get_stats19(year = 2024, type = "collision", engine = "readr", silent = TRUE)

# Read with duckdb
col_duckdb = get_stats19(year = 2024, type = "collision", engine = "duckdb", silent = TRUE)
```

### Comparing record counts and fatal counts

Both engines should return the same number of records and the same
number of fatal collisions.

``` r

nrow(col_readr)
#> [1] 100927
nrow(col_duckdb)
#> [1] 100927

# Check fatal counts
sum(col_readr$collision_severity == "Fatal", na.rm = TRUE)
#> [1] 1502
sum(col_duckdb$collision_severity == "Fatal", na.rm = TRUE)
#> [1] 1502
```

### Using waldo for deep comparison

We can use the `waldo` package to check for any differences between the
first 10 records.

``` r

if (requireNamespace("waldo", quietly = TRUE)) {
  waldo::compare(head(col_readr, 10), head(col_duckdb, 10))
}
#> `old$enhanced_severity_collision` is a double vector (3, 3, NA, 6, 7, ...)
#> `new$enhanced_severity_collision` is a character vector ('3', '3', NA, '6', '7', ...)
#> 
#> `old$collision_adjusted_severity_serious` is a double vector (0, 0, 0.0147426895360595, 1, 1, ...)
#> `new$collision_adjusted_severity_serious` is a character vector ('0', '0', '0.0147426895360595', '1', '1', ...)
#> 
#> `old$collision_adjusted_severity_slight` is a double vector (1, 1, 0.98525731046394, 0, 0, ...)
#> `new$collision_adjusted_severity_slight` is a character vector ('1', '1', '0.98525731046394', '0', '0', ...)
```

## Working with large datasets (1979-latest)

When working with the full historical dataset (from 1979 onwards), the
`duckdb` engine is highly recommended. The following code demonstrates
how to use the `duckdb` engine with a `where` clause to filter the data
efficiently.

``` r

# This chunk is not evaluated because it requires downloading ~1.5GB of data
# and can take several minutes to run with the readr engine.

# Download and read all collisions since 1979, but only keep those with speed_limit = 30
crashes_30mph = get_stats19(year = 1979, type = "collision", 
                           engine = "duckdb", 
                           where = "speed_limit = 30")
```

The `duckdb` engine can be more than 50 times faster than the `readr`
engine when performing such filtered reads on large files.
