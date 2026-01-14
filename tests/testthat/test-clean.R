test_that("extract_make_stats19 works", {
  skip_if_not_installed("stringr")
  
  expect_equal(extract_make_stats19("FORD FIESTA"), "FORD")
  expect_equal(extract_make_stats19("LAND ROVER DISCOVERY"), "LAND ROVER")
  expect_equal(extract_make_stats19("RANGE ROVER EVOQUE"), "LAND ROVER")
  expect_equal(extract_make_stats19("ALFA ROMEO GIULIETTA"), "ALFA ROMEO")
  expect_equal(extract_make_stats19("UNKNOWN MAKE"), "UNKNOWN")
})

test_that("clean_make works", {
  skip_if_not_installed("stringr")
  
  # Previous tests (with extract_make = FALSE implicit or explicit if we passed cleaned makes)
  # But now default is extract_make = TRUE.
  # If we pass simple makes, extract_make should just return them if they are single words,
  # or handle them if they are the multi-word ones.
  
  expect_equal(clean_make("VW", extract_make = FALSE), "Volkswagen")
  expect_equal(clean_make("Volksw", extract_make = FALSE), "Volkswagen")
  expect_equal(clean_make("Citro", extract_make = FALSE), "Citroen")
  expect_equal(clean_make("Merc", extract_make = FALSE), "Mercedes")
  expect_equal(clean_make("Range Rover", extract_make = FALSE), "Land Rover")
  expect_equal(clean_make("Geely", extract_make = FALSE), "Geely")
  expect_equal(clean_make("Skoda", extract_make = FALSE), "Skoda")
  expect_equal(clean_make("oda", extract_make = FALSE), "Skoda")
  expect_equal(clean_make("FORD", extract_make = FALSE), "Ford")
  
  # Check preserved upper case
  expect_equal(clean_make("GM", extract_make = FALSE), "GM")
  expect_equal(clean_make("MG", extract_make = FALSE), "MG")
  
  # Test with extract_make = TRUE (default)
  expect_equal(clean_make("FORD FIESTA"), "Ford")
  expect_equal(clean_make("LAND ROVER DISCOVERY"), "Land Rover")
  expect_equal(clean_make("RANGE ROVER EVOQUE"), "Land Rover")
  
  # Test the specific multi-word cleaning logic in clean_make
  # e.g. "Land" -> "Land Rover"
  expect_equal(clean_make("Land", extract_make = FALSE), "Land Rover")
  expect_equal(clean_make("Alfa", extract_make = FALSE), "Alfa Romeo")
  
  # Test Opel -> Vauxhall
  expect_equal(clean_make("Opel Corsa"), "Vauxhall")
})

test_that("clean_model works", {
  skip_if_not_installed("stringr")
  expect_equal(clean_model("FIESTA"), "Fiesta")
  expect_equal(clean_model("ka"), "Ka")
})