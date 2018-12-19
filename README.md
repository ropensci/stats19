
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
#> Data saved at /tmp/Rtmp1K5WYn/dftRoadSafetyData_Accidents_2017/Acc.csv
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
#> /tmp/Rtmp1K5WYn/dftRoadSafetyData_Accidents_2017/Acc.csv
nrow(crashes_2017_raw)
#> [1] 129982
ncol(crashes_2017_raw)
#> [1] 32
crashes_2017 = format_accidents(crashes_2017_raw)
```

What just happened? We read-in data on all road crashes recorded by the
police in 2017 across Great Britain. The dataset contains 32 columns
(variables) for 129982 crashes.

This work was done by `read_accidents()`, which imported the ‘raw’
Stats19 data without cleaning messy column names or re-categorising the
outputs. `format_accidents()` does the formatting work, automating the
process of matching column names with variable names and labels in a
[`.xls`
file](http://data.dft.gov.uk/road-accidents-safety-data/Road-Accident-Safety-Data-Guide.xls)
provided by the DfT. This means `crashes_2017` is much more usable than
`crashes_2017_raw`, as shown below, which shows some key variables in
the messy and clean datasets:

``` r
crashes_2017_raw[c(7, 18, 23, 25)]
#> # A tibble: 129,982 x 4
#>    Accident_Severity Speed_limit `Pedestrian_Crossing-Hum… Light_Conditions
#>                <int>       <int>                     <int>            <int>
#>  1                 1          30                         0                4
#>  2                 3          30                         0                4
#>  3                 3          30                         0                4
#>  4                 3          30                         0                4
#>  5                 2          20                         0                4
#>  6                 3          30                         0                4
#>  7                 3          40                         0                4
#>  8                 3          30                         2                4
#>  9                 2          50                         0                4
#> 10                 2          30                         0                4
#> # ... with 129,972 more rows
crashes_2017[c(7, 18, 23, 25)]
#> # A tibble: 129,982 x 4
#>    accident_severity speed_limit pedestrian_crossing_hu… light_conditions  
#>    <chr>                   <int> <chr>                   <chr>             
#>  1 Fatal                      30 None within 50 metres   Darkness - lights…
#>  2 Slight                     30 None within 50 metres   Darkness - lights…
#>  3 Slight                     30 None within 50 metres   Darkness - lights…
#>  4 Slight                     30 None within 50 metres   Darkness - lights…
#>  5 Serious                    20 None within 50 metres   Darkness - lights…
#>  6 Slight                     30 None within 50 metres   Darkness - lights…
#>  7 Slight                     40 None within 50 metres   Darkness - lights…
#>  8 Slight                     30 Control by other autho… Darkness - lights…
#>  9 Serious                    50 None within 50 metres   Darkness - lights…
#> 10 Serious                    30 None within 50 metres   Darkness - lights…
#> # ... with 129,972 more rows
```

The full list of column names in the `crashes` dataset is:

``` r
names(crashes_2017)
#>  [1] "accident_index"                             
#>  [2] "location_easting_osgr"                      
#>  [3] "location_northing_osgr"                     
#>  [4] "longitude"                                  
#>  [5] "latitude"                                   
#>  [6] "police_force"                               
#>  [7] "accident_severity"                          
#>  [8] "number_of_vehicles"                         
#>  [9] "number_of_casualties"                       
#> [10] "date"                                       
#> [11] "day_of_week"                                
#> [12] "time"                                       
#> [13] "local_authority_district"                   
#> [14] "local_authority_highway"                    
#> [15] "first_road_class"                           
#> [16] "first_road_number"                          
#> [17] "road_type"                                  
#> [18] "speed_limit"                                
#> [19] "junction_detail"                            
#> [20] "junction_control"                           
#> [21] "second_road_class"                          
#> [22] "second_road_number"                         
#> [23] "pedestrian_crossing_human_control"          
#> [24] "pedestrian_crossing_physical_facilities"    
#> [25] "light_conditions"                           
#> [26] "weather_conditions"                         
#> [27] "road_surface_conditions"                    
#> [28] "special_conditions_at_site"                 
#> [29] "carriageway_hazards"                        
#> [30] "urban_or_rural_area"                        
#> [31] "did_police_officer_attend_scene_of_accident"
#> [32] "lsoa_of_accident_location"
```

<!-- This means `crashes_2017` is much more usable than `crashes_2017_raw`, as shown below, which shows three records and some key variables in the messy and clean datasets: -->

**Note**: The Department for Transport calls this table ‘accidents’ but
a more appropriate term may be more appropriate, according to road
safety advocacy groups such as
[RoadPeace](http://www.roadpeace.org/take-action/crash-not-accident/).
For this reason we are faithful to the name provided in the data’s
official documentation but call the resulting datset `crashes`.

## Casualties data

As with `crashes_2017`, casualty data for 2017 can be downloaded,
read-in and formated as follows:

``` r
dl_stats19(year = 2017, type = "casualties")
#> Files identified: dftRoadSafetyData_Casualties_2017.zip
#> Attempt downloading from:
#>    http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/dftRoadSafetyData_Casualties_2017.zip
#> Data saved at /tmp/Rtmp1K5WYn/dftRoadSafetyData_Casualties_2017/Cas.csv
casualties_2017_raw = read_casualties(year = 2017)
nrow(casualties_2017_raw)
#> [1] 170993
ncol(casualties_2017_raw)
#> [1] 16
casualties_2017 = format_casualties(casualties_2017_raw)
```

The results show that there were 170993 casualties reported by the
police in the STATS19 dataset in 2017. There are 16 columns (variables)
on these casualties. Values for a sample of these columns is shown
below:

``` r
casualties_2017[c(4, 5, 6, 14)]
#> # A tibble: 170,993 x 4
#>    casualty_class  sex_of_casualty age_of_casualty casualty_type           
#>    <chr>           <chr>                     <int> <chr>                   
#>  1 Passenger       Female                       18 Car occupant            
#>  2 Driver or rider Male                         19 Motorcycle 50cc and und…
#>  3 Passenger       Male                         18 Motorcycle 50cc and und…
#>  4 Passenger       Female                       33 Car occupant            
#>  5 Driver or rider Female                       31 Car occupant            
#>  6 Passenger       Male                          3 Car occupant            
#>  7 Pedestrian      Male                         45 Pedestrian              
#>  8 Driver or rider Male                         14 Motorcycle 125cc and un…
#>  9 Driver or rider Female                       58 Car occupant            
#> 10 Driver or rider Male                         27 Car occupant            
#> # ... with 170,983 more rows
```

The full list of column names in the `casualties` dataset is:

``` r
names(casualties_2017)
#>  [1] "accident_index"                    
#>  [2] "vehicle_reference"                 
#>  [3] "casualty_reference"                
#>  [4] "casualty_class"                    
#>  [5] "sex_of_casualty"                   
#>  [6] "age_of_casualty"                   
#>  [7] "age_band_of_casualty"              
#>  [8] "casualty_severity"                 
#>  [9] "pedestrian_location"               
#> [10] "pedestrian_movement"               
#> [11] "car_passenger"                     
#> [12] "bus_or_coach_passenger"            
#> [13] "pedestrian_road_maintenance_worker"
#> [14] "casualty_type"                     
#> [15] "casualty_home_area_type"           
#> [16] "casualty_imd_decile"
```

## Vehicles data

As before, vehicles data for 2017 can be downloaded, read-in and
formated as follows:

``` r
dl_stats19(year = 2017, type = "vehicles")
#> Files identified: dftRoadSafetyData_Vehicles_2017.zip
#> Attempt downloading from:
#>    http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/dftRoadSafetyData_Vehicles_2017.zip
#> Data saved at /tmp/Rtmp1K5WYn/dftRoadSafetyData_Vehicles_2017/Veh.csv
vehicles_2017_raw = read_vehicles(year = 2017)
nrow(vehicles_2017_raw)
#> [1] 238926
ncol(vehicles_2017_raw)
#> [1] 23
vehicles_2017 = format_vehicles(vehicles_2017_raw)
```

The results show that there were 238926 vehicles involved in crashes
reported by the police in the STATS19 dataset in 2017. There are 23
columns (variables) on these vehicles. Values for a sample of these
columns is shown below:

``` r
vehicles_2017[c(3, 14:16)]
#> # A tibble: 238,926 x 4
#>    vehicle_type          journey_purpose_of_dr… sex_of_driver age_of_driver
#>    <chr>                 <chr>                  <chr>                 <int>
#>  1 Car                   Not known              Male                     24
#>  2 Motorcycle 50cc and … Not known              Male                     19
#>  3 Car                   Not known              Male                     33
#>  4 Car                   Not known              Male                     40
#>  5 Car                   Not known              Not known                -1
#>  6 Car                   Not known              Male                     35
#>  7 Car                   Not known              Female                   31
#>  8 Car                   Not known              Female                   37
#>  9 Car                   Not known              Female                   29
#> 10 Car                   Not known              Male                     78
#> # ... with 238,916 more rows
```

The full list of column names in the `vehicles` dataset is:

``` r
names(vehicles_2017)
#>  [1] "accident_index"                   "vehicle_reference"               
#>  [3] "vehicle_type"                     "towing_and_articulation"         
#>  [5] "vehicle_manoeuvre"                "vehicle_location_restricted_lane"
#>  [7] "junction_location"                "skidding_and_overturning"        
#>  [9] "hit_object_in_carriageway"        "vehicle_leaving_carriageway"     
#> [11] "hit_object_off_carriageway"       "first_point_of_impact"           
#> [13] "was_vehicle_left_hand_drive"      "journey_purpose_of_driver"       
#> [15] "sex_of_driver"                    "age_of_driver"                   
#> [17] "age_band_of_driver"               "engine_capacity_cc"              
#> [19] "propulsion_code"                  "age_of_vehicle"                  
#> [21] "driver_imd_decile"                "driver_home_area_type"           
#> [23] "vehicle_imd_decile"
```

<!-- More data can be read-in as follows: -->

## Creating geographic crash data

An important feature of STATS19 data is that the ‘accidents’ table
contains geographic coordinates. These are provided at ~10m resolution
in the UK’s official coordinate reference system (the Ordnance Survey
National Grid, EPSG code 27700). **stats19** converts the non-geographic
tables created by `format_accidents()` into a geographic (`sf`) data
form with the function `format_sf()` as follows:

``` r
crashes_sf = format_sf(crashes_2017)
#> 19 rows removed with no coordinates
```

Note: rows without coordinates are removed, NAs are not permitted in
`sf` coordinates. Once the data is in this form you can do geographic
operations on it. The following code chunk, for example, returns all
crashes in the Leeds local authority (requires the **ukboundaries**
GitHub package):

``` r
library(sf)
#> Linking to GEOS 3.6.2, GDAL 2.2.3, PROJ 4.9.3
leeds_osgb = st_transform(ukboundaries::leeds, crs = 27700)
#> Using default data cache directory ~/.ukboundaries/cache 
#> Use cache_dir() to change it.
crashes_leeds = crashes_sf[leeds_osgb, ]
```

## Joining tables

The three tables we have just read-in can be joined by shared key
variables. This is demonstrated in the code chunk below, which subsets
all casualties that took place in Leeds, and counts the number of
casualties by severity for each crash:

``` r
sel = casualties_2017$accident_index %in% crashes_leeds$accident_index
casualties_leeds = casualties_2017[sel, ]
library(tidyverse)
#> ── Attaching packages ───────────────────────────────────────────── tidyverse 1.2.1 ──
#> ✔ ggplot2 3.1.0     ✔ purrr   0.2.5
#> ✔ tibble  1.4.2     ✔ dplyr   0.7.8
#> ✔ tidyr   0.8.2     ✔ stringr 1.3.1
#> ✔ readr   1.3.0     ✔ forcats 0.3.0
#> ── Conflicts ──────────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
cas_types = casualties_leeds %>% 
  select(accident_index, casualty_type) %>% 
  mutate(n = 1) %>% 
  group_by(accident_index, casualty_type) %>% 
  summarise(n = sum(n)) %>% 
  spread(casualty_type, n, fill = 0) 
