#' Import and format UK 'Stats19' road traffic casualty data
#'
#' @section Details:
#' This is a wrapper function to access and load stats 19 data in a user-friendly way.
#' The function returns a data frame, in which each record is a reported incident in the
#' stats19 dataset.
#'
#' Ensure you have a fast internet connection and at least 100 Mb space.
#'
#' @param data_dir Character string representing where the data is stored.
#' If empty, R will attempt to download and unzip the data for you.
#' @param filename Character string of the filename of the .csv to read in - default values
#' are those downloaded from the UK Department for Transport (DfT).
#'
#' @export
#' @examples
#' \dontrun{
#' ac <- read_stats19_2005_2014_ac()
#' }
read_stats19_2005_2014_ac <- function(data_dir = tempdir(), filename = "Accidents0514.csv") {

  if (!filename %in% list.files(data_dir)) {
    stop("No data found. Run dl_stats19*() functions first to download the data.")
  }

  # read the data in
  ac <- readr::read_csv(file.path(data_dir, "Accidents0514.csv"), col_types = readr::cols(
    .default = readr::col_integer(),
    Accident_Index = readr::col_character(),
    Longitude = readr::col_double(),
    Latitude = readr::col_double(),
    Date = readr::col_character(),
    Time = readr::col_character(),
    `Local_Authority_(Highway)` = readr::col_character(),
    LSOA_of_Accident_Location = readr::col_character()
  ))

  # format ac data
  ac <- format_stats19_ac(ac)

  ac
}
