#' Stats19 schema and variables
#'
#' `stats19_schema` and `stats19_variables` contain
#' metadata on \pkg{stats19} data.
#' `stats19_schema` is a look-up table matching
#' codes provided in the raw stats19 dataset with
#' character strings.
#'
#' @note The schema data can be (re-)generated using the script in the
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
#' released by the DfT (Department for Transport) and the details include
#' how these were obtained and would be kept up to date.
#'
#' @note These were generated using the script in the
#' `data-raw` directory (`misc.Rmd` file).
#'
#' @examples
#' \dontrun{
#'  length(file_names)
#'  file_names$dftRoadSafetyData_Vehicles_2017.zip
#' }
#' @docType data
#' @keywords datasets
#' @name file_names
#' @format A named list
NULL

#' Sample of stats19 data (2017 accidents)
#'
#' @note These were generated using the script in the
#' `data-raw` directory (`misc.Rmd` file).
#'
#' @examples
#' \donttest{
#' nrow(accidents_sample_raw)
#' accidents_sample_raw
#' }
#' @docType data
#' @keywords datasets
#' @name accidents_sample
#' @aliases accidents_sample_raw
#' @format A data frame
NULL

#' Sample of stats19 data (2017 casualties)
#'
#' @note These were generated using the script in the
#' `data-raw` directory (`misc.Rmd` file).
#'
#' @examples
#' \donttest{
#' nrow(casualties_sample_raw)
#' casualties_sample_raw
#' }
#' @docType data
#' @keywords datasets
#' @name casualties_sample
#' @aliases casualties_sample_raw
#' @format A data frame
NULL

#' Sample of stats19 data (2017 vehicles)
#'
#' @note These were generated using the script in the
#' `data-raw` directory (`misc.Rmd` file).
#'
#' @examples
#' \donttest{
#' nrow(vehicles_sample_raw)
#' vehicles_sample_raw
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
#' @note These were generated using the script in the
#' `data-raw` directory (`misc.Rmd` file).
#' @examples
#' \donttest{
#' nrow(police_boundaries)
#' police_boundaries[police_boundaries$pfa16nm == "West Yorkshire", ]
#' }
#' @docType data
#' @keywords datasets
#' @name police_boundaries
#' @format An sf data frame
NULL
