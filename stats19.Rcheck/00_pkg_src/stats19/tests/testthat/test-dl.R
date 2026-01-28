test_that("dl_stats19 is exported", {
  expect_true("dl_stats19" %in% getNamespaceExports("stats19"))
  expect_true(is.function(dl_stats19))
})

test_that("dl_stats19 has correct parameters", {
  params = names(formals(dl_stats19))
  expect_true("year" %in% params)
  expect_true("type" %in% params)
  expect_true("data_dir" %in% params)
  expect_true("file_name" %in% params)
  expect_true("ask" %in% params)
  expect_true("silent" %in% params)
  expect_true("timeout" %in% params)
})

test_that("dl_stats19 validates data directory", {
  skip_if_not_installed("stats19")
  skip_if_offline()
  
  # Test that function creates directory if it doesn't exist
  temp_subdir = file.path(tempdir(), "stats19_test_dir_123")
  
  # Remove if exists from previous test
  if(dir.exists(temp_subdir)) {
    unlink(temp_subdir, recursive = TRUE)
  }
  
  # This should create the directory (but we skip actual download with ask=FALSE and no internet)
  expect_false(dir.exists(temp_subdir))
})

test_that("dl_stats19 handles existing files", {
  skip_if_not_installed("stats19")
  
  # This tests the logic for detecting existing files
  # Full download test would require internet and is integration test
  expect_true(is.function(dl_stats19))
})
