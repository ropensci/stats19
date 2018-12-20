#' Stats19 schema and variables
#'
#' `stats19_schema` and `stats19_variables` contain
#' metadata on stats19 data.
#' `stats19_schema` is a look-up table matching
#' codes provided in the raw stats19 dataset with
#' character strings.
#'
#'
#'
#' @docType data
#' @keywords datasets
#' @name stats19_schema
#' @aliases stats19_variables
#' @examples
#' \dontrun{
#' WARNING: this does not work on Windows.
#' Load stats19 schema
#'
#' This function generates the data object `stats19_schema` in a reproducible way
#' using DfT's schema definition (see function [dl_schema()]).
#'
#' The function also generates `stats19_variables`
#' (see the function's source code for details).
#'
#' read_schema = function(
#'   data_dir = tempdir(),
#'   filename = "Road-Accident-Safety-Data-Guide.xls",
#'   sheet = NULL
#' ) {
#'
#'   file_path = file.path(data_dir, filename)
#'   if (!file.exists(file_path)) {
#'     dl_schema()
#'   }
#'   if (is.null(sheet)) {
#'     export_variables = readxl::read_xls(path = file_path,
#'                                         sheet = 2,
#'                                         skip = 2)
#'     export_variables_accidents = tibble::tibble(
#'       table = "accidents",
#'       variable = export_variables$`Accident Circumstances`
#'     )
#'     export_variables_vehicles =  tibble::tibble(
#'       table = "vehicles",
#'       variable = export_variables$Vehicle
#'     )
#'     export_variables_casualties =  tibble::tibble(
#'       table = "casualties",
#'       variable = export_variables$Casualty
#'     )
#'     export_variables_long = rbind(
#'       export_variables_accidents,
#'       export_variables_casualties,
#'       export_variables_vehicles
#'     )
#'     stats19_variables = stats::na.omit(export_variables_long)
#'     stats19_variables$type = stats19_vtype(stats19_variables$variable)
#'
#'     # add variable linking to names in formatted data
#'     names_acc = names(accidents_sample)
#'     names_veh = names(vehicles_sample)
#'     names_cas = names(casualties_sample)
#'     names_all = c(names_acc, names_veh, names_cas)
#'
#'     variables_lower = schema_to_variable(stats19_variables$variable)
#'     # test result
#'     # variables_lower[!variables_lower %in% names_all]
#'     # names_all[!names_all %in% variables_lower]
#'     stats19_variables$column_name = variables_lower
#'     # head(stats19_variables)
#'
#'     #' export result: usethis::use_data(stats19_variables, overwrite = TRUE)
#'
#'     sel_character = stats19_variables$type == "character"
#'     character_vars = stats19_variables$variable[sel_character]
#'     character_vars = stats19_vname_switch(character_vars)
#'
#'     schema_list = lapply(
#'       X = seq_along(character_vars),
#'       FUN = function(i) {
#'         x = readxl::read_xls(path = file_path, sheet = character_vars[i])
#'         names(x) = c("code", "label")
#'         x
#'       }
#'     )
#'
#'     stats19_schema = do.call(what = rbind, args = schema_list)
#'     n_categories = vapply(schema_list, nrow, FUN.VALUE = integer(1))
#'     stats19_schema$variable = rep(character_vars, n_categories)
#'
#'     character_cols = stats19_variables$column_name[sel_character]
#'     stats19_schema$variable_formatted = rep(character_cols, n_categories)
#'
#'   } else {
#'     stats19_schema = readxl::read_xls(path = file_path, sheet = sheet)
#'   }
#'   stats19_schema
#' }
#' schema_to_variable = function(x) {
#'   x = format_column_names(x)
#'   x = gsub(pattern = " ", replacement = "_", x = x)
#'   x = gsub(pattern = "_null_if_not_known", replacement = "", x)
#'   x = gsub(pattern = "_dd/mm/yyyy|_hh:mm", replacement = "", x)
#'   x = gsub(pattern = "highway_authority___ons_code", replacement = "highway", x)
#'   x = gsub(pattern = "lower_super_ouput_area", replacement = "lsoa", x)
#'   x = gsub(pattern = "_england_&_wales_only", replacement = "", x)
#'   x = gsub(pattern = "_cc", replacement = "", x)
#'   x = gsub(pattern = "vehicle_propulsion_code", replacement = "propulsion_code", x)
#'   x = gsub(pattern = "pedestrian_road_maintenance_worker_from_2011",
#'            replacement = "pedestrian_road_maintenance_worker", x)
#'   x = gsub(pattern = "engine_capacity", replacement = "engine_capacity_cc", x)
#'   x = gsub(pattern = "age_of_vehicle_manufacture", replacement = "age_of_vehicle", x)
#'   x
#' }
#'
#' #' Return type of variable of stats19 data - informal test:
#' #' variable_types = stats19_vtype(stats19_variables$variable)
#' #' names(variable_types) = stats19_variables$variable
#' #' variable_types
#' #' x = names(read_accidents())
#' #' n = stats19_vtype(x)
#' #' names(n) = x
#' #' n
#' stats19_vtype = function(x) {
#'   variable_types = rep("character", length(x))
#'   sel_numeric = grepl(pattern = "Number|Speed|Age*.of|Capacity", x = x)
#'   variable_types[sel_numeric] = "numeric"
#'   sel_date = grepl(pattern = "^Date", x = x)
#'   variable_types[sel_date] = "date"
#'   sel_time = grepl(pattern = "^Time", x = x)
#'   variable_types[sel_time] = "time"
#'   sel_location = grepl(pattern = "^Location|Longi|Lati", x = x)
#'   variable_types[sel_location] = "location"
#'   #' remove other variables with no lookup: no weather ?!
#'   sel_other = grepl(
#'     pattern = paste0(
#'       "Did|Lower|Accident*.Ind|Reference|Restricted|",
#'       "Leaving|Hit|Age*.Band*.of*.D|Driver*.[H|I]"
#'     ),
#'     x = x
#'   )
#'   variable_types[sel_other] = "other"
#'   variable_types
#' }
#'
#' stats19_vname_switch = function(x) {
#'   x = gsub(pattern = " Authority - ONS code", "", x = x)
#'   x = gsub(
#'     pattern = "Pedestrian Crossing-Human Control",
#'     "Ped Cross - Human",
#'     x = x
#'     )
#'   x = gsub(
#'     pattern = "Pedestrian Crossing-Physical Facilities",
#'     "Ped Cross - Physical",
#'     x = x
#'     )
#'   x = gsub(pattern = "r Conditions", "r", x = x)
#'   x = gsub(pattern = "e Conditions", "e", x = x)
#'   x = gsub(pattern = " Area|or ", "", x = x)
#'   x = gsub(pattern = "Age Band of Casualty", "Age Band", x = x)
#'   x = gsub(pattern = "Pedestrian", "Ped", x = x)
#'   x = gsub(pattern = "Bus Coach Passenger", "Bus Passenger", x = x)
#'   x = gsub(pattern = " \\(From 2011\\)", "", x = x)
#'   x = gsub(pattern = "Casualty Home Type", "Home Area Type", x = x)
#'   x = gsub(pattern = "Casualty IMD Decile", "IMD Decile", x = x)
#'   x = gsub(pattern = "Journey Purpose of Driver", "Journey Purpose", x = x)
#'   x
#' }
#'
#' stats19_schema = read_schema()
#' }
#'
NULL
#' Schema for stats19 data (UKDS)
#'
#' @docType data
#' @keywords datasets
#' @name schema_original
#' @format A data frame
NULL
#' stats19 file names for easy access
#'
#' URL decoded file names. Currently there are 52 file names
#' released by the DfT and the details include
#' how these were obtained and would be kept up to date.
#'
#' The file names were generated as follows:
#'
#' library(rvest)
#' #> Loading required package: xml2
#' library(stringr)
#' page <- read_html("https://data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-safety-data")
#'
#' r = page %>%
#'   html_nodes("a") %>%       # find all links
#'   html_attr("href") %>%     # get the url
#'   str_subset("\\.zip")
#'
#' dr = c()
#' for(i in 1:length(r)) {
#'   dr[i] = sub("http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/",
#'               "", URLdecode(r[i]))
#'   dr[i] = sub("http://data.dft.gov.uk/road-accidents-safety-data/",
#'               "", dr[i])
#' }
#' file_names = setNames(as.list(file_names), file_names)
#' usethis::use_data(file_names)
#'
#' @docType data
#' @keywords datasets
#' @name file_names
#' @format A named list
NULL
#' Sample of stats19 data (2017 accidents)
#'
#' @examples
#' \dontrun{
#' # Obtained with:
#' dl_stats19(year = 2017, type = "Accide")
#' accidents_2017_raw = read_accidents(year = 2017)
#' set.seed(350)
#' sel = sample(nrow(accidents_2017_raw), 3)
#' accidents_sample_raw = accidents_2017_raw[sel, ]
#' accidents_sample = format_accidents(accidents_sample_raw)
#' }
#' @docType data
#' @keywords datasets
#' @name accidents_sample
#' @aliases accidents_sample_raw
#' @format A data frame
NULL
#' Sample of stats19 data (2017 casualties)
#'
#' @examples
#' \dontrun{
#' # Obtained with:
#' dl_stats19(year = 2017, type = "cas")
#' casualties_2017_raw = read_casualties(year = 2017)
#' set.seed(350)
#' sel = sample(nrow(casualties_2017_raw), 3)
#' casualties_sample_raw = casualties_2017_raw[sel, ]
#' casualties_sample = format_casualties(casualties_sample_raw)
#' }
#' @docType data
#' @keywords datasets
#' @name casualties_sample
#' @aliases casualties_sample_raw
#' @format A data frame
NULL
#' Sample of stats19 data (2017 vehicles)
#'
#' @examples
#' \dontrun{
#' # Obtained with:
#' dl_stats19(year = 2017, type = "veh")
#' vehicles_2017_raw = read_vehicles(year = 2017)
#' set.seed(350)
#' sel = sample(nrow(vehicles_2017_raw), 3)
#' vehicles_sample_raw = vehicles_2017_raw[sel, ]
#' vehicles_sample = format_vehicles(vehicles_sample_raw)
#' }
#' @docType data
#' @keywords datasets
#' @name vehicles_sample
#' @aliases vehicles_sample_raw
#' @format A data frame
NULL
