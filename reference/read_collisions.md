# Read in STATS19 road safety data from .csv files downloaded.

Read in STATS19 road safety data from .csv files downloaded.

## Usage

``` r
read_collisions(
  year = NULL,
  filename = "",
  data_dir = get_data_directory(),
  format = TRUE,
  silent = FALSE
)
```

## Arguments

- year:

  Single year for which data are to be read

- filename:

  Character string of the filename of the .csv to read, if this is
  given, type and years determine whether there is a target to read,
  otherwise disk scan would be needed.

- data_dir:

  Where sets of downloaded data would be found.

- format:

  Switch to return raw read from file, default is `TRUE`.

- silent:

  Boolean. If `FALSE` (default value), display useful progress messages
  on the screen.

## Details

This is a wrapper function to access and load stats 19 data in a
user-friendly way. The function returns a data frame, in which each
record is a reported incident in the STATS19 data.

## Examples

``` r
# \donttest{
if(curl::has_internet()) {
dl_stats19(year = 2024, type = "collision")
ac = read_collisions(year = 2024)
}
#> Files identified: dft-road-casualty-statistics-collision-2024.csv
#> Data saved at /tmp/RtmpXo7tls/dft-road-casualty-statistics-collision-2024.csv
#> Reading in: /tmp/RtmpXo7tls/dft-road-casualty-statistics-collision-2024.csv
#> date and time columns present, creating formatted datetime column
# }
```
