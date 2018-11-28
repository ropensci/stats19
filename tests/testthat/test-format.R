context("test-format")

test_that("read_schema works", {
  skip_download()
  t = stats19::read_schema()
  expect_equal(nrow(t), 969)
})

test_that("format_accidents works", {
  df = format_accidents(stats19::accidents_2016_sample)
  expect_equal(nrow(df), 2)
})

test_that("format_sf works", {
  df = format_sf(format_accidents(stats19::accidents_2016_sample))
  expect_equal(nrow(df), 2)
  expect_true(is(df, "sf"))
})
