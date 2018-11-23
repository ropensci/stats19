#' Download Stats19 data for a year or range of two years.
#'
#' @section Details:
#' This convenient function downloads and unzips UK road traffic casualty data.
#' It results in unzipped .csv data in R's temporary directory.
#'
#' Ensure you have a fast internet connection and at least 100 Mb space
#'
#' @param years Either a single year or a two year range, defaults to 2 years ago
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents'#' @export
#' @param file_name The file name to download, above two will be ignore.
#' @examples
#' \dontrun{
#' dl_stats19()
#' # now you can analyse the UK's stats19 data in a single table
#' }
dl_stats19 = function(file_name = NULL, years = "", type = "Accidents") {
  # exdir = "Stats19_Data_2005-2014"
  exdir = generate_file_name(years = years, type = type)
  zip_url = get_url(paste0(exdir, ".zip"))
  if(!is.null(file_name)) {
    exdir = file_name
    zip_url = get_url(file_name = file_name)
  }

  message("Your inputs generated:")
  message(exdir)
  message("Will try to ownloaded from: ")
  message(zip_url)
  readline("happy to go (Y = enter, N = esc)?")
  # download and unzip the data if it's not present
  download_and_unzip(zip_url = zip_url, exdir = exdir)
}

#' Download Stats19 data
#'
#' @section Details:
#' This convenience function downloads and unzips UK road traffic casualty data.
#' It results in unzipped .csv data in R's temporary directory.
#'
#' Ensure you have a fast internet connection and at least 100 Mb space
#'
#' @param zip_url The url where the data is stored
#' @param exdir Folder where data should be unzipped to
#' @aliases dl_stats19_2015 dl_stats19_2016_ac dl_stats19_2016_ac dl_stats19_2017_ac
#' @export
#' @examples
#' \dontrun{
#' dl_stats19_2005_2014()
#'
#' # Load all stats19 datasets
#' ac = read_accidents()
#' ca = read_stats19_2005_2014_ca()
#' ve = read_stats19_2005_2014_ve()
#' # now you can analyse the UK's stats19 data in a single table
#' }
dl_stats19_2005_2014 = function(
  zip_url = paste0("http://data.dft.gov.uk.s3.amazonaws.com/",
    "road-accidents-safety-data/Stats19_Data_2005-2014.zip"),
  exdir = "Stats19_Data_2005-2014") {
  download_and_unzip(zip_url = zip_url, exdir = exdir)
}
#' @inheritParams dl_stats19_2005_2014
#' @export
dl_stats19_2015 = function(
  zip_url = paste0("http://data.dft.gov.uk/road-accidents-safety-data/",
  "RoadSafetyData_2015.zip"),
  data_dir = ".",
  exdir = "RoadSafetyData_2015") {

  # download and unzip the data if it's not present
  download_and_unzip(zip_url = zip_url, exdir = exdir)
}
#' @inheritParams dl_stats19_2005_2014
#' @export
dl_stats19_2016_ac = function(
  zip_url = paste0("http://data.dft.gov.uk/road-accidents-safety-data/",
                   "dftRoadSafety_Accidents_2016.zip"),
  data_dir = ".",
  exdir = "dftRoadSafety_Accidents_2016") {

  # download and unzip the data if it's not present
  download_and_unzip(zip_url = zip_url, exdir = exdir)
}
#' @inheritParams dl_stats19_2005_2014
#' @export
dl_stats19_2017_ac = function(
  zip_url = paste0("http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/",
                   "dftRoadSafetyData_Accidents_2017.zip"),
  data_dir = ".",
  exdir = "dftRoadSafetyData_Accidents_2017") {

  # download and unzip the data if it's not present
  download_and_unzip(zip_url = zip_url, exdir = exdir)
}
#' Download stats19 schema
#'
#' This downloads an excel spreadsheet containing variable names and categories
#'
#' @inheritParams dl_stats19_2005_2014
#' @param data_dir Location to download, defaults to `tempdir()`
#' @export
#' @examples \dontrun{
#' dl_schema()
#' }
dl_schema = function(data_dir = tempdir()) {
  u = "http://data.dft.gov.uk/road-accidents-safety-data/Road-Accident-Safety-Data-Guide.xls"
  utils::download.file(u, destfile = file.path(data_dir, "Road-Accident-Safety-Data-Guide.xls"))
  # download and unzip the data if it's not present
}
