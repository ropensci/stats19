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
dl_stats19_2005_2014 <- function(zip_url = paste0(
  "http://data.dft.gov.uk.s3.amazonaws.com/",
  "road-accidents-safety-data/Stats19_Data_2005-2014.zip"
), data_dir = ".") {

  # download and unzip the data if it's not present
  data_already_exists <- "Accidents0514.csv" %in% list.files(data_dir) |
    file.exists("Stats19_Data_2005-2014.zip") |
    file.exists(file.path(data_dir, "Stats19_Data_2005-2014.zip"))
  if(data_already_exists) {
    stop("Aborting download: data already exists in data_dir")
  }
  destfile <- file.path(data_dir, "Stats19_Data_2005-2014.zip")
  download.file(zip_url, destfile)
  unzip(destfile, exdir = data_dir)

  print(paste0("Data saved at: ", list.files(data_dir,
                                             pattern = "csv", full.names = TRUE
  )))
}
