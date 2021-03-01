#' Download, read and format STATS19 data in one function.
#'
#' @section Details:
#' This function uses gets STATS19 data. Behind the scenes it uses
#' `dl_stats19()` and `read_*` functions, returning a
#' `tibble` (default), `data.frame`, `sf` or `ppp` object, depending on the
#' `output_format` parameter.
#' The function returns data for a specific year (e.g. `year = 2017`) or multiple
#' years (e.g. `year = c(2017, 2018)`).
#' Note: for years before 2009 the function may return data from more years than are
#' requested due to the nature of the files hosted at
#' [data.gov.uk](https://data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data).
#'
#' As this function uses `dl_stats19` function, it can download many MB of data,
#' so ensure you have a sufficient disk space.
#'
#' If `output_format = "data.frame"` or `output_format = "sf"` or `output_format
#' = "ppp"` then the output data is transformed into a data.frame, sf or ppp
#' object using the [as.data.frame()] or [format_sf()] or [format_ppp()]
#' functions, respectively.
#' See examples.
#'
#' @seealso [dl_stats19()]
#' @seealso [read_accidents()]
#'
#' @inheritParams dl_stats19
#' @param format Switch to return raw read from file, default is `TRUE`.
#' @param output_format A string that specifies the desired output format. The
#'   default value is `"tibble"`. Other possible values are `"data.frame"`, `"sf"`
#'   and `"ppp"`, that, respectively, returns objects of class [`data.frame`],
#'   [`sf::sf`] and [`spatstat.geom::ppp`]. Any other string is ignored and a tibble
#'   output is returned. See details and examples.
#' @param year Valid vector of one or more years from 1979 up until last year.
#' @param ... Other arguments that should be passed to [format_sf()] or
#'   [format_ppp()] functions. Read and run the examples.
#'
#' @export
#' @examples
#' \donttest{
#' # default tibble output
#' x = get_stats19(2019)
#' class(x)
#' x = get_stats19(2017, silent = TRUE)
#'
#' # data.frame output
#' x = get_stats19(2019, silent = TRUE, output_format = "data.frame")
#' class(x)
#'
#' # multiple years
#' get_stats19(c(2017, 2018), silent = TRUE)
#'
#' # sf output
#' x_sf = get_stats19(2017, silent = TRUE, output_format = "sf")
#'
#' # sf output with lonlat coordinates
#' x_sf = get_stats19(2017, silent = TRUE, output_format = "sf", lonlat = TRUE)
#' sf::st_crs(x_sf)
#'
#' # multiple years
#' get_stats19(c(2017, 2018), silent = TRUE, output_format = "sf")
#'
#' if (requireNamespace("spatstat.core", quietly = TRUE)) {
#' # ppp output
#' x_ppp = get_stats19(2017, silent = TRUE, output_format = "ppp")
#'
#' # Multiple years
#' get_stats19(c(2017, 2018), silent = TRUE, output_format = "ppp")
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
#' leeds_ppp = get_stats19(2017, silent = TRUE, output_format = "ppp", window = leeds_window)
#' spatstat.geom::plot.ppp(leeds_ppp, use.marks = FALSE, clipwin = leeds_window)
#'
#' # or even more fancy examples where we subset all the events occurred in a
#' # pre-defined polygon area
#'
#' # The following example requires osmdata package
#' # greater_london_sf_polygon = osmdata::getbb(
#' # "Greater London, UK",
#' # format_out = "sf_polygon"
#' # )
#' # spatstat works only with planar coordinates
#' # greater_london_sf_polygon = sf::st_transform(greater_london_sf_polygon, 27700)
#' # then we extract the coordinates and create the window object.
#' # greater_london_polygon = sf::st_coordinates(greater_london_sf_polygon)[, c(1, 2)]
#' # greater_london_window = spatstat.geom::owin(poly = greater_london_polygon)
#'
#' # greater_london_ppp = get_stats19(2017, output_format = "ppp", window = greater_london_window)
#' # spatstat.geom::plot.ppp(greater_london_ppp, use.marks = FALSE, clipwin = greater_london_window)
#' }
#' }
get_stats19 = function(year = NULL,
                      type = "accidents",
                      data_dir = get_data_directory(),
                      file_name = NULL,
                      format = TRUE,
                      ask = FALSE,
                      silent = FALSE,
                      output_format = "tibble",
                      ...) {
  if(!exists("type")) {
    stop("Type is required", call. = FALSE)
  }
  if (!output_format %in% c("tibble", "data.frame", "sf", "ppp")) {
    warning(
      "output_format parameter should be one of c('tibble', 'data.frame', 'sf', 'ppp').\n",
      "You entered ", output_format, ".\n",
      "Defaulting to tibble.",
      call. = FALSE,
      immediate. = TRUE
    )
    output_format = "tibble"
  }
  if (grepl(type, "casualties", ignore.case = TRUE) && output_format %in% c("sf", "ppp")) {
    warning(
      "You cannot select output_format = 'sf' or output_format = 'ppp' when type = 'casualties'.\n",
      "Casualties do not have a spatial dimension.\n",
      "Defaulting to tibble output_format",
      call. = FALSE,
      immediate. = TRUE
    )
    output_format = "tibble"
  }

  if(!is.null (year)) {
    year = check_year(year)
  }

  if(is.vector(year) && length(year) > 1) {
    all  = list()
    i = 1
    for (aYear in year) {
      all[[i]] = get_stats19(
        year = aYear,
        type = type,
        data_dir = data_dir,
        file_name = file_name,
        format = format,
        ask = ask,
        silent = silent,
        output_format = output_format,
        ...
      )
      i = i + 1
    }
    if (output_format == "ppp") {
      all = do.call(spatstat.geom::superimpose, all)
    } else {
      all_colnames = unique(unlist(lapply(all, names)))
      all = lapply(all, function(x) {
        x[setdiff(all_colnames, names(x))] <- NA
        x
      })
      all = do.call(rbind, all)
    }
    return(all)
  }

  # download what the user wanted
  dl_stats19(year = year,
             type = type,
             data_dir = data_dir,
             file_name = file_name,
             ask = ask,
             silent = silent)
  read_in = NULL
  # read in
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
      format = format,
      silent = silent)
  }

  # transform read_in into the desired format
  if (output_format != "tibble") {
    read_in = switch(
      output_format,
      "data.frame" = as.data.frame(read_in, ...),
      "sf" = format_sf(read_in, ...),
      "ppp" = format_ppp(read_in, ...)
    )
  }

  read_in
}

