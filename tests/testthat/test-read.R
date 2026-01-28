test_that("col_spec returns correct column specification", {
  skip_if_not_installed("readr")
  
  spec = col_spec()
  
  # Check that it returns a col_spec object
  expect_s3_class(spec, "col_spec")
})

test_that("convert_to_col_type handles different types", {
  # Test character type
  expect_equal(convert_to_col_type("character"), readr::col_character())
  
  # Test integer type
  expect_equal(convert_to_col_type("integer"), readr::col_integer())
  
  # Test double type
  expect_equal(convert_to_col_type("double"), readr::col_double())
  
  # Test date type
  expect_equal(convert_to_col_type("date"), readr::col_date(format = ""))
})

test_that("check_input_file validates parameters correctly", {
  skip_if_not_installed("stats19")
  
  temp_dir = tempdir()
  
  # Test with missing data - should error
  expect_error(
    check_input_file(filename = NULL, type = "collision", data_dir = temp_dir, year = 2022),
    "No files found"
  )
})

test_that("check_input_file works with valid filename", {
  skip_if_not_installed("stats19")
  
  # This test would need actual data files to work fully
  # Testing the function signature and basic structure
  expect_true(is.function(check_input_file))
  expect_equal(length(formals(check_input_file)), 4)
})

test_that("read_collisions is exported", {
  expect_true("read_collisions" %in% getNamespaceExports("stats19"))
  expect_true(is.function(read_collisions))
})

test_that("read_collisions has correct parameters", {
  params = names(formals(read_collisions))
  expect_true("year" %in% params)
  expect_true("filename" %in% params)
  expect_true("data_dir" %in% params)
  expect_true("format" %in% params)
  expect_true("silent" %in% params)
})

test_that("read_vehicles is exported", {
  expect_true("read_vehicles" %in% getNamespaceExports("stats19"))
  expect_true(is.function(read_vehicles))
})

test_that("read_vehicles has correct parameters", {
  params = names(formals(read_vehicles))
  expect_true("year" %in% params)
  expect_true("filename" %in% params)
  expect_true("data_dir" %in% params)
  expect_true("format" %in% params)
})

test_that("read_casualties is exported", {
  expect_true("read_casualties" %in% getNamespaceExports("stats19"))
  expect_true(is.function(read_casualties))
})

test_that("read_casualties has correct parameters", {
  params = names(formals(read_casualties))
  expect_true("year" %in% params)
  expect_true("filename" %in% params)
  expect_true("data_dir" %in% params)
  expect_true("format" %in% params)
})

test_that("read_null returns NULL", {
  result = read_null("some_path")
  expect_null(result)
})

test_that("read_ve_ca is a function", {
  expect_true(is.function(read_ve_ca))
  expect_equal(length(formals(read_ve_ca)), 1)
})
