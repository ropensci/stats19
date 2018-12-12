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
# work in progress:
# Example stats19 data file
#
# The data was created using the xcv rust program (see vignette for details).
# The raw csv file is stored as `ac_2005_2014_100.csv`
# @rdname ac_2005_2014_100
# "ac_2005_2014_100"
