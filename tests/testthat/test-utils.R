context("test-utils")

source("../skip-download.R")

test_that("geturl works", {
  expect_equal(get_url(),
               file.path("https://data.dft.gov.uk",
                         "road-accidents-safety-data/"))
})

test_that("find_file_name works", {
  expect_true(length(find_file_name(type = "coll")) > 5)
  # cover https://github.com/ITSLeeds/stats19/issues/21
  # start OR end year is between 79 and 04
  expect_message(find_file_name(years = 1973))
})
