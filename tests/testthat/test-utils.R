context("test-utils")

test_that("geturl works", {
  expect_equal(get_url(), "http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/")
})

test_that("generate_file_name works", {
  expect_equal(generate_file_name(), "dftRoadSafety_Accidents_2016")
  expect_equal(generate_file_name(zip = TRUE), "dftRoadSafety_Accidents_2016.zip")
})
