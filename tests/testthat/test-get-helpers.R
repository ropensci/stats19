# Helper to find a data dir with downloaded STATS19 CSVs for offline tests.
# Prefer STATS19_DOWNLOAD_DIRECTORY; fall back to common stats19py checkout
# data dirs, then a local ./data dir.
find_test_data_dir = function() {
  d = Sys.getenv("STATS19_DOWNLOAD_DIRECTORY", unset = "")
  if (nzchar(d) && dir.exists(d)) {
    return(d)
  }
  candidates = c(
    file.path(dirname(dirname(getwd())), "robinlovelace", "stats19py", "data"),
    "~/github/robinlovelace/stats19py/data",
    file.path(getwd(), "data")
  )
  for (p in candidates) {
    p = path.expand(p)
    if (dir.exists(p)) {
      return(p)
    }
  }
  NULL
}

test_that("get_collisions returns formatted collisions", {
  local_data = find_test_data_dir()
  if (is.null(local_data)) {
    skip("no local STATS19 data directory found")
  }
  ac = get_collisions(year = 2024, data_dir = local_data, silent = TRUE)
  expect_s3_class(ac, "data.frame")
  expect_true("collision_severity" %in% names(ac))
  expect_true(all(c("location_easting_osgr", "location_northing_osgr") %in% names(ac)))
  expect_gt(nrow(ac), 100000)
})

test_that("get_casualties returns formatted casualties", {
  local_data = find_test_data_dir()
  if (is.null(local_data)) {
    skip("no local STATS19 data directory found")
  }
  ca = get_casualties(year = 2024, data_dir = local_data, silent = TRUE)
  expect_s3_class(ca, "data.frame")
  expect_true("casualty_type" %in% names(ca))
  expect_gt(nrow(ca), 100000)
})

test_that("get_vehicles returns formatted vehicles", {
  local_data = find_test_data_dir()
  if (is.null(local_data)) {
    skip("no local STATS19 data directory found")
  }
  ve = get_vehicles(year = 2024, data_dir = local_data, silent = TRUE)
  expect_s3_class(ve, "data.frame")
  expect_true("vehicle_type" %in% names(ve))
  expect_gt(nrow(ve), 100000)
})

test_that("get_* helpers match get_stats19 output", {
  local_data = find_test_data_dir()
  if (is.null(local_data)) {
    skip("no local STATS19 data directory found")
  }
  ac1 = get_collisions(year = 2024, data_dir = local_data, silent = TRUE)
  ac2 = get_stats19(year = 2024, type = "collision", data_dir = local_data, silent = TRUE)
  expect_identical(ac1, ac2)
})
