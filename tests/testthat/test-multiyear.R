test_that("find_file_name handles multiple years", {
  # Pre-2021 should return only the 1979-latest file: it already contains
  # every year, so individual-year files would just duplicate rows
  f1 = find_file_name(years = 2018:2021, type = "collision")
  expect_true(any(grepl("1979", f1)))
  expect_false(any(grepl("2021", f1)))
  expect_length(f1, 1)

  # A single pre-2021 year should also resolve to the 1979-latest file
  # (individual files for 2019/2020 no longer exist on data.gov.uk)
  f1b = find_file_name(years = 2020, type = "collision")
  expect_true(any(grepl("1979", f1b)))
  expect_length(f1b, 1)

  # Only post-2020 (2021+) should only include individual files
  f2 = find_file_name(years = 2021:2022, type = "collision")
  expect_false(any(grepl("1979", f2)))
  expect_true(all(grepl("2021|2022", f2)))

  # "all" should resolve to the single 1979-latest file
  f3 = find_file_name(years = "all", type = "collision")
  expect_true(any(grepl("1979", f3)))
  expect_length(f3, 1)
})

test_that("read_stats19 filters by year correctly", {
  skip_if_not_installed("readr")
  tmp_csv = tempfile(fileext = ".csv")
  df = data.frame(
    accident_year = c(2011, 2012, 2013),
    accident_index = c("A", "B", "C"),
    stringsAsFactors = FALSE
  )
  readr::write_csv(df, tmp_csv)
  
  # Manually set names to what read_stats19 expects for filtering
  # (usually it uses find_file_name, but we can pass filename)
  data_dir = tempdir()
  fname = basename(tmp_csv)
  file.copy(tmp_csv, file.path(data_dir, fname))
  
  # Request only 2011 and 2012
  res = read_stats19(year = 2011:2012, filename = fname, data_dir = data_dir, format = FALSE)
  
  expect_equal(nrow(res), 2)
  expect_true(all(res$accident_year %in% 2011:2012))
})
