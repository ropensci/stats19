context("test-read_stats19")
# To run download functions you need an internet connection.
# pref a fast one
skip_download = function() {
  connected = !is.null(curl::nslookup("r-project.org", error = FALSE))
  if(!connected)
    skip("No connection to run download function.")
}

test_that("read_stats19 works", {
  skip_download()
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
  expect_error(read_accidents("junk"))
})
