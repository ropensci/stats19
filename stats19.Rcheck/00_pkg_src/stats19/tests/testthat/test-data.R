test_that("stats19_schema dataset is available", {
  data("stats19_schema", package = "stats19")
  expect_true(exists("stats19_schema"))
  expect_true(is.data.frame(stats19_schema))
  expect_true(nrow(stats19_schema) > 0)
})

test_that("stats19_variables dataset is available", {
  data("stats19_variables", package = "stats19")
  expect_true(exists("stats19_variables"))
  expect_true(is.data.frame(stats19_variables))
  expect_true(nrow(stats19_variables) > 0)
})

test_that("file_names dataset is available", {
  data("file_names", package = "stats19")
  expect_true(exists("file_names"))
  expect_true(is.list(file_names))
  expect_true(length(file_names) > 0)
})

test_that("accidents_sample dataset is available", {
  data("accidents_sample", package = "stats19")
  expect_true(exists("accidents_sample"))
  expect_true(is.data.frame(accidents_sample))
  expect_true(nrow(accidents_sample) > 0)
})

test_that("accidents_sample_raw dataset is available", {
  data("accidents_sample_raw", package = "stats19")
  expect_true(exists("accidents_sample_raw"))
  expect_true(is.data.frame(accidents_sample_raw))
  expect_true(nrow(accidents_sample_raw) > 0)
})

test_that("casualties_sample dataset is available", {
  data("casualties_sample", package = "stats19")
  expect_true(exists("casualties_sample"))
  expect_true(is.data.frame(casualties_sample))
  expect_true(nrow(casualties_sample) > 0)
})

test_that("casualties_sample_raw dataset is available", {
  data("casualties_sample_raw", package = "stats19")
  expect_true(exists("casualties_sample_raw"))
  expect_true(is.data.frame(casualties_sample_raw))
  expect_true(nrow(casualties_sample_raw) > 0)
})

test_that("vehicles_sample dataset is available", {
  data("vehicles_sample", package = "stats19")
  expect_true(exists("vehicles_sample"))
  expect_true(is.data.frame(vehicles_sample))
  expect_true(nrow(vehicles_sample) > 0)
})

test_that("vehicles_sample_raw dataset is available", {
  data("vehicles_sample_raw", package = "stats19")
  expect_true(exists("vehicles_sample_raw"))
  expect_true(is.data.frame(vehicles_sample_raw))
  expect_true(nrow(vehicles_sample_raw) > 0)
})

test_that("police_boundaries dataset is available", {
  skip_if_not_installed("sf")
  data("police_boundaries", package = "stats19")
  expect_true(exists("police_boundaries"))
  expect_s3_class(police_boundaries, "sf")
  expect_true(nrow(police_boundaries) > 0)
})
