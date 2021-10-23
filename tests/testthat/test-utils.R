context("test-utils")

source("../skip-download.R")

test_that("geturl works", {
  expect_equal(get_url(),
               file.path("https://data.dft.gov.uk",
                         "road-accidents-safety-data/"))
})

test_that("find_file_name works", {
  expect_true(length(find_file_name(type = "accid")) > 5)
  expect_equal(find_file_name(year = 2016, type = "accid"),
               "dft-road-casualty-statistics-accident-2016.csv")
  # cover https://github.com/ITSLeeds/stats19/issues/21
  # start OR end year is between 79 and 04
  expect_warning(find_file_name(years = 1974:2004))
  expect_message(
    find_file_name(years = -888),
    "No files found. Check the stats19 website on data.gov.uk"
    )
  expect_message(find_file_name(years = 1973))
})

test_that("locate_files & locate_one_file works", {
  fn = stats19::file_names$`dft-road-casualty-statistics-accident-2017.csv`
  skip_download()
  dl_stats19(file_name = fn)
  x = locate_files(years = 2017, type = "cas")
  expect_true(length(x) > 0) # other files would have been downloaded already
})
