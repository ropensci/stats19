# Sample of stats19 data (2022 vehicles)

Sample of stats19 data (2022 vehicles)

## Format

A data frame

## Note

These were generated using the script in the `data-raw` directory
(`misc.Rmd` file).

## Examples

``` r
# \donttest{
nrow(vehicles_sample_raw)
#> [1] 3
vehicles_sample_raw
#> # A tibble: 3 × 23
#>   Accident_Index Vehicle_Reference Vehicle_Type Towing_and_Articulation
#>   <chr>                      <int>        <int>                   <int>
#> 1 2017010047506                  2            9                       0
#> 2 2017010068468                  2           21                       0
#> 3 2017471704529                  3            9                       0
#> # ℹ 19 more variables: Vehicle_Manoeuvre <int>,
#> #   `Vehicle_Location-Restricted_Lane` <int>, Junction_Location <int>,
#> #   Skidding_and_Overturning <int>, Hit_Object_in_Carriageway <int>,
#> #   Vehicle_Leaving_Carriageway <int>, Hit_Object_off_Carriageway <int>,
#> #   `1st_Point_of_Impact` <int>, `Was_Vehicle_Left_Hand_Drive?` <int>,
#> #   Journey_Purpose_of_Driver <int>, Sex_of_Driver <int>, Age_of_Driver <int>,
#> #   Age_Band_of_Driver <int>, `Engine_Capacity_(CC)` <int>, …
# }
```
