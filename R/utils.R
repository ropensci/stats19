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

#' check and convert year argument
#' @inheritParams dl_stats19
check_year = function (year) {
  if (is.null (year) | length (year) > 1)
    stop ("Please specify a single year between 1979 and ",
          format (format(Sys.Date(), "%Y")))
  year = as.numeric (year)
  current_year = as.numeric (format(Sys.Date(), "%Y"))
  if (!year %in% 1979:current_year)
    stop ("Please provide a year between 1979 and ", current_year)

  return (year)
}

#' Find file names within stats19::file_names.
#'
#' Currently, there are 52 file names to download data from.
#'
#' @param years Years for which data are to be found
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents', ignores case.
#'
#' @examples
#' find_file_name(2016)
#' find_file_name(2016, type = "accident")
#' find_file_name(1979)
#' find_file_name(2016:2017)
#' @export
find_file_name = function(years = NULL, type = NULL) {

  years = vapply (years, check_year, numeric (1))
  file_names_vec = unlist(stats19::file_names, use.names = FALSE)
  result = NULL
  # see https://github.com/ITSLeeds/stats19/issues/21
  if (any (years %in% 1979:2004)) {
      result = c (result, file_names_vec [grep ("1979", file_names_vec)])
  }
  if (is.null (years))
      index = seq (file_names_vec)
  else
      index = unlist(lapply(years, function(i) grep(i, file_names_vec,
                                                    ignore.case = TRUE)))
  result = c (result, file_names_vec[index])

  if (!is.null (type))
      result = result[grep(type, result, ignore.case = TRUE)]

  if (length(result) < 1)
    stop("No files of that type exist")

  return (unique (result))
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
#' @return Depending on @param return: full path of a single file found, list of directories
#' where data from DfT (stats19::filenames) have been downloaded to or NULL.
#'
#' @examples
#' locate_files(years = 2016)
#' @export
locate_files = function(data_dir = tempdir(),
                        type = "Accidents",
                        years = NULL,
                        quiet = FALSE) {
  stopifnot(dir.exists(data_dir))
  file_names = find_file_name(years = years, type = type)
  file_names = tools::file_path_sans_ext (file_names)
  dir_files = list.dirs (data_dir)
  files_on_disk = NULL
  # check is any file names match those on disk
  gr = vapply (file_names, function (i) any (grepl (i, dir_files)),
                logical (1))
  if (any (gr)) { # return those on disk which match file names
    gr = names (gr [which (gr)])
    index = vapply (gr, function (i) grepl (i, dir_files),
                     logical (length (dir_files)))
    files_on_disk = dir_files [index]
  }

  return (files_on_disk)
}

#' Pin down a file on disk from four parameters.
#'
#' @param filename Character string of the filename of the .csv to read, if this
#' is given, type and years determin whether there is a target to read,
#' otherwise disk scan would be needed.
#' @param data_dir Where sets of downloaded data would be found.
#' @param year Single year for which file is to be found.
#' @param type One of: 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents', ignores case.
#'
#' @return One of: path for one file, a message `More than one file found` or NULL
#' @export
#' @examples
#' \dontrun{
#' locate_one_file()
#' locate_one_file(filename = "Cas.csv")
#' }
locate_one_file = function(filename = NULL,
                           data_dir = tempdir(),
                           year = NULL,
                           type = "Accidents") {
  year = check_year (year)
  # see if locate_files can pin it down
  path = locate_files(data_dir = data_dir,
                      type = type,
                      years = year,
                      quiet = TRUE)

  if (length (path) == 0)
    stop ("folder not found") # TODO: Delete this?

  scan1 = function (path, type) {
    lf = list.files (path, full.names = TRUE, pattern = ".csv$")
    if (!is.null (type))
      lf = lf [grep (type, lf, ignore.case = TRUE)]
    return (lf)
  }
  res = unlist (lapply (path, function (i) scan1 (i, type)))
  if (!is.null (filename))
    res = res [grep (filename, res)]
  return (res)
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
#' @param data_dir Parent directory of exdir
#' @return Names of file added to `data_dir`
download_and_unzip = function(exdir, zip_url, data_dir = tempdir()) {
  destfile = file.path(data_dir, paste0(exdir, ".zip"))
  data_already_exists = file.exists(destfile)
  if (data_already_exists) {
    message("Data already exists in data_dir, not downloading")
  } else {
    utils::download.file(zip_url, destfile = destfile)
  }
  zipfiles = file.path (destfile, utils::unzip(destfile, list = TRUE)$Name)
  utils::unzip(destfile, exdir = file.path(data_dir, exdir))
  return (zipfiles)
}
utils::globalVariables(c("stats19_variables", "stats19_schema", "skip"))
