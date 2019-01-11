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
#'
#' @export
#' @examples
#' \donttest{
#' dl_stats19(year = 2011, type = "Accidents")
#' ac = read_accidents(year = 2011)
#'
#' dl_stats19(year = 2009, type = "Accidents")
#' ac_2009 = read_accidents(year = 2009)
#' }
read_accidents = function(year = NULL,
                          filename = "",
                          data_dir = tempdir(),
                          format = TRUE) {
  path = check_input_file(
    filename = filename,
    type = "accidents",
    data_dir = data_dir,
    year = year
  )
  message("Reading in: ")
  message(path)
  # read the data in
  suppressWarnings({
    ac = readr::read_csv(
      path,
      col_types = readr::cols(
        .default = readr::col_integer(),
        Accident_Index = readr::col_character(),
        Longitude = readr::col_double(),
        Latitude = readr::col_double(),
        Date = readr::col_character(),
        Time = readr::col_character(),
        `Local_Authority_(Highway)` = readr::col_character(),
        LSOA_of_Accident_Location = readr::col_character()
      )
    )
  })

  if(format)
    return(format_accidents(ac))
  ac
}

#' Read in stats19 road safety data from .csv files downloaded.
#'
#' @section Details:
#' The function returns a data frame, in which each record is a reported vehicle in the
#' STATS19 dataset for the data_dir and filename provided.
#'
#' @inheritParams read_accidents
#'
#' @export
#' @examples
#' \donttest{
#' dl_stats19(year = 2009, type = "vehicles")
#' ve = read_vehicles(year = 2009)
#' }
read_vehicles = function(year = NULL,
                         filename = "",
                         data_dir = tempdir(),
                         format = TRUE) {
  # check inputs
  path = check_input_file(
    filename = filename,
    type = "vehicles",
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
#' @inheritParams read_accidents
#'
#' @export
#' @examples
#' \donttest{
#' dl_stats19(year = 2017, type = "casualties")
#' casualties = read_casualties(year = 2017)
#' }
read_casualties = function(year = NULL,
                           filename = "",
                           data_dir = tempdir(),
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
  if(!is.null (year)) {
    year = check_year(year)
  }
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
    message(path)
    stop("Change data_dir, filename, year or run dl_stats19() first.",
         call. = FALSE)
  }
  return(path)
}

# # informal test
# dl_stats19(year = 2009, type = "vehicles")
# f = "DfTRoadSafety_Vehicles_2009/DfTRoadSafety_Vehicles_2009.csv"
# path = file.path(tempdir(), f)
# read_ve_ca(path)
read_ve_ca = function(path) {
  h = utils::read.csv(path, nrows = 1)
  if(grepl("Accident_Index", names(h)[1])) {
    readr::read_csv(path, col_types = readr::cols(
      .default = readr::col_integer(),
      Accident_Index = readr::col_character()
    ))
  } else {
    x = readr::read_csv(path, col_types = readr::cols(
      .default = readr::col_integer(),
      Acc_Index = readr::col_character()
    ))
    names(x)[names(x) == "Acc_Index"] = "Accident_Index"
    x
  }
}

