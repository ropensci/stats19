# Download, read and format STATS19 data in one function.

Download, read and format STATS19 data in one function.

## Usage

``` r
get_stats19(
  year = NULL,
  type = "collision",
  data_dir = get_data_directory(),
  file_name = NULL,
  format = TRUE,
  ask = FALSE,
  silent = FALSE,
  output_format = "tibble",
  engine = "readr",
  where = NULL,
  ...
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

- format:

  Switch to return raw read from file, default is `TRUE`.

- ask:

  Should you be asked whether or not to download the files? `TRUE` by
  default.

- silent:

  Boolean. If `FALSE` (default value), display useful progress messages
  on the screen.

- output_format:

  A string that specifies the desired output format. The default value
  is `"tibble"`. Other possible values are `"data.frame"`, `"sf"` and
  `"ppp"`, that, respectively, returns objects of class
  [`data.frame`](https://rdrr.io/r/base/data.frame.html),
  [`sf::sf`](https://r-spatial.github.io/sf/reference/sf.html) and
  `spatstat.geom::ppp`. Any other string is ignored and a tibble output
  is returned. See details and examples.

- engine:

  CSV reader backend. Defaults to `"readr"`. Set to `"duckdb"` to query
  files via DuckDB before loading into R.

- where:

  Optional SQL predicate appended to the `WHERE` clause when
  `engine = "duckdb"`, e.g. `"longitude > -1.9 AND longitude < -1.2"`.
  For OSGR coordinate predicates on `location_easting_osgr` and
  `location_northing_osgr`, values are safely `TRY_CAST` to `DOUBLE` to
  avoid type issues when source CSV columns are loaded as text. Ignored
  when `engine = "readr"`.

- ...:

  Other arguments be passed to
  [`format_sf()`](https://docs.ropensci.org/stats19/reference/format_sf.md)
  or
  [`format_ppp()`](https://docs.ropensci.org/stats19/reference/format_ppp.md)
  functions. Read and run the examples.

## Details

This function gets STATS19 data. Behind the scenes it uses
[`dl_stats19()`](https://docs.ropensci.org/stats19/reference/dl_stats19.md)
and `read_*` functions, returning a `tibble` (default), `data.frame`,
`sf` or `ppp` object, depending on the `output_format` parameter.

By default, stats19 downloads files to a temporary directory. You can
change this behavior to save the files in a permanent directory. This is
done by setting the `STATS19_DOWNLOAD_DIRECTORY` environment variable. A
convenient way to do this is by adding
`STATS19_DOWNLOAD_DIRECTORY=/path/to/a/dir` to your `.Renviron` file,
which can be opened with
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/reference/edit.html).

The function returns data for a specific year (e.g. `year = 2022`)

Note: for years before 2016 the function may return data from more years
than are requested due to the nature of the files hosted at
[data.gov.uk](https://www.data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-accidents-safety-data).

As this function uses `dl_stats19` function, it can download many MB of
data, so ensure you have a sufficient disk space.

If `output_format = "data.frame"` or `output_format = "sf"` or
`output_format = "ppp"` then the output data is transformed into a
data.frame, sf or ppp object using the
[`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) or
[`format_sf()`](https://docs.ropensci.org/stats19/reference/format_sf.md)
or
[`format_ppp()`](https://docs.ropensci.org/stats19/reference/format_ppp.md)
functions, as shown in the examples.

## See also

[`dl_stats19()`](https://docs.ropensci.org/stats19/reference/dl_stats19.md)

[`read_collisions()`](https://docs.ropensci.org/stats19/reference/read_collisions.md)

## Examples

``` r
# \donttest{
if(curl::has_internet()) {
col = get_stats19(year = 2022, type = "collision")
cas = get_stats19(year = 2022, type = "casualty")
veh = get_stats19(year = 2022, type = "vehicle")
class(col)
# data.frame output
x = get_stats19(2022, silent = TRUE, output_format = "data.frame")
class(x)

# # Get 5-years worth of data (commented-out due to large response size):
# col_5 = get_stats19(year = 5, type = "collision")
# cas_5 = get_stats19(year = 5, type = "casualty")
# veh_5 = get_stats19(year = 5, type = "vehicle")


# Run tests only if endpoint is alive:
if(nrow(x) > 0) {

# use duckdb engine
col_duck = get_stats19(year = 2022, type = "collision", engine = "duckdb")

# use duckdb with where clause
col_where = get_stats19(year = 2022, type = "collision", engine = "duckdb",
                       where = "speed_limit = 30")

# sf output
x_sf = get_stats19(2022, silent = TRUE, output_format = "sf")

# sf output with lonlat coordinates
x_sf = get_stats19(2022, silent = TRUE, output_format = "sf", lonlat = TRUE)
sf::st_crs(x_sf)

if (requireNamespace("spatstat.geom", quietly = TRUE)) {
# ppp output
x_ppp = get_stats19(2022, silent = TRUE, output_format = "ppp")

# We can use the window parameter of format_ppp function to filter only the
# events occurred in a specific area. For example we can create a new bbox
# of 5km around the city center of Leeds

leeds_window = spatstat.geom::owin(
xrange = c(425046.1, 435046.1),
yrange = c(428577.2, 438577.2)
)

leeds_ppp = get_stats19(2022, silent = TRUE, output_format = "ppp", window = leeds_window)
spatstat.geom::plot.ppp(leeds_ppp, use.marks = FALSE, clipwin = leeds_window)
}
}
}
#> Files identified: dft-road-casualty-statistics-collision-2022.csv
#> Data already exists in data_dir, not downloading: dft-road-casualty-statistics-collision-2022.csv
#> Reading in: /tmp/RtmpXo7tls/dft-road-casualty-statistics-collision-2022.csv
#> date and time columns present, creating formatted datetime column
#> Files identified: dft-road-casualty-statistics-casualty-2022.csv
#> Data already exists in data_dir, not downloading: dft-road-casualty-statistics-casualty-2022.csv
#> Reading in: /tmp/RtmpXo7tls/dft-road-casualty-statistics-casualty-2022.csv
#> Files identified: dft-road-casualty-statistics-vehicle-2022.csv
#> Data already exists in data_dir, not downloading: dft-road-casualty-statistics-vehicle-2022.csv
#> Reading in: /tmp/RtmpXo7tls/dft-road-casualty-statistics-vehicle-2022.csv
#> date and time columns present, creating formatted datetime column
#> Files identified: dft-road-casualty-statistics-collision-2022.csv
#> Data already exists in data_dir, not downloading: dft-road-casualty-statistics-collision-2022.csv
#> date and time columns present, creating formatted datetime column
#> Files identified: dft-road-casualty-statistics-collision-2022.csv
#> Data already exists in data_dir, not downloading: dft-road-casualty-statistics-collision-2022.csv
#> date and time columns present, creating formatted datetime column
#> date and time columns present, creating formatted datetime column
#> 22 rows removed with no coordinates
#> date and time columns present, creating formatted datetime column
#> 22 rows removed with no coordinates
# }
```
