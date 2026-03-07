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
#' dl_stats19(year = 2024, type = "collision")
#' ac = read_collisions(year = 2024)
#' }
#' }
read_collisions = function(year = NULL,
                          filename = "",
                          data_dir = get_data_directory(),
                          format = TRUE,
                          silent = FALSE) {
  read_stats19(year = year, filename = filename, data_dir = data_dir, 
               format = format, silent = silent, type = "collision")
}

#' Read in stats19 road safety data from .csv files downloaded.
#'
#' @inheritParams read_collisions
#' @export
read_vehicles = function(year = NULL,
                         filename = "",
                         data_dir = get_data_directory(),
                         format = TRUE) {
  read_stats19(year = year, filename = filename, data_dir = data_dir, 
               format = format, type = "vehicle")
}

#' Read in STATS19 road safety data from .csv files downloaded.
#'
#' @inheritParams read_collisions
#' @export
read_casualties = function(year = NULL,
                           filename = "",
                           data_dir = get_data_directory(),
                           format = TRUE) {
  read_stats19(year = year, filename = filename, data_dir = data_dir, 
               format = format, type = "cas")
}

# Internal helper to handle all stats19 reading
read_stats19 = function(year = NULL,
                        filename = "",
                        data_dir = get_data_directory(),
                        format = TRUE,
                        silent = TRUE,
                        type = "collision") {
  # Set the local edition for readr.
  if (.Platform$OS.type == "windows" && utils::packageVersion("readr") >= "2.0.0") {
    readr::local_edition(1)
  }

  fnames = filename
  if (filename == "" || is.null(filename)) {
    fnames = find_file_name(years = year, type = type)
  }
  
  if (length(fnames) == 0) {
    message("No files found.")
    return(NULL)
  }

  paths = file.path(data_dir, fnames)
  existing_paths = paths[file.exists(paths)]
  
  if (length(existing_paths) == 0) {
    message("Files not found on disk.")
    return(NULL)
  }

  read_one = function(p) {
    if (isFALSE(silent)) message("Reading in: ", p)
    readr::read_csv(p, col_types = col_spec(p), na = c("", "NA", "-1"), show_col_types = FALSE)
  }
  
  # Read and bind
  x_list = lapply(existing_paths, read_one)
  x = dplyr::bind_rows(x_list)
  
  if(format) {
    format_fun = switch(tolower(substr(type, 1, 3)),
                        "col" = format_collisions,
                        "veh" = format_vehicles,
                        "cas" = format_casualties)
    x = format_fun(x)
  }
  
  # Filter by year if requested
  if (!is.null(year) && !identical(year, 5) && !identical(year, "5 years")) {
    year_col = intersect(names(x), c("accident_year", "collision_year"))
    if (length(year_col) > 0) {
      x = x[x[[year_col[1]]] %in% year, ]
    }
  }
  
  x
}

#' Local helper to be reused.
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
  
  if (is.null(path) || length(path) == 0 || !endsWith(path, ".csv") || !file.exists(path)) {
    message(path, " not found")
    message("Try running dl_stats19(), change arguments or try later.")
    return(NULL)
  }
  return(path)
}

# possibly in utils
# Convert the 'type' column to readr's col_type format
convert_to_col_type = function(type) {
  switch(type,
         character = readr::col_character(),
         numeric = readr::col_integer(),
         integer = readr::col_integer(),
         logical = readr::col_logical(),
         date = readr::col_date(),
         datetime = readr::col_datetime(),
         readr::col_guess())
}

col_spec = function(path = NULL) {
  # Create a named list of column types
  unique_vars = unique(stats19::stats19_variables$variable)

  if (!is.null(path)) {
    # Read only the first row to get column names
    header = names(readr::read_csv(path, n_max = 0, show_col_types = FALSE))
    header = format_column_names(header)
    unique_vars = unique_vars[unique_vars %in% header]
  }

  unique_types = sapply(unique_vars, function(v) {
    type = stats19::stats19_variables$type[stats19::stats19_variables$variable == v][1]
    convert_to_col_type(type)
  })

  col_types = stats::setNames(unique_types, unique_vars)
  do.call(readr::cols, col_types)
}
