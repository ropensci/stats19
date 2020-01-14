context("Get/Set STATS19_DOWNLOAD_DIRECTORY envvar")

test_that("Set STATS19_DOWNLOAD_DIRECTORY ", {
  expect_error(set_data_directory())
})

test_that("Get STATS19_DOWNLOAD_DIRECTORY ", {
  expect_true(identical(get_data_directory(), tempdir()))
})

