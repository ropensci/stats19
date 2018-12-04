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
#' @param years Either a single year or a two year range, defaults to 2 years ago
#' @param type One of 'Accidents', 'Casualties', or 'Vehicles' in any
#' umambiguous form, so just 'a', 'c', or 'v' will suffice.
#' @param data_dir Parent directory for all downloaded files. Defaults to `tempdir()`
#'
#' @export
#' @examples
#' \dontrun{
#' dl_stats19(years = 2017) # interactively select files...
#'
#' # now you can read-in the data
#' dl_stats19(years = 2004)
#' }
dl_stats19 = function(file_name = NULL, years = 2017, type = "acc", data_dir = tempdir()) {
  type = convert_type_param(type)

  if (is.null(file_name)) {
    fnames = find_file_name(years = years, type = type)
    zip_url = get_url(fnames) # no need for the .zip here
  } else {
    fnames = file_name
    zip_url = get_url(file_name = file_name)
  }
  nfiles_found = length(fnames)
  if(length(nfiles_found) == 0) {
    message("For parameters: ")
    if(!identical(years, "") & !is.null(years) & !is.na(years)) {
      print(paste0("years: ", years))
    }
    if(!identical(type, "") & !is.null(type) & !is.na(years)) {
      print(paste0("type: ", type))
    }
    stop("No results found, please try again")
  }
  pl <- ""
  if(length(fnames) > 1)
    pl <- "s"
  message(paste0("File", pl, " to download:"))
  message(paste0("   ", fnames, collapse = "\n"))
  message("Attempt downloading from: ")
  message(paste0("   ", zip_url, collapse = "\n"))
  resp = readline(phrase(data_dir))
  if (tolower (substr (resp, 1, 1)) != "y")
    stop("Stopping as requested")

  if (!dir.exists (data_dir))
    dir.create (data_dir, recursive = TRUE)
  # download and unzip the data if it's not present
  for (i in seq (zip_url))
    download_and_unzip(zip_url = zip_url[i],
                       fname = tools::file_path_sans_ext(fnames[i]),
                       data_dir = data_dir)
  message ("Data saved at:\n",
           paste0 ("   ", list.files (data_dir, full.names = TRUE),
                   collapse = "\n"))
}

phrase <- function(data_dir)
{
  if (!dir.exists (data_dir))
    message ("data_dir \'", data_dir,
             "\' will also be created as it does not exist")
  txt <- c ("Happy to go",
            "Good to go",
            "Download now",
            "Wanna do it")
  paste0 (txt [ceiling (runif (1) * length(txt))],
          " (y = enter, n = esc)? ")
}

# convert 'type' parameter is any form to text as given on official file names:
convert_type_param <- function(type)
{
  types = c("a", "c", "v")
  type = match.arg(substring (tolower(type), 1, 1), types)
  c("Accidents", "Casualties", "Vehicles") [match(type, types)]
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
  u = paste0(
    "http://data.dft.gov.uk/road-accidents-safety-data/",
    "Road-Accident-Safety-Data-Guide.xls"
  )
  destfile = file.path(data_dir, "Road-Accident-Safety-Data-Guide.xls")
  utils::download.file(u, destfile = destfile)
  # download and unzip the data if it's not present
}
