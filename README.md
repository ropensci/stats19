
[![The API of a maturing package has been roughed out, but finer details
likely to
change.](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Travis build
status](https://travis-ci.org/ITSLeeds/stats19.svg?branch=master)](https://travis-ci.org/ITSLeeds/stats19)
[![codecov](https://codecov.io/gh/ITSLeeds/stats19/branch/master/graph/badge.svg)](https://codecov.io/gh/ITSLeeds/stats19)
[![Gitter
chat](https://badges.gitter.im/ITSLeeds/stats19.png)](https://gitter.im/stats19/Lobby?source=orgpage)
[![](http://www.r-pkg.org/badges/version/stats19)](http://www.r-pkg.org/pkg/stats19)
[![CRAN RStudio mirror
downloads](http://cranlogs.r-pkg.org/badges/stats19)](http://www.r-pkg.org/pkg/stats19)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# stats19

The goal of **stats19** is to make it easy to work with road crash data.
Specifically it enables access to and processing of the UK’s official
road traffic casualty database, which is called
[STATS19](https://data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data).
The name comes from the form used by the police to record car crashes
and other incidents resulting in casualties on the roads.

A description of the stats19 data and variables they contain can be
found in a
[document](http://data.dft.gov.uk/road-accidents-safety-data/Brief-guide-to%20road-accidents-and-safety-data.doc)
hosted by the UK’s Department for Transport (DfT).

The package builds on previous work including:

  - code in the [bikeR](https://github.com/Robinlovelace/bikeR) repo
    underlying an academic paper on collisions involving cyclists
  - functions in
    [**stplanr**](https://github.com/ropensci/stplanr/blob/master/R/load-stats19.R)
    for downloading Stats19 data
  - updated functions related to the
    [CyIPT](https://github.com/cyipt/stats19) project

## Installation

Install and attach the latest version with:

``` r
devtools::install_github("ITSLeeds/stats19")
```

``` r
library(stats19)
#> Data provided under the conditions of the Open Government License.
#> If you use data from this package, mention the source
#> (Department for Transport), cite the package and link to:
#> www.nationalarchives.gov.uk/doc/open-government-licence/version/3/.
```

<!-- You can install the released version of stats19 from [CRAN](https://CRAN.R-project.org) with: -->

<!-- ``` r -->

<!-- install.packages("stats19") -->

<!-- ``` -->

## Data download

**stats19** enables download of raw stats19 data with `dl_*` functions.
The following code chunk, for example, downloads and unzips a .zip file
containing Stats19 data from 2017:

``` r
dl_stats19(year = 2017, type = "Accidents")
#> File to download: dftRoadSafetyData_Accidents_2017.zip
#> Attempt downloading from:
#>    http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/dftRoadSafetyData_Accidents_2017.zip
#> Data saved at /tmp/Rtmpkpois6/dftRoadSafetyData_Accidents_2017.zip/Acc.csv
```

Currently, these files are downloaded to a default location of “tempdir”
which is a platform independent “safe” location to download the data in.
Once downloaded, they are unzipped under original DfT file names. The
function prints out the location and final file name(s) of unzipped
files(s) as shown above.

Data files from other years can be downloaded in an interactive manner,
providing just the year for example, would result in options presented
to you:

``` r
dl_stats19(year = 2017)
#> File to download: dftRoadSafetyData_Accidents_2017.zip
#> Attempt downloading from:
#>    http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/dftRoadSafetyData_Accidents_2017.zip
#> Data already exists in data_dir, not downloading
#> Data saved at /tmp/Rtmpkpois6/dftRoadSafetyData_Accidents_2017.zip/Acc.csv
```

## Reading-in data

Downloaded data can then be read-in as follows (assuming the data
download went OK):

``` r
d17 = "dftRoadSafetyData_Accidents_2017"
dl_stats19(file_name = paste0(d17, ".zip"))
#> File to download: dftRoadSafetyData_Accidents_2017.zip
#> Attempt downloading from:
#>    http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/dftRoadSafetyData_Accidents_2017.zip
#> Data already exists in data_dir, not downloading
#> Data saved at /tmp/Rtmpkpois6/dftRoadSafetyData_Accidents_2017.zip/Acc.csv
crashes_2017_raw = read_accidents(year = 2017, filename = "Acc.csv")
#> Reading in:
#> /tmp/Rtmpkpois6/dftRoadSafetyData_Accidents_2017/Acc.csv
crashes_2017 = format_accidents(crashes_2017_raw)
```

What just happened? We read-in data on all road crashes recorded by the
police in 2017 across Great Britain. `read_accidents()` imports the
‘raw’ Stats19 data without cleaning messy column names or
re-categorising the outputs. `format_accidents()` does this work,
automating the process of matching column names with variable names and
labels in a [`.xls`
file](http://data.dft.gov.uk/road-accidents-safety-data/Road-Accident-Safety-Data-Guide.xls)
provided by the DfT. This means `crashes_2017` is much more usable than
`crashes_2017_raw`, as shown below, which shows three records and some
key variables in the messy and clean datasets:

``` r
key_patt = "severity|speed|light|human"
key_vars = grep(key_patt, x = names(crashes_2017_raw), ignore.case = TRUE)
random_n = sample(x = nrow(crashes_2017_raw), size = 3)
crashes_2017_raw[random_n, key_vars]
#> # A tibble: 3 x 4
#>   Accident_Severity Speed_limit `Pedestrian_Crossing-Hum… Light_Conditions
#>               <int>       <int>                     <int>            <int>
#> 1                 3          40                         0                4
#> 2                 3          30                         0                4
#> 3                 2          60                         0                1
crashes_2017[random_n, key_vars]
#> # A tibble: 3 x 4
#>   accident_severity speed_limit pedestrian_crossing_hu… light_conditions  
#>   <chr>                   <int> <chr>                   <chr>             
#> 1 Slight                     40 None within 50 metres   Darkness - lights…
#> 2 Slight                     30 None within 50 metres   Darkness - lights…
#> 3 Serious                    60 None within 50 metres   Daylight
```

<!-- More data can be read-in as follows: -->
