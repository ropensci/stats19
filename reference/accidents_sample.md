# Sample of stats19 data (2022 collisions)

Sample of stats19 data (2022 collisions)

## Format

A data frame

## Note

These were generated using the script in the `data-raw` directory
(`misc.Rmd` file).

## Examples

``` r
# \donttest{
nrow(accidents_sample_raw)
#> [1] 3
accidents_sample_raw
#> # A tibble: 3 × 37
#>   accident_index accident_year accident_reference location_easting_osgr
#>   <chr>                  <int> <chr>                              <int>
#> 1 2023010451590           2023 010451590                         530265
#> 2 2023471310743           2023 471310743                         487614
#> 3 2023522301107           2023 522301107                         369566
#> # ℹ 33 more variables: location_northing_osgr <int>, longitude <int>,
#> #   latitude <int>, police_force <chr>, accident_severity <chr>,
#> #   number_of_vehicles <chr>, number_of_casualties <chr>, date <chr>,
#> #   day_of_week <chr>, time <chr>, local_authority_district <chr>,
#> #   local_authority_ons_district <chr>, local_authority_highway <chr>,
#> #   first_road_class <chr>, first_road_number <chr>, road_type <chr>,
#> #   speed_limit <chr>, junction_detail <chr>, junction_control <chr>, …
# }
```
