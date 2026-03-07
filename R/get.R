#' Download, read and format STATS19 data in one function.
#'
#' @section Details:
#' This function gets STATS19 data. Behind the scenes it uses
#' `dl_stats19()` and `read_*` functions, returning a
#' `tibble` (default), `data.frame`, `sf` or `ppp` object, depending on the
#' `output_format` parameter.
#'
#' By default, stats19 downloads files to a temporary directory.
#' You can change this behavior to save the files in a permanent directory.
#' This is done by setting the `STATS19_DOWNLOAD_DIRECTORY` environment variable.
#' A convenient way to do this is by adding `STATS19_DOWNLOAD_DIRECTORY=/path/to/a/dir`
#' to your `.Renviron` file, which can be opened with `usethis::edit_r_environ()`.
#'
#' The function returns data for a specific year (e.g. `year = 2022`)
#'
#' Note: for years before 2016 the function may return data from more years than are
#' requested due to the nature of the files hosted at
#' [data.gov.uk](https://www.data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-accidents-safety-data).
#'
#' As this function uses `dl_stats19` function, it can download many MB of data,
#' so ensure you have a sufficient disk space.
#'
#' If `output_format = "data.frame"` or `output_format = "sf"` or `output_format
#' = "ppp"` then the output data is transformed into a data.frame, sf or ppp
#' object using the [as.data.frame()] or [format_sf()] or [format_ppp()]
#' functions, as shown in the examples.
#'
#' @seealso [dl_stats19()]
#' @seealso [read_collisions()]
#'
#' @inheritParams dl_stats19
#' @param format Switch to return raw read from file, default is `TRUE`.
#' @param output_format A string that specifies the desired output format. The
#'   default value is `"tibble"`. Other possible values are `"data.frame"`, `"sf"`
#'   and `"ppp"`, that, respectively, returns objects of class [`data.frame`],
#'   [`sf::sf`] and [`spatstat.geom::ppp`]. Any other string is ignored and a tibble
#'   output is returned. See details and examples.
#' @param ... Other arguments be passed to [format_sf()] or
#'   [format_ppp()] functions. Read and run the examples.
#'
#' @export
#' @examples
#' \donttest{
#' if(curl::has_internet()) {
#' col = get_stats19(year = 2022, type = "collision")
#' cas = get_stats19(year = 2022, type = "casualty")
#' veh = get_stats19(year = 2022, type = "vehicle")
#' class(col)
#' # data.frame output
#' x = get_stats19(2022, silent = TRUE, output_format = "data.frame")
#' class(x)
#' 
#' # # Get 5-years worth of data (commented-out due to large response size):
#' # col_5 = get_stats19(year = 5, type = "collision")
#' # cas_5 = get_stats19(year = 5, type = "casualty")
#' # veh_5 = get_stats19(year = 5, type = "vehicle")
#' 
#'
#' # Run tests only if endpoint is alive:
#' if(nrow(x) > 0) {
#'
#' # sf output
#' x_sf = get_stats19(2022, silent = TRUE, output_format = "sf")
#'
#' # sf output with lonlat coordinates
#' x_sf = get_stats19(2022, silent = TRUE, output_format = "sf", lonlat = TRUE)
#' sf::st_crs(x_sf)
#'
#' if (requireNamespace("spatstat.geom", quietly = TRUE)) {
#' # ppp output
#' x_ppp = get_stats19(2022, silent = TRUE, output_format = "ppp")
#'
#' # We can use the window parameter of format_ppp function to filter only the
#' # events occurred in a specific area. For example we can create a new bbox
#' # of 5km around the city center of Leeds
#'
#' leeds_window = spatstat.geom::owin(
#' xrange = c(425046.1, 435046.1),
#' yrange = c(428577.2, 438577.2)
#' )
#'
#' leeds_ppp = get_stats19(2022, silent = TRUE, output_format = "ppp", window = leeds_window)
#' spatstat.geom::plot.ppp(leeds_ppp, use.marks = FALSE, clipwin = leeds_window)
#' }
#' }
#' }
#' }
get_stats19 = function(year = NULL,
                      type = "collision",
                      data_dir = get_data_directory(),
                      file_name = NULL,
                      format = TRUE,
                      ask = FALSE,
                      silent = FALSE,
                      output_format = "tibble",
                      ...) {
  # Set type to "collision" if it's "accident" or similar:
  if (grepl("acc", x = type, ignore.case = TRUE)) {
    type = "collision"
  }
  
  valid_formats = c("tibble", "data.frame", "sf", "ppp")
  if (!output_format %in% valid_formats) {
    warning("output_format should be one of ", paste(valid_formats, collapse = ", "), 
            ". Defaulting to tibble.", call. = FALSE, immediate. = TRUE)
    output_format = "tibble"
  }
  
  if (grepl("cas", type, ignore.case = TRUE) && output_format %in% c("sf", "ppp")) {
    warning("Casualties do not have a spatial dimension. Defaulting to tibble.",
            call. = FALSE, immediate. = TRUE)
    output_format = "tibble"
  }

  # download what the user wanted
  dl_stats19(year = year, type = type, data_dir = data_dir, 
             file_name = file_name, ask = ask, silent = silent)
  
  # read in
  read_in = read_stats19(year = year, filename = file_name %||% "", 
                         data_dir = data_dir, format = format, 
                         silent = silent, type = type)

  # Smart Unification for E-scooter Casualties
  # If type is casualty, we check vehicles to find e-scooter riders
  if (grepl("cas", type, ignore.case = TRUE) && !is.null(read_in) && format) {
    ve_escooter = tryCatch({
      ve_temp = read_stats19(year = year, filename = "", data_dir = data_dir, 
                             format = TRUE, silent = TRUE, type = "vehicle")
      if (!is.null(ve_temp) && "escooter_flag" %in% names(ve_temp)) {
        ve_temp[ve_temp$escooter_flag == "Vehicle was an e-scooter", 
                c("collision_index", "vehicle_reference")]
      } else {
        NULL
      }
    }, error = function(e) NULL)
    
    if (!is.null(ve_escooter) && nrow(ve_escooter) > 0) {
      # Identify casualties associated with e-scooter vehicles
      is_escooter_rider = paste(read_in$collision_index, read_in$vehicle_reference) %in% 
                          paste(ve_escooter$collision_index, ve_escooter$vehicle_reference)
      # If they are linked to an e-scooter and their type is NA, they are the rider
      read_in$casualty_type[is_escooter_rider & is.na(read_in$casualty_type)] = "E-scooter rider"
    }
  }

  # transform read_in into the desired format
  if (output_format != "tibble" && !is.null(read_in)) {
    read_in = switch(
      output_format,
      "data.frame" = as.data.frame(read_in, ...),
      "sf" = format_sf(read_in, ...),
      "ppp" = format_ppp(read_in, ...)
    )
  }

  read_in
}

# Helper to handle NULL with default
`%||%` = function(a, b) if (!is.null(a)) a else b
