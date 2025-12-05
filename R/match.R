#' Match STATS19 collisions with TAG (RAS4001) cost estimates
#'
#' @description
#' Downloads and processes the UK Department for Transport **TAG Data Book**
#' table **RAS4001**, and joins estimated collision costs to STATS19 data.
#'
#' Three matching modes are available:
#'
#' * `"severity"` — cost varies only by collision severity
#' * `"severity_road"` — cost varies by severity *and* road type
#' * `"severity_road_bua"` — cost varies by severity & road type, where road
#'   type is determined using **ONS Built-Up Area (BUA)** polygons (2022)
#'
#' BUA polygons are downloaded automatically from:
#' <https://open-geography-portalx-ons.hub.arcgis.com/api/download/v1/items/ad30b234308f4b02b4bb9b0f4766f7bb/geoPackage?layers=0>
#'
#' Optionally, total costs may be summarised by severity and/or road type.
#'
#' @param crashes A STATS19 collision data frame. May be `sf` or non-`sf`,
#'   but spatial geometry is required when using `"severity_road_bua"`.
#'
#' @param shapes_url URL to download the ONS Built-Up Areas geopackage.
#'   Defaults to the official ONS 2022 dataset.
#'
#' @param costs_url URL to download the TAG Data Book **RAS4001** table
#'   (ODS format). Defaults to the Department for Transport asset link.
#'
#' @param match_with Character string specifying the matching mode.
#'   One of:
#'   * `"severity"`
#'   * `"severity_road"`
#'   * `"severity_road_bua"`
#'
#'   The default uses `match_with = c("severity", "severity_road", "severity_road_bua")`,
#'   so users get tab-completion and help in RStudio.
#'
#' @param include_motorway_bua Logical; if `TRUE`, motorways inside a built-up
#'   area polygon are treated as `"built_up"` rather than `"Motorway"`.
#'
#' @param summarise Logical; if `TRUE`, returns a summary table of total
#'   costs (in millions) grouped by severity and/or road type.
#'
#' @details
#' The function:
#'
#' 1. Downloads and parses **RAS4001** cost tables
#' 2. Computes road type using STATS19 fields or optional BUA polygons
#' 3. Joins appropriate cost estimates
#' 4. Optionally aggregates totals
#'
#' When `crashes` is an `sf` object and `summarise = TRUE`, geometry is
#' automatically dropped.
#'
#' @return
#' A data frame (or `sf` object if input is `sf`) with added columns for
#' estimated collision costs.
#' If `summarise = TRUE`, a summary table of total costs (in millions) is returned.
#'
#' @examples
#' \dontrun{
#'   # Simple severity-based matching
#'   match_tag(stats19_df, match_with = "severity")
#'
#'   # Severity + road type
#'   match_tag(stats19_df, match_with = "severity_road")
#'
#'   # Using ONS Built-Up Areas, with motorway override
#'   match_tag(
#'     stats19_df,
#'     match_with = "severity_road_bua",
#'     include_motorway_bua = TRUE
#'   )
#'
#'   # Summarised totals
#'   match_tag(stats19_df, match_with = "severity", summarise = TRUE)
#' }
#'
#' @export
match_tag = function(
    crashes,
    shapes_url = "https://open-geography-portalx-ons.hub.arcgis.com/api/download/v1/items/ad30b234308f4b02b4bb9b0f4766f7bb/geoPackage?layers=0",
    costs_url = "https://assets.publishing.service.gov.uk/media/68d421cc275fc9339a248c8e/ras4001.ods",
    match_with = "severity",
    include_motorway_bua = FALSE,
    summarise = FALSE
){

  # ---- DOWNLOAD RAS4001 ----

  tmpfile = tempfile(fileext = ".ods")

  message("Downloading RAS4001 ODS...")
  utils::download.file(costs_url, destfile = tmpfile, mode = "wb")

  # ---------------------------------------------------------------
  #  MATCH WITH: SEVERITY ONLY
  # ---------------------------------------------------------------
  if (match_with == "severity") {

    # read in applicable sheet and fix messy headers and convert some columns to numeric for future calcs
    ras4001 = readODS::read_ods(tmpfile, sheet = "Average_value", skip = 5,
                                col_names = FALSE) |>
      dplyr::transmute(
        collision_year      = ...1,
        collision_severity  = ...3,
        cost_per_casualty   = as.numeric(...4),
        cost_per_collision  = as.numeric(...5)
      )

    # join with year and severity only
    tag_cost = crashes |>
      dplyr::left_join(ras4001, by = c("collision_year", "collision_severity"))

    # if summarise option summarise by only these two parameters otherwise original crashes df returned with additional columns for cost
    if (isTRUE(summarise)) {
      tag_cost = tag_cost |>
        dplyr::group_by(collision_severity) |>
        dplyr::summarise(
          casualty_cost_millions  = round(sum(cost_per_casualty, na.rm = TRUE) / 1e6),
          collision_cost_millions = round(sum(cost_per_collision, na.rm = TRUE) / 1e6)
        )
    }

    return(tag_cost)
  }


  # ---------------------------------------------------------------
  #  MATCH WITH: SEVERITY + ROAD TYPE
  # ---------------------------------------------------------------
  if(match_with == "severity_road"){

    # get table average_value_road_type
    ras4001 = readODS::read_ods(tmpfile, sheet = "Average_value_road_type", skip = 3) |>
      dplyr::rename(
        built_up = tidyselect::matches("Built-up roads"),
        not_built_up = tidyselect::matches("Non built-up roads"),
        Motorway = tidyselect::matches(c("A(M)", "Motorways"))
      ) |>
      dplyr::transmute(collision_year = `Collision data year`,
                       collision_severity = Severity,
                       built_up = built_up1,
                       not_built_up,
                       Motorway) |>
      dplyr::filter(collision_severity %in% c("Fatal", "Serious", "Slight")) |>
      tidyr::pivot_longer(
        cols = -c(collision_year, collision_severity),
        names_to = "ons_road",
        values_to = "cost"
      )

    # define road category, first by motorway or not, then speed limit and 3 collisions had no speed data but did have urban or rural, so that also used.
    tag_cost = crashes |>
      dplyr::mutate(speed_limit = as.numeric(speed_limit)) |>
      dplyr::mutate(ons_road = ifelse(first_road_class %in% c("A(M)", "Motorway"), "Motorway", ifelse(speed_limit <= "40", "built_up", "not_built_up"))) |>
      dplyr::mutate(ons_road = ifelse(is.na(speed_limit) & urban_or_rural_area == "Urban", "built_up",ons_road)) |>
      dplyr::mutate(ons_road = ifelse(is.na(speed_limit) & urban_or_rural_area == "Rural", "not_built_up",ons_road)) |>
      dplyr::left_join(ras4001, by = c("collision_year", "collision_severity", "ons_road"))

    if(isTRUE(summarise)){

      if (inherits(tag_cost, "sf")) {
        tag_cost <- sf::st_set_geometry(tag_cost, NULL)
      }

      # summarise to severity and road type
      tag_cost = tag_cost |>
        dplyr::group_by(collision_severity, ons_road) |>
        dplyr::summarise(costs_millions = round(sum(cost)/1e6)) |>
        tidyr::pivot_wider(
          names_from  = ons_road,
          values_from = costs_millions
        )

    }

    return(tag_cost)

  }


  # ---------------------------------------------------------------
  #  MATCH WITH: SEVERITY + ROAD TYPE BASED ON ONS BUILT-UP AREAS
  # ---------------------------------------------------------------
  if (match_with == "severity_road_bua") {

    # read in applicable sheet and tidy up ready to be used
    ras4001 = readODS::read_ods(tmpfile, sheet = "Average_value_road_type", skip = 3) |>
      dplyr::rename(
        built_up = tidyselect::matches("Built-up roads"),
        not_built_up = tidyselect::matches("Non built-up roads"),
        Motorway = tidyselect::matches(c("A(M)", "Motorways"))
      ) |>
      dplyr::transmute(collision_year = `Collision data year`,
                       collision_severity = Severity,
                       built_up = built_up1,
                       not_built_up,
                       Motorway) |>
      dplyr::filter(collision_severity %in% c("Fatal", "Serious", "Slight")) |>
      tidyr::pivot_longer(
        cols = -c(collision_year, collision_severity),
        names_to = "ons_road",
        values_to = "cost"
      )

    # ---- LOAD ONS BUILT-UP AREAS ----
    message("Downloading ONS Built-Up Areas gpkg...")
    bua_gb = sf::st_read(
      shapes_url,
      quiet = TRUE
    ) |>
      dplyr::select(BUA22CD, BUA22NM, SHAPE) |>
      sf::st_transform(4326) |>
      sf::st_make_valid()

    # ensure geometry exists
    if (!inherits(crashes, "sf")){
      crashes = crashes |>
        format_sf()
    }

    # should motorways running through built up areas be considered built up?
    if(isTRUE(include_motorway_bua)){

      # determine collision location based on ONS built up area shape file
      tag_cost = crashes |>
        sf::st_transform(4326) |>
        sf::st_join(bua_gb) |>
        dplyr::mutate(speed_limit = as.numeric(speed_limit)) |>
        # logical test, is it inside bua shape file? If yes "built up", if not is it on a mway, if so mway, everything else is not built up
        dplyr::mutate(ons_road = ifelse(!is.na(BUA22CD), "built_up", ifelse(first_road_class %in% c("A(M)", "Motorway"), "Motorway", "not_built_up"))) |>
        dplyr::left_join(ras4001, by = c("collision_year", "collision_severity", "ons_road"))

    } else {

      # determine collision location based on ONS built up area shape file
      tag_cost = crashes |>
        sf::st_transform(4326) |>
        sf::st_join(bua_gb) |>
        dplyr::mutate(speed_limit = as.numeric(speed_limit)) |>
        # logical test, it a motorway? If so "motorway", if not is it inside built up area shape file? if so "built up", if not "not built up"
        dplyr::mutate(ons_road = ifelse(first_road_class %in% c("A(M)", "Motorway"), "Motorway", ifelse(!is.na(BUA22CD), "built_up", "not_built_up"))) |>
        dplyr::left_join(ras4001, by = c("collision_year", "collision_severity", "ons_road"))

    }

    if (isTRUE(summarise)) {

      if (inherits(tag_cost, "sf")) {
        tag_cost <- sf::st_set_geometry(tag_cost, NULL)
      }

      tag_cost = tag_cost |>
        dplyr::group_by(collision_severity, ons_road) |>
        dplyr::summarise(costs_millions = round(sum(cost, na.rm = TRUE)/1e6)) |>
        tidyr::pivot_wider(
          names_from  = ons_road,
          values_from = costs_millions
        )
    }

    return(tag_cost)
  }

}
