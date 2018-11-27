#' Import and Stats19 data on road traffic casualties
#'
#' @section Details:
#' This is a wrapper function to access and load stats 19 data in a user-friendly way.
#' The function returns a data frame, in which each record is a reported incident in the
#' stats19 dataset.
#'
#'
#' @param data_dir Character string representing where the data is stored.
#' Default value assumes in recent session `tempdir` there is
#' a `dftRoadSafetyData_Accidents_2017` directory.
#' @param filename Character string of the filename of the .csv to read in - default values
#' are those downloaded from the UK Department for Transport (DfT).
#' Default value is `Acc.csv` under above default `data_dir`.
#'
#' @export
#' @examples
#' \dontrun{
#' ac = read_accidents()
#' }
read_accidents = function(data_dir = file.path(tempdir(), "dftRoadSafetyData_Accidents_2017"),
                          filename = "Acc.csv") {

  if (!filename %in% list.files(data_dir)) {
    stop("No data found. Change data_dir or Run dl_stats19*() functions first.")
  }

  # read the data in
  ac = readr::read_csv(file.path(data_dir, filename), col_types = readr::cols(
    .default = readr::col_integer(),
    Accident_Index = readr::col_character(),
    Longitude = readr::col_double(),
    Latitude = readr::col_double(),
    Date = readr::col_character(),
    Time = readr::col_character(),
    `Local_Authority_(Highway)` = readr::col_character(),
    LSOA_of_Accident_Location = readr::col_character()
  ))

  ac

}

#' Import and Stats19 data on vehicles
#'
#' @section Details:
#' The function returns a data frame, in which each record is a reported vehicle in the
#' stats19 dataset for the data_dir and filename provided.
#'
#'
#' @param data_dir Character string representing where the data is stored.
#' If empty, R will attempt to download and unzip the data for you.
#' @param filename Character string of the filename of the .csv to read in - default value
#' is `Veh.csv` from default data_dir
#'
#' @export
#' @examples
#' \dontrun{
#' ve = read_vehicles()
#' }
read_vehicles = function(data_dir = file.path(tempdir(), "dftRoadSafetyData_Vehicles_2017"),
                          filename = "Veh.csv") {

  if (!filename %in% list.files(data_dir)) {
    stop("No data found. Change data_dir or Run dl_stats19*() functions first.")
  }

  # read the data in
  ve = readr::read_csv(file.path(data_dir, filename), col_types = readr::cols(
    .default = readr::col_integer(),
    Accident_Index = readr::col_character()
  ))
  ve
}
