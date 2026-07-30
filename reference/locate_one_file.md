# Pin down a file on disk from parameters.

Pin down a file on disk from parameters.

## Usage

``` r
locate_one_file(
  filename = NULL,
  data_dir = get_data_directory(),
  year = NULL,
  type = NULL
)
```

## Arguments

- filename:

  Character string of the filename of the .csv to read.

- data_dir:

  Where sets of downloaded data would be found.

- year:

  Single year for which data are to be read.

- type:

  One of 'collision', 'casualty', 'Vehicle'; defaults to 'collision'.

## Examples

``` r
# \donttest{
locate_one_file()
#> [1] "/tmp/RtmpXo7tls/dft-road-casualty-statistics-casualty-2022.csv"
# }
```
