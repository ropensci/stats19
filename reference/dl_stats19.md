# Download STATS19 data for a year

Download STATS19 data for a year

## Usage

``` r
dl_stats19(
  year = NULL,
  type = NULL,
  data_dir = get_data_directory(),
  file_name = NULL,
  ask = FALSE,
  silent = FALSE,
  timeout = 600
)
```

## Arguments

- year:

  Single year for which data are to be read

- type:

  One of 'collision', 'casualty', 'Vehicle'; defaults to 'collision'.

- data_dir:

  Where sets of downloaded data would be found.

- file_name:

  Character string of a specific STATS19 CSV filename to download/read.
  If `NULL`, filenames are inferred from `year` and `type`.

- ask:

  Should you be asked whether or not to download the files? `TRUE` by
  default.

- silent:

  Boolean. If `FALSE` (default value), display useful progress messages
  on the screen.

- timeout:

  Timeout in seconds for the download if current option is less than
  this value. Defaults to 600 (10 minutes).

## Examples

``` r
# \donttest{
if (curl::has_internet()) {
  # type by default is collisions table
  dl_stats19(year = 2022)
}
#> Files identified: dft-road-casualty-statistics-casualty-2022.csv, dft-road-casualty-statistics-vehicle-2022.csv, dft-road-casualty-statistics-collision-2022.csv
#> Data saved at /tmp/RtmpXo7tls/dft-road-casualty-statistics-casualty-2022.csv
#> Data saved at /tmp/RtmpXo7tls/dft-road-casualty-statistics-vehicle-2022.csv
#> Data saved at /tmp/RtmpXo7tls/dft-road-casualty-statistics-collision-2022.csv
#> NULL
# }
```
