#' Download STATS19 data for a year
#'
#' @section Details:
#' This function downloads and unzips UK road crash data.
#' It results in unzipped .csv files that are put
#' in the temporary directory specified by `get_data_directory()` or provided `data_dir`.
#'
#' The file downloaded would be for a specific year (e.g. 2022).
#' It could also be a file containing data for a range of two (e.g. 2005-2014).
#'
#' The `dl_*` functions can download many MB of data so ensure you
#' have a sufficient internet access and hard disk space.
#'
#' @seealso [get_stats19()]
#'
#' @param file_name The file name (DfT named) to download.
#' @param year A year matching file names on the STATS19
#' [data release page](https://www.data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data)
#'  e.g. `2020`
#' @param type One of 'collision', 'casualty', 'Vehicle'; defaults to 'collision'.
#' This text string is used to match the file names released by the DfT.
#' @param data_dir Parent directory for all downloaded files. Defaults to `tempdir()`.
#' @param ask Should you be asked whether or not to download the files? `TRUE` by default.
#' @param silent Boolean. If `FALSE` (default value), display useful progress
#'   messages on the screen.
#' @param timeout Timeout in seconds for the download if current option is less than
#'   this value. Defaults to 600 (10 minutes).
#'
#' @export
#' @examples
#' \donttest{
#' if (curl::has_internet()) {
#'   # type by default is collisions table
#'   dl_stats19(year = 2022)
#'   # with type as casualty
#'   dl_stats19(year = 2022, type = "casualty")
#'   # try another year
#'   dl_stats19(year = 2018)
#' }
#' }
dl_stats19 = function(year = NULL,
                       type = NULL,
                       data_dir = get_data_directory(),
                       file_name = NULL,
                       ask = FALSE,
                       silent = FALSE,
                       timeout = 600) {
  current_timeout = getOption("timeout")
  if (current_timeout < timeout) {
    options(timeout = timeout)
    on.exit(options(timeout = current_timeout))
  }
  if (is.null(file_name)) {
    fnames = find_file_name(years = year, type = type)
    nfiles_found = length(fnames)
    many_found = nfiles_found > 1
    if (many_found) {
      if (interactive()) {
        fnames = select_file(fnames)
      } else {
        if (isFALSE(silent)) {
          message("More than one file found, selecting the first.")
        }
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

  if (isFALSE(silent)) {
    message("Files identified: ", paste0(fnames, "\n"))
    message(paste0("   ", zip_url, collapse = "\n"))
  }

  if (!dir.exists(data_dir)) {
    dir.create(data_dir, recursive = TRUE)
  }

  exdir = sub(".zip", "", fnames)
  destfile = file.path(data_dir, paste0(exdir))
  data_already_exists = file.exists(destfile)
  if (data_already_exists) {
    if (isFALSE(silent)) {
      message("Data already exists in data_dir, not downloading")
    }
  } else {
    if (interactive() && !many_found) {
      if (ask) {
        resp = readline(phrase())
      } else {
        resp = ""
      }
      if (resp != "" &
        !grepl(
          pattern = "yes|y",
          x = resp,
          ignore.case = TRUE
        )) {
        stop("Stopping as requested", call. = FALSE)
      }
    }
    if (isFALSE(silent)) {
      message("Attempt downloading from: ", zip_url)
    }
    # Save to tempfile first, to avoid partial downloads
    tmp_file = tempfile()
    utils::download.file(zip_url, tmp_file, quiet = silent)
    file.rename(tmp_file, destfile)
    if (isFALSE(silent)) {
      message("Data saved at ", destfile)
    }
    return(NULL)
  }
}
