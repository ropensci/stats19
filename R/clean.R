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
  
  # Force uppercase and remove parentheses for consistent matching
  generic_make_model = toupper(generic_make_model)
  generic_make_model = stringr::str_remove_all(generic_make_model, "\\s*\\([^\\)]+\\)")
  generic_make_model = stringr::str_trim(generic_make_model)
  
  # Handle multi-word makes first
  make = dplyr::case_when(
    stringr::str_starts(generic_make_model, "ALFA ROMEO") ~ "ALFA ROMEO",
    stringr::str_starts(generic_make_model, "ASTON MARTIN") ~ "ASTON MARTIN",
    stringr::str_starts(generic_make_model, "AUSTIN MORRIS") ~ "AUSTIN MORRIS",
    stringr::str_starts(generic_make_model, "LAND ROVER") ~ "LAND ROVER",
    stringr::str_starts(generic_make_model, "RANGE ROVER") ~ "LAND ROVER",
    stringr::str_starts(generic_make_model, "LONDON TAXIS") ~ "LONDON TAXIS INTERNATIONAL",
    stringr::str_starts(generic_make_model, "JOHN DEERE") ~ "JOHN DEERE",
    stringr::str_starts(generic_make_model, "NEW HOLLAND") ~ "NEW HOLLAND",
    stringr::str_starts(generic_make_model, "ALEXANDER DENNIS") ~ "ALEXANDER DENNIS",
    stringr::str_starts(generic_make_model, "ROYAL ENFIELD") ~ "ROYAL ENFIELD",
    stringr::str_starts(generic_make_model, "ROLLS ROYCE") ~ "ROLLS ROYCE",
    stringr::str_starts(generic_make_model, "MASSEY FERGUSON") ~ "MASSEY FERGUSON",
    stringr::str_starts(generic_make_model, "LEYLAND DAF") ~ "LEYLAND DAF",
    stringr::str_starts(generic_make_model, "DAF TRUCKS") ~ "DAF",
    stringr::str_starts(generic_make_model, "LEYLAND CARS MINI") ~ "MINI",
    stringr::str_starts(generic_make_model, "IVECO FORD") ~ "IVECO",
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
    make %in% c("-1", "Make", "Other", "All", "Better", "Easy", "David", "White", "Int.", "Data") ~ NA_character_,
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
    make == "Leyland Daf" ~ "DAF",
    
    # Specific ambiguous or stylized fixes
    make == "Dennis" ~ "Alexander Dennis",
    make == "Case" ~ "Case IH",
    make == "London Taxis Int" ~ "London Taxis International",
    make == "London Taxis International" ~ "London Taxis International",
    make == "Ssangyong" ~ "SsangYong",
    make %in% c("Smart", "smart") ~ "smart",
    make == "Mini" ~ "MINI",
    
    # Merges
    make == "Iveco-Ford" ~ "Iveco",
    make == "Enfield" ~ "Royal Enfield",
    stringr::str_detect(make, "Man/Vw") ~ "MAN", # Handle Man/Vw
    
    # Ambiguous/Fixes
    make == "Int." ~ "International",
    make == "Freight" ~ "Freight Rover",
    stringr::str_detect(make, "Redacted") ~ NA_character_,
    
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
  
  # Pre-process: Uppercase, remove parentheses
  model_upper = toupper(model)
  model_clean = stringr::str_remove_all(model_upper, "\\s*\\([^\\)]+\\)")
  model_clean = stringr::str_trim(model_clean)
  
  # Extract the make part (using the same logic as extract_make)
  make_part = extract_make_stats19(model_clean)
  
  # Remove the make part from the start of the string
  # We use nchar to know how much to chop off, plus 1 for the space
  model_only = stringr::str_sub(model_clean, start = nchar(make_part) + 2)
  model_only = stringr::str_trim(model_only)
  
  # Strip "TRUCKS" if present (often part of DAF TRUCKS but make is DAF)
  model_only = stringr::str_remove(model_only, "^TRUCKS\\s*")
  
  model_only = dplyr::na_if(model_only, "")
  
  # Vectorized check for invalid strings
  is_invalid = stringr::str_detect(model_clean, "REDACTED") | 
               stringr::str_detect(model_only, "MISSING") |
               model_only %in% c("AND MODEL REDACTED", "MISSING OR OUT OF RANGE", "MODEL UNKNOWN")
               
  # Handle NAs properly in condition
  is_invalid[is.na(is_invalid)] = FALSE
  
  model_only = dplyr::if_else(is_invalid, NA_character_, model_only)
  
  # Convert numeric-looking strings to proper format (e.g., "1.0" -> "1")
  # Only if it looks like a decimal number with trailing .0
  is_whole_number = stringr::str_detect(model_only, "^[0-9]+\\.0$")
  model_only = dplyr::if_else(is_whole_number, 
                               stringr::str_remove(model_only, "\\.0$"),
                               model_only)
  
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