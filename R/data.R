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
#' @aliases file_names_old
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
#' This dataset represents the 43 police forces in England and Wales.
#' These are described on the
#' [Wikipedia page](https://en.wikipedia.org/wiki/List_of_police_forces_of_the_United_Kingdom).
#' on UK police forces.
#'
#' The geographic boundary data were taken from the UK government's
#' official geographic data portal.
#' See http://geoportal.statistics.gov.uk/
#'
#' @note These were generated using the script in the
#' `data-raw` directory (`misc.Rmd` file) in the package's GitHub repo:
#' [github.com/ITSLeeds/stats19](https://github.com/ITSLeeds/stats19).
#' @examples
#' nrow(police_boundaries)
#' police_boundaries[police_boundaries$pfa16nm == "West Yorkshire", ]
#' sf:::plot.sf(police_boundaries)
#' @docType data
#' @keywords datasets
#' @name police_boundaries
#' @format An sf data frame
NULL
