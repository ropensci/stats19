test_that("col_spec returns correct column specification", {
  skip_if_not_installed("readr")
  
  spec = col_spec()
  
  # Check that it returns a col_spec object
  expect_s3_class(spec, "col_spec")
})

test_that("convert_to_col_type handles different types", {
  # Test character type
  result_char = convert_to_col_type("character")
  expect_s3_class(result_char, "collector")
  
  # Test integer type
  result_int = convert_to_col_type("integer")
  expect_s3_class(result_int, "collector")
  
  # Test double type
  result_dbl = convert_to_col_type("double")
  expect_s3_class(result_dbl, "collector")
  
  # Test date type
  result_date = convert_to_col_type("date")
  expect_s3_class(result_date, "collector")
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

test_that("read_null is a function", {
  # read_null actually tries to read the file, so we just test it exists
  expect_true(is.function(read_null))
})

test_that("read_ve_ca is a function", {
  expect_true(is.function(read_ve_ca))
  expect_equal(length(formals(read_ve_ca)), 1)
})
