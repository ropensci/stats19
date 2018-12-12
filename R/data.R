#' Stats19 schema and variables
#'
#' `stats19_schema` and `stats19_variables` contain
#' metadata on stats19 data.
#' `stats19_schema` is a look-up table matching
#' codes provided in the raw stats19 dataset with
#' character strings.
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
#' File names for easy access
#'
#' URL encoded file names. Generated as follows:
#' Visit URL from Chrome/Firefox
#' https://data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data
#'
#' Enter the browser JavaScript console and run:
#' filenames = []
#' list = document.getElementsByClassName("dgu-datafile")
#' for (var i = 0; i < list.length; i++) {
#'  filenames.push(list[i].firstElementChild.children[0].href.split("/")[4]);
#' }
#' now copy to clipboard
#' copy(filenames)
#'
#' paste into Rstudio and create a vector (file_names)
#' then
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
