# Download DVLA-based vehicle data from the TfL API using VRM.

Download DVLA-based vehicle data from the TfL API using VRM.

## Usage

``` r
get_ULEZ(vrm)
```

## Arguments

- vrm:

  A list of VRMs as character strings.

## Details

This function takes a character vector of vehicle registrations (VRMs)
and returns DVLA-based vehicle data from TfL's API, included ULEZ
eligibility. It returns a data frame of those VRMs which were
successfully used with the TfL API. Vehicles are either compliant,
non-compliant or exempt. ULEZ-exempt vehicles will not have all vehicle
details returned - they will simply be marked "exempt".

Be aware that the API has usage limits. The function will therefore
limit API calls to below 50 per minute - this is the maximum rate before
an API key is required.

## Examples

``` r
# \donttest{
if(curl::has_internet()) {
vrm = c("1RAC","P1RAC")
get_ULEZ(vrm = vrm)
}
#> This script only does 50 vrms per minute at most
#> Warning: TfL ULEZ API is producing some strange results currently
#> 
  |                                                                            
  |                                                                      |   0%
#>     vrm API Status
#> 1  1RAC        404
#> 2 P1RAC        404
# }
```
