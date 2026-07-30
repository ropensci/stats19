# Convert STATS19 data into ppp (spatstat) format.

This function is a wrapper around the `spatstat.geom::ppp()` function
and it is used to transform STATS19 data into a ppp format.

## Usage

``` r
format_ppp(data, window = NULL, ...)
```

## Arguments

- data:

  A STATS19 dataframe to be converted into ppp format.

- window:

  A windows of observation, an object of class `owin()`. If
  `window = NULL` (i.e. the default) then the function creates an
  approximate bounding box covering the whole UK. It can also be used to
  filter only the events occurring in a specific region of UK (see the
  examples of
  [`get_stats19`](https://docs.ropensci.org/stats19/reference/get_stats19.md)).

- ...:

  Additional parameters that should be passed to `spatstat.geom::ppp()`
  function. Read the help page of that function for a detailed
  description of the available parameters.

## Value

A ppp object.

## See also

[`format_sf`](https://docs.ropensci.org/stats19/reference/format_sf.md)
for an analogous function used to convert data into sf format and
`spatstat.geom::ppp()` for the original function.

## Examples

``` r
if (requireNamespace("spatstat.geom", quietly = TRUE)) {
  x_ppp = format_ppp(accidents_sample)
  x_ppp
}
```
