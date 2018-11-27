context("test-read_stats19")

test_that("read_stats19 works", {
  # download real data
  acc_2016 = file_names$dftRoadSafety_Accidents_2016.zip
  dl_stats19(file_name = acc_2016)
  path = file.path(
    tempdir(), sub(".zip", "", acc_2016))
  # read it
  read = read_accidents(
    data_dir = path,
    filename = sub(".zip", ".csv", acc_2016)
  )
  raw_read = read.csv(file.path(path, sub(".zip", ".csv", acc_2016)))
  expect_equal(nrow(read), nrow(raw_read))
})
