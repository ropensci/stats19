context("test-utils")

test_that("geturl works", {
  expect_equal(get_url(), "http://data.dft.gov.uk.s3.amazonaws.com/road-accidents-safety-data/")
})
