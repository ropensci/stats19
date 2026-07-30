# Police force boundaries in England (2016)

This dataset represents the 43 police forces in England and Wales. These
are described on the [Wikipedia
page](https://en.wikipedia.org/wiki/List_of_police_forces_of_the_United_Kingdom).
on UK police forces.

## Format

An sf data frame

## Details

The geographic boundary data were taken from the UK government's
official geographic data portal. See http://geoportal.statistics.gov.uk/

## Note

These were generated using the script in the `data-raw` directory
(`misc.Rmd` file) in the package's GitHub repo:
[github.com/ITSLeeds/stats19](https://github.com/ITSLeeds/stats19).

## Examples

``` r
nrow(police_boundaries)
#> [1] 43
police_boundaries[police_boundaries$pfa16nm == "West Yorkshire", ]
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> Simple feature collection with 1 feature and 2 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 388662.6 ymin: 402593.5 xmax: 452991.6 ymax: 451901.4
#> Projected CRS: OSGB36 / British National Grid
#> # A tibble: 1 × 3
#>   pfa16cd   pfa16nm                                                     geometry
#>   <chr>     <chr>                                             <MULTIPOLYGON [m]>
#> 1 E23000010 West Yorkshire (((408054.7 451818.9, 408045.8 450915.7, 408358.1 44…
sf:::plot.sf(police_boundaries)
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
#> old-style crs object detected; please recreate object with a recent sf::st_crs()
```
