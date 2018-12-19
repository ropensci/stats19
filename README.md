
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

**stats19** provides functions for downloading and formatting road crash
data. Specifically, it enables access to the UK’s official road traffic
casualty database,
[STATS19](https://data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data)
(the name comes from the form used by the police to record car crashes
and other incidents resulting in casualties on the roads).

The data, in its original form, is provided as a series of .csv files
that are stored in dozens of `.zip` files. Finding, reading-in and
formatting the data for research can be a time consuming process subject
to human error. **stats19** speeds-up these vital data access and
cleaning stages of the research process, enabling reproducibility, by
streamlining the work into 3 stages:

  - **Download**: This stage is taken care of by the `dl_stats19()`
    function. `year`, `type` and `filename` arguments make it easy to
    find the right file for your research question.

  - **Read**: STATS19 data is provided in a particular format that
    benefits from being read-in with pre-specified column types. This is
    taken care of with `read_*()` functions corresponding to the 3 main
    tables in STATS19 data:
    
      - `read_accidents()` reads-in the crash data (which has one row
        per incident)
      - `read_casualties()` reads-in the casualty data (which has one
        row per person injured or killed)
      - `read_vehicles()` reads-in the vehicles table, which contains
        information on the vehicles involved in the crashes (one row per
        vehicle)

  - **Format**: in this stage labels are added to the tables. The raw
    data provided by the DfT contains only integers. Running the
    following commands converts these integer values to the
    corresponding character variables, for each of the three tables:
    
      - `read_accidents()` adds labels to the accidents table. The
        values in the `accident_severity` column, for example, are
        converted from `1`, `2` and `3` into `Slight`, `Serious` or
        `Fatal`.
      - `read_casualties()` formats the casualty data
      - `read_vehicles()`formats the vehicle data

A full description of the stats19 data and variables they contain can be
found in a
[document](http://data.dft.gov.uk/road-accidents-safety-data/Brief-guide-to%20road-accidents-and-safety-data.doc)
hosted by the UK’s Department for Transport (DfT).

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
#> Files identified: dftRoadSafetyData_Accidents_2017.zip
#> Attempt downloading from:
#>    http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/dftRoadSafetyData_Accidents_2017.zip
#> Data saved at /tmp/RtmphiBH2G/dftRoadSafetyData_Accidents_2017/Acc.csv
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
```

    Multiple matches. Which do you want to download?
    
    1: dftRoadSafetyData_Vehicles_2017.zip
    2: dftRoadSafetyData_Casualties_2017.zip
    3: dftRoadSafetyData_Accidents_2017.zip
    
    Selection: 
    Enter an item from the menu, or 0 to exit

## Reading-in and formatting STATS19 data

As mentioned above STATS19 contains 3 main tables:

  - Accidents, the main table which contains information on the crash
    time, location and other variables (`ncol(accidents_sample)` columns
    in total)
  - Casualties, with data on the people hurt or killed in each crash
    (`ncol(casualties_sample)` columns in total)
  - Vehicles, with data on the vehicles involved in or causing each
    crash (`ncol(vehicles_sample)` columns in total)

Code to read-in and format each of these tables is demonstrated below.

### Crash data

After raw data files have been downloaded (as described in the previous
section), they can then be read-in as follows:

``` r
crashes_2017_raw = read_accidents(year = 2017)
#> Reading in:
#> /tmp/RtmphiBH2G/dftRoadSafetyData_Accidents_2017/Acc.csv
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
#>   Accident_Severity Speed_limit `Pedestrian_Crossing-Huma… Light_Conditions
#>               <int>       <int>                      <int>            <int>
#> 1                 3          30                          0                1
#> 2                 2          30                          0                1
#> 3                 3          60                          0                1
crashes_2017[random_n, key_vars]
#> # A tibble: 3 x 4
#>   accident_severity speed_limit pedestrian_crossing_human… light_conditions
#>   <chr>                   <int> <chr>                      <chr>           
#> 1 Slight                     30 None within 50 metres      Daylight        
#> 2 Serious                    30 None within 50 metres      Daylight        
#> 3 Slight                     60 None within 50 metres      Daylight
```

**Note**: The Department for Transport calls this table ‘accidents’ but
a more appropriate term may be more appropriate, according to road
safety advocacy groups such as
[RoadPeace](http://www.roadpeace.org/take-action/crash-not-accident/).
For this reason we are faithful to the name provided in the data’s
official documentation but call the resulting datset `crashes`.

## Casualties data

## Vehicles data

<!-- More data can be read-in as follows: -->

## Further information

The **stats19** package builds on previous work, including:

  - code in the [bikeR](https://github.com/Robinlovelace/bikeR) repo
    underlying an academic paper on collisions involving cyclists
  - functions in
    [**stplanr**](https://github.com/ropensci/stplanr/blob/master/R/load-stats19.R)
    for downloading Stats19 data
  - updated functions related to the
    [CyIPT](https://github.com/cyipt/stats19) project
