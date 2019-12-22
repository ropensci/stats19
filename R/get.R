#' Download, read and format STATS19 data in one function.
#'
#' @section Details:
#' This function utilizes `dl_stats19` and `read_*` functions
#' and retuns a df. The file downloaded would be for a specific year (e.g 2017).
#'
#' As this function uses `dl_stats19` function, it can download
#' many MB of data so ensure you have a sufficient disk space.
#'
#' @seealso [dl_stats19()]
#' @seealso [read_accidents()]
#' @inheritParams dl_stats19
#' @param format Switch to return raw read from file, default is `TRUE`.
#' @param output_format Possible values are c("tibble", "sf").
#' See details and examples
#' @param ... Other arguments that should be passed to output_format functions.
#' See details and examples
#'
#' @export
#' @examples
#' \donttest{
#' get_stats19(year = 2017)
#' get_stats19(year = 2009)
#' }
get_stats19 = function(year = NULL,
                      type = "accidents",
                      data_dir = tempdir(),
                      file_name = NULL,
                      format = TRUE,
                      ask = FALSE,
                      output_format = "tibble",
                      ...) {
  if(!exists("type")) {
    stop("Type is required", call. = FALSE)
  }
  # download what the user wanted
  dl_stats19(year = year,
             type = type,
             data_dir = data_dir,
             file_name = file_name,
             ask = ask)
  read_in = NULL
  # what did the user want?
  if(grepl(type, "vehicles",  ignore.case = TRUE)){
    read_in = read_vehicles(
      year = year,
      data_dir = data_dir,
      format = format)
  } else if(grepl(type, "casualties", ignore.case = TRUE)) {
    read_in = read_casualties(
      year = year,
      data_dir = data_dir,
      format = format)
  } else { # inline with type = "accidents" by default
    read_in = read_accidents(
      year = year,
      data_dir = data_dir,
      format = format)
  }

  # transform read_in into the desired format
  if (output_format != "tibble") {
    read_in = switch(
      output_format,
      "sf" = format_sf(read_in, ...)
    )
  }
  read_in
}
