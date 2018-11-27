context("test-dl_stats19")

# To run download functions you need an internet connection.
# pref a fast one
skip_download = function() {
  connected = !is.null(curl::nslookup("r-project.org", error = FALSE))
  if(!connected)
    skip("No connection to run download function.")
}

test_that("dl_2017_accidents works", {
  skip_download()
  expect_output(dl_2017_accidents())
})

test_that("dl_stats19 works for junk", {
  expect_output(dl_stats19(type = "junk"))
  expect_output(dl_stats19(years = "2999", type = "junk"))
})

test_that("dl_stats19 works for default", {
  skip_download()
  expect_output(dl_stats19())
})

test_that("dl_stats19 works for 2017", {
  skip_download()
  expect_output(dl_stats19(years = "2017"))
  # already downloaded
  expect_output(dl_stats19(years = "2017"))
})

test_that("dl_stats19 works for chosen file name", {
  skip_download()
  expect_output(dl_stats19(
    file_name = stats19::file_names$DfTRoadSafety_Accidents_2009.zip))
})
