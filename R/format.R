#' Format stats19 'accidents' data
#'
#' @section Details:
#' This is a helper function to format raw stats19 data
#'
#' @param x Data frame created with `read_accidents()`
#' @export
#' @examples
#' \dontrun{
#' dl_stats19(year = 2017, type = "accident")
#' x = read_accidents(year = 2017)
#' crashes = format_accidents(x)
#' }
#' @export
format_accidents = function(x) {
  format_stats19(x, type = "accidents")
}
#' Format stats19 casualties
#'
#' @section Details:
#' This function formats raw stats19 data
#'
#' @param x Data frame created with `read_casualties()`
#' @export
#' @examples
#' \dontrun{
#' dl_stats19(year = 2017, type = "casualties")
#' x = read_casualties(year = 2017)
#' casualties = format_casualties(x)
#' }
#' @export
format_casualties = function(x) {
  format_stats19(x, type = "casualties")
}
#' Format stats19 vehicles data
#'
#' @section Details:
#' This function formats raw stats19 data
#'
#' @param x Data frame created with `read_vehicles()`
#' @export
#' @examples
#' \dontrun{
#' dl_stats19(year = 2017, type = "vehicles")
#' x = read_vehicles(year = 2017)
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
  lkp = stats19_variables[stats19_variables$table == type,]

  vkeep = new_names %in% stats19_schema$variable_formatted # new way with summary(vkeep) 12 true
  vars_to_change = which(vkeep)

  for(i in vars_to_change) {
    lookup_col_name = lkp$column_name[lkp$column_name == new_names[i]]
    lookup = stats19_schema[stats19_schema$variable_formatted == lookup_col_name, 1:2]
    x[[i]] = lookup$label[match(x[[i]], lookup$code)]
  }
  x
}

#' Format column names of raw stats19 data
#'
#' This function takes messy column names and returns clean ones that work well with
#' R by default. Names that are all lower case with no R-unfriendly characters
#' such as spaces and `-` are returned.
#' @param column_names Column names to be cleaned
#' @return Column names cleaned.
#' @export
#' @examples
#' \dontrun{
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
#' Load stats19 schema
#'
#' This function generates the data object `stats19_schema` in a reproducible way
#' using DfT's schema definition (see function [dl_schema()]).
#'
#' The function also generates `stats19_variables`
#' (see the function's source code for details).
#'
#' @inheritParams read_accidents
#' @param sheet integer to be added if you want to download a single sheet
#' @export
#' @examples
#' \dontrun{
#' stats19_schema = read_schema()
#' }
read_schema = function(
  data_dir = tempdir(),
  filename = "Road-Accident-Safety-Data-Guide.xls",
  sheet = NULL
) {

  file_path = file.path(data_dir, filename)
  if (!file.exists(file_path)) {
    dl_schema()
  }
  if (is.null(sheet)) {
    export_variables = readxl::read_xls(path = file_path,
                                        sheet = 2,
                                        skip = 2)
    export_variables_accidents = tibble::tibble(
      table = "accidents",
      variable = export_variables$`Accident Circumstances`
    )
    export_variables_vehicles =  tibble::tibble(
      table = "vehicles",
      variable = export_variables$Vehicle
    )
    export_variables_casualties =  tibble::tibble(
      table = "casualties",
      variable = export_variables$Casualty
    )
    export_variables_long = rbind(
      export_variables_accidents,
      export_variables_casualties,
      export_variables_vehicles
    )
    stats19_variables = stats::na.omit(export_variables_long)
    stats19_variables$type = stats19_vtype(stats19_variables$variable)

    # add variable linking to names in formatted data
    names_acc = names(accidents_sample)
    names_veh = names(vehicles_sample)
    names_cas = names(casualties_sample)
    names_all = c(names_acc, names_veh, names_cas)

    variables_lower = schema_to_variable(stats19_variables$variable)
    # test result
    # variables_lower[!variables_lower %in% names_all]
    # names_all[!names_all %in% variables_lower]
    stats19_variables$column_name = variables_lower
    # head(stats19_variables)

    # export result: usethis::use_data(stats19_variables, overwrite = TRUE)

    sel_character = stats19_variables$type == "character"
    character_vars = stats19_variables$variable[sel_character]
    character_vars = stats19_vname_switch(character_vars)

    schema_list = lapply(
      X = seq_along(character_vars),
      FUN = function(i) {
        x = readxl::read_xls(path = file_path, sheet = character_vars[i])
        names(x) = c("code", "label")
        x
      }
    )

    stats19_schema = do.call(what = rbind, args = schema_list)
    n_categories = vapply(schema_list, nrow, FUN.VALUE = integer(1))
    stats19_schema$variable = rep(character_vars, n_categories)

    character_cols = stats19_variables$column_name[sel_character]
    stats19_schema$variable_formatted = rep(character_cols, n_categories)

  } else {
    stats19_schema = readxl::read_xls(path = file_path, sheet = sheet)
  }
  stats19_schema
}
schema_to_variable = function(x) {
  x = format_column_names(x)
  x = gsub(pattern = " ", replacement = "_", x = x)
  x = gsub(pattern = "_null_if_not_known", replacement = "", x)
  x = gsub(pattern = "_dd/mm/yyyy|_hh:mm", replacement = "", x)
  x = gsub(pattern = "highway_authority___ons_code", replacement = "highway", x)
  x = gsub(pattern = "lower_super_ouput_area", replacement = "lsoa", x)
  x = gsub(pattern = "_england_&_wales_only", replacement = "", x)
  x = gsub(pattern = "_cc", replacement = "", x)
  x = gsub(pattern = "vehicle_propulsion_code", replacement = "propulsion_code", x)
  x = gsub(pattern = "pedestrian_road_maintenance_worker_from_2011",
           replacement = "pedestrian_road_maintenance_worker", x)
  x = gsub(pattern = "engine_capacity", replacement = "engine_capacity_cc", x)
  x = gsub(pattern = "age_of_vehicle_manufacture", replacement = "age_of_vehicle", x)
  x
}

