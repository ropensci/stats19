test_that("clean_make works", {
  skip_if_not_installed("stringr")
  
  expect_equal(clean_make("VW"), "Volkswagen")
  expect_equal(clean_make("Volksw"), "Volkswagen")
  expect_equal(clean_make("Citro"), "Citroen")
  expect_equal(clean_make("Merc"), "Mercedes")
  expect_equal(clean_make("Range Rover"), "Land Rover")
  expect_equal(clean_make("Geely"), "Geely")
  expect_equal(clean_make("Skoda"), "Skoda")
  expect_equal(clean_make("oda"), "Skoda")
  expect_equal(clean_make("FORD"), "Ford")
  
  # Check preserved upper case
  expect_equal(clean_make("GM"), "GM")
  expect_equal(clean_make("MG"), "MG")
})

test_that("clean_model works", {
  skip_if_not_installed("stringr")
  expect_equal(clean_model("FIESTA"), "Fiesta")
  expect_equal(clean_model("ka"), "Ka")
})
