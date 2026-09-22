# Table-driven tests. Each case is one row of input = expected, so a new DfT
# spelling is a one-line change, duplicated cases are visible at a glance, and
# failure messages name the input that broke.

extract_make_cases = c(
  "FORD FIESTA" = "FORD",
  "LAND ROVER DISCOVERY" = "LAND ROVER",
  "RANGE ROVER EVOQUE" = "LAND ROVER",
  "ALFA ROMEO GIULIETTA" = "ALFA ROMEO",
  "UNKNOWN MAKE" = "UNKNOWN"
)

clean_make_no_extract = c(
  # Abbreviations and truncated names
  "VW" = "Volkswagen",
  "Volksw" = "Volkswagen",
  "Citro" = "Citroen",
  "Merc" = "Mercedes",
  "Range Rover" = "Land Rover",
  "Geely" = "Geely",
  "Skoda" = "Skoda",
  "oda" = "Skoda",
  "FORD" = "Ford",
  # Makes whose upper case is preserved
  "GM" = "GM",
  "MG" = "MG",
  "BMW" = "BMW",
  "DAF" = "DAF",
  "Daf" = "DAF",
  "KTM" = "KTM",
  "MAN" = "MAN",
  "VDL" = "VDL",
  "LEVC" = "LEVC",
  "ERF" = "ERF",
  "LDV" = "LDV",
  "JCB" = "JCB",
  # Merges, splits and stylised names
  "Iveco-Ford" = "Iveco",
  "Enfield" = "Royal Enfield",
  "Man/Vw" = "MAN",
  "Freight" = "Freight Rover",
  "Dennis" = "Alexander Dennis",
  "Case" = "Case IH",
  "London Taxis Int" = "London Taxis International",
  "Ssangyong" = "SsangYong",
  "Smart" = "smart",
  "Mini" = "MINI",
  # Missing value
  "-1" = NA_character_
)

clean_make_extract = c(
  # Make extracted from a full make and model string
  "FREIGHT ROVER SHERPA" = "Freight Rover",
  "AUSTIN MORRIS MINI" = "Austin Morris",
  "LONDON TAXIS INTERNATIONAL TX4" = "London Taxis International",
  "SSANGYONG KORANDO" = "SsangYong",
  "SMART FORTWO" = "smart",
  "MINI COOPER" = "MINI",
  "FORD FIESTA" = "Ford",
  "LAND ROVER DISCOVERY" = "Land Rover",
  "RANGE ROVER EVOQUE" = "Land Rover",
  # Advanced rules
  "VOLVO MODEL MISSING" = "Volvo",
  "MAKE AND MODEL REDACTED" = NA_character_,
  "VESPA (DOUGLAS)" = "Vespa",
  "BRISTOL (BLMC)" = "Bristol",
  "IVECO-FORD" = "Iveco",
  "IVECO FORD CARGO" = "Iveco",
  "LEYLAND DAF 45" = "DAF",
  "LEYLAND CARS MINI" = "MINI",
  "DAF TRUCKS CF" = "DAF",
  "Alexander Dennis" = "Alexander Dennis",
  "ALEXANDER DENNIS" = "Alexander Dennis",
  "Daf Trucks" = "DAF",
  "DAF TRUCKS" = "DAF",
  # Missing or uninformative values
  "-1" = NA_character_,
  "Make" = NA_character_,
  "Other" = NA_character_,
  "Generic" = NA_character_,
  "All" = NA_character_,
  "Int." = NA_character_
)

clean_model_cases = c(
  "FORD FIESTA" = "Fiesta",
  "LAND ROVER DISCOVERY" = "Discovery",
  "BMW 3 SERIES" = "3 Series",
  "VESPA (DOUGLAS) 150" = "150",
  "DAF TRUCKS CF" = "Cf",
  # Missing, redacted or make-only values
  "FORD" = NA_character_,
  "VOLVO MODEL MISSING" = NA_character_,
  "MAKE AND MODEL REDACTED" = NA_character_,
  "TALBOT Model Unknown" = NA_character_
)

clean_make_model_cases = c(
  "FORD FIESTA" = "Ford Fiesta",
  "LAND ROVER DISCOVERY" = "Land Rover Discovery",
  "BMW 3 SERIES" = "BMW 3 Series",
  "DAF TRUCKS" = "DAF",
  "FORD" = "Ford"
)

# Check every input = expected pair, naming the input in any failure
expect_lookup = function(cases, fun, ...) {
  for (input in names(cases)) {
    expected = cases[[input]]
    actual = fun(input, ...)
    if (is.na(expected)) {
      expect_true(is.na(actual), info = input)
    } else {
      expect_equal(actual, expected, info = input)
    }
  }
}

test_that("extract_make_stats19 works", {
  skip_if_not_installed("stringr")
  expect_lookup(extract_make_cases, extract_make_stats19)
})

test_that("clean_make works", {
  skip_if_not_installed("stringr")
  expect_lookup(clean_make_no_extract, clean_make, extract_make = FALSE)
  expect_lookup(clean_make_extract, clean_make)
})

test_that("clean_model works", {
  skip_if_not_installed("stringr")
  expect_lookup(clean_model_cases, clean_model)
})

test_that("clean_make_model works", {
  skip_if_not_installed("stringr")
  expect_lookup(clean_make_model_cases, clean_make_model)
})
