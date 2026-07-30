# Format column names of raw STATS19 data

This function takes messy column names and returns clean ones that work
well with R by default. Names that are all lower case with no
R-unfriendly characters such as spaces and `-` are returned.

## Usage

``` r
format_column_names(column_names)
```

## Arguments

- column_names:

  Column names to be cleaned

## Value

Column names cleaned.

## Examples

``` r
# \donttest{
if(curl::has_internet()) {
crashes_raw = read_collisions(year = 2022)
column_names = names(crashes_raw)
column_names
format_column_names(column_names = column_names)
}
#> Reading in: /tmp/RtmpXo7tls/dft-road-casualty-statistics-collision-2022.csv
#> date and time columns present, creating formatted datetime column
#>  [1] "collision_index"                                 
#>  [2] "collision_year"                                  
#>  [3] "collision_reference"                             
#>  [4] "location_easting_osgr"                           
#>  [5] "location_northing_osgr"                          
#>  [6] "longitude"                                       
#>  [7] "latitude"                                        
#>  [8] "police_force"                                    
#>  [9] "collision_severity"                              
#> [10] "number_of_vehicles"                              
#> [11] "number_of_casualties"                            
#> [12] "date"                                            
#> [13] "day_of_week"                                     
#> [14] "time"                                            
#> [15] "local_authority_district"                        
#> [16] "local_authority_ons_district"                    
#> [17] "local_authority_highway"                         
#> [18] "local_authority_highway_current"                 
#> [19] "first_road_class"                                
#> [20] "first_road_number"                               
#> [21] "road_type"                                       
#> [22] "speed_limit"                                     
#> [23] "junction_detail"                                 
#> [24] "junction_control"                                
#> [25] "second_road_class"                               
#> [26] "second_road_number"                              
#> [27] "pedestrian_crossing_physical_facilities_historic"
#> [28] "pedestrian_crossing"                             
#> [29] "light_conditions"                                
#> [30] "weather_conditions"                              
#> [31] "road_surface_conditions"                         
#> [32] "special_conditions_at_site"                      
#> [33] "carriageway_hazards"                             
#> [34] "urban_or_rural_area"                             
#> [35] "did_police_officer_attend_scene_of_accident"     
#> [36] "trunk_road_flag"                                 
#> [37] "lsoa_of_accident_location"                       
#> [38] "enhanced_severity_collision"                     
#> [39] "collision_injury_based"                          
#> [40] "collision_adjusted_severity_serious"             
#> [41] "collision_adjusted_severity_slight"              
#> [42] "datetime"                                        
# }
```
