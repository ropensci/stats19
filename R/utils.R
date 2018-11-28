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
  stopifnot(length(years) <= 2)
  file_names_vec = unlist(stats19::file_names, use.names = FALSE)
  result = file_names_vec[grep(years[1], file_names_vec, ignore.case = TRUE)]
  if (length(years) == 2) {
    result2 = file_names_vec[grep(years[2], file_names_vec, ignore.case = TRUE)]
    result = c(result, result2)
  }
  return(result[grep(type, result, ignore.case = TRUE)])
}

#' Locate a file on disk
#'
#' Helper function to locate files. Given below params, the function
#' returns 0 or more files found at location/names given.
#'
#' @param years Provide a year, part of it or maximum range of two years.
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents', ignores case.
#' @param data_dir super directory where dataset(s) were first downloaded to.
#'
#' @examples
#' locate_files(years = 2016)
#' @export
locate_files = function(data_dir = tempdir(),
                        type = "",
                        years = "") {
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
      x = list.files(path)
      if(length(x) == 0) {
        message("Destination directory is empty")
      } else {
        return(x)
      }
    } else {
      message("No files downloaded at: ")
      message(path)
    }
  }
  # just show list of destination directories & contents.
  all_empty = TRUE
  downloaded_files_count = 0
  downloaded_file_path = NULL
  for (x in file_names_found) {
    path = file.path(data_dir, sub(".zip", "", x))
    if(dir.exists(path)) {
      all_empty = FALSE
      downloaded_files_count = downloaded_files_count + 1
      print(path)
      lf = list.files(path)
      downloaded_file_path =  file.path(path, lf[1]) # no harm if downloaded_files_count != 1
      print("File(s) found: ")
      print(lf)
    }
  }
  # just in case one is found
  if(downloaded_files_count == 1 && !is.null(downloaded_file_path))
    return(downloaded_file_path)
  if(all_empty) {
    message("Looks like nothing has been downloaded at: ")
    message(data_dir)
  }
}

#' Zip file builder
#' default "dftRoadSafety_Accidents_2016"
#' @param years Either a single year or a two year range, defaults to 2 years ago
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents'
#' @param dft The prefix with the file name 'dft'
#' @param zip Add the '.zip' to the file name? Defaults to `FALSE`
#'
#' @examples
#' \dontrun{
#' generate_file_name()
#' generate_file_name(zip = TRUE)
#' }
generate_file_name = function(years = as.integer(format(Sys.Date(), "%Y")) - 2,
                              type = "Accidents", # keep the A capital
                              dft = "dft",
                              zip = FALSE) {
  if (length(years) == 2 | length(years) == 1) {
    if (length(years) == 2 && as.integer(years[2]) < as.integer(years[1])) {
      years = paste(years[2], years[1], sep = "_")
    } else {
      years = paste(years, collapse = "_") # dont worry about length == 1
    }
  } else {
    stop("stats19 currently only takes two years.")
  }
  z = ""
  if (zip) {
    z = ".zip"
  }
  if (identical(type, "") | is.null(type)) {
    return(sprintf("%sRoadSafety_%s%s", dft, years, z))
  }
  return(sprintf("%sRoadSafety_%s_%s%s", dft, type, years, z))
}

#' Download and unzip given appropriate params
#'
#' Downloads dftRoadSafety_2016_Accidents.zip to /tmp/blahDIR
#' Unzips dftRoadSafety_2016_Accidents.zip to
#' /tmp/blahDIR/dftRoadSafety_2016_Accidents
#' and lists what is in it.
#'
#' @param exdir Required zip name also used as destination of csv folder
#' @param zip_url Required full path of file to download
download_and_unzip = function(exdir, zip_url) {
  # download and unzip the data if it's not present
  data_dir = tempdir()
  destfile = file.path(data_dir, paste0(exdir, ".zip"))
  data_already_exists = file.exists(destfile)
  if (data_already_exists) {
    message("Data already exists in data_dir, not downloading")
  } else {
    utils::download.file(zip_url, destfile = destfile)
  }
  utils::unzip(destfile, exdir = file.path(data_dir, exdir))
  print(paste0(
    "Data saved at: ",
    list.files(
      file.path(data_dir, exdir),
      pattern = "csv",
      full.names = TRUE
    )
  ))
}
utils::globalVariables(c("stats19_variables", "stats19_schema", "skip"))

# To run download functions you need an internet connection.
# pref a fast one
skip_download = function() {
  connected = !is.null(curl::nslookup("r-project.org", error = FALSE))
  if(!connected | identical(Sys.getenv("DONT_DOWNLOAD_ANYTHING"), "true"))
    skip("No connection to run download function.")
}
