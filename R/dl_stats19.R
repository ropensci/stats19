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
#' @param file_name The file name to download, above two will be ignore.
#' @param year Single year for which file is to be downloaded
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents'#'
#' @param data_dir Parent directory for all downloaded files. Defaults to `tempdir()`
#'
#' @export
#' @examples
#' \dontrun{
#' dl_stats19(year = 2017) # interactively select files...
#' # now you can read-in the data
#' dl_stats19(year = 2009)
#' dl_stats19(year = 2009, type = "casualties")
#' dl_stats19(type = "casualties")
#' dl_stats19(year = 1985)
#' }
dl_stats19 = function(year = NULL,
                      type = NULL,
                      data_dir = tempdir(),
                      file_name = NULL) {
  if(!is.null (year)) {
    year = check_year(year)
  }
  if(is.null(file_name)) {
    fnames = find_file_name(years = year, type = type)
    # todo: add menu here...
    if(length(fnames) > 1) {
      if(interactive()) {
        fnames = select_file(fnames)
      } else {
        message("More than one file found, selecting the first.")
        fnames = fnames[1]
      }
    }
    zip_url = get_url(fnames) # no need for the .zip here
  } else {
    fnames = file_name
    zip_url = get_url(file_name = file_name)
  }

  nfiles_found = length(fnames)
  if (length(nfiles_found) == 0) {
    message("For parameters ", "year: ", year, ", type: ", type)
    stop("No results found, please try again")
  }
  message("Files identified: ", paste0(fnames, "\n"))
  if (identical(fnames, "Stats19-Data1979-2004.zip")) {
    # extra warnings
    message("\033[31mThis file is over 240 MB in size.\033[39m")
    message("\033[31mOnce unzipped it is over 1.8 GB.\033[39m")
  }
  message("Attempt downloading from: ")
  message(paste0("   ", zip_url, collapse = "\n"))
  resp = readline(phrase(data_dir))
  if (resp != "") {
   stop("Stopping as requested")
  }

  if (!dir.exists(data_dir)) {
    dir.create(data_dir, recursive = TRUE)
  }


  # download and unzip the data if it's not present
  f = download_and_unzip(
    zip_url = zip_url,
    exdir = sub(".zip", "", fnames),
    data_dir = data_dir
  )
  message("Data saved at ", f)
}

#' Generate a phrase for data download purposes
#' @inheritParams dl_stats19
#' @examples
#' stats19:::phrase(tempdir())
phrase = function(data_dir) {
  if (!dir.exists(data_dir)) {
    message(
      "data_dir \'", data_dir,
      "\' will also be created as it does not exist"
    )
  }
  txt = c(
    "Happy to go",
    "Good to go",
    "Download now",
    "Wanna do it"
  )
  paste0(
    txt [ceiling(stats::runif(1) * length(txt))],
    " (y = enter, n = esc)? "
  )
}
#' Download stats19 schema
#'
#' This downloads an excel spreadsheet containing variable names and categories
#'
#' @inheritParams dl_stats19_2005_2014
#' @param data_dir Location to download, defaults to `tempdir()`
#' @export
#' @examples
#' \dontrun{
#' dl_schema()
#' }
dl_schema = function(data_dir = tempdir()) {
  u = paste0(
    "http://data.dft.gov.uk/road-accidents-safety-data/",
    "Road-Accident-Safety-Data-Guide.xls"
  )
  destfile = file.path(data_dir, "Road-Accident-Safety-Data-Guide.xls")
  utils::download.file(u, destfile = destfile)
  # download and unzip the data if it's not present
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
