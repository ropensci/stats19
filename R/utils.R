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
#' @example
#' find_file_name(2016)
#' find_file_name(2005)
#' find_file_name(2016:2017)
#' @export
find_file_name = function(years = "2016", type = "") {
  stopifnot(length(years) <= 2)
  file_names_vec = unlist(stats19::file_names, use.names = FALSE)
  result = file_names_vec[grep(years[1], file_names_vec, ignore.case = TRUE)]
  if (length(years) == 2) {
    result2 = file_names_vec[grep(years[2], file_names_vec, ignore.case = TRUE)]
    result = c(result, result2)
  }
  return(result)
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
utils::globalVariables(c("stats19_variables", "stats19_schema"))
