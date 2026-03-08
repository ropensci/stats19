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
