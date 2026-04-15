#' Classify active travel collision types
#'
#' These functions classify STATS19 collisions involving pedal cycles into
#' common active travel categories based on vehicle maneuvers and collision context.
#'
#' @param vehicles A STATS19 vehicle data frame with vehicle_manoeuvre, junction_location,
#'   first_point_of_impact, vehicle_type, and optionally object_hit_in_carriageway columns.
#' @param collisions Optional STATS19 collision data frame for junction_detail context.
#'
#' @return A data frame with an additional `active_travel_category` column containing:
#'   - "Left Hook": Motor vehicle turning left across cyclist's path
#'   - "Right Hook": Motor vehicle turning right across cyclist's path
#'   - "Dooring": Cyclist hit by vehicle door
#'   - "Alongside": Sideswipe collisions while moving parallel
#'   - "Failed to Give Way": Motor vehicle failed to yield at junction
#'   - "Other": Collisions that don't fit above categories
#'
#' @name classify_active_travel
#' @export
NULL

#' @rdname classify_active_travel
#' @export
classify_active_travel = function(vehicles, collisions = NULL) {
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("package dplyr required")
  }

  required_cols = c("vehicle_manoeuvre", "vehicle_type", "first_point_of_impact")
  missing = setdiff(required_cols, names(vehicles))
  if (length(missing) > 0) {
    stop(paste("Missing required columns:", paste(missing, collapse = ", ")))
  }

  vehicles |>
    dplyr::mutate(
      active_travel_category = dplyr::case_when(
        vehicle_type == "Pedal cycle" &
          (tolower(vehicle_manoeuvre) %in% c("parked", "parking") |
           hit_object_in_carriageway == "Vehicle door") ~ "Dooring",

        vehicle_type == "Pedal cycle" &
          vehicle_manoeuvre == "Turning left" ~ "Left Hook",

        vehicle_type == "Pedal cycle" &
          vehicle_manoeuvre == "Turning right" ~ "Right Hook",

        vehicle_type == "Pedal cycle" &
          vehicle_manoeuvre == "Going ahead" &
          first_point_of_impact %in% c("Nearside", "Offside") ~ "Alongside",

        vehicle_type == "Pedal cycle" &
          (vehicle_manoeuvre == "Entering main road" |
           junction_location == "Entering main road") ~ "Failed to Give Way",

        vehicle_type == "Pedal cycle" ~ "Other",

        TRUE ~ NA_character_
      )
    )
}

#' @rdname classify_active_travel
#' @param ... Additional grouping variables (e.g., collision_severity)
#' @export
count_active_travel = function(vehicles, ...) {
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    stop("package dplyr required")
  }

  vehicles |>
    dplyr::filter(!is.na(active_travel_category)) |>
    dplyr::group_by(active_travel_category, ...) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop")
}

#' Filter for left hook collisions
#'
#' @param vehicles A STATS19 vehicle data frame
#' @return Filtered data frame with pedal cycles where the vehicle was turning left
#' @export
filter_left_hook = function(vehicles) {
  vehicles |>
    dplyr::filter(
      vehicle_type == "Pedal cycle",
      vehicle_manoeuvre == "Turning left"
    )
}

#' Filter for right hook collisions
#'
#' @param vehicles A STATS19 vehicle data frame
#' @return Filtered data frame with pedal cycles where the vehicle was turning right
#' @export
filter_right_hook = function(vehicles) {
  vehicles |>
    dplyr::filter(
      vehicle_type == "Pedal cycle",
      vehicle_manoeuvre == "Turning right"
    )
}

#' Filter for dooring collisions
#'
#' @param vehicles A STATS19 vehicle data frame
#' @return Filtered data frame with pedal cycles where vehicle was parked/parking
#' @export
filter_dooring = function(vehicles) {
  vehicles |>
    dplyr::filter(
      vehicle_type == "Pedal cycle",
      tolower(vehicle_manoeuvre) %in% c("parked", "parking")
    )
}

#' Filter for alongside (sideswipe) collisions
#'
#' @param vehicles A STATS19 vehicle data frame
#' @return Filtered data frame with pedal cycles in sideswipe collisions
#' @export
filter_alongside = function(vehicles) {
  vehicles |>
    dplyr::filter(
      vehicle_type == "Pedal cycle",
      vehicle_manoeuvre == "Going ahead",
      first_point_of_impact %in% c("Nearside", "Offside")
    )
}

#' Filter for failed to give way collisions
#'
#' @param vehicles A STATS19 vehicle data frame
#' @return Filtered data frame with pedal cycles where vehicle was entering main road
#' @export
filter_failed_give_way = function(vehicles) {
  vehicles |>
    dplyr::filter(
      vehicle_type == "Pedal cycle",
      vehicle_manoeuvre == "Entering main road"
    )
}