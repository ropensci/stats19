context("test-dl_stats19")

source("../skip-download.R")

test_that("dl_stats19 works for junk", {
  expect_error(dl_stats19(type = "junk"))
  expect_error(dl_stats19(year = "2999", type = "junk"))
})

test_that("dl_stats19 requires year", {
  skip_download()
  expect_error(dl_stats19()
               # "Either file_name or year must be specified"
               )
})

test_that("dl_stats19 works for 2017", {
  skip_download()
  expect_message(dl_stats19(year = "2017"))
  # already downloaded
  expect_message(dl_stats19(year = "2017"),
                 "Data already exists in data_dir")
})

test_that("dl_stats19 works for chosen file name", {
  skip_download()
  expect_message(dl_stats19(
    file_name = stats19::file_names$DfTRoadSafety_Accidents_2009.zip),
                 "File to download")
})
