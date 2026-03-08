#' Format STATS19 'collisions' data
#'
#' @section Details:
#' This is a helper function to format raw STATS19 data
#'
#' @param x Data frame created with `read_collisions()`
#' @export
#' @examples
#' \donttest{
#'   if(curl::has_internet()) {
#'     dl_stats19(year = 2022, type = "collision")
#'   }
#' }
#' @export
format_collisions = function(x) {
  format_stats19(x, type = "Collision")
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
  # Rename columns
  names(x) = format_column_names(names(x))
  
  # Standardize index names: accident_index -> collision_index
  if ("accident_index" %in% names(x)) {
    names(x)[names(x) == "accident_index"] = "collision_index"
  }
  if ("accident_year" %in% names(x)) {
    names(x)[names(x) == "accident_year"] = "collision_year"
  }
  if ("accident_reference" %in% names(x)) {
    names(x)[names(x) == "accident_reference"] = "collision_reference"
  }
  if ("accident_severity" %in% names(x)) {
    names(x)[names(x) == "accident_severity"] = "collision_severity"
  }

  # create lookup table
  lkp_vars = stats19::stats19_variables$variable[stats19::stats19_variables$table == tolower(type)]
  vars_to_change = intersect(names(x), lkp_vars)
  vars_to_change = intersect(vars_to_change, stats19::stats19_schema$variable)
  
  missing_labels = c("Data missing or out of range", "Unknown", "Undefined", "Code deprecated", "Not known")

  for(v in vars_to_change) {
    lookup = stats19::stats19_schema[stats19::stats19_schema$variable == v, c("code", "label")]
    # Vectorized match
    matched_idx = match(x[[v]], lookup$code)
    has_match = !is.na(matched_idx)
    
    if (any(has_match)) {
      labels = lookup$label[matched_idx[has_match]]
      # Mask missing labels at replacement time
      labels[labels %in% missing_labels] = NA_character_
      x[[v]][has_match] = labels
    }
  }

  # Standardize missing labels across ALL columns
  x[] = lapply(x, function(col) {
    if (is.character(col)) {
      col[col %in% missing_labels] = NA_character_
    }
    col
  })

  # Smart Unification for E-scooters
  if ("escooter_flag" %in% names(x) && "vehicle_type" %in% names(x)) {
    is_escooter = !is.na(x$escooter_flag) & x$escooter_flag == "Vehicle was an e-scooter"
    # If it's an e-scooter and vehicle_type is NA, set it
    x$vehicle_type[is_escooter & is.na(x$vehicle_type)] = "E-scooter"
  }

  # Unify historic columns
  historic_cols = names(x)[grepl("_historic$", names(x))]
  for (hcol in historic_cols) {
    # Try exact match first
    primary_col = gsub("_historic$", "", hcol)
    
    # Special cases for non-exact matches
    if (primary_col == "pedestrian_crossing_human_control") {
      primary_col = "pedestrian_crossing" # Merge into the newer unified field if present
    }
    
    if (primary_col %in% names(x)) {
      # Use primary if available, otherwise use historic
      x[[primary_col]] = ifelse(is.na(x[[primary_col]]), x[[hcol]], x[[primary_col]])
      # Remove the historic column
      x[[hcol]] = NULL
    }
  }

  if("date" %in% names(x)) {
    x$date = as.Date(x$date, format = "%d/%m/%Y")
  }
  
  if("date" %in% names(x) && "time" %in% names(x)) {
    message("date and time columns present, creating formatted datetime column")
    x$datetime = as.POSIXct(paste(as.character(x$date), x$time), tz = 'Europe/London', format = "%Y-%m-%d %H:%M")
  }

  cregex = "easting|northing|latitude|longitude"
  names_coordinates = names(x)[grepl(pattern = cregex, x = names(x), ignore.case = TRUE)]
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
