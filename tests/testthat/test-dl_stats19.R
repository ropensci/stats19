context("test-dl_stats19")

source("../skip-download.R")

test_that("dl_stats19 works for junk", {
  expect_error(dl_stats19(type = "junk"))
  expect_error(dl_stats19(year = "2999", type = "junk"))
})

test_that("dl_stats19 works for no data_dir", {
  skip_on_cran()
  # this test is bound to the next
  skip_download()
  # remove tempdir
  unlink(tempdir(), recursive = TRUE)
  expect_message(dl_stats19(year = "2022", type = "collision"))
  # tempdir created.
})
