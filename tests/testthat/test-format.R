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
  rd = format_accidents(stats19::accidents_2016_sample)
  df1 = format_sf(rd)
  df2 = format_sf(rd, lonlat = TRUE)
  expect_equal(nrow(df1), 2)
  expect_equal(nrow(df2), 2)
  expect_true(is(df1, "sf"))
  expect_true(is(df2, "sf"))
})
