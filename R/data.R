#' Stats19 schema and variables
#'
#' `stats19_schema` and `stats19_variables` contain
#' metadata on stats19 data.
#' `stats19_schema` is a look-up table matching
#' codes provided in the raw stats19 dataset with
#' character strings.
#'
#' @note The schema data can be (re-)generated using the script given in the
#' `data-raw` directory.
#'
#' @docType data
#' @keywords datasets
#' @name stats19_schema
#' @aliases stats19_variables
NULL

#' Schema for stats19 data (UKDS)
#'
#' @docType data
#' @keywords datasets
#' @name schema_original
#' @format A data frame
NULL

#' stats19 file names for easy access
#'
#' URL decoded file names. Currently there are 52 file names
#' released by the DfT and the details include
#' how these were obtained and would be kept up to date.
#'
#' The file names were generated as follows:
#'
#' library(rvest)
#' #> Loading required package: xml2
#' library(stringr)
#' page = read_html("https://data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data")
#'
#' r = page %>%
#'   html_nodes("a") %>%       # find all links
#'   html_attr("href") %>%     # get the url
#'   str_subset("\\.zip")
#'
#' dr = c()
#' for(i in 1:length(r)) {
#'   dr[i] = sub("http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/",
#'               "", URLdecode(r[i]))
#'   dr[i] = sub("http://data.dft.gov.uk/road-accidents-safety-data/",
#'               "", dr[i])
#' }
#' file_names = setNames(as.list(file_names), file_names)
#' usethis::use_data(file_names)
#'
#' @docType data
#' @keywords datasets
#' @name file_names
#' @format A named list
NULL

#' Sample of stats19 data (2017 accidents)
#'
#' @examples
#' \dontrun{
#' # Obtained with:
#' dl_stats19(year = 2017, type = "Accide")
#' accidents_2017_raw = read_accidents(year = 2017)
#' set.seed(350)
#' sel = sample(nrow(accidents_2017_raw), 3)
#' accidents_sample_raw = accidents_2017_raw[sel, ]
#' accidents_sample = format_accidents(accidents_sample_raw)
#' }
#' @docType data
#' @keywords datasets
#' @name accidents_sample
#' @aliases accidents_sample_raw
#' @format A data frame
NULL

#' Sample of stats19 data (2017 casualties)
#'
#' @examples
#' \dontrun{
#' # Obtained with:
#' dl_stats19(year = 2017, type = "cas")
#' casualties_2017_raw = read_casualties(year = 2017)
#' set.seed(350)
#' sel = sample(nrow(casualties_2017_raw), 3)
#' casualties_sample_raw = casualties_2017_raw[sel, ]
#' casualties_sample = format_casualties(casualties_sample_raw)
#' }
#' @docType data
#' @keywords datasets
#' @name casualties_sample
#' @aliases casualties_sample_raw
#' @format A data frame
NULL

#' Sample of stats19 data (2017 vehicles)
#'
#' @examples
#' \dontrun{
#' # Obtained with:
#' dl_stats19(year = 2017, type = "veh")
#' vehicles_2017_raw = read_vehicles(year = 2017)
#' set.seed(350)
#' sel = sample(nrow(vehicles_2017_raw), 3)
#' vehicles_sample_raw = vehicles_2017_raw[sel, ]
#' vehicles_sample = format_vehicles(vehicles_sample_raw)
#' }
#' @docType data
#' @keywords datasets
#' @name vehicles_sample
#' @aliases vehicles_sample_raw
#' @format A data frame
NULL

#' Police force boundaries in England (2016)
#'
#' See http://geoportal.statistics.gov.uk/
#'
#' @examples
#' \dontrun{
#' # Obtained with:
#' library(sf)
#' u = paste0("https://opendata.arcgis.com/",
#'   "datasets/3e5a096a8c7c456fb6d3164a3f44b005_3.kml"
#'   )
#' police_boundaries_wgs = read_sf(u)
#' police_boundaries = st_transform(police_boundaries_wgs, 27700)
#' police_boundaries = police_boundaries[c("pfa16cd", "pfa16nm")]
#' }
#' @docType data
#' @keywords datasets
#' @name police_boundaries
#' @format An sf data frame
NULL
