#' Extract vehicle make from generic make/model string
#'
#' This function extracts the make from a generic make/model string, handling multi-word makes.
#'
#' @param generic_make_model A character vector of generic make/model strings
#' @export
#' @examples
#' extract_make_stats19(c("FORD FIESTA", "LAND ROVER DISCOVERY"))
extract_make_stats19 = function(generic_make_model) {
  if (!requireNamespace("stringr", quietly = TRUE)) {
    stop("package stringr required, please install it first")
  }
  
  # Handle multi-word makes first
  make = dplyr::case_when(
    stringr::str_starts(generic_make_model, "ALFA ROMEO") ~ "ALFA ROMEO",
    stringr::str_starts(generic_make_model, "ASTON MARTIN") ~ "ASTON MARTIN",
    stringr::str_starts(generic_make_model, "LAND ROVER") ~ "LAND ROVER",
    stringr::str_starts(generic_make_model, "RANGE ROVER") ~ "LAND ROVER",
    stringr::str_starts(generic_make_model, "LONDON TAXIS") ~ "LONDON TAXIS INT",
    stringr::str_starts(generic_make_model, "JOHN DEERE") ~ "JOHN DEERE",
    stringr::str_starts(generic_make_model, "NEW HOLLAND") ~ "NEW HOLLAND",
    stringr::str_starts(generic_make_model, "ALEXANDER DENNIS") ~ "ALEXANDER DENNIS",
    stringr::str_starts(generic_make_model, "ROYAL ENFIELD") ~ "ROYAL ENFIELD",
    stringr::str_starts(generic_make_model, "ROLLS ROYCE") ~ "ROLLS ROYCE",
    stringr::str_starts(generic_make_model, "MASSEY FERGUSON") ~ "MASSEY FERGUSON",
    # Default to first word
    TRUE ~ stringr::str_split(generic_make_model, " ", n = 2, simplify = TRUE)[,1]
  )
  return(make)
}

#' Clean vehicle make
#'
#' This function cleans the make of the vehicle.
#'
#' @param make A character vector of vehicle makes. Can be raw generic make/model strings if extract_make is TRUE.
#' @param extract_make Logical, whether to extract the make from the input string using extract_make_stats19 first. Default is TRUE.
#' @export
#' @examples
#' clean_make(c("VW", "Mercedez"))
#' clean_make(c("FORD FIESTA", "LAND ROVER DISCOVERY"), extract_make = TRUE)
clean_make = function(make, extract_make = TRUE) {
  if (!requireNamespace("stringr", quietly = TRUE)) {
    stop("package stringr required, please install it first")
  }

  if (extract_make) {
    make = extract_make_stats19(make)
  }

  # Standardize casing for specific brands
  make = dplyr::case_when(
    make %in% c("GM", "BYD", "VW", "NIO", "ORA", "IM", "MG", "MINI", "EV", "EV6", "EV9", "EQC", "EQB", "EQA", "EQE", "XPENG", "CUPRA", "DS", "GEELY", "SAIC", "BMW") ~ make,
    TRUE ~ stringr::str_to_title(make)
  )
  # Clean up synonyms and multi-word standardizations
  make = dplyr::case_when(
    stringr::str_detect(make, "Volksw|VW") ~ "Volkswagen",
    stringr::str_detect(make, "Citro") ~ "Citroen",
    # Mercs are Mercedes
    stringr::str_detect(make, "Merc") ~ "Mercedes",
    # Range Rover is Land Rover
    stringr::str_detect(make, "Range Rover") ~ "Land Rover",
    # Any string containing GEELY is Geely
    stringr::str_detect(make, "Geely") ~ "Geely",
    # *oda is Skoda
    stringr::str_detect(make, "oda|Oda") ~ "Skoda",
    stringr::str_detect(make, "Opel") ~ "Vauxhall",
    TRUE ~ make
  )
  make
}

#' Clean vehicle model
#'
#' This function cleans the model of the vehicle.
#'
#' @param model A character vector of vehicle models
#' @export
#' @examples
#' clean_model(c("FIESTA", "ka"))
clean_model = function(model) {
  if (!requireNamespace("stringr", quietly = TRUE)) {
    stop("package stringr required, please install it first")
  }
  stringr::str_to_title(model)
}