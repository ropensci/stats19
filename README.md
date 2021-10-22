
<!-- badges: start -->
<!-- [![Travis build status](https://travis-ci.org/ropensci/stats19.svg?branch=master)](https://travis-ci.org/ropensci/stats19) -->

[![](http://www.r-pkg.org/badges/version/stats19)](https://www.r-pkg.org/pkg/stats19)
[![R-CMD-check](https://github.com/ropensci/stats19/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/stats19/actions)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/grand-total/stats19)](https://www.r-pkg.org/pkg/stats19)
[![Life
cycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![](https://badges.ropensci.org/266_status.svg)](https://github.com/ropensci/software-review/issues/266)
[![DOI](https://joss.theoj.org/papers/10.21105/joss.01181/status.svg)](https://doi.org/10.21105/joss.01181)
![codecov](https://codecov.io/gh/ropensci/stats19/branch/master/graph/badge.svg)
<!-- badges: end -->

<!-- [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2540781.svg)](https://doi.org/10.5281/zenodo.2540781) -->
<!-- [![Gitter chat](https://badges.gitter.im/ITSLeeds/stats19.png)](https://gitter.im/stats19/Lobby?source=orgpage) -->
<!-- README.md is generated from README.Rmd. Please edit that file -->

# stats19 <a href='https://docs.ropensci.org/stats19/'><img src='https://raw.githubusercontent.com/ropensci/stats19/master/man/figures/logo.png' align="right" height=215/></a>

**stats19** provides functions for downloading and formatting road crash
data. Specifically, it enables access to the UK’s official road traffic
casualty database,
[STATS19](https://data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data).
(The name comes from the form used by the police to record car crashes
and other incidents resulting in casualties on the roads.)

A full overview of STATS19 variables be found in a
[document](https://data.dft.gov.uk/road-accidents-safety-data/Brief-guide-to%20road-accidents-and-safety-data.doc)
provided by the UK’s Department for Transport (DfT).

The raw data is provided as a series of `.csv` files that contain
integers and which are stored in dozens of `.zip` files. Finding,
reading-in and formatting the data for research can be a time consuming
process subject to human error. **stats19** speeds up these vital but
boring and error-prone stages of the research process with a single
function: `get_stats19()`. By allowing public access to properly
labelled road crash data, **stats19** aims to make road safety research
more reproducible and accessible.

For transparency and modularity, each stage can be undertaken
separately, as documented in the [stats19
vignette](https://itsleeds.github.io/stats19/articles/stats19.html).

## Installation

Install and load the latest version with:

``` r
remotes::install_github("ropensci/stats19")
```

``` r
library(stats19)
#> Data provided under OGL v3.0. Cite the source and link to:
#> www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
```

You can install the released version of stats19 from
[CRAN](https://cran.r-project.org/package=stats19) with:

``` r
install.packages("stats19")
```

## get_stats19()

`get_stats19()` requires `year` and `type` parameters, mirroring the
provision of STATS19 data files, which are categorised by year (from
1979 onward) and type (with separate tables for crashes, casualties and
vehicles, as outlined below). The following command, for example, gets
crash data from 2017 (**note**: we follow the “crash not accident”
campaign of
[RoadPeace](https://www.roadpeace.org/take-action/crash-not-accident/)
in naming crashes, although the DfT refers to the relevant tables as
‘accidents’ data):

``` r
crashes = get_stats19(year = 2017, type = "accident")
#> accident
#> Files identified: dft-road-casualty-statistics-accident-2017.csv
#>    https://data.dft.gov.uk/road-accidents-safety-data/dft-road-casualty-statistics-accident-2017.csv
#> Data already exists in data_dir, not downloading
#> Data saved at ~/stats19-data/dft-road-casualty-statistics-accident-2017.csv
#> Called from: check_input_file(filename = filename, type = "accident", data_dir = data_dir, 
#>     year = year)
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#151: if (!is.null(year)) {
#>     year = check_year(year)
#> }
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#152: year = check_year(year)
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#154: path = locate_one_file(type = type, filename = filename, data_dir = data_dir, 
#>     year = year)
#> accident
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#160: if (identical(path, "More than one csv file found.")) stop("Multiple files with the same name found.", 
#>     call. = FALSE)
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#163: if (is.null(path) || length(path) == 0 || !endsWith(path, ".csv") || 
#>     !file.exists(path)) {
#>     message(path)
#>     stop("Change data_dir, filename, year or run dl_stats19() first.", 
#>         call. = FALSE)
#> }
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#170: return(path)
#> Reading in:
#> ~/stats19-data/dft-road-casualty-statistics-accident-2017.csv
#> Warning: One or more parsing issues, see `problems()` for details
#> date and time columns present, creating formatted datetime column
```

What just happened? For the `year` 2017 we read-in crash-level
(`type = "accident"`) data on all road crashes recorded by the police
across Great Britain. The dataset contains 37 columns (variables) for
129,982 crashes. We were not asked to download the file (by default you
are asked to confirm the file that will be downloaded). The contents of
this dataset, and other datasets provided by **stats19**, are outlined
below and described in more detail in the [stats19
vignette](https://itsleeds.github.io/stats19/articles/stats19.html).

We will see below how the function also works to get the corresponding
casualty and vehicle datasets for 2017. The package also allows STATS19
files to be downloaded and read-in separately, allowing more control
over what you download, and subsequently read-in, with
`read_accidents()`, `read_casualties()` and `read_vehicles()`, as
described in the vignette.

## Data download

Data files can be downloaded without reading them in using the function
`dl_stats19()`. If there are multiple matches, you will be asked to
choose from a range of options. Providing just the year, for example,
will result in the following options:

``` r
dl_stats19(year = 2017)
```

    Multiple matches. Which do you want to download?

    1: dftRoadSafetyData_vehicles.zip
    2: dftRoadSafetyData_casualties.zip
    3: dftRoadSafetyData_Accidents_2017.zip

    Selection: 
    Enter an item from the menu, or 0 to exit

## Using the data

STATS19 data consists of 3 main tables:

-   Accidents, the main table which contains information on the crash
    time, location and other variables (32 columns in total)
-   Casualties, containing data on people hurt or killed in each crash
    (16 columns in total)
-   Vehicles, containing data on vehicles involved in or causing each
    crash (23 columns in total)

The contents of each is outlined below.

### Crash data

Crash data was downloaded and read-in using the function
`get_stats19()`, as described above.

``` r
nrow(crashes)
#> [1] 129982
ncol(crashes)
#> [1] 37
```

Some of the key variables in this dataset include:

``` r
key_column_names = grepl(pattern = "severity|speed|pedestrian|light_conditions", x = names(crashes))
crashes[key_column_names]
#> # A tibble: 129,982 × 5
#>    accident_severity speed_limit pedestrian_crossing… pedestrian_crossing_physi…
#>    <chr>                   <int> <chr>                <chr>                     
#>  1 Fatal                      30 None within 50 metr… No physical crossing faci…
#>  2 Slight                     30 None within 50 metr… No physical crossing faci…
#>  3 Slight                     30 None within 50 metr… No physical crossing faci…
#>  4 Slight                     30 None within 50 metr… Pelican, puffin, toucan o…
#>  5 Serious                    20 None within 50 metr… Pedestrian phase at traff…
#>  6 Slight                     30 None within 50 metr… No physical crossing faci…
#>  7 Slight                     40 None within 50 metr… Pelican, puffin, toucan o…
#>  8 Slight                     30 Control by other au… Pedestrian phase at traff…
#>  9 Serious                    50 None within 50 metr… Pelican, puffin, toucan o…
#> 10 Serious                    30 None within 50 metr… No physical crossing faci…
#> # … with 129,972 more rows, and 1 more variable: light_conditions <chr>
```

For the full list of columns, run `names(crashes)` or see the
[vignette](https://github.com/ropensci/stats19/blob/master/vignettes/stats19.Rmd).

<!-- This means `crashes` is much more usable than `crashes_raw`, as shown below, which shows three records and some key variables in the messy and clean datasets: -->

### Casualties data

As with `crashes`, casualty data for 2017 can be downloaded, read-in and
formatted as follows:

``` r
casualties = get_stats19(year = 2017, type = "casualty", ask = FALSE)
#> casualty
#> Files identified: dft-road-casualty-statistics-casualty-2017.csv
#>    https://data.dft.gov.uk/road-accidents-safety-data/dft-road-casualty-statistics-casualty-2017.csv
#> Data already exists in data_dir, not downloading
#> Data saved at ~/stats19-data/dft-road-casualty-statistics-casualty-2017.csv
#> Called from: check_input_file(filename = filename, type = "accident", data_dir = data_dir, 
#>     year = year)
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#151: if (!is.null(year)) {
#>     year = check_year(year)
#> }
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#152: year = check_year(year)
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#154: path = locate_one_file(type = type, filename = filename, data_dir = data_dir, 
#>     year = year)
#> accident
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#160: if (identical(path, "More than one csv file found.")) stop("Multiple files with the same name found.", 
#>     call. = FALSE)
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#163: if (is.null(path) || length(path) == 0 || !endsWith(path, ".csv") || 
#>     !file.exists(path)) {
#>     message(path)
#>     stop("Change data_dir, filename, year or run dl_stats19() first.", 
#>         call. = FALSE)
#> }
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#170: return(path)
#> Reading in:
#> ~/stats19-data/dft-road-casualty-statistics-accident-2017.csv
#> Warning: One or more parsing issues, see `problems()` for details
#> date and time columns present, creating formatted datetime column
nrow(casualties)
#> [1] 129982
ncol(casualties)
#> [1] 37
```

The results show that there were 129,982 casualties reported by the
police in the STATS19 dataset in 2017, and 37 columns (variables).
Values for a sample of these columns are shown below:

``` r
casualties[c(4, 5, 6, 14)]
#> # A tibble: 129,982 × 4
#>    location_easting_osgr location_northing_osgr longitude  time
#>                    <int>                  <int>     <int> <int>
#>  1                532920                 196330        NA    NA
#>  2                526790                 181970        NA    NA
#>  3                535200                 181260        NA    NA
#>  4                534340                 193560        NA    NA
#>  5                533680                 187820        NA    NA
#>  6                514510                 172370        NA    NA
#>  7                508640                 181870        NA    NA
#>  8                527880                 181950        NA    NA
#>  9                520940                 192820        NA    NA
#> 10                531430                 178450        NA    NA
#> # … with 129,972 more rows
```

The full list of column names in the `casualties` dataset is:

``` r
names(casualties)
#>  [1] "accident_index"                             
#>  [2] "accident_year"                              
#>  [3] "accident_reference"                         
#>  [4] "location_easting_osgr"                      
#>  [5] "location_northing_osgr"                     
#>  [6] "longitude"                                  
#>  [7] "latitude"                                   
#>  [8] "police_force"                               
#>  [9] "accident_severity"                          
#> [10] "number_of_vehicles"                         
#> [11] "number_of_casualties"                       
#> [12] "date"                                       
#> [13] "day_of_week"                                
#> [14] "time"                                       
#> [15] "local_authority_district"                   
#> [16] "local_authority_ons_district"               
#> [17] "local_authority_highway"                    
#> [18] "first_road_class"                           
#> [19] "first_road_number"                          
#> [20] "road_type"                                  
#> [21] "speed_limit"                                
#> [22] "junction_detail"                            
#> [23] "junction_control"                           
#> [24] "second_road_class"                          
#> [25] "second_road_number"                         
#> [26] "pedestrian_crossing_human_control"          
#> [27] "pedestrian_crossing_physical_facilities"    
#> [28] "light_conditions"                           
#> [29] "weather_conditions"                         
#> [30] "road_surface_conditions"                    
#> [31] "special_conditions_at_site"                 
#> [32] "carriageway_hazards"                        
#> [33] "urban_or_rural_area"                        
#> [34] "did_police_officer_attend_scene_of_accident"
#> [35] "trunk_road_flag"                            
#> [36] "lsoa_of_accident_location"                  
#> [37] "datetime"
```

### Vehicles data

Data for vehicles involved in crashes in 2017 can be downloaded, read-in
and formatted as follows:

``` r
vehicles = get_stats19(year = 2017, type = "vehicle", ask = FALSE)
#> vehicle
#> Files identified: dft-road-casualty-statistics-vehicle-2017.csv
#>    https://data.dft.gov.uk/road-accidents-safety-data/dft-road-casualty-statistics-vehicle-2017.csv
#> Data already exists in data_dir, not downloading
#> Data saved at ~/stats19-data/dft-road-casualty-statistics-vehicle-2017.csv
#> Called from: check_input_file(filename = filename, type = "accident", data_dir = data_dir, 
#>     year = year)
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#151: if (!is.null(year)) {
#>     year = check_year(year)
#> }
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#152: year = check_year(year)
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#154: path = locate_one_file(type = type, filename = filename, data_dir = data_dir, 
#>     year = year)
#> accident
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#160: if (identical(path, "More than one csv file found.")) stop("Multiple files with the same name found.", 
#>     call. = FALSE)
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#163: if (is.null(path) || length(path) == 0 || !endsWith(path, ".csv") || 
#>     !file.exists(path)) {
#>     message(path)
#>     stop("Change data_dir, filename, year or run dl_stats19() first.", 
#>         call. = FALSE)
#> }
#> debug at /mnt/57982e2a-2874-4246-a6fe-115c199bc6bd/orgs/ropensci/stats19/R/read.R#170: return(path)
#> Reading in:
#> ~/stats19-data/dft-road-casualty-statistics-accident-2017.csv
#> Warning: One or more parsing issues, see `problems()` for details
#> date and time columns present, creating formatted datetime column
nrow(vehicles)
#> [1] 129982
ncol(vehicles)
#> [1] 37
```

The results show that there were 129,982 vehicles involved in crashes
reported by the police in the STATS19 dataset in 2017, with 37 columns
(variables). Values for a sample of these columns are shown below:

``` r
vehicles[c(3, 14:16)]
#> # A tibble: 129,982 × 4
#>    accident_reference  time local_authority_district local_authority_ons_distri…
#>                 <int> <int> <chr>                                          <int>
#>  1           10001708    NA Enfield                                           NA
#>  2           10009342    NA Westminster                                       NA
#>  3           10009344    NA Tower Hamlets                                     NA
#>  4           10009348    NA Enfield                                           NA
#>  5           10009350    NA Hackney                                           NA
#>  6           10009351    NA Richmond upon Thames                              NA
#>  7           10009353    NA Hillingdon                                        NA
#>  8           10009354    NA Westminster                                       NA
#>  9           10009357    NA Barnet                                            NA
#> 10           10009358    NA Lambeth                                           NA
#> # … with 129,972 more rows
```

The full list of column names in the `vehicles` dataset is:

``` r
names(vehicles)
#>  [1] "accident_index"                             
#>  [2] "accident_year"                              
#>  [3] "accident_reference"                         
#>  [4] "location_easting_osgr"                      
#>  [5] "location_northing_osgr"                     
#>  [6] "longitude"                                  
#>  [7] "latitude"                                   
#>  [8] "police_force"                               
#>  [9] "accident_severity"                          
#> [10] "number_of_vehicles"                         
#> [11] "number_of_casualties"                       
#> [12] "date"                                       
#> [13] "day_of_week"                                
#> [14] "time"                                       
#> [15] "local_authority_district"                   
#> [16] "local_authority_ons_district"               
#> [17] "local_authority_highway"                    
#> [18] "first_road_class"                           
#> [19] "first_road_number"                          
#> [20] "road_type"                                  
#> [21] "speed_limit"                                
#> [22] "junction_detail"                            
#> [23] "junction_control"                           
#> [24] "second_road_class"                          
#> [25] "second_road_number"                         
#> [26] "pedestrian_crossing_human_control"          
#> [27] "pedestrian_crossing_physical_facilities"    
#> [28] "light_conditions"                           
#> [29] "weather_conditions"                         
#> [30] "road_surface_conditions"                    
#> [31] "special_conditions_at_site"                 
#> [32] "carriageway_hazards"                        
#> [33] "urban_or_rural_area"                        
#> [34] "did_police_officer_attend_scene_of_accident"
#> [35] "trunk_road_flag"                            
#> [36] "lsoa_of_accident_location"                  
#> [37] "datetime"
```

## Creating geographic crash data

An important feature of STATS19 data is that the “accidents” table
contains geographic coordinates. These are provided at \~10m resolution
in the UK’s official coordinate reference system (the Ordnance Survey
National Grid, EPSG code 27700). **stats19** converts the non-geographic
tables created by `format_accidents()` into the geographic data form of
the [`sf` package](https://cran.r-project.org/package=sf) with the
function `format_sf()` as follows:

``` r
crashes_sf = format_sf(crashes)
#> 19 rows removed with no coordinates
```

The note arises because `NA` values are not permitted in `sf`
coordinates, and so rows containing no coordinates are automatically
removed. Having the data in a standard geographic form allows various
geographic operations to be performed on it. The following code chunk,
for example, returns all crashes within the boundary of West Yorkshire
(which is contained in the object
[`police_boundaries`](https://itsleeds.github.io/stats19/reference/police_boundaries.html),
an `sf` data frame containing all police jurisdictions in England and
Wales).

``` r
library(sf)
#> Linking to GEOS 3.9.1, GDAL 3.3.2, PROJ 7.2.1
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
wy = filter(police_boundaries, pfa16nm == "West Yorkshire")
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
crashes_wy = crashes_sf[wy, ]
nrow(crashes_sf)
#> [1] 129963
nrow(crashes_wy)
#> [1] 4371
```

This subsetting has selected the 4,371 crashes which occurred within
West Yorkshire in 2017.

## Joining tables

The three main tables we have just read-in can be joined by shared key
variables. This is demonstrated in the code chunk below, which subsets
all casualties that took place in Leeds, and counts the number of
casualties by severity for each crash:

``` r
sel = casualties$accident_index %in% crashes_wy$accident_index
casualties_wy = casualties[sel, ]
names(casualties_wy)
#>  [1] "accident_index"                             
#>  [2] "accident_year"                              
#>  [3] "accident_reference"                         
#>  [4] "location_easting_osgr"                      
#>  [5] "location_northing_osgr"                     
#>  [6] "longitude"                                  
#>  [7] "latitude"                                   
#>  [8] "police_force"                               
#>  [9] "accident_severity"                          
#> [10] "number_of_vehicles"                         
#> [11] "number_of_casualties"                       
#> [12] "date"                                       
#> [13] "day_of_week"                                
#> [14] "time"                                       
#> [15] "local_authority_district"                   
#> [16] "local_authority_ons_district"               
#> [17] "local_authority_highway"                    
#> [18] "first_road_class"                           
#> [19] "first_road_number"                          
#> [20] "road_type"                                  
#> [21] "speed_limit"                                
#> [22] "junction_detail"                            
#> [23] "junction_control"                           
#> [24] "second_road_class"                          
#> [25] "second_road_number"                         
#> [26] "pedestrian_crossing_human_control"          
#> [27] "pedestrian_crossing_physical_facilities"    
#> [28] "light_conditions"                           
#> [29] "weather_conditions"                         
#> [30] "road_surface_conditions"                    
#> [31] "special_conditions_at_site"                 
#> [32] "carriageway_hazards"                        
#> [33] "urban_or_rural_area"                        
#> [34] "did_police_officer_attend_scene_of_accident"
#> [35] "trunk_road_flag"                            
#> [36] "lsoa_of_accident_location"                  
#> [37] "datetime"
# cas_types = casualties_wy %>% 
#   select(accident_index, casualty_type) %>% 
#   mutate(n = 1) %>% 
#   group_by(accident_index, casualty_type) %>% 
#   summarise(n = sum(n)) %>% 
#   tidyr::spread(casualty_type, n, fill = 0) 
# cas_types$Total = rowSums(cas_types[-1])
# cj = left_join(crashes_wy, cas_types, by = "accident_index")
```

What just happened? We found the subset of casualties that took place in
West Yorkshire with reference to the `accident_index` variable. Then we
used functions from the **tidyverse** package **dplyr** (and `spread()`
from **tidyr**) to create a dataset with a column for each casualty
type. We then joined the updated casualty data onto the `crashes_wy`
dataset. The result is a spatial (`sf`) data frame of crashes in Leeds,
with columns counting how many road users of different types were hurt.
The original and joined data look like this:

``` r
knitr::opts_chunk$set(eval = FALSE)
```

``` r
crashes_wy %>%
  select(accident_index, accident_severity) %>% 
  st_drop_geometry()
cas_types[1:2, c("accident_index", "Cyclist")]
cj[1:2, c(1, 5, 34)] %>% st_drop_geometry()
```

## Mapping crashes

The join operation added a geometry column to the casualty data,
enabling it to be mapped (for more advanced maps, see the
[vignette](https://itsleeds.github.io/stats19/articles/stats19.html)):

``` r
cex = cj$Total / 3
plot(cj["speed_limit"], cex = cex)
```

The spatial distribution of crashes in West Yorkshire clearly relates to
the region’s geography. Crashes tend to happen on busy Motorway roads
(with a high speed limit, of 70 miles per hour, as shown in the map
above) and city centres, of Leeds and Bradford in particular. The
severity and number of people hurt (proportional to circle width in the
map above) in crashes is related to the speed limit.

STATS19 data can be used as the basis of road safety research. The map
below, for example, shows the results of an academic paper on the
social, spatial and temporal distribution of bike crashes in West
Yorkshire, which estimated the number of crashes per billion km cycled
based on commuter cycling as a proxy for cycling levels overall (more
sophisticated measures of cycling levels are now possible thanks to new
data sources) (Lovelace, Roberts, and Kellar 2016):

## Time series analysis

We can also explore seasonal trends in crashes by aggregating crashes by
day of the year:

``` r
library(ggplot2)
crashes_dates = cj %>% 
  st_set_geometry(NULL) %>% 
  group_by(date) %>% 
  summarise(
    walking = sum(Pedestrian),
    cycling = sum(Cyclist),
    passenger = sum(`Car occupant`)
    ) %>% 
  tidyr::gather(mode, casualties, -date)
ggplot(crashes_dates, aes(date, casualties)) +
  geom_smooth(aes(colour = mode), method = "loess") +
  ylab("Casualties per day")
```

Different types of crashes also tend to happen at different times of
day. This is illustrated in the plot below, which shows the times of day
when people who were travelling by different modes were most commonly
injured.

``` r
library(stringr)

crash_times = cj %>% 
  st_set_geometry(NULL) %>% 
  group_by(hour = as.numeric(str_sub(time, 1, 2))) %>% 
  summarise(
    walking = sum(Pedestrian),
    cycling = sum(Cyclist),
    passenger = sum(`Car occupant`)
    ) %>% 
  tidyr::gather(mode, casualties, -hour)

ggplot(crash_times, aes(hour, casualties)) +
  geom_line(aes(colour = mode))
```

Note that cycling manifests distinct morning and afternoon peaks (see
Lovelace, Roberts, and Kellar 2016 for more on this).

## Usage in research and policy contexts

The package has now been peer reviewed and is stable, and has been
published in the Journal of Open Source Software (Lovelace et al. 2019).
Please tell people about the package, link to it and cite it if you use
it in your work.

Examples of how the package can been used for policy making include:

-   Use of the package in a web app created by the library service of
    the UK Parliament. See
    [commonslibrary.parliament.uk](https://commonslibrary.parliament.uk/constituency-data-traffic-accidents/),
    screenshots of which from December 2019 are shown below, for
    details.

![](https://user-images.githubusercontent.com/1825120/70164249-bf730080-16b8-11ea-96d8-ec92c0b5cc69.png)

-   Use of methods taught in the
    [stats19-training](https://docs.ropensci.org/stats19/articles/stats19-training.html)
    vignette by road safety analysts at Essex Highways and the Safer
    Essex Roads Partnership ([SERP](https://saferessexroads.org/)) to
    inform the deployment of proactive front-line police enforcement in
    the region (credit: Will Cubbin).

-   Mention of road crash data analysis based on the package in an
    [article](https://www.theguardian.com/cities/2019/oct/07/a-deadly-problem-should-we-ban-suvs-from-our-cities)
    on urban SUVs. The question of how vehicle size and type relates to
    road safety is an important area of future research. A starting
    point for researching this topic can be found in the
    [`stats19-vehicles`](https://docs.ropensci.org/stats19/articles/stats19-vehicles.html)
    vignette, representing a possible next step in terms of how the data
    can be used.

## Next steps

There is much important research that needs to be done to help make the
transport systems in many cities safer. Even if you’re not working with
UK data, we hope that the data provided by **stats19** data can help
safety researchers develop new methods to better understand the reasons
why people are needlessly hurt and killed on the roads.

The next step is to gain a deeper understanding of **stats19** and the
data it provides. Then it’s time to pose interesting research questions,
some of which could provide an evidence-base in support policies that
save lives (e.g. Sarkar, Webster, and Kumari 2018). For more on these
next steps, see the package’s introductory
[vignette](https://itsleeds.github.io/stats19/articles/stats19.html).

## Further information

The **stats19** package builds on previous work, including:

-   code in the [bikeR](https://github.com/Robinlovelace/bikeR) repo
    underlying an academic paper on collisions involving cyclists
-   functions in [**stplanr**](https://docs.ropensci.org/stplanr/) for
    downloading Stats19 data
-   updated functions related to the
    [CyIPT](https://github.com/cyipt/stats19) project

[![ropensci_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-lovelace_stats19_2019" class="csl-entry">

Lovelace, Robin, Malcolm Morgan, Layik Hama, Mark Padgham, and M
Padgham. 2019. “Stats19 A Package for Working with Open Road Crash
Data.” *Journal of Open Source Software* 4 (33): 1181.
<https://doi.org/10.21105/joss.01181>.

</div>

<div id="ref-lovelace_who_2016" class="csl-entry">

Lovelace, Robin, Hannah Roberts, and Ian Kellar. 2016. “Who, Where,
When: The Demographic and Geographic Distribution of Bicycle Crashes in
West Yorkshire.” *Transportation Research Part F: Traffic Psychology and
Behaviour*, Bicycling and bicycle safety, 41, Part B.
<https://doi.org/10.1016/j.trf.2015.02.010>.

</div>

<div id="ref-sarkar_street_2018" class="csl-entry">

Sarkar, Chinmoy, Chris Webster, and Sarika Kumari. 2018. “Street
Morphology and Severity of Road Casualties: A 5-Year Study of Greater
London.” *International Journal of Sustainable Transportation* 12 (7):
510–25. <https://doi.org/10.1080/15568318.2017.1402972>.

</div>

</div>
