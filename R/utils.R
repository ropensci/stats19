#' Static values
#' Main location of any changes from upstream
#' On 22nd Nov 2018 tested both
#' http://data.dft.gov.uk/road-accidents-safety-data/road-accidents-safety-data/RoadSafetyData_2015.zip
#' and
#' http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/dftRoadSafety_Accidents_2016
#' both were available from the s3 url below, so decided to make it the
#' main domain URL of the stats19
domain = "http://data.dft.gov.uk.s3.amazonaws.com"
directory = "road-accidents-safety-data"

#' Build the API endpoints
#' @param file_name (Optional) to add to the url returned.
#' @examples
#' \dontrun{
#' get_url()
#' }
get_url = function(file_name = "") {
  path = file.path(get_domain(), get_directory(), file_name)
  path
}

#' Return only the domain
get_domain = function() {
  domain
}

#' Return only the directory
get_directory = function() {
  directory
}

#' Find a file name within stats19::file_names.
#'
#' Currently, there are 52 file names to download data from.
#'
#' @param years Provide a year, part of it or maximum range of two years. Defaults to two years ago.
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents', ignores case.
#'
#' @examples
#' find_file_name(2016)
#' find_file_name(2016, type = "accident")
#' find_file_name(1979)
#' find_file_name(2016:2017)
#' @export
find_file_name = function(years =  as.integer(format(Sys.Date(), "%Y")) - 2,
                          type = "") {
  stopifnot(is.numeric(years))
  file_names_vec = unlist(stats19::file_names, use.names = FALSE)
  index = unlist(lapply(years, function(i) grep(i, file_names_vec,
                                                ignore.case = TRUE)))
  if (length(index) < 1)
    stop("No files of those years exist")
  result = file_names_vec[index]
  result = result[grep(type, result, ignore.case = TRUE)]
  if (length(result) < 1)
    stop("No files of that type exist")
  return(result)
}

#' Locate a file on disk
#'
#' Helper function to locate files. Given below params, the function
#' returns 0 or more files found at location/names given.
#'
#' @param years Provide a year, part of it or maximum range of two years.
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents', ignores case.
#' @param data_dir Super directory where dataset(s) were first downloaded to.
#' @param return If you want the found files returned pass TRUE
#' @param quiet Print out messages (files found)
#'
#' @return Depending on @param return: full path of a single file found, list of directories
#' where data from DfT (stats19::filenames) have been downloaded to or NULL.
#'
#' @examples
#' locate_files(years = 2016)
#' @export
locate_files = function(data_dir = tempdir(),
                        type = "",
                        years = "",
                        return = FALSE,
                        quiet = FALSE) {
  stopifnot(length(years) <= 2)
  # does data_dir exists?
  stopifnot(dir.exists(data_dir))
  # does downloaded directory exists?
  file_names_found = find_file_name(years = years, type = type)
  # see if any of these has been downloaded
  count = length(file_names_found)
  if(count == 1) {
    path = file.path(data_dir, sub(".zip", "", file_names_found))
    if(dir.exists(path)) {
      ls = list.files(path)
      if(length(ls) == 0) {
        if(!quiet)
          message("Destination directory is empty")
      } else {
        if(length(ls) > 1 && !quiet) {
          print(path)
          print("File(s) found: ")
          print(ls)
        }
        # return first file
        # TODO: let user know!
        if(return) return(file.path(path, ls[1])) # first file from ownloaded DfT filename
      }
    } else {
      if(!quiet) {
        message("No files downloaded at: ")
        print(path)
      }
    }
  } else {
    # show list of destination directories & contents and return
    # one found or
    # vector of found downloaded locations in data_dir
    i = 1
    valid_paths = c()
    for (x in file_names_found) {
      path = file.path(data_dir, sub(".zip", "", x))
      if(dir.exists(path)) {
        i = i + 1
        valid_paths = c(valid_paths, path)
        ls = list.files(path)
        if(!quiet) {
          print(path)
          print("File(s) found: ")
          print(ls)
        }
      }
    }
    if(length(valid_paths) > 0 && return) {
      ls = list.files(valid_paths)
      if(length(valid_paths) == 1 && length(ls) == 1) {
        return(file.path(valid_paths, ls)) # return the full path of single file
      } else {
        # TODO: return list of files in the single path?
        return(valid_paths) # return path(s)
      }
      return(NULL)
    }
    if(length(valid_paths) == 0 & !quiet) {
      message("Looks like nothing has been downloaded at: ")
      message(data_dir)
    }
  }
}

#' Pin down a file on disk from four parameters.
#'
#' @param filename Character string of the filename of the .csv to read, if this is given, type and
#' years determin whether there is a target to read, otherwise disk scan would be needed.
#' @param data_dir Where sets of downloaded data would be found.
#' @param years Either a single year or a two year range, defaults to 2 years ago
#' @param type One of: 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents', ignores case.
#'
#' @return One of: path for one file, a message `More than one file found` or NULL
#' @export
#' @examples \dontrun{
#' locate_one_file()
#' locate_one_file(filename = "Cas.csv")
#' }
locate_one_file = function(filename = "",
                           data_dir = tempdir(),
                           years = "",
                           type = "") {
  # see if locate_files can pin it down
  path = locate_files(data_dir = data_dir,
                      type = type,
                      years = years,
                      return = TRUE,
                      quiet = TRUE)
  if(length(path) == 1 && endsWith(path, filename)) { # endsWith("foo/Acc.csv","") or endsWith("foo/Acc.csv", "Acc.csv")
    # got it
    return(path)
  } else {
    # did locate_files returned multiple locations? is there a filename?
    if(length(path) > 1 & endsWith(filename, ".csv")) {
      for (p in path) {
        ls = list.files(p)
        for (file in ls) {
          if(identical(file, filename)) { # matched filename?
            return(file.path(p, file))
          }
        }
      }
    }
  }
  if(length(list.files(path)) > 1) {
    return("More than one file found") # I cannot, give me a filename to match.
  }
  return(NULL)
}

#' Download and unzip given appropriate params
#'
#' Downloads dftRoadSafety_2016_Accidents.zip to /tmp/blahDIR
#' Unzips dftRoadSafety_2016_Accidents.zip to
#' /tmp/blahDIR/dftRoadSafety_2016_Accidents
#' and lists what is in it.
#'
#' @param fname Required zip name also used as destination of csv folder
#' @param zip_url Required full path of file to download
#' @param data_dir Parent directory of fname
download_and_unzip = function(fname, zip_url, data_dir = tempdir()) {
  # download and unzip the data if it's not present
  destfile = file.path(data_dir, paste0(fname, ".zip"))
  data_already_exists = file.exists(destfile)
  if (data_already_exists) {
    message("Data already exists in data_dir, not downloading")
  } else {
    utils::download.file(zip_url, destfile = destfile)
  }
  zipfiles <- utils::unzip(destfile, list = TRUE)$Name
  utils::unzip(destfile, exdir = data_dir)
  invisible(file.remove(destfile))
}
utils::globalVariables(c("stats19_variables", "stats19_schema", "skip"))

# To run download functions you need an internet connection.
# pref a fast one
skip_download = function() {
  connected = !is.null(curl::nslookup("r-project.org", error = FALSE))
  if(!connected | identical(Sys.getenv("DONT_DOWNLOAD_ANYTHING"), "true"))
    skip("No connection to run download function.")
}
