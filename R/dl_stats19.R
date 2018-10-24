#' Download Stats19 data
#'
#' @section Details:
#' This convenience function downloads and unzips UK road traffic casualty data.
#' It results in unzipped .csv data in R's temporary directory.
#'
#' Ensure you have a fast internet connection and at least 100 Mb space
#'
#' @param zip_url The url where the data is stored
#' @param data_dir Directory to which to download the file
#' @param exdir Folder where data should be unzipped to
#' @aliases dl_stats19_2015
#' @export
#' @examples
#' \dontrun{
#' dl_stats19_2005_2014()
#'
#' # Load all stats19 datasets
#' ac <- read_stats19_2005_2014_ac()
#' ca <- read_stats19_2005_2014_ca()
#' ve <- read_stats19_2005_2014_ve()
#' # now you can analyse the UK's stats19 data in a single table
#' }
dl_stats19_2005_2014 <- function(
  zip_url = paste0("http://data.dft.gov.uk.s3.amazonaws.com/",
    "road-accidents-safety-data/Stats19_Data_2005-2014.zip"),
  data_dir = ".",
  exdir = "Stats19_Data_2005-2014") {

  # download and unzip the data if it's not present
  destfile <- file.path(data_dir, paste0(exdir, ".zip"))
  data_already_exists <- file.exists(destfile)
  if(data_already_exists) {
    message("Data already exists in data_dir, not downloading")
  } else {
    utils::download.file(zip_url, destfile)
  }
  utils::unzip(destfile, exdir = exdir)

  print(paste0("Data saved at: ",
               list.files(exdir, pattern = "csv", full.names = TRUE
  )))
}
#' @inheritParams dl_stats19_2005_2014
#' @export
dl_stats19_2015 <- function(
  zip_url = paste0("http://data.dft.gov.uk/road-accidents-safety-data/",
  "RoadSafetyData_2015.zip"),
  data_dir = ".",
  exdir = "RoadSafetyData_2015") {

  # download and unzip the data if it's not present
  destfile <- file.path(data_dir, paste0(exdir, ".zip"))
  data_already_exists <- file.exists(destfile)
  if(data_already_exists) {
    message("Data already exists in data_dir, not downloading")
  } else {
    utils::download.file(zip_url, destfile)
  }
  utils::unzip(destfile, exdir = exdir)

  print(paste0("Data saved at: ",
               list.files(exdir, pattern = "csv", full.names = TRUE
               )))
}
