#' Download STATS19 data for a year
#'
#' @inheritParams read_collisions
#' @param type One of 'collision', 'casualty', 'Vehicle'; defaults to 'collision'.
#' @param ask Should you be asked whether or not to download the files? `TRUE` by default.
#' @param timeout Timeout in seconds for the download if current option is less than
#'   this value. Defaults to 600 (10 minutes).
#'
#' @export
#' @examples
#' \donttest{
#' if (curl::has_internet()) {
#'   # type by default is collisions table
#'   dl_stats19(year = 2022)
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
  
  fnames = file_name %||% find_file_name(years = year, type = type)
  if (length(fnames) == 0) return(NULL)
  
  if (!silent) {
    message("Files identified: ", paste(fnames, collapse = ", "))
  }

  if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)

  for (f in fnames) {
    destfile = file.path(data_dir, f)
    if (file.exists(destfile)) {
      if (!silent) message("Data already exists in data_dir, not downloading: ", f)
      next
    }

    if (interactive() && ask) {
      message("Download ", f, "?")
      resp = readline(phrase())
      if (resp != "" && !grepl("yes|y", resp, ignore.case = TRUE)) next
    }
    
    file_url = get_url(f)
    tryCatch({
      curl::curl_download(file_url, destfile)
      if (!silent) message("Data saved at ", destfile)
    }, error = function(e) {
      message("Failed to download file: ", file_url)
    })
  }
  return(NULL)
}
