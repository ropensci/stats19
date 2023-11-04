#' Format STATS19 'accidents' data
#'
#' @section Details:
#' This is a helper function to format raw STATS19 data
#'
#' @param x Data frame created with `read_collisions()`
#' @export
#' @examples
#' \donttest{
#' if(curl::has_internet()) {
#' dl_stats19(year = 2022, type = "collision")
#' x = read_collisions(year = 2022, format = FALSE)
#' x = readr::read_csv("https://github.com/ropensci/stats19/releases/download/v3.0.0/fatalities.csv")
#' if(nrow(x) > 0) {
#' x[1:3, 1:12]
#' crashes = format_collisions(x)
#' crashes[1:3, 1:12]
#' summary(crashes$datetime)
#' }
#' }
#' }
#' @export
format_collisions = function(x) {
  format_stats19(x, type = "Accident")
}
#' Format STATS19 casualties
#'
#' @section Details:
#' This function formats raw STATS19 data
#'
#' @param x Data frame created with `read_casualties()`
#' @export
#' @examples
#' \donttest{
#' if(curl::has_internet()) {
#' dl_stats19(year = 2022, type = "casualty")
#' x = read_casualties(year = 2022)
#' casualties = format_casualties(x)
#' }
#' }
#' @export
format_casualties = function(x) {
  format_stats19(x, type = "Casualty")
}
#' Format STATS19 vehicles data
#'
#' @section Details:
#' This function formats raw STATS19 data
#'
#' @param x Data frame created with `read_vehicles()`
#' @export
#' @examples
#' \donttest{
#' if(curl::has_internet()) {
#' dl_stats19(year = 2022, type = "vehicle", ask = FALSE)
#' x = read_vehicles(year = 2022, format = FALSE)
#' vehicles = format_vehicles(x)
#' }
#' }
#' @export
format_vehicles = function(x) {
  format_stats19(x, type = "Vehicle")
}

format_stats19 = function(x, type) {
  # rename colums
  old_names = names(x)
  new_names = format_column_names(old_names)
  names(x) = new_names

  # create lookup table
  lkp = stats19::stats19_variables[stats19::stats19_variables$table == type,]

  vkeep = new_names %in% stats19::stats19_schema$variable_formatted
  vars_to_change = which(vkeep)

  # browser()
  for(i in vars_to_change) {
    lkp_name = lkp$column_name[lkp$column_name == new_names[i]]
    lookup = stats19::stats19_schema[
      stats19::stats19_schema$variable_formatted == lkp_name,
      c("code", "label")
      ]
    x[[i]] = lookup$label[match(x[[i]], lookup$code)]
  }

  date_in_names = "date" %in% names(x)
  if(date_in_names) {
    date_char = x$date
    x$date = as.Date(date_char, format = "%d/%m/%Y")
  }
  if(date_in_names && "time" %in% names(x)) {
    # Add formated datetime column, tell people about this new feature
    # (message could be removed in future versions)
    message("date and time columns present, creating formatted datetime column")
    # names(x)
    # class(x$time) # it's a character string
    # head(x$time) # just the time (not date)

    x$datetime = as.POSIXct(paste(date_char, x$time), tz = 'Europe/London', format = "%d/%m/%Y %H:%M")
    # summary(x$datetime)
  }
  cregex = "easting|northing|latitude|longitude"
  names_coordinates = names(x)[grepl(pattern = cregex, x = names(x), ignore.case = TRUE)]
  # convert them to numeric if not already:
  for(i in names_coordinates) {
    if(!is.numeric(x[[i]])) {
      x[[i]] = as.numeric(x[[i]])
    }
  }
  x
}

