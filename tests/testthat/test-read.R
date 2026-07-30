test_that("readr::read_csv with stats19 settings handles -1 as NA", {
  skip_if_not_installed("readr")
  tmp_csv = tempfile(fileext = ".csv")
  df = data.frame(
    accident_index = "202401",
    speed_limit = "-1",
    weather_conditions = "1",
    stringsAsFactors = FALSE
  )
  readr::write_csv(df, tmp_csv)
  
  # Test the logic we added to read_collisions/read_null
  ac = readr::read_csv(tmp_csv, col_types = col_spec(tmp_csv), na = c("", "NA", "-1"))
  
  expect_true(is.na(ac$speed_limit[1]))
  expect_equal(as.character(ac$weather_conditions[1]), "1")
})

test_that("format_stats19 handles missing data labels as NA", {
  df = data.frame(
    collision_index = "202401",
    speed_limit = "30",
    weather_conditions = "Data missing or out of range",
    light_conditions = "Unknown",
    junction_control = "Undefined",
    stringsAsFactors = FALSE
  )
  
  # We need to set names that match the schema
  names(df) = format_column_names(names(df))
  
  formatted = format_stats19(df, type = "Collision")
  
  expect_true(is.na(formatted$weather_conditions[1]))
  expect_true(is.na(formatted$light_conditions[1]))
  expect_true(is.na(formatted$junction_control[1]))
  expect_equal(formatted$speed_limit[1], "30")
})

test_that("duckdb where handles OSGR BETWEEN predicates on text columns", {
  skip_if_not_installed("readr")
  skip_if_not_installed("duckdb")
  skip_if_not_installed("DBI")
  
  tmp_csv = tempfile(fileext = ".csv")
  df = data.frame(
    collision_index = c("A", "B", "C"),
    accident_year = c("2024", "2024", "2024"),
    location_easting_osgr = c("430000", "not_a_number", "450000"),
    location_northing_osgr = c("430000", "440000", "not_a_number"),
    stringsAsFactors = FALSE
  )
  readr::write_csv(df, tmp_csv)
  
  data_dir = tempfile("stats19-read-test-")
  dir.create(data_dir)
  fname = basename(tmp_csv)
  file.copy(tmp_csv, file.path(data_dir, fname), overwrite = TRUE)
  
  res = read_stats19(
    year = NULL,
    filename = fname,
    data_dir = data_dir,
    format = FALSE,
    engine = "duckdb",
    where = paste(
      "location_easting_osgr BETWEEN 425000 AND 435000",
      "AND location_northing_osgr BETWEEN 425000 AND 435000"
    )
  )
  
  expect_equal(nrow(res), 1)
  expect_equal(res$collision_index[1], "A")
})

test_that("read_stats19 normalizes collision_ref_no to collision_reference early", {
  skip_if_not_installed("readr")
  
  tmp_csv = tempfile(fileext = ".csv")
  df = data.frame(
    collision_index = c("A", "B"),
    collision_ref_no = c("0001", "0002"),
    accident_year = c("2024", "2024"),
    stringsAsFactors = FALSE
  )
  readr::write_csv(df, tmp_csv)
  
  data_dir = tempfile("stats19-read-test-")
  dir.create(data_dir)
  fname = basename(tmp_csv)
  file.copy(tmp_csv, file.path(data_dir, fname), overwrite = TRUE)
  
  res = read_stats19(
    year = NULL,
    filename = fname,
    data_dir = data_dir,
    format = FALSE,
    silent = TRUE
  )
  
  expect_true("collision_reference" %in% names(res))
  expect_false("collision_ref_no" %in% names(res))
  expect_equal(res$collision_reference, c("0001", "0002"))
})

test_that("read_stats19 preserves alphanumeric collision/accident_index as character (fixes #231)", {
  skip_if_not_installed("readr")
  
  tmp_csv = tempfile(fileext = ".csv")
  df = data.frame(
    accident_index = c("201801T266389", "201801T271905"),
    accident_year = c(2018, 2018),
    stringsAsFactors = FALSE
  )
  readr::write_csv(df, tmp_csv)
  
  data_dir = tempfile("stats19-read-test-")
  dir.create(data_dir)
  fname = basename(tmp_csv)
  file.copy(tmp_csv, file.path(data_dir, fname), overwrite = TRUE)
  
  res = read_stats19(
    year = NULL,
    filename = fname,
    data_dir = data_dir,
    format = FALSE,
    silent = TRUE
  )
  
  expect_type(res$accident_index, "character")
  expect_equal(res$accident_index, c("201801T266389", "201801T271905"))
})

test_that("format_collisions creates valid POSIXct datetime at midnight 00:00 (fixes #236)", {
  df = data.frame(
    collision_index = "A",
    date = "10/05/2024",
    time = "00:00",
    stringsAsFactors = FALSE
  )
  
  formatted = format_collisions(df)
  
  expect_s3_class(formatted$datetime, "POSIXct")
  expect_equal(format(formatted$datetime, "%H:%M"), "00:00")
})
