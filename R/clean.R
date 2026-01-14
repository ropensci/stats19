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
    stringr::str_starts(generic_make_model, "LONDON TAXIS") ~ "LONDON TAXIS INTERNATIONAL",
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
    make %in% c("GM", "BYD", "VW", "NIO", "ORA", "IM", "MG", "MINI", "EV", "EV6", "EV9", "EQC", "EQB", "EQA", "EQE", "XPENG", "CUPRA", "DS", "GEELY", "SAIC", "BMW", "DAF", "KTM", "MAN", "VDL", "LEVC", "ERF", "LDV", "MCW", "JCB", "MZ", "MCC", "BSA", "TVR", "CZ", "MBK", "AJS", "CPI", "PGO") ~ make,
    TRUE ~ stringr::str_to_title(make)
  )
  # Clean up synonyms and multi-word standardizations
  make = dplyr::case_when(
    make %in% c("-1", "Make", "Other", "Generic", "All", "Better", "Easy", "David", "White", "Int.") ~ NA_character_,
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
    # DAF
    make == "Daf" ~ "DAF",
    # Specific ambiguous or stylized fixes
    make == "Dennis" ~ "Alexander Dennis",
    make == "Case" ~ "Case IH",
    make == "London Taxis Int" ~ "London Taxis International",
    make == "Ssangyong" ~ "SsangYong",
    make %in% c("Smart", "smart") ~ "smart",
    make == "Mini" ~ "MINI",
    
    # Merges
    make == "Iveco-Ford" ~ "Iveco",
    make == "Enfield" ~ "Royal Enfield",
    stringr::str_detect(make, "Man/Vw") ~ "MAN", # Handle Man/Vw
    
    # Ambiguous/Fixes
    make == "Freight" ~ "Freight Rover",
    
    TRUE ~ make
  )
  make
}

#' Clean vehicle model
#'
#' This function cleans the model of the vehicle.
#' It extracts the make using \code{extract_make_stats19} and removes it from the string,
#' returning the remaining text as the model in title case.
#'
#' @param model A character vector of generic make/model strings
#' @export
#' @examples
#' clean_model(c("FORD FIESTA", "BMW 3 SERIES"))
clean_model = function(model) {
  if (!requireNamespace("stringr", quietly = TRUE)) {
    stop("package stringr required, please install it first")
  }
  
  # Extract the make part
  make_part = extract_make_stats19(model)
  
  # Remove the make part from the start of the string
  # We use nchar to know how much to chop off, plus 1 for the space
  # If make_part is same as model (e.g. just "FORD"), result is empty
  
  model_only = stringr::str_sub(model, start = nchar(make_part) + 2)
  
  # Handle cases where model is empty or just whitespace
  model_only = stringr::str_trim(model_only)
  model_only = dplyr::na_if(model_only, "")
  
  stringr::str_to_title(model_only)
}

#' Clean vehicle make and model
#'
#' This function returns a combined cleaned make and model string.
#' It uses \code{clean_make} and \code{clean_model} to standardize both parts.
#'
#' @param generic_make_model A character vector of generic make/model strings
#' @export
#' @examples
#' clean_make_model(c("FORD FIESTA", "BMW 3 SERIES"))
clean_make_model = function(generic_make_model) {
  make = clean_make(generic_make_model)
  model = clean_model(generic_make_model)
  
  # Combine, handling NAs
  # If model is NA, just return make. If make is NA, return NA? 
  # Usually make is key.
  
  res = paste(make, model)
  res = stringr::str_remove(res, " NA") # If model is NA
  res = stringr::str_remove(res, "NA ") # If make is NA (unlikely if model exists?)
  
  # If both NA -> "NA" -> NA
  dplyr::case_when(
    res == "NA" ~ NA_character_,
    TRUE ~ res
  )
}