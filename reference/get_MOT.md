# Download vehicle data from the DVSA MOT API using VRM.

Download vehicle data from the DVSA MOT API using VRM.

## Usage

``` r
get_MOT(vrm, apikey)
```

## Arguments

- vrm:

  A list of VRMs as character strings.

- apikey:

  Your API key as a character string.

## Details

This function takes a a character vector of vehicle registrations (VRMs)
and returns vehicle data from MOT records. It returns a data frame of
those VRMs which were successfully used with the DVSA MOT API.

Information on the DVSA MOT API is available here:
https://dvsa.github.io/mot-history-api-documentation/

The DVSA MOT API requires a registration. The function therefore
requires the API key provided by the DVSA. Be aware that the API has
usage limits. The function will therefore limit lists with more than
150,000 VRMs.

## Examples

``` r
# \donttest{
vrm = c("1RAC","P1RAC")
apikey = Sys.getenv("MOTKEY")
if(nchar(apikey) > 0) {
  get_MOT(vrm = vrm, apikey = apikey)
}
# }
```
