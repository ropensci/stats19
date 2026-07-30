# Locate a file on disk

Locate a file on disk

## Usage

``` r
locate_files(
  data_dir = get_data_directory(),
  type = NULL,
  years = NULL,
  quiet = FALSE
)
```

## Arguments

- data_dir:

  Where sets of downloaded data would be found.

- type:

  One of 'collision', 'casualty', 'Vehicle'; defaults to 'collision'.

- years:

  Single year or vector of years for which data are to be read.

- quiet:

  Print out messages (files found)
