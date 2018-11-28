context("test-format-read_schema")

test_that("read_schema works", {
  skip_download()
  t = stats19::read_schema()
  expect_equal(nrow(t), 969)
})

context("test-format: accidents")

test_that("format_accidents works", {
  df = format_accidents(stats19::accidents_2016_sample)
  expect_equal(nrow(df), 2)
})

context("test-format: vehicles")

test_that("format_vehicles works", {
  fn = stats19::file_names$dftRoadSafetyData_Vehicles_2017.zip
  skip_download()
  dl_stats19(file_name = fn)
  path = file.path(
    tempdir(), sub(".zip", "", fn))
  # read it
  read = read_vehicles(
    data_dir = path,
    filename = "Veh.csv"
  )
  df = format_vehicles(head(read))
  expect_true(is(df, "data.frame"))
})

context("test-format: casualties")

test_that("format_casualties works", {
  fn = stats19::file_names$dftRoadSafetyData_Casualties_2017.zip
  skip_download()
  dl_stats19(file_name = fn)
  path = file.path(
    tempdir(), sub(".zip", "", fn))
  # read it
  read = read_casualties(
    data_dir = path,
    filename = "Cas.csv"
  )
  df = format_casualties(head(read))
  expect_true(is(df, "data.frame"))
})

context("test-format: sf")

test_that("format_sf works", {
  rd = format_accidents(stats19::accidents_2016_sample)
  df1 = format_sf(rd)
  df2 = format_sf(rd, lonlat = TRUE)
  expect_equal(nrow(df1), 2)
  expect_equal(nrow(df2), 2)
  expect_true(is(df1, "sf"))
  expect_true(is(df2, "sf"))
})