#' Format column names of raw STATS19 data
#'
#' This function takes messy column names and returns clean ones that work well with
#' R by default. Names that are all lower case with no R-unfriendly characters
#' such as spaces and `-` are returned.
#' @param column_names Column names to be cleaned
#' @return Column names cleaned.
#' @export
#' @examples
#' \donttest{
#' if(curl::has_internet()) {
#' crashes_raw = read_collisions(year = 2022)
#' column_names = names(crashes_raw)
#' column_names
#' format_column_names(column_names = column_names)
#' }
#' }
format_column_names = function(column_names) {
  x = tolower(column_names)
  x = gsub(pattern = " ", replacement = "_", x = x)
  x = gsub(pattern = "\\(|\\)", replacement = "", x = x)
  x = gsub(pattern = "1st", replacement = "first", x = x)
  x = gsub(pattern = "2nd", replacement = "second", x = x)
  x = gsub(pattern = "-", replacement = "_", x = x)
  x = gsub(pattern = "\\?", replacement = "", x)
  x
}

#' Format convert STATS19 data into spatial (sf) object
#'
#' @param x Data frame created with `read_collisions()`
#' @param lonlat Should the results be returned in longitude/latitude?
#' By default `FALSE`, meaning the British National Grid (EPSG code: 27700)
#' is used.
#'
#' @export
#' @examples
#' x_sf = format_sf(accidents_sample)
#' sf:::plot.sf(x_sf)

format_sf = function(x, lonlat = FALSE) {
  n = names(x)
  coords = n[grep(pattern = "easting|northing",
                  x = n,
                  ignore.case = TRUE)]
  coord_null = is.na(x[[coords[1]]]) | is.na(x[[coords[2]]])
  message(sum(coord_null), " rows removed with no coordinates")
  x = x[!coord_null, ]
  x_sf = sf::st_as_sf(x, coords = coords, crs = 27700)
  if(lonlat) {
    x_sf = sf::st_transform(x_sf, crs = 4326)
  }
  x_sf
}

#' Convert STATS19 data into ppp (spatstat) format.
#'
#' This function is a wrapper around the [spatstat.geom::ppp()] function and
#' it is used to transform STATS19 data into a ppp format.
#'
#' @param data A STATS19 dataframe to be converted into ppp format.
#' @param window A windows of observation, an object of class `owin()`. If
#'   `window = NULL` (i.e. the default) then the function creates an approximate
#'   bounding box covering the whole UK. It can also be used to filter only the
#'   events occurring in a specific region of UK (see the examples of
#'   \code{\link{get_stats19}}).
#' @param ... Additional parameters that should be passed to
#'   [spatstat.geom::ppp()] function. Read the help page of that function
#'   for a detailed description of the available parameters.
#'
#' @return A ppp object.
#' @seealso \code{\link{format_sf}} for an analogous function used to convert
#'   data into sf format and [spatstat.geom::ppp()] for the original function.
#' @export
#'
#' @examples
#' if (requireNamespace("spatstat.geom", quietly = TRUE)) {
#'   x_ppp = format_ppp(accidents_sample)
#'   x_ppp
#' }
#'

format_ppp = function(data, window = NULL,  ...) {
  # check that spatstat.geom is installed
  if (!requireNamespace("spatstat.geom", quietly = TRUE)) {
    stop("package spatstat.geom required, please install it first")
  }

  # look for column names of coordinates
  names_data = names(data)
  coords = names_data[grepl(
    pattern = "easting|northing",
    x = names_data,
    ignore.case = TRUE
  )]

  # exclude car crashes with NA in the coordinates
  coords_null = is.na(data[[coords[1]]] | data[[coords[2]]])
  if (sum(coords_null) > 0) {
    message(sum(coords_null), " rows removed with no coordinates")
    data = data[!coords_null, ]
  }

  # owin object for ppp. Default values represent an approximate bbox of UK
  if (is.null(window)) {
    window = spatstat.geom::owin(
      xrange = c(64950, 655391),
      yrange = c(10235, 1209512)
    )
  }

  data_ppp = spatstat.geom::ppp(
    x = data[[coords[[1]]]],
    y = data[[coords[[2]]]],
    window = window,
    marks = data[setdiff(names_data, coords)],
    ...
  )
  data_ppp
}