cas_types$Total = rowSums(cas_types[-1])
crashes_joined = left_join(crashes_leeds[1], cas_types)
#> Joining, by = "accident_index"
```

What just happened? We found the subset of casualties that took place in
Leeds with reference to the `accident_index` variable. Then we used
functions from the **tidyverse** package **dplyr** (and `spread()` from
**tidyr**) to create a dataset with a column for each casualty type. We
then joined the updated casualty data onto the `crashes_leeds` dataset.
The result is a spatial (`sf`) data frame of crashes in Leeds, with
columns counting how many road users of different types were hurt. We
can now explore the spatial distribution of different casualty types as
follows:

``` r
plot(crashes_joined[crashes_joined$Pedestrian > 0, "Pedestrian"])
plot(crashes_joined[crashes_joined$Cyclist > 0, "Cyclist"])
plot(crashes_joined[crashes_joined$`Car occupant` > 0, "Car occupant"])
```

<img src="man/figures/README-sfplot-1.png" width="33%" /><img src="man/figures/README-sfplot-2.png" width="33%" /><img src="man/figures/README-sfplot-3.png" width="33%" />

It is clear from the previous plot that pedestrians, cyclists and car
occupants tend to get hurt in different places. Car occupant casulaties,
for example, are comparatively common on the outskirts of Leeds, where
speed limits tend to be higher and where there are comparatively high
volumes of motor traffic, compared with the city centre.

Another way of visualising the data, in this case to show the spatial
distribution of crashes causing pedestrian casualties by numbers of
pedestrians hurt, is with **ggplot2**:

``` r
ggplot(crashes_joined, aes(colour = Total)) +
  geom_sf() +
  facet_wrap(vars(Pedestrian))
```

<img src="man/figures/README-ggplot-1.png" width="100%" />

Note: Both figures show that pedestrian casualties tend to happen more
frequently near the city centre, compared with other types of casualty.

## Next steps

There is much important research that needs to be done to help make the
transport systems in many cities safer. Even if you’re not working with
UK data, we hope that the data provided by **stats19** data can help
safety researchers develop new methods to better understand the reasons
why people are needlessly hurt and killed on the roads.

The next step is to gain a deeper understanding of **stats19** and the
data it provides. Then it’s time to pose interesting research questions,
some of which could provide an evidence-base in support policies that
save lives. For more on these next steps, see the package’s introductory
vignette.

## Further information

The **stats19** package builds on previous work, including:

  - code in the [bikeR](https://github.com/Robinlovelace/bikeR) repo
    underlying an academic paper on collisions involving cyclists
  - functions in
    [**stplanr**](https://github.com/ropensci/stplanr/blob/master/R/load-stats19.R)
    for downloading Stats19 data
  - updated functions related to the
    [CyIPT](https://github.com/cyipt/stats19) project
