#' Match STATS19 collisions with TAG (RAS4001) cost estimates
#'
#' @description
#' Downloads and processes the UK Department for Transport TAG Data Book
#' table **RAS4001**, and joins cost estimates to STATS19 collision data.
#' Also the option to use the ONS built up areas polygons (2022) for all of great Britain, obtained from:
#' https://open-geography-portalx-ons.hub.arcgis.com/api/download/v1/items/ad30b234308f4b02b4bb9b0f4766f7bb/geoPackage?layers=0
#'
#' Three matching modes are supported:
#'
#' - `"severity"` — cost varies only by severity (fatal/serious/slight)
#' - `"severity_road"` — cost varies by severity & road type (motorway / built_up / non_built_up)
#' - `"severity_road_bua"` — cost varies by severity & road type but road type
#'   is determined using **ONS Built-Up Area** polygons
#'
#' The function can optionally summarise total costs by severity and/or road type.
#'
#' @param crashes A STATS19 collision data frame (sf or non-sf accepted, but geometry required for BUA matching).
#' @param match_with One of `"severity"`, `"severity_road"`, `"severity_road_bua"`.
#' @param include_motorway_bua Logical; if `TRUE`, all collisions inside a built up area (BUA) are "built_up" even if motorway.
#' @param summarise Logical; if `TRUE`, returns aggregated total costs.
#'
#' @return A data frame (or sf object) with estimated TAG collision costs added,
#'         or a summary table if `summarise = TRUE`.
#'
#' @examples =
#' \dontrun{
#'   match_TAG(stats19_data, match_with = "severity_road_bua")
#' }
#'
#' @export
match_TAG = function(
    crashes,
    match_with = c("severity", "severity_road", "severity_road_bua"),
    include_motorway_bua = FALSE,
    summarise = FALSE
){


  # ---- DOWNLOAD RAS4001 ----
  url = "https://assets.publishing.service.gov.uk/media/68d421cc275fc9339a248c8e/ras4001.ods"
  tmpfile = tempfile(fileext = ".ods")

  message("Downloading RAS4001 ODS...")
  utils::download.file(url, destfile = tmpfile, mode = "wb")

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
      dplyr::transmute(collision_year = `Collision data year`,
                       collision_severity = Severity,
                       built_up = `Built-up roads (£) [note 3]`,
                       not_built_up = `Non built-up roads (£) [note 3]`,
                       Motorway = `Motorways (£) [note 3]`) |>
      dplyr::filter(collision_severity %in% c("Fatal", "Serious", "Slight")) |>
      reshape2::melt(c("collision_year", "collision_severity"), variable.name = "ons_road", value.name = "cost")

    # define road category, first by motorway or not, then speed limit and 3 collisions had no speed data but did have urban or rural, so that also used.
    tag_cost = crashes |>
      dplyr::mutate(speed_limit = as.numeric(speed_limit)) |>
      dplyr::mutate(ons_road = if_else(first_road_class == "Motorway", "Motorway", if_else(speed_limit <= "40", "built_up", "not_built_up"))) |>
      dplyr::mutate(ons_road = if_else(is.na(speed_limit) & urban_or_rural_area == "Urban", "built_up",ons_road)) |>
      dplyr::mutate(ons_road = if_else(is.na(speed_limit) & urban_or_rural_area == "Rural", "not_built_up",ons_road)) |>
      dplyr::left_join(ras4001, by = c("collision_year", "collision_severity", "ons_road"))

    if(isTRUE(summarise)){

      # summarise to severity and road type
      tag_cost = tag_cost |>
        st_set_geometry(NULL) |>
        dplyr::group_by(collision_severity, ons_road) |>
        dplyr::summarise(costs_millions = round(sum(cost)/1e6)) |>
        reshape2::dcast(collision_severity~ons_road)

    }

    return(tag_cost)

  }


  # ---------------------------------------------------------------
  #  MATCH WITH: SEVERITY + ROAD TYPE BASED ON ONS BUILT-UP AREAS
  # ---------------------------------------------------------------
  if (match_with == "severity_road_bua") {

    # read in applicable sheet and tidy up ready to be used
    ras4001 = readODS::read_ods(tmpfile, sheet = "Average_value_road_type", skip = 3) |>
      dplyr::transmute(
        collision_year     = `Collision data year`,
        collision_severity = Severity,
        built_up           = `Built-up roads (£) [note 3]`,
        not_built_up       = `Non built-up roads (£) [note 3]`,
        Motorway           = `Motorways (£) [note 3]`
      ) |>
      dplyr::filter(collision_severity %in% c("Fatal", "Serious", "Slight")) |>
      reshape2::melt(
        id.vars       = c("collision_year", "collision_severity"),
        variable.name = "ons_road",
        value.name    = "cost"
      )

    # ---- LOAD ONS BUILT-UP AREAS ----
    message("Downloading ONS Built-Up Areas gpkg...")
    bua_gb = sf::st_read(
      "https://open-geography-portalx-ons.hub.arcgis.com/api/download/v1/items/ad30b234308f4b02b4bb9b0f4766f7bb/geoPackage?layers=0",
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
        st_transform(4326) |>
        st_join(bua_gb) |>
        mutate(speed_limit = as.numeric(speed_limit)) |>
        mutate(ons_road = if_else(!is.na(BUA22CD), "built_up", if_else(first_road_class == "Motorway", "Motorway", "not_built_up"))) |>
        left_join(ras4001, by = c("collision_year", "collision_severity", "ons_road"))

    } else {

      # determine collision location based on ONS built up area shape file
      tag_cost = crashes |>
        st_transform(4326) |>
        st_join(bua_gb) |>
        mutate(speed_limit = as.numeric(speed_limit)) |>
        mutate(ons_road = if_else(first_road_class == "Motorway", "Motorway", if_else(!is.na(BUA22CD), "built_up", "not_built_up"))) |>
        left_join(ras4001, by = c("collision_year", "collision_severity", "ons_road"))

    }

    if (isTRUE(summarise)) {
      tag_cost = tag_cost |>
        sf::st_set_geometry(NULL) |>
        dplyr::group_by(collision_severity, ons_road) |>
        dplyr::summarise(costs_millions = round(sum(cost, na.rm = TRUE)/1e6)) |>
        reshape2::dcast(collision_severity ~ ons_road)
    }

    return(tag_cost)
  }

}
