context("test-format")

# To run download functions you need an internet connection.
# pref a fast one
skip_download = function() {
  connected = !is.null(curl::nslookup("r-project.org", error = FALSE))
  if(!connected)
    skip("No connection to run download function.")
}

test_that("read_schema works", {
  skip_download()
  t = stats19::read_schema()
  expect_equal(nrow(t), 969)
})

test_that("format_accidents works", {
  df = format_accidents(stats19::accidents_2016_sample)
  expect_equal(nrow(df), 2)
})
