#' Download STATS19 data for a year or range of two years.
#'
#' @section Details:
#' This function downloads and unzips UK road crash data.
#' It results in unzipped .csv files that are put
#' in the temporary directory specified by `tempdir()` or provided `data_dir`.
#'
#' The file downloaded would be for a specific year (e.g. 2017).
#' It could also be a file containing data for a range of two (e.g. 2005-2014).
#'
#' The `dl_*` functions can download many MB of data so ensure you
#' have a sufficient internet access and hard disk space.
#'
#' @seealso [get_stats19()]
#'
#' @param file_name The file name (DfT named) to download.
#' @param year Single year for which file is to be downloaded.
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents'.
#' Or any variation of to search the file names with such as "acc" or "accid".
#' @param data_dir Parent directory for all downloaded files. Defaults to `tempdir()`.
#' @param ask Should you be asked whether or not to download the files? `TRUE` by default.
#'
#' @export
#' @examples
#' \donttest{
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
                      file_name = NULL,
                      ask = FALSE
                      ) {
  if(!is.null (year)) {
    year = check_year(year)
  }
  if(is.null(file_name)) {
    fnames = find_file_name(years = year, type = type)
    nfiles_found = length(fnames)
    many_found = nfiles_found > 1
    if(many_found) {
      if(interactive()) {
        fnames = select_file(fnames)
      } else {
        message("More than one file found, selecting the first.")
        fnames = fnames[1]
      }
    }
    zip_url = get_url(fnames)
  } else {
    many_found = FALSE
    fnames = file_name
    nfiles_found = length(fnames)
    zip_url = get_url(file_name = file_name)
  }

  message("Files identified: ", paste0(fnames, "\n"))
  message(paste0("   ", zip_url, collapse = "\n"))
  if (!dir.exists(data_dir)) {
    dir.create(data_dir, recursive = TRUE)
  }

  is_zip_file = grepl(pattern = "zip", zip_url)
  exdir = sub(".zip", "", fnames)
  if(is_zip_file) {
    destfile = file.path(data_dir, paste0(exdir, ".zip"))
  } else {
    destfile = file.path(data_dir, paste0(exdir))
  }
    data_already_exists = file.exists(destfile)
    if(data_already_exists) {
      message("Data already exists in data_dir, not downloading")
    } else {
      if(interactive() & !many_found) {
        if(ask) {
          resp = readline(phrase())
        } else {
          resp = ""
        }
        if (resp != "" & !grepl(pattern = "yes|y", x = resp, ignore.case = TRUE)) {
          stop("Stopping as requested", call. = FALSE)
        }
      }
      message("Attempt downloading from: ")
      utils::download.file(zip_url, destfile = destfile)
    }
    if(is_zip_file) {
      f = file.path(destfile, utils::unzip(destfile, list = TRUE)$Name)
      utils::unzip(destfile, exdir = file.path(data_dir, exdir))
      message("Data saved at ", sub(".zip", "",f))
    } else {
      message("Data saved at ", destfile)
    }
}
