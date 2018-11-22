#' Load stats19 schema
#'
#' This function generates the data object `stats19_schema` in a reproducible way
#' using DfT's schema definition (see function [dl_schema()]).
#'
#' @examples
#' stats19_schema = read_schema()
#'
#' @inheritParams read_stats19_2005_2014_ac
#' @param sheet integer to be added if you want to download a single sheet
read_schema = function(
  dir = tempdir(),
  filename = "Road-Accident-Safety-Data-Guide.xls",
  sheet = NULL
  ) {
  file_path = file.path(dir, filename)
  if (!file.exists(file_path)) {
    dl_schema()
  }
  if(is.null(sheet)) {
    export_variables = readxl::read_xls(path = file_path, sheet = 2, skip = 2)
    export_variables_accidents = data.frame(
      stringsAsFactors = FALSE,
      table = "accidents",
      variable = export_variables$`Accident Circumstances`
        )
    export_variables_vehicles = data.frame(
      stringsAsFactors = FALSE,
      table = "vehicles",
      variable = export_variables$Vehicle
    )
    export_variables_casualties = data.frame(
      stringsAsFactors = FALSE,
      table = "casualties",
      variable = export_variables$Casualty
    )
    export_variables_long = rbind(
      export_variables_accidents,
      export_variables_casualties,
      export_variables_vehicles
    )
    stats19_variables = na.omit(export_variables_long)

    # export result:
    # usethis::use_data(stats19_variables, overwrite = TRUE)

    # test results:
    # sheet_name = stats19_variables$variable[2]
    # schema_1 = readxl::read_xls(path = file_path, sheet = sheet_name)

    sel_numeric = grepl(pattern = "Number|Speed|Age of|Capacity", x = stats19_variables$variable)
    vars_numeric = stats19_variables$variable[sel_numeric]
    sel_date = grepl(pattern = "^Date", x = stats19_variables$variable)
    vars_date = stats19_variables$variable[sel_date]
    sel_time = grepl(pattern = "^Time", x = stats19_variables$variable)
    vars_time = stats19_variables$variable[sel_time]
    sel_location = grepl(pattern = "^Location|Longi|Lati", x = stats19_variables$variable)
    vars_location = stats19_variables$variable[sel_location]
    # remove other variables with no lookup: no weather ?!
    sel_other = grepl(
      pattern = "Did|Lower|Accident Ind|Reference|Restricted|Leaving|Hit|Age Band of D|Driver [H|I]",
      x = stats19_variables$variable
      )

    sel_character = !sel_numeric & !sel_date & !sel_time & !sel_location & !sel_other

    character_vars = stats19_variables$variable[sel_character]
    character_vars = stats19_vname_switch(character_vars)

    schema_list = lapply(
      X = 1:length(character_vars),
      FUN = function(i) {
        x = readxl::read_xls(path = file_path, sheet = character_vars[i])
        # x$code = as.character(x$code)
        names(x) = c("code", "label")
        x
      }

    )

    stats19_schema = do.call(what = rbind, args = schema_list)
    n_categories = sapply(schema_list, nrow)
    stats19_schema$variable = rep(character_vars, n_categories)
  } else {
    stats19_schema = readxl::read_xls(path = file_path, sheet = sheet)
  }
  stats19_schema
}

stats19_vname_switch = function(x) {
  x = gsub(pattern = " Authority - ONS code", "", x = x)
  x = gsub(pattern = "Pedestrian Crossing-Human Control", "Ped Cross - Human", x = x)
  x = gsub(pattern = "Pedestrian Crossing-Physical Facilities", "Ped Cross - Physical", x = x)
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

#' Format UK 'Stats19' road traffic casualty data
#'
#' @section Details:
#' This is a helper function to format raw stats19 data
#'
#' @param ve Dataframe representing the raw Stats19 data read-in with `read_csv()`.
#' @export
#' @examples
#' \dontrun{
#' ve <- format_stats19_2005_2014_ve(ve)
#' }
format_accidents <- function() {

}

