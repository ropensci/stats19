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
  expect_equal(clean_make("BMW", extract_make = FALSE), "BMW")
  expect_equal(clean_make("DAF", extract_make = FALSE), "DAF")
  expect_equal(clean_make("KTM", extract_make = FALSE), "KTM")
  expect_equal(clean_make("MAN", extract_make = FALSE), "MAN")
  expect_equal(clean_make("VDL", extract_make = FALSE), "VDL")
  expect_equal(clean_make("LEVC", extract_make = FALSE), "LEVC")
  expect_equal(clean_make("ERF", extract_make = FALSE), "ERF")
  expect_equal(clean_make("LDV", extract_make = FALSE), "LDV")
  expect_equal(clean_make("JCB", extract_make = FALSE), "JCB")
  
  # Test merges/fixes
  expect_equal(clean_make("Iveco-Ford", extract_make = FALSE), "Iveco")
  expect_equal(clean_make("Enfield", extract_make = FALSE), "Royal Enfield")
  expect_equal(clean_make("Man/Vw", extract_make = FALSE), "MAN")
  expect_equal(clean_make("Freight", extract_make = FALSE), "Freight Rover")

  # Test specific ambiguous or stylized fixes
  expect_equal(clean_make("Dennis", extract_make = FALSE), "Alexander Dennis")
  expect_equal(clean_make("Case", extract_make = FALSE), "Case IH")
  expect_equal(clean_make("London Taxis Int", extract_make = FALSE), "London Taxis International")
  # Test with extraction for London Taxis (which sets it to INTERNATIONAL)
  expect_equal(clean_make("LONDON TAXIS INTERNATIONAL TX4"), "London Taxis International")
  
  expect_equal(clean_make("Ssangyong", extract_make = FALSE), "SsangYong")
  expect_equal(clean_make("SSANGYONG KORANDO"), "SsangYong")
  
  expect_equal(clean_make("Smart", extract_make = FALSE), "smart")
  expect_equal(clean_make("SMART FORTWO"), "smart")
  
  expect_equal(clean_make("Mini", extract_make = FALSE), "MINI")
  expect_equal(clean_make("MINI COOPER"), "MINI")
  
  # Test with extract_make = TRUE (default)
  expect_equal(clean_make("FORD FIESTA"), "Ford")
  expect_equal(clean_make("LAND ROVER DISCOVERY"), "Land Rover")
  expect_equal(clean_make("RANGE ROVER EVOQUE"), "Land Rover")
  
  # Test Opel -> Vauxhall
  expect_equal(clean_make("Opel Corsa"), "Vauxhall")
  
  # Test missing values
  expect_true(is.na(clean_make("-1")))
  expect_true(is.na(clean_make("-1", extract_make = FALSE)))
  expect_true(is.na(clean_make("Make")))
  expect_true(is.na(clean_make("Other")))
  expect_true(is.na(clean_make("Generic")))
  expect_true(is.na(clean_make("All")))
  expect_true(is.na(clean_make("Int.")))
  
  # Test DAF
  expect_equal(clean_make("Daf", extract_make = FALSE), "DAF")
})

test_that("clean_model works", {
  skip_if_not_installed("stringr")
  expect_equal(clean_model("FORD FIESTA"), "Fiesta")
  expect_equal(clean_model("LAND ROVER DISCOVERY"), "Discovery")
  expect_equal(clean_model("BMW 3 SERIES"), "3 Series")
  # Test with only make
  expect_true(is.na(clean_model("FORD")))
})

test_that("clean_make_model works", {
  skip_if_not_installed("stringr")
  expect_equal(clean_make_model("FORD FIESTA"), "Ford Fiesta")
  expect_equal(clean_make_model("LAND ROVER DISCOVERY"), "Land Rover Discovery")
  expect_equal(clean_make_model("BMW 3 SERIES"), "BMW 3 Series")
  expect_equal(clean_make_model("DAF TRUCKS"), "DAF Trucks")
  expect_equal(clean_make_model("FORD"), "Ford")
})