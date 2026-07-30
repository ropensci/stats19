# Read in stats19 road safety data from .csv files downloaded.

Read in stats19 road safety data from .csv files downloaded.

## Usage

``` r
read_vehicles(
  year = NULL,
  filename = "",
  data_dir = get_data_directory(),
  format = TRUE
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