# Return type of variable of stats19 data - informal test:
# variable_types = stats19_vtype(stats19_variables$variable)
# names(variable_types) = stats19_variables$variable
# variable_types
# x = names(read_accidents())
# n = stats19_vtype(x)
# names(n) = x
# n
stats19_vtype = function(x) {
  variable_types = rep("character", length(x))
  sel_numeric = grepl(pattern = "Number|Speed|Age*.of|Capacity", x = x)
  variable_types[sel_numeric] = "numeric"
  sel_date = grepl(pattern = "^Date", x = x)
  variable_types[sel_date] = "date"
  sel_time = grepl(pattern = "^Time", x = x)
  variable_types[sel_time] = "time"
  sel_location = grepl(pattern = "^Location|Longi|Lati", x = x)
  variable_types[sel_location] = "location"
  # remove other variables with no lookup: no weather ?!
  sel_other = grepl(
    pattern = paste0(
      "Did|Lower|Accident*.Ind|Reference|Restricted|",
      "Leaving|Hit|Age*.Band*.of*.D|Driver*.[H|I]"
    ),
    x = x
  )
  variable_types[sel_other] = "other"
  variable_types
}

stats19_vname_switch = function(x) {
  x = gsub(pattern = " Authority - ONS code", "", x = x)
  x = gsub(
    pattern = "Pedestrian Crossing-Human Control",
    "Ped Cross - Human",
    x = x
    )
  x = gsub(
    pattern = "Pedestrian Crossing-Physical Facilities",
    "Ped Cross - Physical",
    x = x
    )
  x = gsub(pattern = "r Conditions", "r", x = x)
  x = gsub(pattern = "e Conditions", "e", x = x)
  x = gsub(pattern = " Area|or ", "", x = x)
  x = gsub(pattern = "Age Band of Casualty", "Age Band", x = x)
  x = gsub(pattern = "Pedestrian", "Ped", x = x)
  x = gsub(pattern = "Bus Coach Passenger", "Bus Passenger", x = x)
  x = gsub(pattern = " \\(From 2011\\)", "", x = x)
  x = gsub(pattern = "Casualty Home Type", "Home Area Type", x = x)
  x = gsub(pattern = "Casualty IMD Decile", "IMD Decile", x = x)
  x = gsub(pattern = "Journey Purpose of Driver", "Journey Purpose", x = x)
  x
}

#' Format convert stats19 data into spatial (sf) object
#'
#' @param x Data frame created with `read_accidents()`
#' @param lonlat Should the results be returned in longitude/latitude?
#' By default `FALSE`, meaning the British National Grid (EPSG code: 27700)
#' is used.
#'
#' @export
#' @examples
#' \dontrun{
#' x = read_accidents()
#' x_formatted = format_accidents(x)
#' x_sf = format_sf(x_formatted)
#' sf:::plot.sf(x_sf["accident_severity"])
#' }
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
