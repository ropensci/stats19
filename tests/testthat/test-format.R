source("../skip-download.R")

context("test-format: accidents")

test_that("format_accidents works", {
  df = format_accidents(stats19::accidents_sample_raw)
  expect_equal(nrow(df), nrow(stats19::accidents_sample_raw))
})

context("test-format: vehicles")

test_that("format_vehicles works", {
  fn = stats19::file_names$dftRoadSafetyData_Vehicles_2016.zip
  skip_download()
  dl_stats19(file_name = fn)
  # read it
  read = read_vehicles(
    year = 2016,
    data_dir = tempdir(),
    filename = "Veh.csv"
  )
  df = format_vehicles(head(read))
  expect_true(is(df, "data.frame"))
})

context("test-format: casualties")

test_that("format_casualties works", {
  fn = stats19::file_names$dftRoadSafetyData_Casualties_2016.zip
  skip_download()
  dl_stats19(file_name = fn)
  # read it
  read = read_casualties(
    year = 2016,
    data_dir = tempdir(),
    filename = "Cas.csv"
  )
  df = format_casualties(head(read))
  expect_true(is(df, "data.frame"))
})

context("test-format: sf")
test_that("format_column_names works", {
  # basic
  rd = names(stats19::accidents_sample_raw)
  expect_equal(nrow(rd), nrow(format_column_names(rd)))
})
test_that("format_sf works", {
  rd = format_accidents(stats19::accidents_sample_raw)
  df1 = format_sf(rd)
  df2 = format_sf(rd, lonlat = TRUE)
  expect_equal(nrow(df1), nrow(rd))
  expect_equal(nrow(df2), nrow(rd))
  expect_true(is(df1, "sf"))
  expect_true(is(df2, "sf"))
})
