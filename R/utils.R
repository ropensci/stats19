#' Convert file names to urls
#'
#' @details
#' This function returns urls that allow data to be downloaded from the pages:
#'
#' https://data.dft.gov.uk/road-accidents-safety-data/RoadSafetyData_2015.zip
#'
#' Last updated: October 2020.
#' Files available from the s3 url in the default `domain` argument.
#'
#' @param file_name Optional file name to add to the url returned (empty by default)
#' @param domain The domain from where the data will be downloaded
#' @param directory The subdirectory of the url
#' @examples
#' # get_url(find_file_name(1985))
get_url = function(file_name = "",
                   domain = "https://data.dft.gov.uk",
                   directory = "road-accidents-safety-data"
                   ) {
  path = file.path(domain, directory, file_name)
  path
}

# current_year()
current_year = function() as.integer(format(format(Sys.Date(), "%Y")))

#' Find file names within stats19::file_names.
#'
#' Currently, there are 52 file names to download/read data from.
#'
#' @param years Year for which data are to be found
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents', ignores case.
#'
#' @examples
#' find_file_name(2016)
#' find_file_name(2016, type = "accident")
#' find_file_name(1985, type = "accident")
#' find_file_name(type = "cas")
#' find_file_name(type = "accid")
#' find_file_name(2016:2017) # warning when multiple years requested
#' @export
find_file_name = function(years = NULL, type = NULL) {
  result = unlist(stats19::file_names, use.names = FALSE)
  if(!is.null(years)) {
    if(min(years) >= 2016) {
      result = result[!grepl(pattern = "1979", x = result)]
    }
    result = result[!grepl(pattern = "adjust", x = result)]
    result = result[grepl(pattern = years, x = result)]
    }

  # see https://github.com/ITSLeeds/stats19/issues/21
  if(!is.null(type)) {
    type = gsub(pattern = "cas", replacement = "ics-cas", x = type)
    result_type = result[grep(pattern = type, result, ignore.case = TRUE)]
    if(length(result_type) > 0) {
      result = result_type
    } else {
      if(is.null(years)) {
       stop("No files of that type found", call. = FALSE)
      } else {
        message("No files of that type found for that year.")
      }
    }
  }

  if(length(result) < 1) {
    message("No files found. Check the stats19 website on data.gov.uk")
  }
  unique(result)
}

#' Locate a file on disk
#'
#' Helper function to locate files. Given below params, the function
#' returns 0 or more files found at location/names given.
#'
#' @param years Years for which data are to be found
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents', ignores case.
#' @param data_dir Super directory where dataset(s) were first downloaded to.
#' @param quiet Print out messages (files found)
#'
#' @return Character string representing the full path of a single file found,
#' list of directories where data from the Department for Transport
#' (stats19::filenames) have been downloaded, or NULL if no files were found.
#'
locate_files = function(data_dir = get_data_directory(),
                        type = NULL,
                        years = NULL,
                        quiet = FALSE) {
  stopifnot(dir.exists(data_dir))
  file_names = find_file_name(years = years, type = type)
  if(all(grepl(pattern = "csv", file_names))) {
    return(file.path(data_dir, file_names))
  }
  file_names = tools::file_path_sans_ext(file_names)
  dir_files = list.dirs(data_dir)
  # check is any file names match those on disk
  files_on_disk = vapply(file_names, function(i) any(grepl(i, dir_files)),
                logical(1))
  if(any(files_on_disk)) { # return those on disk which match file names
    files_on_disk = names(files_on_disk[files_on_disk])
  }
  return(files_on_disk)
}

#' Pin down a file on disk from four parameters.
#'
#' @param filename Character string of the filename of the .csv to read, if this
#' is given, type and years determine whether there is a target to read,
#' otherwise disk scan would be needed.
#' @param data_dir Where sets of downloaded data would be found.
#' @param year Single year for which file is to be found.
#' @param type One of: 'Accidents', 'Casualties', 'Vehicles'; ignores case.
#'
#' @return One of: path for one file, a message `More than one file found` or error if none found.
#' @export
#' @examples
#' \donttest{
#' locate_one_file()
#' locate_one_file(filename = "Cas.csv")
#' }
locate_one_file = function(filename = NULL,
                           data_dir = get_data_directory(),
                           year = NULL,
                           type = NULL) {
  # see if locate_files can pin it down
  # browser()
  path = locate_files(data_dir = data_dir,
                      type = type,
                      years = year,
                      quiet = TRUE)
  if(length(path) == 0) {
    stop("No files found under: ", data_dir, call. = FALSE)
  }
  # Test if path points to a single existing CSV file. See
  # https://github.com/ropensci/stats19/issues/197 for more details.
  if (length(path) == 1 && file.exists(path) && tools::file_ext(path) == "csv") {
    return(path)
  }
  scan1 = function(path, type) {
    lf = list.files(file.path(data_dir, path), ".csv$", full.names = TRUE)
    if(!is.null(type))
      lf = lf [grep(type, lf, ignore.case = TRUE)]
    return(lf)
  }
  res = unlist(lapply(path, function(i) scan1(i, type)))
  if(!is.null(filename))
    res = res [grep(filename, res)]
  if(length(res) > 1)
    return("More than one csv file found.")
  return(res)
}
utils::globalVariables(
  c("stats19_variables", "stats19_schema", "skip", "accidents_sample",
    "accidents_sample_raw", "casualties_sample", "casualties_sample_raw",
    "vehicles_sample", "vehicles_sample_raw"))
#' Generate a phrase for data download purposes
#' @examples
#' stats19:::phrase()
phrase = function() {
  txt = c(
    "Happy to go",
    "Good to go",
    "Download now",
    "Wanna do it"
  )
  paste0(
    txt [ceiling(stats::runif(1) * length(txt))],
    " (y = enter, n = N/other)? "
  )
}

#' Interactively select from options
#' @param fnames File names to select from
#' @examples
#' # fnames = c("f1", "f2")
#' # stats19:::select_file(fnames)
select_file = function(fnames) {
  message("Multiple matches. Which do you want to download?")
  selection = utils::menu(choices = fnames)
  fnames[selection]
}

#' Get data download dir
#' @examples
#' # get_data_directory()
get_data_directory = function() {
  data_directory = Sys.getenv("STATS19_DOWNLOAD_DIRECTORY")
  if(data_directory != "") {
    return(data_directory)
  }
  tempdir()
}

#' Set data download dir
#'
#' Handy function to manage `stats19` package underlying environment
#' variable. If run interactively it makes sure user does not change
#' directory by mistatke.
#'
#' @param data_path valid existing path to save downloaded files in.
#' @examples
#' # set_data_directory("MY_PATH")
set_data_directory = function(data_path) {
  force(data_path)
  set_it = function() {
    Sys.setenv(STATS19_DOWNLOAD_DIRECTORY= data_path)
    message("STATS19_DOWNLOAD_DIRECTORY is set, undo with Sys.unsetenv")
  }

  if(!dir.exists(data_path)) {
    stop("Directory does not exist, please create it first.")
    # TODO: check write permissions?
  }
  data_directory = Sys.getenv("STATS19_DOWNLOAD_DIRECTORY")
  if(data_directory != "") {
    message("STATS19_DOWNLOAD_DIRECTORY is set, change it?")
    if(interactive()) {
      c = utils::menu(sample(c("Yes", "No!")))
      if(c == 1L) {
        set_it()
      }
    } else {
      Sys.setenv(STATS19_DOWNLOAD_DIRECTORY= data_path)
      message("Overwrote STATS19_DOWNLOAD_DIRECTORY without asking.")
    }
  } else {
    set_it()
  }
}
