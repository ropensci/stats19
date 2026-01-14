#' Clean vehicle make
#'
#' This function cleans the make of the vehicle.
#'
#' @param make A character vector of vehicle makes
#' @export
#' @examples
#' clean_make(c("VW", "Mercedez"))
clean_make = function(make) {
  if (!requireNamespace("stringr", quietly = TRUE)) {
    stop("package stringr required, please install it first")
  }

  make = dplyr::case_when(
    make %in% c("GM", "BYD", "VW", "NIO", "ORA", "IM", "MG", "MINI", "EV", "EV6", "EV9", "EQC", "EQB", "EQA", "EQE", "XPENG", "CUPRA", "DS", "GEELY", "SAIC") ~ make,
    TRUE ~ stringr::str_to_title(make)
  )
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
    #
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
