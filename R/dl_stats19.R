#' Download Stats19 data for a year or range of two years.
#'
#' @section Details:
#' This convenience function downloads and unzips UK road crash data.
#' It results in unzipped .csv files that are put
#' in the temporary directory specified by `tempdir()`.
#'
#' If you move the files into your current working directory
#' and run the same command again, the file will not
#' downloaded.
#'
#' The `dl_*` functions can download many MB of data so ensure you
#' have a sufficient internet access and hard disk space.
#'
#' @param years Either a single year or a two year range, defaults to 2 years ago
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents'#' @export
#' @param file_name The file name to download, above two will be ignore.
#' @export
#' @examples
#' \dontrun{
#' dl_stats19(years = 2017) # interactively select files...
#'
#' # now you can read-in the data
#' dl_stats19(years = 2004)
#' }
dl_stats19 = function(file_name = NULL, years = "", type = "") {
  error = FALSE
  exdir = find_file_name(years = years, type = type)
  zip_url = get_url(exdir) # no need for the .zip here
  if(!is.null(file_name)) {
    exdir = file_name
    zip_url = get_url(file_name = file_name)
  }
  files_found = length(exdir)
  if(files_found >= 1) {
    if(files_found > 5) {
      message("Too many files found, here are first 6.")
      print(exdir[1:6])
      message("Please copy one into dl_stats19 or try again")
      error = TRUE
    } else if(files_found != 1) {
      # choose one
      message("More than one file found:")
      message("Please corresponding file number: ")
      for(i in 1:files_found){
        message(sprintf("[%d] %s", i, exdir[i]))
      }
      number = as.numeric(readline("1 - 5: "))
      if(is.na(number) | number < 1 | number > 5) {
        message("You made an invalid choice")
        error = TRUE
      }
      exdir = exdir[number]
      # reassign
      zip_url = get_url(exdir) # no need for the .zip here
    }
    # happy
  }
  if(files_found == 0) {
    message("For parameters: ")
    if(!identical(years, "") & !is.null(years) & !is.na(years)) {
      print(paste0("years: ", years))
    }
    if(!identical(type, "") & !is.null(type) & !is.na(years)) {
      print(paste0("type: ", type))
    }
    message("No results found, please try again")
    error = TRUE
  }
  if(!error) {
    # we now have one
    message("File to download:")
    message(exdir)
    message("Attempt downloading from: ")
    message(zip_url)
    readline("happy to go (Y = enter, N = esc)?")
    # download and unzip the data if it's not present
    download_and_unzip(zip_url = zip_url, exdir = sub(".zip", "", exdir))
  }
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
