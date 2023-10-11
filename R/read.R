#' Read in STATS19 road safety data from .csv files downloaded.
#'
#' @section Details:
#' This is a wrapper function to access and load stats 19 data in a user-friendly way.
#' The function returns a data frame, in which each record is a reported incident in the
#' STATS19 data.
#'
#' @param filename Character string of the filename of the .csv to read, if this is given, type and
#' years determine whether there is a target to read, otherwise disk scan would be needed.
#' @param data_dir Where sets of downloaded data would be found.
#' @param year Single year for which data are to be read
#' @param format Switch to return raw read from file, default is `TRUE`.
#' @param silent Boolean. If `FALSE` (default value), display useful progress
#'   messages on the screen.
#'
#' @export
#' @examples
#' \donttest{
#' if(curl::has_internet()) {
#' dl_stats19(year = 2019, type = "collision")
#' ac = read_collisions(year = 2019)
#'
#' dl_stats19(year = 2019, type = "collision")
#' ac_2019 = read_collisions(year = 2019)
#' }
#' }
read_collisions = function(year = NULL,
                          filename = "",
                          data_dir = get_data_directory(),
                          format = TRUE,
                          silent = FALSE) {
  # Set the local edition for readr.
  # See https://github.com/ropensci/stats19/issues/205
  if (.Platform$OS.type == "windows" && utils::packageVersion("readr") >= "2.0.0") {
    readr::local_edition(1)
  }

  path = check_input_file(
    filename = filename,
    type = "collision",
    data_dir = data_dir,
    year = year
  )
  if (isFALSE(silent)) {
    message("Reading in: ")
    message(path)
  }
  # read the data in
  suppressWarnings({
    ac = readr::read_csv(path)
  })

  if(format)
    return(format_collisions(ac))
  ac
}

#' Read in stats19 road safety data from .csv files downloaded.
#'
#' @section Details:
#' The function returns a data frame, in which each record is a reported vehicle in the
#' STATS19 dataset for the data_dir and filename provided.
#'
#' @inheritParams read_collisions
#'
#' @export
#' @examples
#' \donttest{
#' if(curl::has_internet()) {
#' dl_stats19(year = 2019, type = "vehicle")
#' ve = read_vehicles(year = 2019)
#' }
#' }
read_vehicles = function(year = NULL,
                         filename = "",
                         data_dir = get_data_directory(),
                         format = TRUE) {
  # check inputs
  path = check_input_file(
    filename = filename,
    type = "vehicle",
    data_dir = data_dir,
    year = year
  )
  ve = read_ve_ca(path = path)
  if(format) {
    return(format_vehicles(ve))
  } else {
    ve
  }
}

#' Read in STATS19 road safety data from .csv files downloaded.
#'
#' @section Details:
#' The function returns a data frame, in which each record is a reported casualty
#' in the STATS19 dataset.
#'
#' @inheritParams read_collisions
#'
#' @export
#' @examples
#' \donttest{
#' if(curl::has_internet()) {
#' dl_stats19(year = 2022, type = "casualty")
#' casualties = read_casualties(year = 2022)
#' }
#' }
read_casualties = function(year = NULL,
                           filename = "",
                           data_dir = get_data_directory(),
                           format = TRUE) {
  path = check_input_file(
    filename = filename,
    type = "cas",
    data_dir = data_dir,
    year = year
  )
  ca = read_ve_ca(path = path)
  if(format)
    return(format_casualties(ca))
  ca
}

#' Local helper to be reused.
#'
#' @param filename Character string of the filename of the .csv to read, if this is given, type and
#' years determine whether there is a target to read, otherwise disk scan would be needed.
#' @param data_dir Where sets of downloaded data would be found.
#' @param year Single year for which data are to be read
#' @param type  The type of file to be downloaded (e.g. 'Accidents', 'Casualties' or
#' 'Vehicles'). Not case sensitive and searches using regular expressions ('acc' will work).
#'
check_input_file = function(filename = NULL,
                            type = NULL,
                            data_dir = NULL,
                            year = NULL) {
  path = locate_one_file(
    type = type,
    filename = filename,
    data_dir = data_dir,
    year = year
  )
  if(identical(path, "More than one csv file found."))
    stop("Multiple files with the same name found.", call. = FALSE)
  # have we NOT found a csv to read?
  if (is.null(path) || length(path) == 0 || !endsWith(path, ".csv")
      || !file.exists(path)) {
    # locate_files malfunctioned or just path returned with no filename
    message(path, " not found")
    message(
      "Try running dl_stats19(), change arguments or try later.",
      call. = FALSE
      )
    return(NULL)
  }
  return(path)
}

read_ve_ca = function(path) {
  # Set the local edition for readr.
  # See https://github.com/ropensci/stats19/issues/205
  if (.Platform$OS.type == "windows" && utils::packageVersion("readr") >= "2.0.0") {
    readr::local_edition(1)
  }
  x = read_null(path)
  x
}

read_null = function(path, ...) {
  if(is.null(path)) return(NULL)
  readr::read_csv(path, ...)
}
