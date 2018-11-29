#' Import and Stats19 data on road traffic casualties
#'
#' @section Details:
#' This is a wrapper function to access and load stats 19 data in a user-friendly way.
#' The function returns a data frame, in which each record is a reported incident in the
#' stats19 dataset.
#'
#' @param filename Character string of the filename of the .csv to read, if this is given, type and
#' years determin whether there is a target to read, otherwise disk scan would be needed.
#' @param data_dir Where sets of downloaded data would be found.
#' @param years Either a single year or a two year range, defaults to 2 years ago
#'
#' @export
#' @examples
#' \dontrun{
#' ac = read_accidents()
#' }
read_accidents = function(filename = "",
                          data_dir = tempdir(),
                          years = "") {
  path = locate_one_file(
    # type = "accidents", # default
    filename = filename,
    data_dir = data_dir,
    years = years
  )
  # have we NOT found a csv to read?
  if (!endsWith(path, ".csv") | !file.exists(path)) {
    # locate_files malfunctioned or just foo/bar path returned with no filename
    message(path)
    stop("Change data_dir, filename, years or run dl_stats19() first.")
  }

  # read the data in
  ac = readr::read_csv(path, col_types = readr::cols(
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
#' Import and Stats19 data on casualties
#'
#' @section Details:
#' The function returns a data frame, in which each record is a reported casualty
#' in the stats19 dataset.
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
#' dl_stats19(years = 2017, type = "casualties")
#' casualties = read_casualties()
#' }
read_casualties = function(data_dir = file.path(tempdir(), "dftRoadSafetyData_Casualties_2017"),
                         filename = "Cas.csv") {

  if (!filename %in% list.files(data_dir)) {
    stop("No data found. Change data_dir or Run dl_stats19*() functions first.")
  }

  # read the data in
  ca = readr::read_csv(file.path(data_dir, filename), col_types = readr::cols(
    .default = readr::col_integer(),
    Accident_Index = readr::col_character()
  ))
  ca
}
