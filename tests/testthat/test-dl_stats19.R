context("test-dl_stats19")

test_that("dl_2017_accidents works", {
  expect_output(dl_2017_accidents())
})

test_that("dl_stats19 works for junk", {
  expect_output(dl_stats19(type = "junk"))
})

test_that("dl_stats19 works for default", {
  expect_output(dl_stats19())
})

test_that("dl_stats19 works for 2017", {
  expect_output(dl_stats19(years = "2017"))
})

test_that("dl_stats19 works for chosen file name", {
  expect_output(dl_stats19(
    file_name = stats19::file_names$DfTRoadSafety_Accidents_2009.zip))
})
