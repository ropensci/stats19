#' Format STATS19 'accidents' data
#'
#' @section Details:
#' This is a helper function to format raw STATS19 data
#'
#' @param x Data frame created with `read_accidents()`
#' @export
#' @examples
#' \donttest{
#' dl_stats19(year = 2017, type = "accident")
#' x = read_accidents(year = 2017)
#' crashes = format_accidents(x)
#' }
#' @export
format_accidents = function(x) {
  format_stats19(x, type = "accidents")
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
#' dl_stats19(year = 2017, type = "casualties")
#' x = read_casualties(year = 2017)
#' casualties = format_casualties(x)
#' }
#' @export
format_casualties = function(x) {
  format_stats19(x, type = "casualties")
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
#' dl_stats19(year = 2017, type = "vehicles")
#' x = read_vehicles(year = 2017, format = FALSE)
#' vehicles = format_vehicles(x)
#' }
#' @export
format_vehicles = function(x) {
  format_stats19(x, type = "vehicles")
}

format_stats19 = function(x, type) {
  # rename colums
  old_names = names(x)
  new_names = format_column_names(old_names)
  names(x) = new_names

  # create lookup table
  lkp = stats19::stats19_variables[stats19_variables$table == type,]

  vkeep = new_names %in% stats19_schema$variable_formatted
  vars_to_change = which(vkeep)

  for(i in vars_to_change) {
    lkp_name = lkp$column_name[lkp$column_name == new_names[i]]
    lookup = stats19_schema[stats19_schema$variable_formatted == lkp_name, 1:2]
    x[[i]] = lookup$label[match(x[[i]], lookup$code)]
  }

  if("date" %in% names(x)) {
    x$date = as.POSIXct(x$date, format = "%d/%m/%Y")
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
#' crashes_raw = read_accidents(year = 2017)
#' column_names = names(crashes_raw)
#' column_names
#' format_column_names(column_names = column_names)
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
#' @param x Data frame created with `read_accidents()`
#' @param lonlat Should the results be returned in longitude/latitude?
#' By default `FALSE`, meaning the British National Grid (EPSG code: 27700)
#' is used.
#'
#' @export
#' @examples
#' x_sf = format_sf(accidents_sample)
#' sf:::plot.sf(x_sf)
#' @export
format_sf = function(x, lonlat = FALSE) {
  n = names(x)
  if(lonlat) {
    coords = n[grep(pattern = "longitude|latitude",
                    x = n,
                    ignore.case = TRUE)]
    coord_null = is.na(x[[coords[1]]] | x[[coords[2]]])
    x = x[!coord_null, ]
    message(sum(coord_null), " rows removed with no coordinates")
    x_sf = sf::st_as_sf(x, coords = coords, crs = 4326)
  } else {
    coords = n[grep(pattern = "easting|northing",
                    x = n,
                    ignore.case = TRUE)]
    coord_null = is.na(x[[coords[1]]] | x[[coords[2]]])
    message(sum(coord_null), " rows removed with no coordinates")
    x = x[!coord_null, ]
    x_sf = sf::st_as_sf(x, coords = coords, crs = 27700)
  }
  x_sf
}
