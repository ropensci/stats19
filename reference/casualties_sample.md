# Sample of stats19 data (2022 casualties)

Sample of stats19 data (2022 casualties)

## Format

A data frame

## Note

These were generated using the script in the `data-raw` directory
(`misc.Rmd` file).

## Examples

``` r
# \donttest{
nrow(casualties_sample_raw)
#> [1] 3
casualties_sample_raw
#> # A tibble: 3 × 16
#>   Accident_Index Vehicle_Reference Casualty_Reference Casualty_Class
#>   <chr>                      <int>              <int>          <int>
#> 1 2017010048523                  1                  1              1
#> 2 2017010070898                  1                  1              3
#> 3 2017471705929                  1                  1              1
#> # ℹ 12 more variables: Sex_of_Casualty <int>, Age_of_Casualty <int>,
#> #   Age_Band_of_Casualty <int>, Casualty_Severity <int>,
#> #   Pedestrian_Location <int>, Pedestrian_Movement <int>, Car_Passenger <int>,
#> #   Bus_or_Coach_Passenger <int>, Pedestrian_Road_Maintenance_Worker <int>,
#> #   Casualty_Type <int>, Casualty_Home_Area_Type <int>,
#> #   Casualty_IMD_Decile <int>
# }
```
