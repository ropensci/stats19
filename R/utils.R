#' Convert file names to urls
#'
#' @param file_name Optional file name to add to the url returned (empty by default)
#' @param domain The domain from where the data will be downloaded
#' @param directory The subdirectory of the url
#' @export
#' @examples
#' # get_url(find_file_name(1985))
get_url = function(file_name = "",
                   domain = "https://data.dft.gov.uk",
                   directory = "road-accidents-safety-data"
                   ) {
  file.path(domain, directory, file_name)
}

#' Find file names within stats19::file_names.
#'
#' @param years Year for which data are to be found
#' @param type One of 'collisions', 'casualty' or
#' 'vehicles' ignores case.
#'
#' @examples
#' find_file_name(2016)
#' @export
find_file_name = function(years = NULL, type = NULL) {
  all_files = unlist(stats19::file_names, use.names = FALSE)
  if(is.null(years)) {
    result = all_files
  } else {
    result = character(0)
    # Handle pre-2020 (all in one file)
    if(any(years < 2020 & years >= 1979)) {
      result = c(result, all_files[grepl("1979-latest", all_files)])
    }
    # Handle individual years 2020-2050
    indiv_years = years[years >= 2020 & years <= 2050]
    for(y in indiv_years) {
      result = c(result, all_files[grepl(as.character(y), all_files) & !grepl("1979|adjust", all_files)])
    }
    # Handle "5 years"
    if(any(years == 5 | years == "5 years")) {
      result = c(result, all_files[grepl("last-5-years", all_files) & !grepl("adjust", all_files)])
    }
  }

  if(!is.null(type)) {
    type_pattern = gsub("cas", "ics-cas", type)
    result = result[grep(type_pattern, result, ignore.case = TRUE)]
    if(length(result) == 0) {
      if(is.null(years)) stop("No files of that type found", call. = FALSE)
      message("No files of that type found for requested years.")
    }
  }

  if(length(result) < 1) message("No files found. Check the stats19 website on data.gov.uk")
  unique(result)
}

#' Locate a file on disk
#' @inheritParams dl_stats19
#' @param quiet Print out messages (files found)
#' @export
locate_files = function(data_dir = get_data_directory(), type = NULL, years = NULL, quiet = FALSE) {
  stopifnot(dir.exists(data_dir))
  file_names = find_file_name(years = years, type = type)
  files_on_disk = file.path(data_dir, file_names)
  files_on_disk[file.exists(files_on_disk)]
}

#' Pin down a file on disk from parameters.
#' @inheritParams locate_files
#' @export
#' @examples
#' \donttest{
#' locate_one_file()
#' }
locate_one_file = function(filename = NULL, data_dir = get_data_directory(), year = NULL, type = NULL) {
  path = locate_files(data_dir = data_dir, type = type, years = year, quiet = TRUE)
  if(length(path) == 0) stop("No files found under: ", data_dir, call. = FALSE)
  if(!is.null(filename)) path = path[grep(filename, path)]
  if(length(path) > 1) return(path[1])
  path
}

utils::globalVariables(
  c("stats19_variables", "stats19_schema", "skip", "accidents_sample",
    "accidents_sample_raw", "casualties_sample", "casualties_sample_raw",
    "vehicles_sample", "vehicles_sample_raw",
    "...1", "...3", "...4", "...5", "BUA22CD", "BUA22NM", "Collision data year", "Motorway",
    "SHAPE", "Severity", "built_up1", "collision_severity", "collision_year", "cost",
    "cost_per_casualty", "cost_per_collision", "costs_millions", "first_road_class",
    "not_built_up", "ons_road", "speed_limit", "urban_or_rural_area"))

#' Generate a phrase for data download purposes
phrase = function() {
  txt = c("Happy to go", "Good to go", "Download now", "Wanna do it")
  paste0(sample(txt, 1), " (y = enter, n = N/other)? ")
}

#' Interactively select from options
select_file = function(fnames) {
  message("Multiple matches. Which do you want to download?")
  fnames[utils::menu(choices = fnames)]
}

#' Get data download dir
#' @export
get_data_directory = function() {
  d = Sys.getenv("STATS19_DOWNLOAD_DIRECTORY")
  if(d != "") return(d)
  tempdir()
}

#' Set data download dir
#' @param data_path valid existing path to save downloaded files in.
#' @export
set_data_directory = function(data_path) {
  if(!dir.exists(data_path)) stop("Directory does not exist, please create it first.")
  
  set_it = function() {
    Sys.setenv(STATS19_DOWNLOAD_DIRECTORY = data_path)
    message("STATS19_DOWNLOAD_DIRECTORY is set, undo with Sys.unsetenv")
  }

  current = Sys.getenv("STATS19_DOWNLOAD_DIRECTORY")
  if(current != "") {
    message("STATS19_DOWNLOAD_DIRECTORY is set, change it?")
    if(interactive()) {
      if(utils::menu(c("Yes", "No!")) == 1L) set_it()
    } else {
      set_it()
      message("Overwrote STATS19_DOWNLOAD_DIRECTORY without asking.")
    }
  } else {
    set_it()
  }
}

# Helper to handle NULL with default
`%||%` = function(a, b) if (!is.null(a)) a else b
